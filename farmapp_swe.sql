--
-- PostgreSQL database dump
--

-- Dumped from database version 17.0
-- Dumped by pg_dump version 17.0

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
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
-- Name: adds_to; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.adds_to (
    buyerid integer NOT NULL,
    cartid integer
);


ALTER TABLE public.adds_to OWNER TO postgres;

--
-- Name: administrator; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.administrator (
    userid integer NOT NULL
);


ALTER TABLE public.administrator OWNER TO postgres;

--
-- Name: buyer; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.buyer (
    buyerid integer NOT NULL,
    userid integer,
    payment_method character varying(50) NOT NULL,
    delivery_address text NOT NULL
);


ALTER TABLE public.buyer OWNER TO postgres;

--
-- Name: buyer_buyerid_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.buyer_buyerid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.buyer_buyerid_seq OWNER TO postgres;

--
-- Name: buyer_buyerid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.buyer_buyerid_seq OWNED BY public.buyer.buyerid;


--
-- Name: buyer_report; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.buyer_report (
    reportid integer NOT NULL,
    buyerid integer,
    money_spent numeric(10,2) NOT NULL,
    most_purchased_farm integer NOT NULL,
    most_purchased_product integer NOT NULL
);


ALTER TABLE public.buyer_report OWNER TO postgres;

--
-- Name: cart; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.cart (
    cartid integer NOT NULL,
    total_cost numeric(10,2) NOT NULL
);


ALTER TABLE public.cart OWNER TO postgres;

--
-- Name: cart_cartid_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.cart_cartid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.cart_cartid_seq OWNER TO postgres;

--
-- Name: cart_cartid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.cart_cartid_seq OWNED BY public.cart.cartid;


--
-- Name: chat; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.chat (
    chatid integer NOT NULL
);


ALTER TABLE public.chat OWNER TO postgres;

--
-- Name: chat_chatid_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.chat_chatid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.chat_chatid_seq OWNER TO postgres;

--
-- Name: chat_chatid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.chat_chatid_seq OWNED BY public.chat.chatid;


--
-- Name: communication; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.communication (
    chatid integer NOT NULL,
    farmerid integer,
    buyerid integer
);


ALTER TABLE public.communication OWNER TO postgres;

--
-- Name: created_from; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.created_from (
    orderid integer NOT NULL,
    cartid integer
);


ALTER TABLE public.created_from OWNER TO postgres;

--
-- Name: delivered_by; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.delivered_by (
    orderid integer NOT NULL,
    deliveryid integer
);


ALTER TABLE public.delivered_by OWNER TO postgres;

--
-- Name: delivery; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.delivery (
    deliveryid integer NOT NULL,
    method character varying(50) NOT NULL,
    status character varying(50) NOT NULL
);


ALTER TABLE public.delivery OWNER TO postgres;

--
-- Name: delivery_deliveryid_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.delivery_deliveryid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.delivery_deliveryid_seq OWNER TO postgres;

--
-- Name: delivery_deliveryid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.delivery_deliveryid_seq OWNED BY public.delivery.deliveryid;


--
-- Name: document; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.document (
    farmerid integer NOT NULL,
    filepath character varying(255) NOT NULL,
    filename character varying(255) NOT NULL
);


ALTER TABLE public.document OWNER TO postgres;

--
-- Name: farm; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.farm (
    farmid integer NOT NULL,
    farmerid integer,
    location character varying(255) NOT NULL,
    size double precision NOT NULL,
    name character varying(80) NOT NULL
);


ALTER TABLE public.farm OWNER TO postgres;

--
-- Name: farm_farmid_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.farm_farmid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.farm_farmid_seq OWNER TO postgres;

--
-- Name: farm_farmid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.farm_farmid_seq OWNED BY public.farm.farmid;


--
-- Name: farmer; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.farmer (
    farmerid integer NOT NULL,
    userid integer,
    govid character varying(50) NOT NULL
);


ALTER TABLE public.farmer OWNER TO postgres;

--
-- Name: farmer_farmerid_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.farmer_farmerid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.farmer_farmerid_seq OWNER TO postgres;

--
-- Name: farmer_farmerid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.farmer_farmerid_seq OWNED BY public.farmer.farmerid;


--
-- Name: included_in; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.included_in (
    productid integer NOT NULL,
    cartid integer NOT NULL
);


ALTER TABLE public.included_in OWNER TO postgres;

--
-- Name: inventory_item; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.inventory_item (
    itemid integer NOT NULL,
    farmid integer,
    name character varying(80) NOT NULL,
    type character varying(80) NOT NULL,
    quantity integer NOT NULL
);


ALTER TABLE public.inventory_item OWNER TO postgres;

--
-- Name: inventory_item_itemid_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.inventory_item_itemid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.inventory_item_itemid_seq OWNER TO postgres;

--
-- Name: inventory_item_itemid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.inventory_item_itemid_seq OWNED BY public.inventory_item.itemid;


--
-- Name: inventory_report; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.inventory_report (
    reportid integer NOT NULL,
    farmerid integer
);


ALTER TABLE public.inventory_report OWNER TO postgres;

--
-- Name: message; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.message (
    messageid integer NOT NULL,
    "timestamp" timestamp without time zone NOT NULL,
    content text NOT NULL,
    receiverid integer,
    senderid integer,
    chatid integer
);


ALTER TABLE public.message OWNER TO postgres;

--
-- Name: message_messageid_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.message_messageid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.message_messageid_seq OWNER TO postgres;

--
-- Name: message_messageid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.message_messageid_seq OWNED BY public.message.messageid;


--
-- Name: negotiations; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.negotiations (
    negotiationid integer NOT NULL,
    farmerid integer,
    buyerid integer,
    offered_price numeric(10,2) NOT NULL,
    status character varying(80) NOT NULL
);


ALTER TABLE public.negotiations OWNER TO postgres;

--
-- Name: negotiations_negotiationid_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.negotiations_negotiationid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.negotiations_negotiationid_seq OWNER TO postgres;

--
-- Name: negotiations_negotiationid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.negotiations_negotiationid_seq OWNED BY public.negotiations.negotiationid;


--
-- Name: notification; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.notification (
    notificationid integer NOT NULL,
    recipientid integer,
    message text NOT NULL,
    "timestamp" timestamp without time zone NOT NULL,
    status character varying(50) NOT NULL
);


ALTER TABLE public.notification OWNER TO postgres;

