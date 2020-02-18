SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: admins; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.admins (
    id integer NOT NULL,
    email character varying NOT NULL,
    can_change_admins boolean DEFAULT false NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    deleted_at timestamp without time zone,
    password_salt bytea,
    password_hash bytea
);


--
-- Name: admins_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.admins_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: admins_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.admins_id_seq OWNED BY public.admins.id;


--
-- Name: ar_internal_metadata; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ar_internal_metadata (
    key character varying NOT NULL,
    value character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: delayed_jobs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.delayed_jobs (
    id integer NOT NULL,
    priority integer DEFAULT 0 NOT NULL,
    attempts integer DEFAULT 0 NOT NULL,
    handler text NOT NULL,
    last_error text,
    run_at timestamp without time zone,
    locked_at timestamp without time zone,
    failed_at timestamp without time zone,
    locked_by character varying,
    queue character varying,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: delayed_jobs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.delayed_jobs_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: delayed_jobs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.delayed_jobs_id_seq OWNED BY public.delayed_jobs.id;


--
-- Name: participant_states; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.participant_states (
    id bigint NOT NULL,
    type character varying NOT NULL,
    participant_id bigint NOT NULL,
    aasm_state character varying,
    state json DEFAULT '{}'::json NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: participant_states_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.participant_states_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: participant_states_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.participant_states_id_seq OWNED BY public.participant_states.id;


--
-- Name: participants; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.participants (
    id integer NOT NULL,
    survey_id integer NOT NULL,
    phone_number character varying NOT NULL,
    active boolean DEFAULT true NOT NULL,
    login_code character varying,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    time_zone character varying,
    external_key character varying,
    original_number character varying
);


--
-- Name: participants_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.participants_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: participants_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.participants_id_seq OWNED BY public.participants.id;


--
-- Name: schedule_days; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.schedule_days (
    id integer NOT NULL,
    participant_id integer NOT NULL,
    participant_local_date date NOT NULL,
    time_ranges text,
    skip boolean DEFAULT false NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    aasm_state character varying
);


--
-- Name: schedule_days_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.schedule_days_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: schedule_days_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.schedule_days_id_seq OWNED BY public.schedule_days.id;


--
-- Name: scheduled_messages; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.scheduled_messages (
    id integer NOT NULL,
    schedule_day_id integer NOT NULL,
    survey_question_id integer,
    scheduled_at timestamp without time zone NOT NULL,
    delivered_at timestamp without time zone,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    aasm_state character varying,
    message_text text,
    destination_url text,
    expires_at timestamp without time zone
);


--
-- Name: scheduled_messages_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.scheduled_messages_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: scheduled_messages_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.scheduled_messages_id_seq OWNED BY public.scheduled_messages.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.schema_migrations (
    version character varying NOT NULL
);


--
-- Name: survey_permissions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.survey_permissions (
    id integer NOT NULL,
    admin_id integer NOT NULL,
    survey_id integer NOT NULL,
    can_modify_survey boolean,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: survey_permissions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.survey_permissions_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: survey_permissions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.survey_permissions_id_seq OWNED BY public.survey_permissions.id;


--
-- Name: survey_questions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.survey_questions (
    id integer NOT NULL,
    survey_id integer,
    question_text character varying DEFAULT ''::character varying NOT NULL,
    "position" integer DEFAULT 0 NOT NULL,
    deleted_at timestamp without time zone,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: survey_questions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.survey_questions_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: survey_questions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.survey_questions_id_seq OWNED BY public.survey_questions.id;


--
-- Name: surveys; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.surveys (
    id integer NOT NULL,
    name character varying NOT NULL,
    active boolean DEFAULT false NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    twilio_account_sid character varying,
    twilio_auth_token character varying,
    phone_number character varying,
    time_zone character varying,
    help_message text,
    welcome_message character varying DEFAULT 'Welcome to the study! Quit at any time by texting STOP.'::character varying NOT NULL,
    type character varying,
    configuration jsonb DEFAULT '{}'::jsonb
);


--
-- Name: surveys_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.surveys_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: surveys_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.surveys_id_seq OWNED BY public.surveys.id;


--
-- Name: text_messages; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.text_messages (
    id integer NOT NULL,
    survey_id integer NOT NULL,
    type character varying NOT NULL,
    from_number character varying NOT NULL,
    to_number character varying NOT NULL,
    message character varying NOT NULL,
    server_response text,
    scheduled_at timestamp without time zone,
    delivered_at timestamp without time zone,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    simulated boolean DEFAULT false NOT NULL
);


--
-- Name: text_messages_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.text_messages_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: text_messages_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.text_messages_id_seq OWNED BY public.text_messages.id;


--
-- Name: admins id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.admins ALTER COLUMN id SET DEFAULT nextval('public.admins_id_seq'::regclass);


--
-- Name: delayed_jobs id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.delayed_jobs ALTER COLUMN id SET DEFAULT nextval('public.delayed_jobs_id_seq'::regclass);


--
-- Name: participant_states id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.participant_states ALTER COLUMN id SET DEFAULT nextval('public.participant_states_id_seq'::regclass);


--
-- Name: participants id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.participants ALTER COLUMN id SET DEFAULT nextval('public.participants_id_seq'::regclass);


--
-- Name: schedule_days id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.schedule_days ALTER COLUMN id SET DEFAULT nextval('public.schedule_days_id_seq'::regclass);


--
-- Name: scheduled_messages id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.scheduled_messages ALTER COLUMN id SET DEFAULT nextval('public.scheduled_messages_id_seq'::regclass);


--
-- Name: survey_permissions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.survey_permissions ALTER COLUMN id SET DEFAULT nextval('public.survey_permissions_id_seq'::regclass);


--
-- Name: survey_questions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.survey_questions ALTER COLUMN id SET DEFAULT nextval('public.survey_questions_id_seq'::regclass);


--
-- Name: surveys id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.surveys ALTER COLUMN id SET DEFAULT nextval('public.surveys_id_seq'::regclass);


--
-- Name: text_messages id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.text_messages ALTER COLUMN id SET DEFAULT nextval('public.text_messages_id_seq'::regclass);


--
-- Name: admins admins_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.admins
    ADD CONSTRAINT admins_pkey PRIMARY KEY (id);


--
-- Name: ar_internal_metadata ar_internal_metadata_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ar_internal_metadata
    ADD CONSTRAINT ar_internal_metadata_pkey PRIMARY KEY (key);


--
-- Name: delayed_jobs delayed_jobs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.delayed_jobs
    ADD CONSTRAINT delayed_jobs_pkey PRIMARY KEY (id);


--
-- Name: participant_states participant_states_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.participant_states
    ADD CONSTRAINT participant_states_pkey PRIMARY KEY (id);


--
-- Name: participants participants_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.participants
    ADD CONSTRAINT participants_pkey PRIMARY KEY (id);


--
-- Name: schedule_days schedule_days_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.schedule_days
    ADD CONSTRAINT schedule_days_pkey PRIMARY KEY (id);


--
-- Name: scheduled_messages scheduled_messages_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.scheduled_messages
    ADD CONSTRAINT scheduled_messages_pkey PRIMARY KEY (id);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: survey_permissions survey_permissions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.survey_permissions
    ADD CONSTRAINT survey_permissions_pkey PRIMARY KEY (id);


--
-- Name: survey_questions survey_questions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.survey_questions
    ADD CONSTRAINT survey_questions_pkey PRIMARY KEY (id);


--
-- Name: surveys surveys_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.surveys
    ADD CONSTRAINT surveys_pkey PRIMARY KEY (id);


--
-- Name: text_messages text_messages_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.text_messages
    ADD CONSTRAINT text_messages_pkey PRIMARY KEY (id);


--
-- Name: delayed_jobs_priority; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX delayed_jobs_priority ON public.delayed_jobs USING btree (priority, run_at);


--
-- Name: index_admins_on_email; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_admins_on_email ON public.admins USING btree (email);


--
-- Name: index_participant_states_on_participant_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_participant_states_on_participant_id ON public.participant_states USING btree (participant_id);


--
-- Name: index_schedule_days_on_aasm_state; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_schedule_days_on_aasm_state ON public.schedule_days USING btree (aasm_state);


--
-- Name: index_scheduled_messages_on_aasm_state; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_scheduled_messages_on_aasm_state ON public.scheduled_messages USING btree (aasm_state);


--
-- Name: index_surveys_on_phone_number_and_active; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_surveys_on_phone_number_and_active ON public.surveys USING btree (phone_number, active);


--
-- Name: index_text_messages_on_survey_id_and_from_number; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_text_messages_on_survey_id_and_from_number ON public.text_messages USING btree (survey_id, from_number);


--
-- Name: index_text_messages_on_survey_id_and_to_number; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_text_messages_on_survey_id_and_to_number ON public.text_messages USING btree (survey_id, to_number);


--
-- Name: index_text_messages_on_survey_id_and_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_text_messages_on_survey_id_and_type ON public.text_messages USING btree (survey_id, type);


--
-- PostgreSQL database dump complete
--

SET search_path TO "$user", public;

INSERT INTO "schema_migrations" (version) VALUES
('20130208171002'),
('20130305145231'),
('20130305155723'),
('20130305180018'),
('20130305181842'),
('20130305182013'),
('20130322190210'),
('20130329162841'),
('20130711185854'),
('20130717203044'),
('20130724210331'),
('20130725154825'),
('20130805174413'),
('20130805204150'),
('20130812195027'),
('20130812195429'),
('20130812222125'),
('20130816154130'),
('20130819205256'),
('20130906201439'),
('20130906213306'),
('20141216162025'),
('20150114165032'),
('20150130174424'),
('20150217163204'),
('20150304220344'),
('20190221145222'),
('20190221153714'),
('20190221153949'),
('20190221164459'),
('20190222230454'),
('20190222232355'),
('20190224024027'),
('20190226150721'),
('20190301153058'),
('20190410161651'),
('20190515141402'),
('20200214194418'),
('20200218153737');


