FROM postgres

ENV POSTGRES_PASSWORD=pass
ENV POSTGRES_DB=todo
ENV PGDATA=/var/lib/postgresql/data/pgdata

COPY to_do.sql /docker-entrypoint-initdb.d/

EXPOSE 5432