--
-- Name: notification_notificationid_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.notification_notificationid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.notification_notificationid_seq OWNER TO postgres;

--
-- Name: notification_notificationid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.notification_notificationid_seq OWNED BY public.notification.notificationid;


--
-- Name: orderu; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.orderu (
    orderid integer NOT NULL,
    status character varying(50) NOT NULL,
    date_ordered timestamp without time zone NOT NULL,
    date_shipped timestamp without time zone NOT NULL,
    address text NOT NULL,
    cartid integer,
    buyerid integer,
    paymentid integer
);


ALTER TABLE public.orderu OWNER TO postgres;

--
-- Name: orderu_orderid_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.orderu_orderid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.orderu_orderid_seq OWNER TO postgres;

--
-- Name: orderu_orderid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.orderu_orderid_seq OWNED BY public.orderu.orderid;


--
-- Name: payment; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.payment (
    paymentid integer NOT NULL,
    date date,
    amount numeric(10,2) NOT NULL,
    method character varying(80) NOT NULL,
    status character varying(80) NOT NULL,
    buyerid integer
);


ALTER TABLE public.payment OWNER TO postgres;

--
-- Name: payment_paymentid_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.payment_paymentid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.payment_paymentid_seq OWNER TO postgres;

--
-- Name: payment_paymentid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.payment_paymentid_seq OWNED BY public.payment.paymentid;


--
-- Name: pimage; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.pimage (
    productid integer,
    image_url text NOT NULL,
    image_name character varying(255) NOT NULL
);


ALTER TABLE public.pimage OWNER TO postgres;

--
-- Name: popular_products; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.popular_products (
    reportid integer NOT NULL,
    productid integer NOT NULL
);


ALTER TABLE public.popular_products OWNER TO postgres;

--
-- Name: product; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.product (
    productid integer NOT NULL,
    farmid integer,
    name character varying(100) NOT NULL,
    category character varying(80) NOT NULL,
    price double precision NOT NULL,
    quantity integer NOT NULL,
    description text NOT NULL
);


ALTER TABLE public.product OWNER TO postgres;

--
-- Name: product_productid_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.product_productid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.product_productid_seq OWNER TO postgres;

--
-- Name: product_productid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.product_productid_seq OWNED BY public.product.productid;


--
-- Name: received_by; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.received_by (
    notificationid integer NOT NULL,
    userid integer NOT NULL
);


ALTER TABLE public.received_by OWNER TO postgres;

--
-- Name: reports; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.reports (
    reportid integer NOT NULL,
    date date NOT NULL,
    type character varying(80) NOT NULL,
    time_period_start date NOT NULL,
    time_period_end date NOT NULL
);


ALTER TABLE public.reports OWNER TO postgres;

--
-- Name: reports_reportid_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.reports_reportid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.reports_reportid_seq OWNER TO postgres;

--
-- Name: reports_reportid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.reports_reportid_seq OWNED BY public.reports.reportid;


--
-- Name: sales_report; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.sales_report (
    reportid integer NOT NULL,
    farmerid integer,
    total_sales integer NOT NULL,
    revenue numeric(10,2) NOT NULL
);


ALTER TABLE public.sales_report OWNER TO postgres;

--
-- Name: users; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.users (
    userid integer NOT NULL,
    email character varying(255) NOT NULL,
    name character varying(50) NOT NULL,
    phone_number bigint NOT NULL,
    password character varying(255) NOT NULL,
    username character varying(50) NOT NULL
);


ALTER TABLE public.users OWNER TO postgres;

--
-- Name: users_userid_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.users_userid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.users_userid_seq OWNER TO postgres;

--
-- Name: users_userid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.users_userid_seq OWNED BY public.users.userid;


--
-- Name: buyer buyerid; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.buyer ALTER COLUMN buyerid SET DEFAULT nextval('public.buyer_buyerid_seq'::regclass);


--
-- Name: cart cartid; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cart ALTER COLUMN cartid SET DEFAULT nextval('public.cart_cartid_seq'::regclass);


--
-- Name: chat chatid; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.chat ALTER COLUMN chatid SET DEFAULT nextval('public.chat_chatid_seq'::regclass);


--
-- Name: delivery deliveryid; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.delivery ALTER COLUMN deliveryid SET DEFAULT nextval('public.delivery_deliveryid_seq'::regclass);


--
-- Name: farm farmid; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.farm ALTER COLUMN farmid SET DEFAULT nextval('public.farm_farmid_seq'::regclass);


--
-- Name: farmer farmerid; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.farmer ALTER COLUMN farmerid SET DEFAULT nextval('public.farmer_farmerid_seq'::regclass);


--
-- Name: inventory_item itemid; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.inventory_item ALTER COLUMN itemid SET DEFAULT nextval('public.inventory_item_itemid_seq'::regclass);


--
-- Name: message messageid; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.message ALTER COLUMN messageid SET DEFAULT nextval('public.message_messageid_seq'::regclass);


--
-- Name: negotiations negotiationid; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.negotiations ALTER COLUMN negotiationid SET DEFAULT nextval('public.negotiations_negotiationid_seq'::regclass);


--
-- Name: notification notificationid; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.notification ALTER COLUMN notificationid SET DEFAULT nextval('public.notification_notificationid_seq'::regclass);


--
-- Name: orderu orderid; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.orderu ALTER COLUMN orderid SET DEFAULT nextval('public.orderu_orderid_seq'::regclass);


--
-- Name: payment paymentid; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.payment ALTER COLUMN paymentid SET DEFAULT nextval('public.payment_paymentid_seq'::regclass);


--
-- Name: product productid; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.product ALTER COLUMN productid SET DEFAULT nextval('public.product_productid_seq'::regclass);


--
-- Name: reports reportid; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.reports ALTER COLUMN reportid SET DEFAULT nextval('public.reports_reportid_seq'::regclass);


--
-- Name: users userid; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users ALTER COLUMN userid SET DEFAULT nextval('public.users_userid_seq'::regclass);


--
-- Data for Name: adds_to; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.adds_to (buyerid, cartid) FROM stdin;
1	1
2	2
3	3
4	4
5	5
6	6
7	7
8	8
9	9
10	10
\.


--
-- Data for Name: administrator; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.administrator (userid) FROM stdin;
1
2
3
4
5
\.


