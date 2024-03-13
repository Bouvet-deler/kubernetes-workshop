import { db } from '../../../util';

export const GET = async () => {
  try {
    const data = await db.any('SELECT * FROM todo');
    return new Response(JSON.stringify(data));
  } catch (error) {
    console.error('ERROR:', error);
    return { status: 500, body: { error: 'Database query failed' } };
  }
};
