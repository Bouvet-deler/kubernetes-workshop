import pgPromise from 'pg-promise';

const pgp = pgPromise({});

// We can also input the host as a variable from podman
const host = process.env["PG_HOST"]
const user = process.env["PG_USER"]
const password = process.env["POSTGRES_PASSWORD"]
const database = process.env["POSTGRES_DB"]

const db = pgp({
  host: host,
  user: user,
  database: database,
  password: password,
});

export const GET = async () => {
  try {
    const data = await db.any('SELECT * FROM todo');
    return new Response(JSON.stringify(data));
  } catch (error) {
    console.error('ERROR:', error);
    return { status: 500, body: { error: 'Database query failed' } };
  }
};