--
-- Data for Name: buyer; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.buyer (buyerid, userid, payment_method, delivery_address) FROM stdin;
1	6	Credit Card	123 Buyer St, City A
2	7	PayPal	456 Buyer St, City B
3	8	Debit Card	789 Buyer St, City C
4	9	Bank Transfer	321 Buyer St, City D
5	10	Credit Card	654 Buyer St, City E
6	11	Cash	987 Buyer St, City F
7	12	Credit Card	135 Buyer St, City G
8	13	PayPal	246 Buyer St, City H
9	14	Debit Card	357 Buyer St, City I
10	15	Bank Transfer	468 Buyer St, City J
\.


--
-- Data for Name: buyer_report; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.buyer_report (reportid, buyerid, money_spent, most_purchased_farm, most_purchased_product) FROM stdin;
1	1	250.00	1	1
2	2	300.50	2	3
3	3	150.75	3	5
4	4	400.00	4	7
5	5	220.30	5	9
6	6	180.20	1	2
7	7	275.50	2	4
8	8	320.10	3	6
9	9	210.00	4	8
10	10	150.00	5	10
11	1	300.00	1	1
12	2	450.25	2	3
13	3	275.90	3	5
14	4	360.40	4	7
15	5	400.00	5	9
16	6	230.60	1	2
17	7	290.80	2	4
18	8	310.50	3	6
19	9	220.30	4	8
20	10	160.00	5	10
\.


--
-- Data for Name: cart; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.cart (cartid, total_cost) FROM stdin;
1	100.00
2	150.50
3	200.75
4	250.00
5	175.25
6	300.00
7	120.50
8	90.00
9	80.00
10	60.00
11	110.50
12	130.75
13	140.00
14	160.25
15	190.00
16	220.50
17	250.75
18	270.00
19	300.25
20	350.00
\.


--
-- Data for Name: chat; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.chat (chatid) FROM stdin;
1
2
3
4
5
6
7
8
9
10
\.


--
-- Data for Name: communication; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.communication (chatid, farmerid, buyerid) FROM stdin;
1	1	1
2	2	2
3	3	3
4	4	4
5	5	5
6	1	6
7	2	7
8	3	8
9	4	9
10	5	10
\.


--
-- Data for Name: created_from; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.created_from (orderid, cartid) FROM stdin;
\.


--
-- Data for Name: delivered_by; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.delivered_by (orderid, deliveryid) FROM stdin;
1	1
2	2
3	3
4	4
5	5
6	6
7	7
8	8
9	9
10	10
\.


--
-- Data for Name: delivery; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.delivery (deliveryid, method, status) FROM stdin;
1	Standard Shipping	Delivered
2	Express Shipping	Pending
3	Same Day Delivery	Shipped
4	Next Day Delivery	Cancelled
5	Pick Up	Delivered
6	Standard Shipping	Pending
7	Express Shipping	Shipped
8	Same Day Delivery	Delivered
9	Next Day Delivery	Cancelled
10	Pick Up	Pending
11	Standard Shipping	Delivered
12	Express Shipping	Pending
13	Same Day Delivery	Shipped
14	Next Day Delivery	Cancelled
15	Pick Up	Delivered
16	Standard Shipping	Pending
17	Express Shipping	Shipped
18	Same Day Delivery	Delivered
19	Next Day Delivery	Cancelled
20	Pick Up	Pending
\.


--
-- Data for Name: document; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.document (farmerid, filepath, filename) FROM stdin;
\.


--
-- Data for Name: farm; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.farm (farmid, farmerid, location, size, name) FROM stdin;
1	1	123 Orchard Lane, Springfield	50.5	Sunny Acres Farm
2	2	456 Green Valley Road, Springfield	75	Green Pastures Farm
3	3	789 River Bend Drive, Springfield	100	Riverbend Farms
4	4	321 Hilltop Way, Springfield	60.5	Hilltop Harvest Farm
5	5	654 Meadow Lane, Springfield	80	Meadow View Farm
\.


--
-- Data for Name: farmer; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.farmer (farmerid, userid, govid) FROM stdin;
1	16	GOV123456
2	17	GOV234567
3	18	GOV345678
4	19	GOV456789
5	20	GOV567890
\.


--
-- Data for Name: included_in; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.included_in (productid, cartid) FROM stdin;
1	1
2	2
3	3
4	4
5	5
6	6
7	7
8	8
9	9
10	10
1	2
2	3
3	4
4	5
5	6
6	7
7	8
8	9
9	10
10	1
\.


--
-- Data for Name: inventory_item; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.inventory_item (itemid, farmid, name, type, quantity) FROM stdin;
1	1	Organic Apples	Fruits	150
2	1	Fresh Carrots	Vegetables	200
3	2	Free-Range Eggs	Dairy	300
4	2	Grass-Fed Beef	Meat	100
5	3	Whole Wheat Flour	Grains	250
6	3	Cherry Tomatoes	Vegetables - Small	180
7	4	Local Honey	Condiments	50
8	4	Yellow Squash	Vegetables - Summer	120
9	5	Strawberries	Fruits - Berries	200
10	5	Aged Cheddar Cheese	Dairy - Cheese	80
11	1	Organic Spinach	Leafy Greens	160
12	2	Boneless Chicken Breast	Meat - Poultry	90
13	3	Blueberries	Fruits - Berries-Fall	140
14	4	Pumpkins	Vegetables - Fall	75
15	5	Peaches	Fruits - Stone Fruit	110
16	1	Garlic Cloves	Herbs & Spices	200
17	2	Pork Sausages	Meat - Processed	60
18	3	Raspberry Jam	Condiments - Preserves	40
19	4	Kale Leaves	Leafy Greens - Dark	100
20	5	Almond Milk Beverage	Dairy Alternatives	90
\.


--
-- Data for Name: inventory_report; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.inventory_report (reportid, farmerid) FROM stdin;
1	1
2	1
3	2
4	2
5	3
6	3
7	4
8	4
9	5
10	5
11	1
12	2
13	3
14	4
15	5
16	1
17	2
18	3
19	4
20	5
\.


