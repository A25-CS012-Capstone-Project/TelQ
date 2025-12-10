--
-- PostgreSQL database dump
--

\restrict k9Xgk0jfwNaTI4yJq1k3CGXYJrrbTpI3AiUHUKKysTT6HOvZjHKv7mF0vmDZifI

-- Dumped from database version 15.15
-- Dumped by pg_dump version 15.15

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

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: products; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.products (
    product_id integer NOT NULL,
    product_name character varying(255) NOT NULL,
    price integer NOT NULL,
    duration_days integer NOT NULL,
    data_gb integer NOT NULL,
    streaming_gb_bonus integer DEFAULT 0 NOT NULL,
    gaming_gb_bonus integer DEFAULT 0 NOT NULL,
    social_gb_bonus integer DEFAULT 0 NOT NULL,
    call_minutes_bonus integer DEFAULT 0 NOT NULL,
    sms_bonus integer DEFAULT 0 NOT NULL,
    roaming_days_bonus integer DEFAULT 0 NOT NULL,
    target_offer character varying(50) NOT NULL
);


ALTER TABLE public.products OWNER TO postgres;

--
-- Name: purchase_history; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.purchase_history (
    history_id integer NOT NULL,
    customer_id character varying(50) NOT NULL,
    product_id integer NOT NULL,
    purchase_date timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.purchase_history OWNER TO postgres;

--
-- Name: purchase_history_history_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.purchase_history_history_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.purchase_history_history_id_seq OWNER TO postgres;

--
-- Name: purchase_history_history_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.purchase_history_history_id_seq OWNED BY public.purchase_history.history_id;


--
-- Name: user_features; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.user_features (
    customer_id character varying(50) NOT NULL,
    plan_type character varying(50) NOT NULL,
    device_brand character varying(50) NOT NULL,
    avg_data_usage_gb double precision NOT NULL,
    pct_video_usage double precision NOT NULL,
    avg_call_duration double precision NOT NULL,
    sms_freq integer NOT NULL,
    monthly_spend double precision NOT NULL,
    topup_freq integer NOT NULL,
    travel_score double precision NOT NULL,
    complain_count integer NOT NULL,
    spending_tier character varying(10) NOT NULL
);


ALTER TABLE public.user_features OWNER TO postgres;

--
-- Name: users; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.users (
    customer_id character varying(50) NOT NULL,
    firstname character varying(100) NOT NULL,
    lastname character varying(100),
    email character varying(100) NOT NULL,
    password_hash character varying(128) NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.users OWNER TO postgres;

--
-- Name: purchase_history history_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.purchase_history ALTER COLUMN history_id SET DEFAULT nextval('public.purchase_history_history_id_seq'::regclass);


--
-- Data for Name: products; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.products (product_id, product_name, price, duration_days, data_gb, streaming_gb_bonus, gaming_gb_bonus, social_gb_bonus, call_minutes_bonus, sms_bonus, roaming_days_bonus, target_offer) FROM stdin;
1	Data Pure Harian 1GB	6000	1	1	0	0	0	0	0	0	General Offer
2	Data Pure 3GB	15000	30	3	0	0	0	0	0	0	General Offer
3	Data Pure 5GB	25000	30	5	0	0	0	0	0	0	General Offer
4	Data Pure 10GB	45000	30	10	0	0	0	0	0	0	General Offer
5	Data Maxi 20GB	80000	30	20	0	0	0	0	0	0	General Offer
6	StreamMax Harian 3GB (1+2)	10000	1	1	2	0	0	0	0	0	Streaming Offer
7	StreamMax 20GB (10+10)	65000	30	10	10	0	0	0	0	0	Streaming Offer
8	StreamMax 40GB (15+25)	100000	30	15	25	0	0	0	0	0	Streaming Offer
9	VideoPass 15GB (5+10)	55000	30	5	10	0	0	0	0	0	Streaming Offer
10	VideoPass 60GB (20+40)	150000	30	20	40	0	0	0	0	0	Streaming Offer
11	Ngobrol Irit 2GB (200mnt)	25000	7	2	0	0	0	200	50	0	Voice Offer
12	Ngobrol Juara 5GB (500mnt)	45000	30	5	0	0	0	500	100	0	Voice Offer
13	Ngobrol Puas 8GB (1000mnt)	70000	30	8	0	0	0	1000	200	0	Voice Offer
14	TalkMax Bulanan 12GB (1500mnt)	95000	30	12	0	0	0	1500	300	0	Voice Offer
15	Roaming Asia 3 Hari 3GB	130000	3	3	0	0	0	0	0	3	Roaming Offer
16	Roaming Asia 7 Hari 7GB	200000	7	7	0	0	0	0	0	7	Roaming Offer
17	Roaming Dunia 5 Hari 10GB	280000	5	10	0	0	0	0	0	5	Roaming Offer
18	Roaming Dunia 10 Hari 20GB	400000	10	20	0	0	0	0	0	10	Roaming Offer
19	SocmedFun Harian 3GB (1+2)	9000	1	1	0	0	2	0	0	0	Social Offer
20	SocmedFun 10GB (5+5)	40000	30	5	0	0	5	0	0	0	Social Offer
21	SocmedFun 25GB (10+15)	75000	30	10	0	0	15	0	0	0	Social Offer
22	SocmedMax 40GB (15+25)	110000	30	15	0	0	25	0	0	0	Social Offer
23	Super Plan 50GB All-in-One	160000	30	50	10	10	10	500	200	3	Premium Offer
24	Gaming Max 20 + 10	30000	30	20	0	9	0	0	0	0	Gaming Offer
\.


--
-- Data for Name: purchase_history; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.purchase_history (history_id, customer_id, product_id, purchase_date) FROM stdin;
1	08123	11	2025-12-01 19:50:49.53117
2	08123	9	2025-12-01 19:52:30.885999
3	08123	8	2025-12-01 19:53:01.535681
4	08123	24	2025-12-01 19:55:46.353092
5	08123	24	2025-12-01 19:56:00.241972
6	08123	24	2025-12-01 19:56:22.903917
7	08123	24	2025-12-01 19:56:51.184344
8	08123	14	2025-12-01 19:57:48.334397
9	08123	12	2025-12-02 11:07:00.418384
10	08123	18	2025-12-02 11:07:55.230956
11	085678	24	2025-12-02 11:18:18.314732
12	085678	12	2025-12-02 11:19:07.00569
13	08123	14	2025-12-06 13:42:38.873102
14	08123	21	2025-12-06 13:42:59.714855
15	08123	22	2025-12-06 13:43:13.784023
16	08123	19	2025-12-06 13:43:34.894507
17	08123	20	2025-12-06 13:43:50.665571
18	08123	10	2025-12-07 15:21:45.193275
19	08123	24	2025-12-07 19:00:24.493221
20	08123	3	2025-12-07 19:00:45.241786
52	08123	23	2025-12-08 05:31:56.36922
53	08123	12	2025-12-08 05:32:11.46527
54	08123	13	2025-12-08 05:32:15.000941
55	081234567890	21	2025-12-08 05:38:13.867727
56	081234567890	9	2025-12-08 08:07:26.574617
57	081234567890	12	2025-12-08 08:07:51.13216
58	08887788	22	2025-12-08 08:09:45.935965
59	08887788	21	2025-12-08 08:10:04.256564
60	08667788	9	2025-12-08 08:11:10.899159
61	08667788	23	2025-12-08 08:11:29.481828
62	08667788	20	2025-12-08 08:12:26.495714
63	08667788	21	2025-12-08 08:12:43.076374
64	08667788	21	2025-12-08 08:12:55.856471
65	08667788	22	2025-12-08 08:13:00.164529
66	08667788	8	2025-12-08 08:13:43.746271
67	08667788	10	2025-12-08 08:14:52.992959
68	1	16	2025-12-08 08:53:26.124084
69	2	15	2025-12-08 08:54:30.124528
70	3	21	2025-12-08 08:55:44.793545
71	4	7	2025-12-08 08:56:36.585381
\.


--
-- Data for Name: user_features; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.user_features (customer_id, plan_type, device_brand, avg_data_usage_gb, pct_video_usage, avg_call_duration, sms_freq, monthly_spend, topup_freq, travel_score, complain_count, spending_tier) FROM stdin;
085678	Prepaid	Android	12.5	0	250	50	37500	2	0	0	low
08123	Prepaid	Android	13.80952380952381	0.22666666666666666	271.42857142857144	60	78523.80952380953	21	0.15476190476190477	0	mid
081234567890	Prepaid	Android	6.666666666666667	0.3333333333333333	166.66666666666666	33	58333.333333333336	3	0	0	mid
08887788	Prepaid	Android	12.5	0	0	0	92500	2	0	0	mid
08667788	Prepaid	Android	16.25	0.3953488372093023	62.5	25	95625	8	0.09375	0	mid
1	Prepaid	Android	7	0	0	0	200000	1	1	0	high
2	Prepaid	Android	3	0	0	0	130000	1	0.75	0	high
3	Prepaid	Android	10	0	0	0	75000	1	0	0	mid
4	Prepaid	Android	10	0.5	0	0	65000	1	0	0	mid
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.users (customer_id, firstname, lastname, email, password_hash, created_at) FROM stdin;
08123	User A	Testing	a@gmail.com	pbkdf2:sha256:1000000$IUmkTgnNzNGl3UAm$82a7432ce1af2a2e910706ed2ea56bd879f1dc027e8f4718c83f4fcafa333a6f	2025-12-01 19:49:08.700607
085678	User B	Test	b@gmail.com	pbkdf2:sha256:1000000$lFoZmiw9wdhpxCeB$7b0fe6352fda3529cb9aa54b80cf699e7c38a3cde34eb32b0f40cfcebf2882e5	2025-12-02 11:17:49.125888
081234567890	User C	Test	c@gmail.com	pbkdf2:sha256:1000000$qAviYrMTdEGNDfsd$c3458c9200f3e6b2b897f99ff8b334bfc877649a90b274c7a9ec04fe6200f214	2025-12-08 05:37:42.839392
08887788	User D	Test	d@gmail.com	pbkdf2:sha256:1000000$CWWZVE9qWZo8Wt0l$6720d98c177634086a1fac55d2031993a2b5f731d62d1f83321c66da2fcea780	2025-12-08 08:09:03.684472
08667788	User E	Test	e@gmail.com	pbkdf2:sha256:1000000$91H4tXl8tbEJbVLo$895121b92a1346a5ab0660f7284c239d73b0a7190c20a6b3a03fc201e06c30ee	2025-12-08 08:10:48.873693
1	USER 1	TES	1@gmail.com	pbkdf2:sha256:1000000$ud5rFF1GCmev6NEC$2e2a887af2146556a5c391a8ade994cfb988e1ee8bf28b52b931ab3a7d47f15e	2025-12-08 08:53:00.238924
2	USER 2	TEST	2@gmail.com	pbkdf2:sha256:1000000$NTN58RAp5SiJnZbT$3935a951d0af1963e530cb8772134cbf45d2425d04b730867246cad3f7cc7af2	2025-12-08 08:54:05.888546
3	USER 3	TEST	3@gmail.com	pbkdf2:sha256:1000000$fMyOzH0oPi0X1Srm$5e0e39cfa3bd559c114aa3b53238c4d18e923239edd806d4ddbcf5ee36c5ac22	2025-12-08 08:54:58.398276
4	USER 4	TEST	4@gmail.com	pbkdf2:sha256:1000000$VJCcn5S2NFCJOgA3$37484f01a3f1b6d023e200ea27d056f1f329c0a939684de4c57e2ddd02264791	2025-12-08 08:56:16.339337
\.


--
-- Name: purchase_history_history_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.purchase_history_history_id_seq', 71, true);


--
-- Name: products products_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.products
    ADD CONSTRAINT products_pkey PRIMARY KEY (product_id);


--
-- Name: purchase_history purchase_history_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.purchase_history
    ADD CONSTRAINT purchase_history_pkey PRIMARY KEY (history_id);


--
-- Name: user_features user_features_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_features
    ADD CONSTRAINT user_features_pkey PRIMARY KEY (customer_id);


--
-- Name: users users_email_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key UNIQUE (email);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (customer_id);


--
-- Name: purchase_history purchase_history_customer_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.purchase_history
    ADD CONSTRAINT purchase_history_customer_id_fkey FOREIGN KEY (customer_id) REFERENCES public.users(customer_id) ON DELETE CASCADE;


--
-- Name: purchase_history purchase_history_product_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.purchase_history
    ADD CONSTRAINT purchase_history_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.products(product_id) ON DELETE CASCADE;


--
-- Name: user_features user_features_customer_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_features
    ADD CONSTRAINT user_features_customer_id_fkey FOREIGN KEY (customer_id) REFERENCES public.users(customer_id) ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

\unrestrict k9Xgk0jfwNaTI4yJq1k3CGXYJrrbTpI3AiUHUKKysTT6HOvZjHKv7mF0vmDZifI

