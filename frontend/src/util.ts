import pgPromise from 'pg-promise';

const pgp = pgPromise({});

const host = process.env["PG_HOST"] ?? 'localhost'
const user = process.env["PG_USER"] ?? 'postgres'
const password = process.env["POSTGRES_PASSWORD"] ?? 'pass'
const database = process.env["POSTGRES_DB"] ?? 'todo'

export const db = pgp({
    host: host,
    user: user,
    database: database,
    password: password,
});