--
-- Data for Name: message; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.message (messageid, "timestamp", content, receiverid, senderid, chatid) FROM stdin;
1	2024-11-01 09:00:00	Hello! How can I assist you today?	6	16	1
2	2024-11-01 09:05:00	I am interested in your organic vegetables.	16	6	1
3	2024-11-01 09:10:00	What products do you have available?	17	7	2
4	2024-11-01 09:15:00	We have carrots and potatoes.	7	17	2
5	2024-11-01 09:20:00	Can you deliver next week?	18	8	3
6	2024-11-01 09:20:00	Yes, we can arrange that	8	18	3
7	2024-11-01 09:30:00	I would like to know about your pricing of apples.	19	9	4
8	2024-11-01 09:35:00	Our prices are competitive. 500 tenge for 1 kg	9	19	4
9	2024-11-01 11:40:00	Hello! I need fresh fruits for my store.	20	10	5
10	2024-11-01 11:42:00	We have apples and oranges available.	10	20	5
11	2024-11-02 09:00:00	Hi! Can I place a bulk order?	16	11	6
12	2024-11-02 09:05:00	Sure! What quantity are you looking for?	11	16	6
13	2024-11-02 09:10:00	I am interested in your dairy products.	17	12	7
14	2024-11-02 09:15:00	We have fresh milk and cheese.	12	17	7
15	2024-11-02 10:20:00	Hello!Can you provide delivery options?	18	13	8
16	2024-11-02 10:25:00	Yes! We offer same-day delivery.	13	18	8
17	2024-11-02 11:30:00	Hello! I need information on your farm practices.	19	14	9
18	2024-11-02 11:35:00	I can provide all the details you need.	14	19	9
19	2024-11-02 13:40:00	Do you have any seasonal discounts?	20	15	10
20	2024-11-02 13:45:00	Yes! We have discounts for bulk purchases.	15	20	10
\.


--
-- Data for Name: negotiations; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.negotiations (negotiationid, farmerid, buyerid, offered_price, status) FROM stdin;
1	1	1	100.50	Pending
2	2	2	200.00	Accepted
3	3	3	150.75	Rejected
4	4	4	300.00	Pending
5	5	5	250.25	Accepted
6	1	6	180.00	Rejected
7	2	7	220.00	Pending
8	3	8	310.50	Accepted
9	4	9	275.75	Rejected
10	5	10	400.00	Pending
\.


--
-- Data for Name: notification; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.notification (notificationid, recipientid, message, "timestamp", status) FROM stdin;
1	1	Welcome to the platform, Administrator!	2024-11-01 09:00:00	unread
2	2	Your account has been activated.	2024-11-01 09:05:00	unread
3	3	A new product is available in your area.	2024-11-01 09:10:00	unread
4	4	Your order has been shipped!	2024-11-01 09:15:00	unread
5	5	You have a new message from a farmer.	2024-11-01 09:20:00	unread
6	6	Thank you for your purchase!	2024-11-01 09:25:00	unread
7	7	Your payment was successful.	2024-11-01 09:30:00	unread
8	8	New discounts available for your next purchase.	2024-11-01 09:35:00	unread
9	9	Your delivery is scheduled for tomorrow.	2024-11-01 09:40:00	unread
10	10	Reminder: Your subscription will renew soon.	2024-11-01 09:45:00	unread
11	11	You have a new message from support.	2024-11-01 09:50:00	unread
12	12	Your feedback is important to us!	2024-11-01 09:55:00	unread
13	13	A farmer has responded to your inquiry.	2024-11-01 10:00:00	unread
14	14	Your order was delivered successfully.	2024-11-01 10:05:00	unread
15	15	You have earned loyalty points!	2024-11-01 10:10:00	unread
16	16	New features have been added to your account.	2024-11-01 10:15:00	unread
17	17	Your profile has been updated.	2024-11-01 10:20:00	unread
18	18	A new chat message awaits your response.	2024-11-01 10:25:00	unread
19	19	Your request for support has been received.	2024-11-01 10:30:00	unread
20	20	Thank you for being a valued user!	2024-11-01 10:35:00	unread
\.


--
-- Data for Name: orderu; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.orderu (orderid, status, date_ordered, date_shipped, address, cartid, buyerid, paymentid) FROM stdin;
1	Shipped	2024-11-01 10:00:00	2024-11-02 10:00:00	123 Main St, City A	1	1	1
2	Pending	2024-11-02 11:00:00	2024-11-03 11:00:00	456 Elm St, City B	2	2	2
3	Delivered	2024-11-03 12:00:00	2024-11-04 12:00:00	789 Oak St, City C	3	3	3
4	Cancelled	2024-11-04 09:30:00	2024-11-05 09:30:00	321 Pine St, City D	4	4	4
5	Shipped	2024-11-05 14:30:00	2024-11-06 14:30:00	654 Maple St, City E	5	5	5
6	Pending	2024-11-06 16:45:00	2024-11-07 16:45:00	987 Birch St, City F	6	6	6
7	Delivered	2024-11-07 08:15:00	2024-11-08 08:15:00	135 Cedar St, City G	7	7	7
8	Shipped	2024-11-08 10:20:00	2024-11-09 10:20:00	246 Spruce St, City H	8	8	8
9	Pending	2024-11-09 13:50:00	2024-11-10 13:50:00	357 Walnut St ,City I	9	9	9
10	Cancelled	2024-11-10 00:00:00	2024-11-11 00:00:00	468 Chestnut St ,City J	10	10	10
11	Shipped	2024-11-11 00:00:00	2024-11-12 00:00:00	111 Pine St ,City K	11	1	11
12	Pending	2024-11-12 00:00:00	2024-11-13 00:00:00	222 Oak St ,City L	12	2	12
13	Delivered	2024-11-13 00:00:00	2024-11-14 00:00:00	333 Maple St ,City M	13	3	13
14	Cancelled	2024-11-14 00:00:00	2024-11-15 00:00:00	444 Elm St ,City N	14	4	14
15	Shipped	2024-11-15 00:00:00	2024-11-16 00:00:00	555 Birch St ,City O	15	5	15
16	Pending	2024-11-16 00:00:00	2024-11-17 00:00:00	666 Cedar St ,City P	16	6	16
17	Delivered	2024-11-17 00:00:00	2024-11-18 00:00:00	777 Spruce St,Ci ty Q	17	7	17
18	Shipped	2024-11-18 00:00:00	2024-11-19 00:00:00	888 Walnut S t,Ci ty R	18	8	18
19	Pending	2024-11-19 00:00:00	2024-11-20 00:00:00	999 Chestnut S t,Ci ty S	19	9	19
20	Cancelled	2024-12-01 00:00:00	2024-12-02 00:00:00	000 Main S t,Ci ty T	20	10	20
\.


