-- Create users table
create table if not exists users (
    id serial primary key,
    email varchar(255) unique not null,
    username varchar(100) unique not null,
    role varchar(255) not null,
    password varchar(255) not null,
    created_at timestamp with time zone default current_timestamp,
    updated_at timestamp with time zone default current_timestamp
);

CREATE TABLE IF NOT EXISTS chats (
    id          BIGSERIAL PRIMARY KEY,
    ulid        char(26) not null unique,
    room        varchar(64) not null,
    username    varchar(100) not null,
    content     TEXT NOT NULL,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    deleted_at  TIMESTAMPTZ
);
