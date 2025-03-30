--
-- PostgreSQL database dump
--

-- Dumped from database version 15.12 (Debian 15.12-1.pgdg120+1)
-- Dumped by pg_dump version 15.12 (Debian 15.12-1.pgdg120+1)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: clienttype; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.clienttype AS ENUM (
    'ADMINISTRATOR',
    'DEMO'
);


ALTER TYPE public.clienttype OWNER TO postgres;

--
-- Name: licensetype; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.licensetype AS ENUM (
    'BASIC',
    'STANDARD',
    'PREMIUM',
    'ENTERPRISE'
);


ALTER TYPE public.licensetype OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: licenses; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.licenses (
    id uuid NOT NULL,
    ruc character varying NOT NULL,
    nombre character varying NOT NULL,
    mail character varying NOT NULL,
    password_user character varying NOT NULL,
    ip character varying,
    database_name character varying NOT NULL,
    pass_database character varying NOT NULL,
    port character varying NOT NULL,
    tipo public.clienttype NOT NULL,
    licencia public.licensetype NOT NULL,
    is_active boolean,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    expiration_date timestamp without time zone NOT NULL
);


ALTER TABLE public.licenses OWNER TO postgres;

--
-- Data for Name: licenses; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.licenses (id, ruc, nombre, mail, password_user, ip, database_name, pass_database, port, tipo, licencia, is_active, created_at, updated_at, expiration_date) FROM stdin;
79c3aaf4-cd0f-4112-893d-000c95035a64	657106-9	Susana Morales	susana@morales.com	$2b$12$29m5bLEHGK6YER9uvap49OqE7zeSPgsHs3t3cF0C0Nd6b5a0BOeJC	localhost	client_657106_9	G2ICoB6UCk2I	5432	ADMINISTRATOR	BASIC	t	2025-03-18 01:33:31.673427	2025-03-18 01:33:31.673437	2025-03-18 00:55:50.436
5aa22577-f6d5-4ea3-bc01-36115816efb0	80010184-7	Multienvase	multienvase@mail.com	$2b$12$FOe4a/0h0wz4QoibWCiUC.5vCTCmj2ooDpnc25KKFztqvXCOYzSKW	localhost	client_80010184_7	cQ9TjYjC5VAl	5432	ADMINISTRATOR	BASIC	t	2025-03-18 00:57:31.914184	2025-03-18 00:57:31.914191	2025-03-30 00:55:50.436
1c6c7e49-a91f-4040-8af1-51e89f168d50	90090457-6	Susana Morales	hugomedina@gmail.com	$2b$12$FwYAjoJYuU4tXuteLKIyZeqKBbGbvKjOPm8nEWeEFeasovdJ72pZW	localhost	client_90090457_6	2wDo3ZBTgwS3	5432	ADMINISTRATOR	BASIC	t	2025-03-23 17:22:32.480739	2025-03-23 17:22:32.480747	2025-03-18 00:55:50.436
90429a36-e65e-452c-82ac-0e15b3dccf30	3439285-8	AGRO GROUP S.A.	agrogroupsa@mail.com	$2b$12$5.HDQImD2zYcrVHbN6PCFOsMBmO6UWluIPOA7hcDxbeVdZFObPF9.	localhost	client_3439285_8	kflZWmUiI5OU	15432	ADMINISTRATOR	BASIC	t	2025-03-29 14:19:27.912413	2025-03-29 14:19:27.912421	2025-03-29 14:19:27.357
95cdeb45-9e0c-41f5-97ed-ad821a3710cf	9008976-9	Carpenters	carpenters@gmail.com	$2b$12$200hK9/CSr6Qa2fTlGZxJOZ7ylFHas0Rqo2LhgWmWXL0hZMhYwSSi	localhost	client_9008976_9	8RGZ2U5aoJpT	15432	ADMINISTRATOR	BASIC	t	2025-03-29 14:40:51.771693	2025-03-29 14:40:51.771703	2025-03-29 14:40:51.462
\.


--
-- Name: licenses licenses_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.licenses
    ADD CONSTRAINT licenses_pkey PRIMARY KEY (id);


--
-- Name: ix_licenses_mail; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX ix_licenses_mail ON public.licenses USING btree (mail);


--
-- Name: ix_licenses_ruc; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX ix_licenses_ruc ON public.licenses USING btree (ruc);


--
-- PostgreSQL database dump complete
--