--
-- Data for Name: payment; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.payment (paymentid, date, amount, method, status, buyerid) FROM stdin;
1	2024-11-01	100.00	Credit Card	Completed	1
2	2024-11-02	150.50	PayPal	Completed	2
3	2024-11-03	200.75	Debit Card	Pending	3
4	2024-11-04	250.00	Bank Transfer	Completed	4
5	2024-11-05	175.25	Credit Card	Failed	5
6	2024-11-06	300.00	Cash	Completed	6
7	2024-11-07	120.50	PayPal	Completed	7
8	2024-11-08	90.00	Debit Card	Pending	8
9	2024-11-09	80.00	Bank Transfer	Completed	9
10	2024-11-10	60.00	Credit Card	Completed	10
11	2024-11-11	110.50	PayPal	Completed	1
12	2024-11-12	130.75	Debit Card	Completed	2
13	2024-11-13	140.00	Bank Transfer	Pending	3
14	2024-11-14	160.25	Cash	Completed	4
15	2024-11-15	190.00	Credit Card	Failed	5
16	2024-11-16	220.50	PayPal	Completed	6
17	2024-11-17	250.75	Debit Card	Completed	7
18	2024-11-18	270.00	Bank Transfer	Pending	8
19	2024-11-19	300.25	Cash	Completed	9
20	2024-11-20	350.00	Credit Card	Completed	10
\.


--
-- Data for Name: pimage; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.pimage (productid, image_url, image_name) FROM stdin;
20	https://drive.google.com/uc?id=1WMKnM-Z6WiseyNZ8qOtbK9FyEgWGR06x	almond-milk
10	https://drive.google.com/uc?id=1pkeoPCA5eEmBlYSnd7xWbK5EYyNX-4op	cheddar_cheese
12	https://drive.google.com/uc?id=1hq0LwAlLS5Ucj1aWKpgXxhSgi6STYKPm	chicken_breast
19	https://drive.google.com/uc?id=1RyrZMqHEQWkpAMt3jccR8CK9fRWR1RgO	kale
4	https://drive.google.com/uc?id=1w4Uo8Ut-g6ly1-eODOlrI5dtUnGzQUIF	grass_fed_beef
1	https://drive.google.com/uc?id=1oUjZsKYK6ozMkYSCGYrLMUSs71UObfmg	organic_apples
15	https://drive.google.com/uc?id=1L6VLXEvlxmTL-Kg7xUQGo_urmkPeOU5-	peaches
8	https://drive.google.com/uc?id=1DuuNsmMUFOEgoP7_Y0pcbX0pOtzGHP7a	zucchini
13	https://drive.google.com/uc?id=1vGKwOpgANaBssw8MkdIHFOujScbDAwka	blueberries
7	https://drive.google.com/uc?id=1I-LooKKhkBokVKmetVCl6vpDNFpXQMXA	honey
16	https://drive.google.com/uc?id=1ZWBg4_P1P66ia6rcymQTwjuGnCo5GFTi	garlic
2	https://drive.google.com/uc?id=1ku7PrR4CgJOfzZNmQ7CL1Wv_Y3Wl4r7F	fresh_carrots
3	https://drive.google.com/uc?id=1T36UurpbdFUjobj_SPcoDl5__uhpsmWr	free_range_eggs
5	https://drive.google.com/uc?id=1xREtbXeFJ4tmbWq6z6obMSsqeZvE9glw	whole_wheat_bread
6	https://drive.google.com/uc?id=1utZkAu_dTarkwnf0x4LM7o0bl6rmPOyf	tomatoes
11	https://drive.google.com/uc?id=1b6AppMjeo5PyjQ5j4g42m8bKKBQeSZLK	spinach
14	https://drive.google.com/uc?id=1oqCLBqI_Ix9pr4PmDNa74hvKOoSqiNwY	pumpkins
18	https://drive.google.com/uc?id=1rPEYdfj7uFTBF4IlEVBIufVNrugkboPr	raspberry_jam
17	https://drive.google.com/uc?id=1IzgEDl9VTIUrW6yR6WDCm4rYgdApB2RG	pork_sausages
9	https://drive.google.com/uc?id=14LsdIfqsylPFNNm-1H-Xhx67KXs6aEfT	strawberries
\.


--
-- Data for Name: popular_products; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.popular_products (reportid, productid) FROM stdin;
1	1
2	2
3	3
4	4
5	5
6	6
7	7
8	8
9	9
10	10
11	1
12	2
13	3
14	4
15	5
16	6
17	7
18	8
19	9
20	10
\.


--
-- Data for Name: product; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.product (productid, farmid, name, category, price, quantity, description) FROM stdin;
1	1	Organic Apples	Fruits	2.5	100	Fresh organic apples from Sunny Acres Farm.
2	1	Fresh Carrots	Vegetables	1.2	150	Crisp carrots harvested from Sunny Acres Farm.
3	2	Free-Range Eggs	Dairy	3	200	Eggs from free-range chickens at Green Pastures Farm.
4	2	Grass-Fed Beef	Meat	10	50	High-quality grass-fed beef from Green Pastures Farm.
5	3	Whole Wheat Bread	Bakery	2.75	80	Freshly baked whole wheat bread from Riverbend Farms.
6	3	Tomatoes	Vegetables	1.5	120	Juicy tomatoes grown at Riverbend Farms.
7	4	Honey	Condiments	5	60	Pure honey harvested from Hilltop Harvest Farm.
8	4	Zucchini	Vegetables	1.8	90	Fresh zucchini picked from Hilltop Harvest Farm.
9	5	Strawberries	Fruits	3.5	110	Sweet strawberries from Meadow View Farm.
10	5	Cheddar Cheese	Dairy	4.5	70	Aged cheddar cheese made at Meadow View Farm.
11	1	Spinach	Vegetables	2	140	Organic spinach harvested from Sunny Acres Farm.
12	2	Chicken Breast	Meat	8	60	Boneless chicken breast from Green Pastures Farm.
13	3	Blueberries	Fruits	4	130	Fresh blueberries picked at Riverbend Farms.
14	4	Pumpkins	Vegetables	3.25	75	Locally grown pumpkins from Hilltop Harvest Farm.
15	5	Peaches	Fruits	3.75	90	Juicy peaches from Meadow View Farm.
16	1	Garlic	Vegetables	1.5	160	Organic garlic from Sunny Acres Farm.
17	2	Pork Sausages	Meat	6.5	40	Homemade pork sausages from Green Pastures Farm.
18	3	Raspberry Jam	Condiments	5.5	30	Homemade raspberry jam from Riverbend Farms.
19	4	Kale	Vegetables	2.25	110	Fresh kale harvested from Hilltop Harvest Farm.
20	5	Almond Milk	Dairy	3.25	80	Nutritious almond milk produced at Meadow View Farm.
\.


