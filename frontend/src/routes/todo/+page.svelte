<script lang="ts">
	import { base } from '$app/paths';
  import { onMount } from 'svelte';

  let data: string;

  onMount(async () => {
    console.log('Pre fetch');
    
    const resp = await fetch(`/svelte/api/todo`);
    console.log(resp);
    data = await resp.json();
  });
</script>

TODO:

{JSON.stringify(data)}
