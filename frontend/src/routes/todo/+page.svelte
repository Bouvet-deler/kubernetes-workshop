<script lang="ts">
	import { base } from '$app/paths';
	import { onMount } from 'svelte';

	type Todo = {
		id: number;
		message: string;
		completed: boolean;
	};

	type DbError = {
		status: number;
		body: {};
	};

	function isError(res: Todo[] | DbError): res is DbError {
		return (res as DbError)?.status !== undefined;
	}

	function isTodo(res: Todo[] | DbError): res is Todo[] {
		return (res as Todo[])?.[0]?.id !== undefined;
	}

	let todos: Todo[] | DbError;

	onMount(async () => {
		const resp = await fetch(`${base}/api/todo`);
		todos = await resp.json();
	});
</script>

<div>
	{#if isTodo(todos)}
		{#each todos as todo}
			<div class="parent-container flex todo">
				<div>{todo.message}</div>
				<button>{todo.completed}</button>
			</div>
		{/each}
	{:else}
		{JSON.stringify(todos)}
	{/if}
</div>

<style>
	.todo {
		text-align: center;
    background-color: lightgray;
	}

  .flex{
			display: flex;
			justify-content: space-evenly;
	}

  .parent-container{
			border: 2px slategray solid;
			gap: 1rem;
	}
</style>
