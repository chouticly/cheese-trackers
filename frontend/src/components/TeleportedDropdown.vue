<script setup>
// Bootstrap dropdown whose menu is teleported to document.body.
//
// Header and filter menus live inside the tracker table.  The themed `.table`
// rules use overflow clipping and backdrop-filter, which create a stacking
// context so later page content (summary tables) paints over the menu whenever
// the grid is shorter than the menu.  Teleporting matches DropdownSelector.

import { autoUpdate, flip, offset, shift, size, useFloating } from '@floating-ui/vue';
import { computed, ref } from 'vue';

const props = defineProps({
    autoClose: {
        type: [Boolean, String],
        default: true,
    },
    menuTag: {
        type: String,
        default: 'ul',
    },
    menuClass: {
        type: String,
        default: 'dropdown-menu',
    },
    placement: {
        type: String,
        default: 'bottom-start',
    },
    toggleClass: {
        type: String,
        default: 'btn btn-sm btn-outline-light',
    },
});

const dropdownShown = ref(false);

const reference = ref(null);
const floating = ref(null);

const { floatingStyles } = useFloating(reference, floating, {
    placement: computed(() => props.placement),
    middleware: [
        offset(2),
        flip(),
        shift({ padding: 8 }),
        size({
            padding: 8,
            apply({ availableHeight, elements }) {
                const maxHeight = Math.max(
                    80,
                    Math.min(availableHeight, window.innerHeight * 0.5),
                );
                elements.floating.style.maxHeight = `${maxHeight}px`;
                elements.floating.style.overflowY = 'auto';
            },
        }),
    ],
    whileElementsMounted: autoUpdate,
});

function onHide(event) {
    if (props.autoClose !== 'outside') {
        return;
    }

    const clickEvent = event.clickEvent;
    if (clickEvent && floating.value?.contains(clickEvent.target)) {
        event.preventDefault();
    }
}

function onMenuClick(event) {
    if (props.autoClose === 'outside') {
        event.stopPropagation();
    }
}
</script>

<template>
    <button
        :class="props.toggleClass"
        data-bs-toggle="dropdown"
        :data-bs-auto-close="String(props.autoClose)"
        @[`shown.bs.dropdown`]="dropdownShown = true"
        @[`hide.bs.dropdown`]="onHide"
        @[`hidden.bs.dropdown`]="dropdownShown = false"
        ref="reference"
    >
        <slot name="toggle"/>
    </button>
    <ul class="dropdown-menu" style="display: none"/>
    <Teleport to="body">
        <component
            :is="props.menuTag"
            v-if="dropdownShown"
            :class="[props.menuClass, 'show']"
            :style="[floatingStyles, { zIndex: 1050 }]"
            ref="floating"
            @click="onMenuClick"
        >
            <slot/>
        </component>
    </Teleport>
</template>
