#!/usr/bin/env bash
#
# Idempotent development setup for Cheese Trackers.
#
# Prepares everything a Cloud Agent needs to run the app end to end:
#   * a Rust toolchain matching the project's edition 2024 requirement,
#   * a local PostgreSQL server with the dev role/database,
#   * a backend dev config with locally-generated (dev-only) secrets,
#   * a compiled backend and installed frontend dependencies.
#
# Long-running services are started by .cursor/start.sh (PostgreSQL) and the
# `terminals` entries in .cursor/environment.json (backend and frontend).

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_ROOT"

# The Containerfile builds with Rust 1.94.1, and the crates use edition 2024
# (which requires >= 1.85). The default Cloud image may ship an older rustc, so
# pin the matching toolchain.
RUST_VERSION="1.94.1"
if ! rustc --version 2>/dev/null | grep -q "$RUST_VERSION"; then
	rustup toolchain install "$RUST_VERSION" --profile minimal --component clippy
fi
rustup default "$RUST_VERSION"

# PostgreSQL is the only supported data store. Install it if it is missing.
if ! command -v pg_ctlcluster >/dev/null 2>&1; then
	sudo apt-get update
	sudo DEBIAN_FRONTEND=noninteractive apt-get install -y postgresql postgresql-contrib
fi

# Start the cluster so the dev role/database can be provisioned. start.sh also
# starts it on every boot.
sudo pg_ctlcluster 16 main start 2>/dev/null || true
for _ in $(seq 1 30); do
	pg_isready -h 127.0.0.1 -p 5432 >/dev/null 2>&1 && break
	sleep 1
done

# Create the development role and database (idempotent). Credentials match the
# values used by the repository's podman/create-pod dev script.
sudo -u postgres psql -tAc "SELECT 1 FROM pg_roles WHERE rolname='mwtracker'" | grep -q 1 \
	|| sudo -u postgres psql -c "CREATE ROLE mwtracker LOGIN PASSWORD 'mwtracker';"
sudo -u postgres psql -tAc "SELECT 1 FROM pg_database WHERE datname='mwtracker'" | grep -q 1 \
	|| sudo -u postgres createdb -O mwtracker mwtracker

# Generate the backend dev config once. It holds only locally-generated,
# dev-only secrets and is git-ignored (see server/.gitignore).
if [ ! -f server/config.yaml ]; then
	TOKEN_SECRET="$(openssl rand -hex 32)"
	CIPHER_KEY="$(openssl rand -base64 32)"
	cat > server/config.yaml <<EOF
public_url: 'http://localhost:3000/'
http_listen: '0.0.0.0:3000'
client_ip_source: ConnectInfo
cors_permissive: true
hoster: Local Development
banners: []
upstream_trackers:
  - 'https://archipelago.gg/tracker'
auto_upstream_trackers: false
tracker_update_interval_mins: 1
token:
  secret: '${TOKEN_SECRET}'
  issuer: 'localhost'
  validity_duration_days: 90
database:
  type: postgres
  connection_string: 'postgresql://mwtracker:mwtracker@localhost:5432/mwtracker'
discord:
  client_id: '0'
  client_secret: ''
  token_cipher_key: '${CIPHER_KEY}'
EOF
fi

# Compile the backend (warms the build cache) and install frontend deps.
(cd server && cargo build)
(cd frontend && npm ci)
