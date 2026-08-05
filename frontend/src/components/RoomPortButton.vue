<script setup>
import { copy as clipboardCopy } from '@/clipboard';
import { computed } from 'vue';

const props = defineProps(['host', 'port', 'stale', 'connectionName']);

const roomHostAndPort = computed(() => {
  if (props.host && props.port) {
    return `${props.host}:${props.port}`;
  }
});

const displayText = computed(() => {
  if (props.connectionName?.length) {
    return props.connectionName;
  }

  return roomHostAndPort.value;
});
</script>

<template>
  <button
      type="button"
      v-if="roomHostAndPort"
      class="badge border border-0"
      :class="{
        'text-bg-info': !props.stale,
        'text-bg-warning': props.stale,
      }"
      :title="props.connectionName?.length ? roomHostAndPort : undefined"
      @click="clipboardCopy(roomHostAndPort)"
  >
      <i class="bi-ethernet"></i> <span class="font-monospace" style="line-height: 0"
      >
          {{ displayText }}
      </span>
  </button>
</template>
