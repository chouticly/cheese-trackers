<script setup>
const props = defineProps(['isMine']);

const slots = defineSlots();

import { settings } from '@/settings';
import { computed } from 'vue';

const effectiveIsMine = computed(() =>
    props.isMine && settings.value.sortMode === 'selftop'
);

// Slots aren't reactive; can't use computed.
function columns() {
    return slots.activity ? 13 : 12;
}
</script>

<template>
    <tr v-if="$slots.banner" class="tracker-table-full-row">
        <td :colspan="columns()" class="text-center tracker-table-full-cell">
            <slot name="banner"/>
        </td>
    </tr>
    <tr v-else class="tracker-table-slot-row" :class="{ 'is-mine': effectiveIsMine }">
        <td data-label="Name"><slot name="name"/></td>
        <td data-label="Ping"><slot name="ping"/></td>
        <td data-label="Availability"><slot name="availability"/></td>
        <td data-label="Claim"><slot name="claim"/></td>
        <td data-label="Owner"><slot name="owner"/></td>
        <td data-label="Game"><slot name="game"/></td>
        <td data-label="Progression"><slot name="progression"/></td>
        <td data-label="Completion"><slot name="completion"/></td>
        <td data-label="Last checked" class="text-end"><slot name="checked"/></td>
        <td v-if="$slots.activity" data-label="Last activity"><slot name="activity"/></td>
        <td data-label="Still BK" class="text-start ps-0"><slot name="stillbk"/></td>
        <td data-label="Checks"><slot name="checks"/></td>
        <td data-label="Hints"><slot name="hints"/></td>
    </tr>
    <tr v-if="$slots.hintpane" class="tracker-table-full-row" :class="{ 'is-mine': effectiveIsMine }">
        <td :colspan="columns()" class="container-fluid tracker-table-full-cell">
            <slot name="hintpane"/>
        </td>
    </tr>
</template>

<style scoped>
td {
    vertical-align: baseline;
}

tr.is-mine:has(+ tr:not(.is-mine)) td {
    border-bottom-width: 3px !important;
}
</style>
