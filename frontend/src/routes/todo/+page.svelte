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

	let newMessage = '';

	function isTodo(res: Todo[] | DbError): res is Todo[] {
		return (res as Todo[])?.[0]?.id !== undefined;
	}

	async function loadTodos() {
		const resp = await fetch(`${base}/api/todos`);
		todos = await resp.json();

		if (isTodo(todos)) {
			todos = todos.toSorted((a, b) => a.id - b.id);
		}
	}

	async function toggleTask(todo: Todo) {
		let toggle = !todo.completed;
		await fetch(`${base}/api/todo/${todo.id}`, {
			method: 'PUT',
			body: JSON.stringify({ toggle }),
			headers: {
				'content-type': 'application/json'
			}
		});

		await loadTodos();
	}

	async function createTodo() {
		await fetch(`${base}/api/todo`, {
			method: 'POST',
			body: JSON.stringify({ newMessage }),
			headers: {
				'content-type': 'application/json'
			}
		});

		newMessage = '';
		await loadTodos();
	}

	async function deleteTodo(todo: Todo) {
		await fetch(`${base}/api/todo/${todo.id}`, {
			method: 'DELETE'
		});

		await loadTodos();
	}

	let todos: Todo[] | DbError;

	onMount(async () => {
		await loadTodos();
	});
</script>

<div>
	{#if isTodo(todos)}
		{#each todos as todo (todo.id)}
			<div
				class="parent-container flex todo"
				style="background-color: {todo.completed ? 'lightgreen' : 'lightgray'};"
			>
				<input type="checkbox" on:click={() => toggleTask(todo)} checked={todo.completed} />
				<div>{todo.message}</div>
				<input type="button" value="Delete" on:click={() => deleteTodo(todo)} />
			</div>
		{/each}

		<div class="flex">
			<input type="text" bind:value={newMessage} />
			<input type="button" value="Create todo" on:click={() => createTodo()} />
		</div>
	{:else}
		{JSON.stringify(todos)}
	{/if}
</div>

<style>
	.todo {
		text-align: center;
		background-color: lightgray;
	}

	.flex {
		display: flex;
		justify-content: space-between;
	}

	.parent-container {
		border: 2px slategray solid;
		gap: 1rem;
	}
</style>
