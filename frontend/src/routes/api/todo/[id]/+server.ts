import { json } from '@sveltejs/kit';
import { db } from '../../../../util.js';

export const GET = async ({ params }) => {
    try {
        const data = await db.any('SELECT * FROM todo where id = ${params.id}', { id: params.id });
        return new Response(JSON.stringify(data));
    } catch (error) {
        console.error('ERROR:', error);
        return json({ status: 500, body: { error: 'Database query failed' } });
    }
};

export const DELETE = async ({ params }) => {
    try {
        const data = await db.none('DELETE FROM todo where id = ${id}', { id: params.id });
        return new Response();
    } catch (error) {
        console.error('ERROR:', error);
        return json({ status: 500, body: { error: 'Database query failed' } });
    }
};

export const PUT = async ({ params, request }) => {
    try {
        const { toggle } = await request.json();
        await db.none('UPDATE todo SET completed = ${completed} where id = ${id}', { id: params.id, completed: toggle });
        return new Response();
    } catch (error) {
        console.error('ERROR:', error);
        return json({ status: 500, body: { error: 'Database query failed' } });
    }
};
