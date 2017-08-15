-- Database: cis-address
-- DROP DATABASE "cis-address";

CREATE DATABASE "cis-address"
    WITH 
    OWNER = postgres
    ENCODING = 'UTF8'
    LC_COLLATE = 'Russian_Russia.1251'
    LC_CTYPE = 'Russian_Russia.1251'
    TABLESPACE = pg_default
    CONNECTION LIMIT = -1;


-- SCHEMA: public
-- DROP SCHEMA public ;

CREATE SCHEMA public
    AUTHORIZATION postgres;

COMMENT ON SCHEMA public
    IS 'standard public schema';

GRANT ALL ON SCHEMA public TO postgres;
GRANT ALL ON SCHEMA public TO PUBLIC;


-- Table: public.a1
-- DROP TABLE public.a1;

CREATE TABLE public.a1
(
    id integer NOT NULL,
    name character(255) COLLATE pg_catalog."default" NOT NULL,
    sname character(40) COLLATE pg_catalog."default" NOT NULL,
    CONSTRAINT a1_pkey PRIMARY KEY (id)
)
WITH (
    OIDS = FALSE
)
TABLESPACE pg_default;

ALTER TABLE public.a1
    OWNER to postgres;

-- Table: public.a2
-- DROP TABLE public.a2;

CREATE TABLE public.a2
(
    id integer NOT NULL,
    name character(255) COLLATE pg_catalog."default" NOT NULL,
    sname character(40) COLLATE pg_catalog."default" NOT NULL,
    CONSTRAINT a2_pkey PRIMARY KEY (id)
)
WITH (
    OIDS = FALSE
)
TABLESPACE pg_default;

ALTER TABLE public.a2
    OWNER to postgres;


-- Table: public.a3
-- DROP TABLE public.a3;

CREATE TABLE public.a3
(
    id integer NOT NULL,
    name character(255) COLLATE pg_catalog."default" NOT NULL,
    sname character(40) COLLATE pg_catalog."default" NOT NULL,
    CONSTRAINT a3_pkey PRIMARY KEY (id)
)
WITH (
    OIDS = FALSE
)
TABLESPACE pg_default;

ALTER TABLE public.a3
    OWNER to postgres;


-- Table: public.a4
-- DROP TABLE public.a4;

CREATE TABLE public.a4
(
    id integer NOT NULL,
    name character(255) COLLATE pg_catalog."default" NOT NULL,
    sname character(40) COLLATE pg_catalog."default" NOT NULL,
    CONSTRAINT a4_pkey PRIMARY KEY (id)
)
WITH (
    OIDS = FALSE
)
TABLESPACE pg_default;

ALTER TABLE public.a4
    OWNER to postgres;



-- Table: public.a1cat
-- DROP TABLE public.a1cat;

CREATE TABLE public.a1cat
(
    id integer NOT NULL,
    name character(255) COLLATE pg_catalog."default" NOT NULL,
    sname character(40) COLLATE pg_catalog."default" NOT NULL,
    history boolean NOT NULL,
    type integer NOT NULL,
    CONSTRAINT a1cat_pkey PRIMARY KEY (id)
)
WITH (
    OIDS = FALSE
)
TABLESPACE pg_default;

ALTER TABLE public.a1cat
    OWNER to postgres;

-- Table: public.a2cat
-- DROP TABLE public.a2cat;

CREATE TABLE public.a2cat
(
    id integer NOT NULL,
    name character(255) COLLATE pg_catalog."default" NOT NULL,
    sname character(40) COLLATE pg_catalog."default" NOT NULL,
    history boolean NOT NULL,
    type integer NOT NULL,
    CONSTRAINT a2cat_pkey PRIMARY KEY (id)
)
WITH (
    OIDS = FALSE
)
TABLESPACE pg_default;

ALTER TABLE public.a2cat
    OWNER to postgres;

-- Table: public.a3cat
-- DROP TABLE public.a3cat;

CREATE TABLE public.a3cat
(
    id integer NOT NULL,
    name character(255) COLLATE pg_catalog."default" NOT NULL,
    sname character(40) COLLATE pg_catalog."default" NOT NULL,
    history boolean NOT NULL,
    type integer NOT NULL,
    CONSTRAINT a3cat_pkey PRIMARY KEY (id)
)
WITH (
    OIDS = FALSE
)
TABLESPACE pg_default;

ALTER TABLE public.a3cat
    OWNER to postgres;

-- Table: public.a4cat
-- DROP TABLE public.a4cat;

CREATE TABLE public.a4cat
(
    id integer NOT NULL,
    name character(255) COLLATE pg_catalog."default" NOT NULL,
    sname character(40) COLLATE pg_catalog."default" NOT NULL,
    history boolean NOT NULL,
    type integer NOT NULL,
    CONSTRAINT a4cat_pkey PRIMARY KEY (id)
)
WITH (
    OIDS = FALSE
)
TABLESPACE pg_default;

ALTER TABLE public.a4cat
    OWNER to postgres;


-- Table: public.link
-- DROP TABLE public.link;

CREATE TABLE public.link
(
    a1 integer NOT NULL,
    a2 integer NOT NULL,
    a3 integer NOT NULL,
    a4 integer NOT NULL,
    "order" integer NOT NULL,
    CONSTRAINT key PRIMARY KEY (a1, a2, a3, a4)
)
WITH (
    OIDS = FALSE
)
TABLESPACE pg_default;

ALTER TABLE public.link
    OWNER to postgres;


-- Table: public."values"
-- DROP TABLE public."values";

CREATE TABLE public."values"
(
    a_id integer NOT NULL,
    cat_id integer NOT NULL,
    date date NOT NULL,
    value jsonb NOT NULL,
    CONSTRAINT vkey PRIMARY KEY (a_id, cat_id)
)
WITH (
    OIDS = FALSE
)
TABLESPACE pg_default;

ALTER TABLE public."values"
    OWNER to postgres;