--
-- Data for Name: received_by; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.received_by (notificationid, userid) FROM stdin;
1	1
2	2
3	3
4	4
5	5
6	6
7	7
8	8
9	9
10	10
\.


--
-- Data for Name: reports; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.reports (reportid, date, type, time_period_start, time_period_end) FROM stdin;
1	2024-01-01	Monthly Sales Report	2024-01-01	2024-01-31
2	2024-02-01	Inventory Report	2024-02-01	2024-02-28
3	2024-03-01	Buyer Report	2024-03-01	2024-03-31
4	2024-04-01	Popular Products Report	2024-04-01	2024-04-30
5	2024-05-01	Annual Sales Report	2024-05-01	2023-05-31
6	2024-06-01	Monthly Revenue Report	2024-06-01	2024-06-30
7	2024-07-01	Seasonal Product Report	2024-07-01	2024-07-31
8	2024-08-01	Customer Feedback Report	2024-08-01	2024-08-31
9	2024-09-01	Sales Forecast Report	2024-09-01	2024-09-30
10	2024-10-01	Market Trends Report	2024-10-01	2024-10-31
11	2024-11-01	Quarterly Sales Analysis	2024-10-01	2024-12-31
12	2024-12-01	Product Performance Review	2023-12-01	2023-12-31
13	2025-01-01	Supplier Evaluation Report	2025-01-01	2025-03-31
14	2025-02-01	Sales Channel Performance	2025-02-01	2025-02-28
15	2025-03-01	Customer Retention Analysis	2025-03-01	2025-03-31
16	2025-04-01	Annual Financial Summary	2025-04-01	2025-04-30
17	2025-05-01	New Product Launch Report	2025-05-01	2025-05-31
18	2025-06-01	Marketing Campaign Effectiveness	2025-06-01	2025-06-30
19	2025-07-01	Sales Growth Analysis	2025-07-01	2025-07-31
20	2025-08-01	Operational Efficiency Report	2025-08-01	2025-08-31
\.


--
-- Data for Name: sales_report; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.sales_report (reportid, farmerid, total_sales, revenue) FROM stdin;
1	1	150	1200.00
2	2	200	1800.50
3	3	175	1500.75
4	4	220	2100.25
5	5	130	1100.00
6	1	160	1300.50
7	2	190	1600.00
8	3	210	1900.75
9	4	180	1700.00
10	5	140	1150.25
11	1	155	1250.00
12	2	205	1850.00
13	3	165	1400.50
14	4	230	2200.00
15	5	120	1000.00
16	1	175	1550.75
17	2	195	1650.25
18	3	185	1555.50
19	4	215	2050.00
20	5	145	1205.00
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.users (userid, email, name, phone_number, password, username) FROM stdin;
1	john.doe@example.com	John Doe	5551234567	password1	johndoe
2	jane.smith@example.com	Jane Smith	5552345678	password2	janesmith
3	michael.johnson@example.com	Michael Johnson	5553456789	password3	michaeljohnson
4	emily.brown@example.com	Emily Brown	5554567890	password4	emilybrown
5	david.wilson@example.com	David Wilson	5555678901	password5	davidwilson
6	sarah.jones@example.com	Sarah Jones	5556789012	password6	sarahjones
7	chris.miller@example.com	Chris Miller	5557890123	password7	chrismiller
8	linda.davis@example.com	Linda Davis	5558901234	password8	lindadavis
9	robert.garcia@example.com	Robert Garcia	5559012345	password9	robertgarcia
10	patricia.martinez@example.com	Patricia Martinez	5550123456	password10	patriciamartinez
11	james.lopez@example.com	James Lopez	5551357924	password11	jameslopez
12	mary.gonzalez@example.com	Mary Gonzalez	5552468135	password12	marygonzalez
13	william.perez@example.com	William Perez	5553579246	password13	williamperez
14	elizabeth.thompson@example.com	Elizabeth Thompson	5554681357	password14	elizabethtompson
15	charles.white@example.com	Charles White	5555792468	password15	charleswhite
16	jessica.harris@example.com	Jessica Harris	5556803579	password16	jessicaharris
17	thomas.clark@example.com	Thomas Clark	5557914680	password17	thomasclark
18	susan.lewis@example.com	Susan Lewis	5558025791	password18	susanlewis
19	daniel.robinson@example.com	Daniel Robinson	5559136802	password19	danielrobinson
20	kimberly.walker@example.com	Kimberly Walker	5550247913	password20	kimberlywalker
\.


--
-- Name: buyer_buyerid_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.buyer_buyerid_seq', 1, false);


--
-- Name: cart_cartid_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.cart_cartid_seq', 1, false);


--
-- Name: chat_chatid_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.chat_chatid_seq', 1, false);


--
-- Name: delivery_deliveryid_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.delivery_deliveryid_seq', 1, false);


--
-- Name: farm_farmid_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.farm_farmid_seq', 1, false);


--
-- Name: farmer_farmerid_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.farmer_farmerid_seq', 1, false);


--
-- Name: inventory_item_itemid_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.inventory_item_itemid_seq', 1, false);


--
-- Name: message_messageid_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.message_messageid_seq', 1, false);


--
-- Name: negotiations_negotiationid_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.negotiations_negotiationid_seq', 10, true);


--
-- Name: notification_notificationid_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.notification_notificationid_seq', 1, false);


--
-- Name: orderu_orderid_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.orderu_orderid_seq', 1, false);


--
-- Name: payment_paymentid_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.payment_paymentid_seq', 1, false);


--
-- Name: product_productid_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.product_productid_seq', 1, false);


--
-- Name: reports_reportid_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.reports_reportid_seq', 1, false);


--
-- Name: users_userid_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.users_userid_seq', 1, false);


--
-- Name: adds_to adds_to_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.adds_to
    ADD CONSTRAINT adds_to_pkey PRIMARY KEY (buyerid);


