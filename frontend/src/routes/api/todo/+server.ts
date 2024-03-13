import { json } from '@sveltejs/kit';
import { db } from '../../../util.js';

export const POST = async ({ request }) => {
    try {
        const { newMessage } = await request.json();
        await db.none('INSERT INTO todo(message, completed) VALUES(${message}, ${completed})', { message: newMessage, completed: false });
        return new Response();
    } catch (error) {
        console.error('ERROR:', error);
        return json({ status: 500, body: { error: 'Database query failed' } });
    }
};
