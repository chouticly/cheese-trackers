<script setup>
import UsernameDisplay from './UsernameDisplay.vue';
import GameDisplay from './GameDisplay.vue';
import TeleportedDropdown from './TeleportedDropdown.vue';

const props = defineProps([
	'activeSort',
	'sortByName',
	'sortByOwner',
	'sortByGame',
	'sortByActivity',
	'sortByChecks',
	'sortByHints',
	'setSort',
	'availabilityFilter',
	'availabilityStatus',
	'playerFilter',
	'playerFilterAll',
	'playerFilterUnowned',
	'currentUser',
	'playersExceptSelf',
	'usersEqual',
	'gameFilter',
	'uniqueGames',
	'progressionFilter',
	'completionFilter',
	'progressionStatus',
	'completionStatus',
	'showLastActivity',
	'showChecksAsPercent',
	'allExpanded',
	'setAllExpanded',
]);

const emit = defineEmits([
	'update:showLastActivity',
	'update:showChecksAsPercent',
	'update:playerFilter',
	'update:gameFilter',
]);
</script>

<template>
	<div class="tracker-mobile-filters d-lg-none mb-3">
		<div class="d-flex flex-wrap justify-content-center gap-2">
			<TeleportedDropdown toggle-class="btn btn-sm btn-outline-light dropdown-toggle">
				<template #toggle>
					<i class="bi-sort-down"/> Sort
				</template>
				<li>
					<button class="dropdown-item" @click="props.setSort(props.sortByName, false)">
						Name
						<i v-if="props.activeSort[0] === props.sortByName"
							:class="{ 'bi-sort-alpha-down': !props.activeSort[1], 'bi-sort-alpha-up': props.activeSort[1] }"/>
					</button>
				</li>
				<li>
					<button class="dropdown-item" @click="props.setSort(props.sortByOwner, false)">
						Owner
						<i v-if="props.activeSort[0] === props.sortByOwner"
							:class="{ 'bi-sort-alpha-down': !props.activeSort[1], 'bi-sort-alpha-up': props.activeSort[1] }"/>
					</button>
				</li>
				<li>
					<button class="dropdown-item" @click="props.setSort(props.sortByGame, false)">
						Game
						<i v-if="props.activeSort[0] === props.sortByGame"
							:class="{ 'bi-sort-alpha-down': !props.activeSort[1], 'bi-sort-alpha-up': props.activeSort[1] }"/>
					</button>
				</li>
				<li>
					<button class="dropdown-item" @click="props.setSort(props.sortByActivity, true)">
						Last activity
						<i v-if="props.activeSort[0] === props.sortByActivity"
							:class="{ 'bi-sort-numeric-down': !props.activeSort[1], 'bi-sort-numeric-up': props.activeSort[1] }"/>
					</button>
				</li>
				<li>
					<button class="dropdown-item" @click="props.setSort(props.sortByChecks, false)">
						Checks
						<i v-if="props.activeSort[0] === props.sortByChecks"
							:class="{ 'bi-sort-numeric-down': !props.activeSort[1], 'bi-sort-numeric-up': props.activeSort[1] }"/>
					</button>
				</li>
				<li>
					<button class="dropdown-item" @click="props.setSort(props.sortByHints, true)">
						Hints
						<i v-if="props.activeSort[0] === props.sortByHints"
							:class="{ 'bi-sort-numeric-down': !props.activeSort[1], 'bi-sort-numeric-up': props.activeSort[1] }"/>
					</button>
				</li>
			</TeleportedDropdown>

			<TeleportedDropdown auto-close="outside" toggle-class="btn btn-sm btn-outline-light dropdown-toggle">
				<template #toggle>
					<i :class="[props.availabilityFilter.isActive.value ? 'bi-funnel-fill' : 'bi-funnel']"/> Availability
				</template>
				<li v-for="status in props.availabilityStatus" :key="status.id">
					<button class="dropdown-item" :class="props.availabilityFilter.classes(status)"
						@click="props.availabilityFilter.toggle(status)">
						<i :class="`bi-${status.icon}`"/> {{ status.label }}
					</button>
				</li>
			</TeleportedDropdown>

			<TeleportedDropdown toggle-class="btn btn-sm btn-outline-light dropdown-toggle">
				<template #toggle>
					<i :class="{ 'bi-funnel': props.playerFilter === props.playerFilterAll, 'bi-funnel-fill': props.playerFilter !== props.playerFilterAll }"/> Owner
				</template>
				<li>
					<button class="dropdown-item" :class="{ active: props.playerFilter === props.playerFilterAll }"
						@click="emit('update:playerFilter', props.playerFilterAll)">
						All
					</button>
				</li>
				<li>
					<button class="dropdown-item" :class="{ active: props.playerFilter === props.playerFilterUnowned }"
						@click="emit('update:playerFilter', props.playerFilterUnowned)">
						Unclaimed
					</button>
				</li>
				<template v-if="props.currentUser">
					<li><hr class="dropdown-divider"></li>
					<li>
						<button class="dropdown-item"
							:class="{ active: props.usersEqual(props.playerFilter, props.currentUser) }"
							@click="emit('update:playerFilter', props.currentUser)">
							<UsernameDisplay :user="props.currentUser"/>
						</button>
					</li>
				</template>
				<template v-if="props.playersExceptSelf.length">
					<li><hr class="dropdown-divider"></li>
					<li v-for="player in props.playersExceptSelf" :key="player.id ?? player.discordUsername">
						<button class="dropdown-item"
							:class="{ active: props.playerFilter === player }"
							@click="emit('update:playerFilter', player)">
							<UsernameDisplay :user="player"/>
						</button>
					</li>
				</template>
			</TeleportedDropdown>

			<TeleportedDropdown toggle-class="btn btn-sm btn-outline-light dropdown-toggle">
				<template #toggle>
					<i :class="{ 'bi-funnel': !props.gameFilter, 'bi-funnel-fill': !!props.gameFilter }"/> Game
				</template>
				<li>
					<button class="dropdown-item" :class="{ active: !props.gameFilter }"
						@click="emit('update:gameFilter', undefined)">All</button>
				</li>
				<li><hr class="dropdown-divider"></li>
				<li v-for="g in props.uniqueGames" :key="g">
					<button class="dropdown-item" :class="{ active: props.gameFilter === g }"
						@click="emit('update:gameFilter', g)">
						<GameDisplay :game="g"/>
					</button>
				</li>
			</TeleportedDropdown>

			<TeleportedDropdown auto-close="outside" toggle-class="btn btn-sm btn-outline-light dropdown-toggle">
				<template #toggle>
					<i :class="[
						(props.progressionFilter.isActive.value || props.completionFilter.isActive.value) ?
							'bi-funnel-fill' : 'bi-funnel'
					]"/> Status
				</template>
				<li v-for="status in props.progressionStatus" :key="status.id">
					<button class="dropdown-item" :class="props.progressionFilter.classes(status)"
						@click="props.progressionFilter.toggle(status)">
						<i :class="`bi-${status.icon}`"/> {{ status.label }}
					</button>
				</li>
				<li><hr class="dropdown-divider"></li>
				<li v-for="status in props.completionStatus" :key="status.id">
					<button class="dropdown-item" :class="props.completionFilter.classes(status)"
						@click="props.completionFilter.toggle(status)">
						<i :class="`bi-${status.icon}`"/> {{ status.label }}
					</button>
				</li>
			</TeleportedDropdown>

			<TeleportedDropdown
				auto-close="outside"
				toggle-class="btn btn-sm btn-outline-light dropdown-toggle"
				menu-tag="div"
				menu-class="dropdown-menu dropdown-menu-end p-3"
				placement="bottom-end"
			>
				<template #toggle>
					<i class="bi-gear"/> Options
				</template>
				<div class="form-check mb-2">
					<input type="checkbox" class="form-check-input" id="mobileShowLastActivityCheck"
						:checked="props.showLastActivity"
						@change="emit('update:showLastActivity', $event.target.checked)">
					<label class="form-check-label" for="mobileShowLastActivityCheck">
						Show last activity if before last checked
					</label>
				</div>
				<div class="form-check mb-2">
					<input type="checkbox" class="form-check-input" id="mobileShowChecksAsPercentCheck"
						:checked="props.showChecksAsPercent"
						@change="emit('update:showChecksAsPercent', $event.target.checked)">
					<label class="form-check-label" for="mobileShowChecksAsPercentCheck">
						Show checks as percent
					</label>
				</div>
				<button class="btn btn-sm btn-outline-light w-100" @click="props.setAllExpanded(!props.allExpanded)">
					<i :class="{ 'bi-arrows-angle-expand': !props.allExpanded, 'bi-arrows-angle-contract': props.allExpanded }"/>
					{{ props.allExpanded ? 'Collapse all hints' : 'Expand all hints' }}
				</button>
			</TeleportedDropdown>
		</div>
	</div>
</template>