--
-- Name: administrator administrator_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.administrator
    ADD CONSTRAINT administrator_pkey PRIMARY KEY (userid);


--
-- Name: buyer buyer_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.buyer
    ADD CONSTRAINT buyer_pkey PRIMARY KEY (buyerid);


--
-- Name: buyer_report buyer_report_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.buyer_report
    ADD CONSTRAINT buyer_report_pkey PRIMARY KEY (reportid);


--
-- Name: cart cart_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cart
    ADD CONSTRAINT cart_pkey PRIMARY KEY (cartid);


--
-- Name: chat chat_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.chat
    ADD CONSTRAINT chat_pkey PRIMARY KEY (chatid);


--
-- Name: communication communication_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.communication
    ADD CONSTRAINT communication_pkey PRIMARY KEY (chatid);


--
-- Name: created_from created_from_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.created_from
    ADD CONSTRAINT created_from_pkey PRIMARY KEY (orderid);


--
-- Name: delivered_by delivered_by_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.delivered_by
    ADD CONSTRAINT delivered_by_pkey PRIMARY KEY (orderid);


--
-- Name: delivery delivery_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.delivery
    ADD CONSTRAINT delivery_pkey PRIMARY KEY (deliveryid);


--
-- Name: document document_filename_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.document
    ADD CONSTRAINT document_filename_key UNIQUE (filename);


--
-- Name: document document_filepath_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.document
    ADD CONSTRAINT document_filepath_key UNIQUE (filepath);


--
-- Name: document document_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.document
    ADD CONSTRAINT document_pkey PRIMARY KEY (farmerid);


--
-- Name: farm farm_location_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.farm
    ADD CONSTRAINT farm_location_key UNIQUE (location);


--
-- Name: farm farm_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.farm
    ADD CONSTRAINT farm_pkey PRIMARY KEY (farmid);


--
-- Name: farmer farmer_govid_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.farmer
    ADD CONSTRAINT farmer_govid_key UNIQUE (govid);


--
-- Name: farmer farmer_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.farmer
    ADD CONSTRAINT farmer_pkey PRIMARY KEY (farmerid);


--
-- Name: included_in included_in_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.included_in
    ADD CONSTRAINT included_in_pkey PRIMARY KEY (productid, cartid);


--
-- Name: inventory_item inventory_item_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.inventory_item
    ADD CONSTRAINT inventory_item_name_key UNIQUE (name);


--
-- Name: inventory_item inventory_item_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.inventory_item
    ADD CONSTRAINT inventory_item_pkey PRIMARY KEY (itemid);


--
-- Name: inventory_item inventory_item_type_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.inventory_item
    ADD CONSTRAINT inventory_item_type_key UNIQUE (type);


--
-- Name: inventory_report inventory_report_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.inventory_report
    ADD CONSTRAINT inventory_report_pkey PRIMARY KEY (reportid);


--
-- Name: message message_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.message
    ADD CONSTRAINT message_pkey PRIMARY KEY (messageid);


--
-- Name: negotiations negotiations_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.negotiations
    ADD CONSTRAINT negotiations_pkey PRIMARY KEY (negotiationid);


--
-- Name: notification notification_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.notification
    ADD CONSTRAINT notification_pkey PRIMARY KEY (notificationid);


--
-- Name: orderu orderu_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.orderu
    ADD CONSTRAINT orderu_pkey PRIMARY KEY (orderid);


--
-- Name: payment payment_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.payment
    ADD CONSTRAINT payment_pkey PRIMARY KEY (paymentid);


--
-- Name: pimage pimage_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pimage
    ADD CONSTRAINT pimage_pkey PRIMARY KEY (image_name);


--
-- Name: popular_products popular_products_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.popular_products
    ADD CONSTRAINT popular_products_pkey PRIMARY KEY (reportid, productid);


--
-- Name: product product_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.product
    ADD CONSTRAINT product_name_key UNIQUE (name);


--
-- Name: product product_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.product
    ADD CONSTRAINT product_pkey PRIMARY KEY (productid);


--
-- Name: received_by received_by_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.received_by
    ADD CONSTRAINT received_by_pkey PRIMARY KEY (notificationid, userid);


--
-- Name: reports reports_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.reports
    ADD CONSTRAINT reports_pkey PRIMARY KEY (reportid);


--
-- Name: sales_report sales_report_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sales_report
    ADD CONSTRAINT sales_report_pkey PRIMARY KEY (reportid);


--
-- Name: users users_email_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key UNIQUE (email);


--
-- Name: users users_phone_number_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_phone_number_key UNIQUE (phone_number);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (userid);


--
-- Name: users users_username_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key UNIQUE (username);


--
-- Name: adds_to adds_to_buyerid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.adds_to
    ADD CONSTRAINT adds_to_buyerid_fkey FOREIGN KEY (buyerid) REFERENCES public.buyer(buyerid);


--
-- Name: adds_to adds_to_cartid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.adds_to
    ADD CONSTRAINT adds_to_cartid_fkey FOREIGN KEY (cartid) REFERENCES public.cart(cartid);


--
-- Name: administrator administrator_userid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.administrator
    ADD CONSTRAINT administrator_userid_fkey FOREIGN KEY (userid) REFERENCES public.users(userid);


--
-- Name: buyer_report buyer_report_buyerid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.buyer_report
    ADD CONSTRAINT buyer_report_buyerid_fkey FOREIGN KEY (buyerid) REFERENCES public.buyer(buyerid);


--
-- Name: buyer_report buyer_report_most_purchased_farm_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.buyer_report
    ADD CONSTRAINT buyer_report_most_purchased_farm_fkey FOREIGN KEY (most_purchased_farm) REFERENCES public.farm(farmid);


--
-- Name: buyer_report buyer_report_most_purchased_product_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.buyer_report
    ADD CONSTRAINT buyer_report_most_purchased_product_fkey FOREIGN KEY (most_purchased_product) REFERENCES public.product(productid);


--
-- Name: buyer_report buyer_report_reportid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.buyer_report
    ADD CONSTRAINT buyer_report_reportid_fkey FOREIGN KEY (reportid) REFERENCES public.reports(reportid);


--
-- Name: buyer buyer_userid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.buyer
    ADD CONSTRAINT buyer_userid_fkey FOREIGN KEY (userid) REFERENCES public.users(userid);


