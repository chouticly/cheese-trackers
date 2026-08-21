#!/usr/bin/env bash
#
# Per-boot reconciliation: ensure PostgreSQL is running before the backend and
# frontend terminals start. Returns once the database accepts connections.

set -euo pipefail

sudo pg_ctlcluster 16 main start 2>/dev/null || true

for _ in $(seq 1 30); do
	if pg_isready -h 127.0.0.1 -p 5432 >/dev/null 2>&1; then
		exit 0
	fi
	sleep 1
done

echo "PostgreSQL did not become ready within 30s" >&2
exit 1