--
-- Name: communication communication_buyerid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.communication
    ADD CONSTRAINT communication_buyerid_fkey FOREIGN KEY (buyerid) REFERENCES public.buyer(buyerid);


--
-- Name: communication communication_chatid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.communication
    ADD CONSTRAINT communication_chatid_fkey FOREIGN KEY (chatid) REFERENCES public.chat(chatid);


--
-- Name: communication communication_farmerid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.communication
    ADD CONSTRAINT communication_farmerid_fkey FOREIGN KEY (farmerid) REFERENCES public.farmer(farmerid);


--
-- Name: created_from created_from_cartid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.created_from
    ADD CONSTRAINT created_from_cartid_fkey FOREIGN KEY (cartid) REFERENCES public.cart(cartid);


--
-- Name: created_from created_from_orderid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.created_from
    ADD CONSTRAINT created_from_orderid_fkey FOREIGN KEY (orderid) REFERENCES public.orderu(orderid);


--
-- Name: delivered_by delivered_by_deliveryid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.delivered_by
    ADD CONSTRAINT delivered_by_deliveryid_fkey FOREIGN KEY (deliveryid) REFERENCES public.delivery(deliveryid);


--
-- Name: delivered_by delivered_by_orderid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.delivered_by
    ADD CONSTRAINT delivered_by_orderid_fkey FOREIGN KEY (orderid) REFERENCES public.orderu(orderid);


--
-- Name: document document_farmerid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.document
    ADD CONSTRAINT document_farmerid_fkey FOREIGN KEY (farmerid) REFERENCES public.farmer(farmerid);


--
-- Name: farm farm_farmerid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.farm
    ADD CONSTRAINT farm_farmerid_fkey FOREIGN KEY (farmerid) REFERENCES public.farmer(farmerid);


--
-- Name: farmer farmer_userid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.farmer
    ADD CONSTRAINT farmer_userid_fkey FOREIGN KEY (userid) REFERENCES public.users(userid);


--
-- Name: included_in included_in_cartid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.included_in
    ADD CONSTRAINT included_in_cartid_fkey FOREIGN KEY (cartid) REFERENCES public.cart(cartid);


--
-- Name: included_in included_in_productid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.included_in
    ADD CONSTRAINT included_in_productid_fkey FOREIGN KEY (productid) REFERENCES public.product(productid);


--
-- Name: inventory_item inventory_item_farmid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.inventory_item
    ADD CONSTRAINT inventory_item_farmid_fkey FOREIGN KEY (farmid) REFERENCES public.farm(farmid);


--
-- Name: inventory_report inventory_report_farmerid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.inventory_report
    ADD CONSTRAINT inventory_report_farmerid_fkey FOREIGN KEY (farmerid) REFERENCES public.farmer(farmerid);


--
-- Name: inventory_report inventory_report_reportid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.inventory_report
    ADD CONSTRAINT inventory_report_reportid_fkey FOREIGN KEY (reportid) REFERENCES public.reports(reportid);


--
-- Name: message message_chatid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.message
    ADD CONSTRAINT message_chatid_fkey FOREIGN KEY (chatid) REFERENCES public.chat(chatid);


--
-- Name: message message_receiverid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.message
    ADD CONSTRAINT message_receiverid_fkey FOREIGN KEY (receiverid) REFERENCES public.users(userid);


--
-- Name: message message_senderid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.message
    ADD CONSTRAINT message_senderid_fkey FOREIGN KEY (senderid) REFERENCES public.users(userid);


--
-- Name: negotiations negotiations_buyerid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.negotiations
    ADD CONSTRAINT negotiations_buyerid_fkey FOREIGN KEY (buyerid) REFERENCES public.buyer(buyerid);


--
-- Name: negotiations negotiations_farmerid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.negotiations
    ADD CONSTRAINT negotiations_farmerid_fkey FOREIGN KEY (farmerid) REFERENCES public.farmer(farmerid);


--
-- Name: notification notification_recipientid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.notification
    ADD CONSTRAINT notification_recipientid_fkey FOREIGN KEY (recipientid) REFERENCES public.users(userid);


--
-- Name: orderu orderu_buyerid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.orderu
    ADD CONSTRAINT orderu_buyerid_fkey FOREIGN KEY (buyerid) REFERENCES public.buyer(buyerid);


--
-- Name: orderu orderu_cartid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.orderu
    ADD CONSTRAINT orderu_cartid_fkey FOREIGN KEY (cartid) REFERENCES public.cart(cartid);


--
-- Name: orderu orderu_paymentid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.orderu
    ADD CONSTRAINT orderu_paymentid_fkey FOREIGN KEY (paymentid) REFERENCES public.payment(paymentid);


--
-- Name: payment payment_buyerid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.payment
    ADD CONSTRAINT payment_buyerid_fkey FOREIGN KEY (buyerid) REFERENCES public.buyer(buyerid);


--
-- Name: pimage pimage_productid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pimage
    ADD CONSTRAINT pimage_productid_fkey FOREIGN KEY (productid) REFERENCES public.product(productid);


--
-- Name: popular_products popular_products_productid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.popular_products
    ADD CONSTRAINT popular_products_productid_fkey FOREIGN KEY (productid) REFERENCES public.product(productid);


--
-- Name: popular_products popular_products_reportid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.popular_products
    ADD CONSTRAINT popular_products_reportid_fkey FOREIGN KEY (reportid) REFERENCES public.reports(reportid);


--
-- Name: product product_farmid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.product
    ADD CONSTRAINT product_farmid_fkey FOREIGN KEY (farmid) REFERENCES public.farm(farmid);


--
-- Name: received_by received_by_notificationid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.received_by
    ADD CONSTRAINT received_by_notificationid_fkey FOREIGN KEY (notificationid) REFERENCES public.notification(notificationid);


--
-- Name: received_by received_by_userid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.received_by
    ADD CONSTRAINT received_by_userid_fkey FOREIGN KEY (userid) REFERENCES public.users(userid);


--
-- Name: sales_report sales_report_farmerid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sales_report
    ADD CONSTRAINT sales_report_farmerid_fkey FOREIGN KEY (farmerid) REFERENCES public.farmer(farmerid);


--
-- Name: sales_report sales_report_reportid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sales_report
    ADD CONSTRAINT sales_report_reportid_fkey FOREIGN KEY (reportid) REFERENCES public.reports(reportid);


--
-- PostgreSQL database dump complete
--

