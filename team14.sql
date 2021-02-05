--Q1
DROP TABLE IF EXISTS AIRLINE CASCADE;
DROP TABLE IF EXISTS FLIGHT CASCADE;
DROP TABLE IF EXISTS PLANE CASCADE;
DROP TABLE IF EXISTS PRICE CASCADE;
DROP TABLE IF EXISTS CUSTOMER CASCADE;
DROP TABLE IF EXISTS RESERVATION CASCADE;
DROP TABLE IF EXISTS RESERVATION_DETAIL CASCADE;
DROP TABLE IF EXISTS OURTIMESTAMP CASCADE;
DROP TABLE IF EXISTS AIRLINEPRICE CASCADE;
DROP DOMAIN IF EXISTS EMAIL_DOMAIN CASCADE;

--Note: This is a simplified email domain and is not intended to exhaustively check for all requirements of an email
CREATE DOMAIN EMAIL_DOMAIN AS varchar(30)
    CHECK ( value ~ '^[a-zA-Z0-9.!#$%&''*+\/=?^_`{|}~\-]+@(?:[a-zA-Z0-9\-]+\.)+[a-zA-Z0-9\-]+$' );

CREATE TABLE AIRLINE (
  airline_id            integer,
  airline_name          varchar(50)     NOT NULL,
  airline_abbreviation  varchar(10)     NOT NULL,
  year_founded          integer         NOT NULL,
  CONSTRAINT AIRLINE_PK PRIMARY KEY (airline_id),
  CONSTRAINT AIRLINE_UQ1 UNIQUE (airline_name),
  CONSTRAINT AIRLINE_UQ2 UNIQUE (airline_abbreviation)
);

CREATE TABLE PLANE (
    plane_type      char(4),
    manufacturer    varchar(10)     NOT NULL,
    plane_capacity  integer         NOT NULL,
    last_service    date            NOT NULL,
    year            integer         NOT NULL,
    owner_id        integer         NOT NULL,
    CONSTRAINT PLANE_PK PRIMARY KEY (plane_type,owner_id),
    CONSTRAINT PLANE_FK FOREIGN KEY (owner_id) REFERENCES AIRLINE(airline_id)
);

CREATE TABLE FLIGHT (
    flight_number   integer,
    airline_id      integer     NOT NULL,
    plane_type      char(4)     NOT NULL,
    departure_city  char(3)     NOT NULL,
    arrival_city    char(3)     NOT NULL,
    departure_time  varchar(4)  NOT NULL,
    arrival_time    varchar(4)  NOT NULL,
    weekly_schedule varchar(7)  NOT NULL,
    CONSTRAINT FLIGHT_PK PRIMARY KEY (flight_number),
    CONSTRAINT FLIGHT_FK1 FOREIGN KEY (plane_type,airline_id) REFERENCES PLANE(plane_type,owner_id),
    CONSTRAINT FLIGHT_FK2 FOREIGN KEY (airline_id) REFERENCES AIRLINE(airline_id),
    CONSTRAINT FLIGHT_UQ UNIQUE (departure_city, arrival_city)
);

CREATE TABLE PRICE (
    departure_city  char(3),
    arrival_city    char(3),
    airline_id      integer,
    high_price      integer     NOT NULL,
    low_price       integer     NOT NULL,
    CONSTRAINT PRICE_PK PRIMARY KEY (departure_city, arrival_city),
    CONSTRAINT PRICE_FK FOREIGN KEY (airline_id) REFERENCES AIRLINE(airline_id),
    CONSTRAINT PRICE_CHECK_HIGH CHECK (high_price >= 0),
    CONSTRAINT PRICE_CHECK_LOW CHECK (low_price >= 0)
);

--Assuming salutation can be NULL as many people don't use salutations on online forms
--Assuming last_name can be NULL as not everyone has a last name, like Cher
--Assuming phone is optional (can be NULL) but email is required
--Assuming that duplicate first_name and last_name pairs are possible since cid will be unique
--Assuming that email addresses should be unique in the table since multiple customers shouldn't sign up with
---the same email
CREATE TABLE CUSTOMER (
    cid                 integer,
    salutation          varchar(3),
    first_name          varchar(30)     NOT NULL,
    last_name           varchar(30),
    credit_card_num     varchar(16)     NOT NULL,
    credit_card_expire  date            NOT NULL,
    street              varchar(30)     NOT NULL,
    city                varchar(30)     NOT NULL,
    state               varchar(2)      NOT NULL,
    phone               varchar(10),
    email               EMAIL_DOMAIN    NOT NULL,
    frequent_miles      varchar(10),
    CONSTRAINT CUSTOMER_PK PRIMARY KEY (cid),
    CONSTRAINT CUSTOMER_FK FOREIGN KEY (frequent_miles) REFERENCES AIRLINE(airline_abbreviation),
    CONSTRAINT CUSTOMER_CCN CHECK (credit_card_num ~ '\d{16}'),
    CONSTRAINT CUSTOMER_UQ1 UNIQUE (credit_card_num),
    CONSTRAINT CUSTOMER_UQ2 UNIQUE (email)
);

--Assuming that a customer can make multiple reservations, i.e., cid and credit_card_num are not unique here
---since multiple reservations will have unique reservation_numbers
CREATE TABLE RESERVATION (
  reservation_number    integer,
  cid                   integer     NOT NULL,
  cost                  decimal     NOT NULL,
  credit_card_num       varchar(16) NOT NULL,
  reservation_date      timestamp   NOT NULL,
  ticketed              boolean     NOT NULL    DEFAULT FALSE,
  CONSTRAINT RESERVATION_PK PRIMARY KEY (reservation_number),
  CONSTRAINT RESERVATION_FK1 FOREIGN KEY (cid) REFERENCES CUSTOMER(cid),
  CONSTRAINT RESERVATION_FK2 FOREIGN KEY (credit_card_num) REFERENCES CUSTOMER(credit_card_num),
  CONSTRAINT RESERVATION_COST CHECK (cost >= 0)
);

CREATE TABLE RESERVATION_DETAIL (
  reservation_number    integer,
  flight_number         integer     NOT NULL,
  flight_date           timestamp   NOT NULL,
  leg                   integer,
  CONSTRAINT RESERVATION_DETAIL_PK PRIMARY KEY (reservation_number, leg),
  CONSTRAINT RESERVATION_DETAIL_FK1 FOREIGN KEY (reservation_number) REFERENCES RESERVATION(reservation_number) ON DELETE CASCADE,
  CONSTRAINT RESERVATION_DETAIL_FK2 FOREIGN KEY (flight_number) REFERENCES FLIGHT(flight_number),
  CONSTRAINT RESERVATION_DETAIL_CHECK_LEG CHECK (leg > 0)
);

-- The c_timestamp is initialized once using INSERT and updated subsequently
CREATE TABLE OURTIMESTAMP (
    c_timestamp     timestamp,
    CONSTRAINT OURTIMESTAMP_PK PRIMARY KEY (c_timestamp)
);

create table airlinePrice(
    cid integer,
    airline_abbreviation varchar,
    price float,
    primary key (cid,airline_abbreviation),
    foreign key (cid) references customer(cid),
    foreign key (airline_abbreviation) references airline(airline_abbreviation)
);


INSERT INTO AIRLINE (airline_id, airline_name, airline_abbreviation, year_founded)
VALUES (1, 'Alaska Airlines', 'ALASKA', 1932);
INSERT INTO AIRLINE (airline_id, airline_name, airline_abbreviation, year_founded)
VALUES (2, 'Allegiant Air', 'ALLEGIANT', 1997);
INSERT INTO AIRLINE (airline_id, airline_name, airline_abbreviation, year_founded)
VALUES (3, 'American Airlines', 'AMERICAN', 1926);
INSERT INTO AIRLINE (airline_id, airline_name, airline_abbreviation, year_founded)
VALUES (4, 'Delta Air Lines', 'DELTA', 1924);
INSERT INTO AIRLINE (airline_id, airline_name, airline_abbreviation, year_founded)
VALUES (5, 'United Airlines', 'UNITED', 1926);


--INSERT values of PLANE Table

INSERT INTO PLANE (plane_type, manufacturer, plane_capacity, last_service, year, owner_id)
VALUES ('A320', 'Airbus', 186, TO_DATE('11-03-2020', 'MM-DD-YYYY'), 1988, 1);
INSERT INTO PLANE (plane_type, manufacturer, plane_capacity, last_service, year, owner_id)
VALUES ('E175', 'Embraer', 76, TO_DATE('10-22-2020', 'MM-DD-YYYY'), 2004, 2);
INSERT INTO PLANE (plane_type, manufacturer, plane_capacity, last_service, year, owner_id)
VALUES ('B737', 'Boeing', 125, TO_DATE('09-09-2020', 'MM-DD-YYYY'), 2006, 3);
INSERT INTO PLANE (plane_type, manufacturer, plane_capacity, last_service, year, owner_id)
VALUES ('E145', 'Embraer', 50, TO_DATE('06-15-2020', 'MM-DD-YYYY'), 2018, 4);
INSERT INTO PLANE (plane_type, manufacturer, plane_capacity, last_service, year, owner_id)
VALUES ('B777', 'Boeing', 368, TO_DATE('09-16-2020', 'MM-DD-YYYY'), 1995, 5);


--INSERT values of FLIGHT Table

INSERT INTO FLIGHT (flight_number, airline_id, plane_type, departure_city, arrival_city, departure_time, arrival_time,
                    weekly_schedule)
VALUES (1, 1, 'A320', 'PIT', 'JFK', '1355', '1730', 'SMTWTFS');
INSERT INTO FLIGHT (flight_number, airline_id, plane_type, departure_city, arrival_city, departure_time, arrival_time,
                    weekly_schedule)
VALUES (2, 2, 'E175', 'JFK', 'LAX', '0825', '1845', '-MTWTFS');
INSERT INTO FLIGHT (flight_number, airline_id, plane_type, departure_city, arrival_city, departure_time, arrival_time,
                    weekly_schedule)
VALUES (3, 3, 'B737', 'LAX', 'SEA', '1415', '1725', 'SMT-TFS');
INSERT INTO FLIGHT (flight_number, airline_id, plane_type, departure_city, arrival_city, departure_time, arrival_time,
                    weekly_schedule)
VALUES (4, 4, 'E145', 'SEA', 'IAH', '1005', '2035', 'SMTW--S');
INSERT INTO FLIGHT (flight_number, airline_id, plane_type, departure_city, arrival_city, departure_time, arrival_time,
                    weekly_schedule)
VALUES (5, 5, 'B777', 'IAH', 'PIT', '0630', '1620', '-MTW--S');


--INSERT values of PRICE Table

INSERT INTO PRICE (departure_city, arrival_city, airline_id, high_price, low_price)
VALUES ('PIT', 'JFK', 1, 300, 165);
INSERT INTO PRICE (departure_city, arrival_city, airline_id, high_price, low_price)
VALUES ('JFK', 'LAX', 2, 480, 345);
INSERT INTO PRICE (departure_city, arrival_city, airline_id, high_price, low_price)
VALUES ('LAX', 'SEA', 3, 380, 270);
INSERT INTO PRICE (departure_city, arrival_city, airline_id, high_price, low_price)
VALUES ('SEA', 'IAH', 4, 515, 365);
INSERT INTO PRICE (departure_city, arrival_city, airline_id, high_price, low_price)
VALUES ('IAH', 'PIT', 5, 435, 255);
INSERT INTO PRICE (departure_city, arrival_city, airline_id, high_price, low_price)
VALUES ('JFK', 'PIT', 1, 440, 315);
INSERT INTO PRICE (departure_city, arrival_city, airline_id, high_price, low_price)
VALUES ('LAX', 'PIT', 2, 605, 420);
INSERT INTO PRICE (departure_city, arrival_city, airline_id, high_price, low_price)
VALUES ('SEA', 'LAX', 3, 245, 150);
INSERT INTO PRICE (departure_city, arrival_city, airline_id, high_price, low_price)
VALUES ('IAH', 'SEA', 4, 395, 260);
INSERT INTO PRICE (departure_city, arrival_city, airline_id, high_price, low_price)
VALUES ('PIT', 'IAH', 5, 505, 350);


--INSERT values of CUSTOMER Table

INSERT INTO CUSTOMER (cid, salutation, first_name, last_name, credit_card_num, credit_card_expire, street, city, state,
                      phone, email, frequent_miles)
VALUES (1, 'Mr', 'Jon', 'Smith', '6859941825383380', TO_DATE('04-13-2022', 'MM-DD-YYYY'), 'Bigelow Boulevard',
        'Pittsburgh', 'PA', '412222222', 'jsmith@gmail.com', 'ALASKA');
INSERT INTO CUSTOMER (cid, salutation, first_name, last_name, credit_card_num, credit_card_expire, street, city, state,
                      phone, email, frequent_miles)
VALUES (2, 'Mrs', 'Latanya', 'Wood', '7212080255339668', TO_DATE('07-05-2023', 'MM-DD-YYYY'), 'Houston Street',
        'New York', 'NY', '7187181717', 'lw@aol.com', 'ALLEGIANT');
INSERT INTO CUSTOMER (cid, salutation, first_name, last_name, credit_card_num, credit_card_expire, street, city, state,
                      phone, email, frequent_miles)
VALUES (3, 'Ms', 'Gabriella', 'Rojas', '4120892825130802', TO_DATE('09-22-2024', 'MM-DD-YYYY'), 'Melrose Avenue',
        'Los Angeles', 'CA', '2133234567', 'gar@yahoo.com', 'AMERICAN');
INSERT INTO CUSTOMER (cid, salutation, first_name, last_name, credit_card_num, credit_card_expire, street, city, state,
                      phone, email, frequent_miles)
VALUES (4, 'Mr', 'Abbas', 'Malouf', '4259758505178751', TO_DATE('10-17-2021', 'MM-DD-YYYY'), 'Pine Street', 'Seattle',
        'WA', '2066170345', 'malouf.a@outlook.com', 'DELTA');
INSERT INTO CUSTOMER (cid, salutation, first_name, last_name, credit_card_num, credit_card_expire, street, city, state,
                      phone, email, frequent_miles)
VALUES (5, 'Ms', 'Amy', 'Liu', '2538244543760285', TO_DATE('03-24-2022', 'MM-DD-YYYY'), 'Amber Drive', 'Houston', 'TX',
        '2818880102', 'amyliu45@icloud.com', 'UNITED');


--INSERT values of RESERVATION Table

INSERT INTO RESERVATION (reservation_number, cid, cost, credit_card_num, reservation_date, ticketed)
VALUES (1, 1, 1160, '6859941825383380', TO_TIMESTAMP('11-02-2020 10:55', 'MM-DD-YYYY HH24:MI'), TRUE);
INSERT INTO RESERVATION (reservation_number, cid, cost, credit_card_num, reservation_date, ticketed)
VALUES (2, 2, 620, '7212080255339668', TO_TIMESTAMP('11-22-2020 14:25', 'MM-DD-YYYY HH24:MI'), TRUE);
INSERT INTO RESERVATION (reservation_number, cid, cost, credit_card_num, reservation_date, ticketed)
VALUES (3, 3, 380, '4120892825130802', TO_TIMESTAMP('11-05-2020 17:20', 'MM-DD-YYYY HH24:MI'), FALSE);
INSERT INTO RESERVATION (reservation_number, cid, cost, credit_card_num, reservation_date, ticketed)
VALUES (4, 4, 255, '4259758505178751', TO_TIMESTAMP('12-01-2020 06:05', 'MM-DD-YYYY HH24:MI'), TRUE);
INSERT INTO RESERVATION (reservation_number, cid, cost, credit_card_num, reservation_date, ticketed)
VALUES (5, 5, 615, '2538244543760285', TO_TIMESTAMP('10-28-2020 22:45', 'MM-DD-YYYY HH24:MI'), FALSE);


--INSERT values of RESERVATION_DETAIL Table

INSERT INTO RESERVATION_DETAIL (reservation_number, flight_number, flight_date, leg)
VALUES (1, 1, TO_TIMESTAMP('11-02-2020 13:55', 'MM-DD-YYYY HH24:MI'), 1);
INSERT INTO RESERVATION_DETAIL (reservation_number, flight_number, flight_date, leg)
VALUES (1, 2, TO_TIMESTAMP('11-04-2020 08:25', 'MM-DD-YYYY HH24:MI'), 2);
INSERT INTO RESERVATION_DETAIL (reservation_number, flight_number, flight_date, leg)
VALUES (1, 3, TO_TIMESTAMP('11-05-2020 14:15', 'MM-DD-YYYY HH24:MI'), 3);
INSERT INTO RESERVATION_DETAIL (reservation_number, flight_number, flight_date, leg)
VALUES (2, 4, TO_TIMESTAMP('12-14-2020 10:05', 'MM-DD-YYYY HH24:MI'), 1);
INSERT INTO RESERVATION_DETAIL (reservation_number, flight_number, flight_date, leg)
VALUES (2, 5, TO_TIMESTAMP('12-15-2020 06:30', 'MM-DD-YYYY HH24:MI'), 2);
INSERT INTO RESERVATION_DETAIL (reservation_number, flight_number, flight_date, leg)
VALUES (3, 3, TO_TIMESTAMP('11-05-2020 14:15', 'MM-DD-YYYY HH24:MI'), 1);
INSERT INTO RESERVATION_DETAIL (reservation_number, flight_number, flight_date, leg)
VALUES (4, 5, TO_TIMESTAMP('12-15-2020 06:30', 'MM-DD-YYYY HH24:MI'), 1);
INSERT INTO RESERVATION_DETAIL (reservation_number, flight_number, flight_date, leg)
VALUES (5, 2, TO_TIMESTAMP('11-04-2020 08:25', 'MM-DD-YYYY HH24:MI'), 1);
INSERT INTO RESERVATION_DETAIL (reservation_number, flight_number, flight_date, leg)
VALUES (5, 3, TO_TIMESTAMP('11-05-2020 14:15', 'MM-DD-YYYY HH24:MI'), 2);


--INSERT values of OURTIMESTAMP Table
BEGIN;
INSERT INTO OURTIMESTAMP (c_timestamp)
VALUES (TO_TIMESTAMP('11-05-2020 02:15', 'MM-DD-YYYY HH24:MI'));
COMMIT;

BEGIN;
UPDATE OURTIMESTAMP
SET c_timestamp = TO_TIMESTAMP('11-03-2020 20:25', 'MM-DD-YYYY HH24:MI')
WHERE c_timestamp =  TO_TIMESTAMP('11-05-2020 02:15', 'MM-DD-YYYY HH24:MI');
COMMIT;

BEGIN;
UPDATE OURTIMESTAMP
SET c_timestamp = TO_TIMESTAMP('12-13-2020 22:05', 'MM-DD-YYYY HH24:MI')
WHERE c_timestamp =  TO_TIMESTAMP('11-03-2020 20:25', 'MM-DD-YYYY HH24:MI');
COMMIT;
--Q2 getCancellationTime Function
CREATE OR REPLACE FUNCTION getCancellationTime(reservation_num integer)
    RETURNS timestamp AS
$$
DECLARE
    cancellation_time timestamp;
BEGIN
    SELECT (flight_date - INTERVAL '12 hours')
    INTO cancellation_time
    FROM RESERVATION_DETAIL
    WHERE reservation_number = reservation_num
      AND LEG = 1; -- ALTERNATIVE: ORDER BY flight_date FETCH FIRST ROW ONLY;

    RETURN cancellation_time;
END;
$$ LANGUAGE plpgsql;

--TEST: Check that the function is working properly as expected
-- SELECT getCancellationTime(1);


--Q3 isPlaneFull Function

-- Q3 Helper function
-- Gets the number of reservations for a specific flight and datetime
-- Returns NULL if the flight or/and the timestamp do not exist
CREATE OR REPLACE FUNCTION getNumberOfSeats(flight_num integer, flight_time timestamp)
    RETURNS INTEGER AS
$$
DECLARE
    result integer;
BEGIN
    SELECT COUNT(reservation_number)
    INTO result
    FROM reservation_detail
    WHERE flight_number = flight_num
      AND flight_date::timestamp::date = flight_time::timestamp::date
    GROUP BY flight_number, flight_date;

    RETURN result;
END;
$$ language plpgsql;
-- --TEST: Check that Function is working as expected
-- SELECT getNumberOfSeats(3,
--                         TO_TIMESTAMP('2020-11-05 14:15:00', 'YYYY-MM-DD HH24:MI')::timestamp without time zone); -- should return 2
-- -- Returns true if the plane is full for a specific flight and datetime
CREATE OR REPLACE FUNCTION isPlaneFull(flight_num integer, flight_d timestamp)
    RETURNS BOOLEAN AS
$$
DECLARE
    max_capacity     integer;
    current_capacity integer;
    result           BOOLEAN := TRUE;
BEGIN
    --Get appropriate plane's capacity
    SELECT plane_capacity
    INTO max_capacity
    FROM PLANE AS P
             NATURAL JOIN (SELECT plane_type
                           FROM FLIGHT
                           WHERE FLIGHT.flight_number = flight_num) AS F;

    --Get number of seats filled on flight
    current_capacity = getNumberOfSeats(flight_num, flight_d);

    IF current_capacity IS NULL THEN
        RAISE 'No matching flight.';
    ELSEIF current_capacity < max_capacity THEN
        result := FALSE;
    END IF;

    RETURN result;
END;
$$ LANGUAGE plpgsql;

--TEST: Check this function is working as expected
-- SELECT isPlaneFull(1,
--                    TO_TIMESTAMP('2020-11-02 13:55:00', 'YYYY-MM-DD HH24:MI')::timestamp without time zone); -- should return false
-- SELECT isPlaneFull(1, TO_TIMESTAMP('2020-11-02 13:56:00', 'YYYY-MM-DD HH24:MI')::timestamp without time zone);
-- -- should return true with error message


-- Q4 makeReservation Procedure

-- Q4 Helper Functions
-- Check if the reservation exit and if the flight exist
CREATE OR REPLACE FUNCTION validateReservationInfo(reservation_num integer, flight_num integer)
    RETURNS BOOLEAN AS
$$
DECLARE
    reservation_exist BOOLEAN := FALSE;
    flight_exist      BOOLEAN := FALSE;
    result            BOOLEAN := FALSE;
BEGIN
    SELECT (reservation_number = reservation_num)
    INTO reservation_exist
    FROM reservation
    WHERE reservation_number = reservation_num;

    SELECT (flight_number = flight_num)
    INTO flight_exist
    FROM flight
    WHERE flight_number = flight_num;

    IF (reservation_exist IS NULL OR flight_exist IS NULL) THEN
        result := FALSE;
    ELSE
        result := reservation_exist AND flight_exist;
    END IF;

    RETURN result;
END;
$$ LANGUAGE plpgsql;

--TEST: Check this function is working as expected

-- SELECT validateReservationInfo(1, 1); -- should return true
-- SELECT validateReservationInfo(1, 4); -- should return false
--
-- -- Get a letter if there is a flight or '-' if there isn't one
CREATE OR REPLACE FUNCTION getDayLetterFromSchedule(departure_date date, flight_num integer)
    RETURNS VARCHAR AS
$$
DECLARE
    day_of_week integer;
    weekly      varchar(7);
    day         varchar(1);
BEGIN
    SELECT EXTRACT(dow FROM departure_date) INTO day_of_week;

    SELECT weekly_schedule
    INTO weekly
    FROM FLIGHT AS F
    WHERE F.flight_number = flight_num;

    --CAUTION: substring function is one-index based and not zero
    SELECT substring(weekly from (day_of_week + 1) for 1) INTO day;

    RETURN day;
END;
$$ language plpgsql;

--TEST: Check this function is working as expected
-- SELECT getDayLetterFromSchedule(TO_DATE('2020-11-03', 'YYYY-MM-DD'), 1); -- should return T
-- SELECT getDayLetterFromSchedule(TO_DATE('2020-11-01', 'YYYY-MM-DD'), 1); -- should return S

-- Calculate the departure time based on the date and the flight schedule
CREATE OR REPLACE FUNCTION getCalculatedDepartureDate(departure_date date, flight_num integer)
    RETURNS timestamp AS
$$
DECLARE
    flight_time varchar(5);
BEGIN
    SELECT (substring(DEPT_TABLE.departure_time from 1 for 2) || ':' ||
            substring(DEPT_TABLE.departure_time from 3 for 2))
    INTO flight_time
    FROM (SELECT departure_time
          FROM FLIGHT AS F
          WHERE F.flight_number = flight_num) AS DEPT_TABLE;

    RETURN to_timestamp(departure_date || ' ' || flight_time, 'YYYY-MM-DD HH24:MI');
END;
$$ language plpgsql;

--TEST: Check this function is working as expected
-- SELECT getCalculatedDepartureDate(TO_DATE('2020-11-03', 'YYYY-MM-DD'), 1); -- should return M

-- Q4 makeReservation Procedure
CREATE OR REPLACE PROCEDURE makeReservation(reservation_num integer, flight_num integer, departure_date date,
                                            leg_trip integer)
AS
$$
DECLARE
    information_valid      BOOLEAN := FALSE;
    calculated_flight_date timestamp;
    day                    varchar(1);
BEGIN

    -- make sure arguments are valid
    information_valid = validateReservationInfo(reservation_num, flight_num);

    IF (NOT information_valid) THEN
        RAISE EXCEPTION 'reservation number and/or flight number not valid';
    END IF;

    -- get the letter day from flight schedule corresponding to customer desired departure
    day = getDayLetterFromSchedule(departure_date, flight_num);

    IF day = '-' THEN
        RAISE EXCEPTION 'no available flights on desired departure day';
    END IF;

    -- check flight schedule to get the exact flight_date
    calculated_flight_date = getCalculatedDepartureDate(departure_date, flight_num);

    if isPlaneFull(flight_num,calculated_flight_date) then
        Raise exception 'Flight is full';
    end if;

    -- make the reservation
    INSERT INTO RESERVATION_DETAIL (reservation_number, flight_number, flight_date, leg)
    VALUES (reservation_num, flight_num, calculated_flight_date, leg_trip);
END;
$$ LANGUAGE plpgsql;

--TEST: make a reservation to check procedure
-- BEGIN;
-- CALL makeReservation(4, 1, to_date('11-01-2020', 'MM-DD-YYYY'), 3); -- ok
-- END;
-- BEGIN;
-- CALL makeReservation(5, 1, to_date('11-01-2020', 'MM-DD-YYYY'), 3); -- Error
-- END;
--hw5-triggers.sql

--Q5 planeUpgrade Trigger
--Trigger Function for upgrading Plane
CREATE OR REPLACE PROCEDURE upgradePlaneHelper(flight_num integer, flight_time timestamp) AS
$$
DECLARE
    numberOfSeats    integer;
    upgradeFound     boolean := FALSE;
    currentPlaneType varchar(4);
    airplane_row     RECORD;
    airlinePlanes CURSOR FOR
        SELECT p.plane_type, p.plane_capacity
        FROM flight f
                 JOIN plane p ON f.airline_id = p.owner_id
        WHERE f.flight_number = flight_num
        ORDER BY plane_capacity;
BEGIN
    -- get number of seats for the flight
    numberOfSeats = getNumberOfSeats(flight_num, flight_time);
    raise notice '% number of seats for %', numberOfSeats, flight_num;

    -- get plane type
    SELECT plane_type
    INTO currentPlaneType
    FROM flight
    WHERE flight_number = flight_num;

    -- open cursor
    OPEN airlinePlanes;

    -- check if another plane owned by the airlines can fit current seats
    LOOP
        -- get next plane
        FETCH airlinePlanes INTO airplane_row;
        --exit when done
        EXIT WHEN NOT FOUND;

        -- found a plane can fit (we are starting from the smallest)
        IF numberOfSeats IS NULL OR numberOfSeats + 1 <= airplane_row.plane_capacity THEN
            upgradeFound := TRUE;
            raise notice '% should be upgraded', flight_num;
            -- if the next smallest plane can fit is not the one already scheduled for the flight, then change it
            IF airplane_row.plane_type <> currentPlaneType THEN
                raise notice '% is being upgraded to %', flight_num, airplane_row.plane_type;
                UPDATE flight SET plane_type = airplane_row.plane_type WHERE flight_number = flight_num;
            END IF;
            -- mission accomplished (either we changed the plane OR it is already the next smallest we can fit)
            EXIT;
        END IF;

    END LOOP;

    -- close cursor
    CLOSE airlinePlanes;
    IF NOT upgradeFound THEN
        RAISE EXCEPTION 'There is not any upgrade for the flight % on %',flight_num,flight_time;
    END IF;
END;
$$ language plpgsql;


CREATE OR REPLACE FUNCTION upgradePlane()
    RETURNS TRIGGER AS
$$
BEGIN
    raise notice '% is attempting upgrading', new.flight_number;
    -- downgrade plane in case it is upgradable
    CALL upgradePlaneHelper(new.flight_number, new.flight_date);
    RETURN NEW;
END;
$$ language plpgsql;

DROP TRIGGER IF EXISTS upgradePlane ON RESERVATION_DETAIL;
CREATE TRIGGER upgradePlane
    BEFORE INSERT
    ON RESERVATION_DETAIL
    FOR EACH ROW
EXECUTE PROCEDURE upgradePlane();

--TEST: Check the trigger upgradePlane

-- INSERT INTO plane (plane_type, manufacturer, plane_capacity, last_service, year, owner_id)
-- VALUES ('t001', 'Plane 01', 1, '2020-12-12', 2020, 3);
-- INSERT INTO plane (plane_type, manufacturer, plane_capacity, last_service, year, owner_id)
-- VALUES ('t002', 'Plane 02', 2, '2020-12-12', 2020, 3);
-- INSERT INTO plane (plane_type, manufacturer, plane_capacity, last_service, year, owner_id)
-- VALUES ('t003', 'Plane 03', 3, '2020-12-12', 2020, 3);
-- UPDATE flight
-- SET plane_type = 't001'
-- WHERE flight_number = 3;
--



--Q6 cancelReservation Trigger
CREATE OR REPLACE PROCEDURE downgradePlaneHelper(flight_num integer, flight_time timestamp)
AS
$$
DECLARE
    numberOfSeats    integer;
    currentPlaneType varchar(4);
    airplane_row     RECORD;
    airlinePlanes CURSOR FOR
        SELECT p.plane_type, p.plane_capacity
        FROM flight f
                 JOIN plane p ON f.airline_id = p.owner_id
        WHERE f.flight_number = flight_num
        ORDER BY plane_capacity;
BEGIN
    -- get number of seats for the flight
    numberOfSeats = getNumberOfSeats(flight_num, flight_time);
    raise notice '% number of seats for %', numberOfSeats, flight_num;

    -- get plane type
    SELECT plane_type
    INTO currentPlaneType
    FROM flight
    WHERE flight_number = flight_num;

    -- open cursor
    OPEN airlinePlanes;

    -- check if another plane owned by the airlines can fit current seats
    LOOP
        -- get next plane
        FETCH airlinePlanes INTO airplane_row;
        --exit when done
        EXIT WHEN NOT FOUND;

        -- found a plane can fit (we are starting from the smallest)
        IF numberOfSeats - 1 <= airplane_row.plane_capacity THEN
            raise notice '% should be downgraded', flight_num;
            -- if the smallest plane can fit is not the one already scheduled for the flight, then change it
            IF airplane_row.plane_type <> currentPlaneType THEN
                raise notice '% is beign downgraded to %', flight_num, airplane_row.plane_type;
                UPDATE flight SET plane_type = airplane_row.plane_type WHERE flight_number = flight_num;
            END IF;
            -- mission accomplished (either we changed the plane OR it is already the smallest we can fit)
            EXIT;
        END IF;

    END LOOP;

    -- close cursor
    CLOSE airlinePlanes;

END;
$$ language plpgsql;

CREATE OR REPLACE FUNCTION downgradePlane()
    RETURNS TRIGGER AS
$$
BEGIN
    raise notice '% is attempting downgrading', new.flight_number;
    -- downgrade plane in case it is upgradable
    CALL downgradePlaneHelper(new.flight_number, new.flight_date);
    RETURN NEW;
END;
$$ language plpgsql;

Drop trigger if exists planeDowngrade on reservation_detail;
create trigger planeDowngrade
    after delete
    on reservation_detail
    for each row
    execute procedure downgradePlane();


CREATE OR REPLACE FUNCTION reservationCancellation()
    RETURNS TRIGGER AS
$$
DECLARE
    currentTime      timestamp;
    cancellationTime timestamp;
    reservation_row  RECORD;
    reservations CURSOR FOR
        SELECT *
        FROM (SELECT DISTINCT reservation_number
              FROM RESERVATION AS R
              WHERE R.ticketed = FALSE) AS NONTICKETED
                 NATURAL JOIN (SELECT DISTINCT reservation_number, flight_date, flight_number
                               FROM RESERVATION_DETAIL AS RD
                               WHERE (RD.flight_date >= currentTime)) AS CANCELLABLEFLIGHT ;
BEGIN
    -- capture our simulated current time
    currentTime := new.c_timestamp;

    -- open cursor
    OPEN reservations;

    LOOP
        -- get the next reservation number that is not ticketed
        FETCH reservations INTO reservation_row;

        -- exit loop when all records are processed
        EXIT WHEN NOT FOUND;

        -- get the cancellation time for the fetched reservation
        cancellationTime = getcancellationtime(reservation_row.reservation_number);
        raise notice 'cancellationTime = % and currentTime = %', cancellationTime,currentTime;
        -- delete customer reservation if departures is less than or equal 12 hrs
        IF (cancellationTime <= currentTime) THEN
            raise notice '% is being cancelled', reservation_row.reservation_number;
            -- delete the reservation
            DELETE FROM RESERVATION WHERE reservation_number = reservation_row.reservation_number;
            raise notice '% is attempting downgrading', reservation_row.flight_number;
            CALL downgradePlaneHelper(reservation_row.flight_number, reservation_row.flight_date);
        END IF;

    END LOOP;

    -- close cursor
    CLOSE reservations;

    RETURN new;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS cancelReservation ON ourtimestamp;
CREATE TRIGGER cancelReservation
    AFTER UPDATE
    ON OURTIMESTAMP
    FOR EACH ROW
EXECUTE PROCEDURE reservationCancellation();

--Trigger for adjustTicket

create or replace function adjustReservationCost()
    returns trigger as
    $$
    Declare

    Begin
        select ticketed from price p inner join airline a on p.airline_id = a.airline_id inner join flight f on a.airline_id = f.airline_id inner join reservation_detail rd on f.flight_number = rd.flight_number inner join reservation r on rd.reservation_number = r.reservation_number where p.departure_city = new.departure_city AND p.arrival_city = new.arrival_city;
    end;
    $$ language plpgsql;


drop trigger if exists adjustTicket on price;
create trigger adjustTicket
    before update
    on price
    for each row
    execute procedure adjustReservationCost();


--Trigger for frequentFlyer

CREATE OR REPLACE FUNCTION updateFlyer()
    RETURNS TRIGGER AS
$$
DECLARE
    airlineAbv varchar(10);
BEGIN
    if(new.ticketed is true and old.ticketed is false) then
        drop table if exists tiebreaker;
        drop table if exists ties;
        create temp table tiebreaker as select * from customer c natural join reservation r natural join reservation_detail rd natural join flight f natural join airline a where cid = new.cid;
        create temp table ties as select airline_id from tiebreaker group by airline_id having count(airline_id) = (select max(counts) from (select count(airline_id) as counts,airline_id from tiebreaker group by airline_id) as nums);
        if((select count(*) from ties) = 1) then
            update customer set frequent_miles = (select a2.airline_abbreviation from ties inner join airline a2 on ties.airline_id = a2.airline_id limit 1) where cid = new.cid;
        else
            if((select count(airline_abbreviation) from (select airline_abbreviation from airlineprice where cid = new.cid and price = (select max(price) from airlineprice where cid = new.cid)) as foo) = 1) then
                update customer set frequent_miles = (select airline.airline_abbreviation from ties inner join airline on ties.airline_id = airline.airline_id inner join airlineprice on airline.airline_abbreviation = airlineprice.airline_abbreviation where cid = new.cid and price = (select max(price) from ties inner join airline on ties.airline_id = airline.airline_id inner join airlineprice on airline.airline_abbreviation = airlineprice.airline_abbreviation where cid = new.cid)) where cid = new.cid;
                else
                    if((select count(*) FROM (select airline_abbreviation from airlineprice inner join customer on airlineprice.airline_abbreviation = customer.frequent_miles  where airlineprice.cid = new.cid and customer.cid = new.cid and price = (select max(price) from airlineprice where cid = new.cid)) as duplicates)=1) then
                        update customer set frequent_miles = (select airline_abbreviation from airlineprice inner join customer on airlineprice.airline_abbreviation = customer.frequent_miles  where airlineprice.cid = new.cid and customer.cid = new.cid and price = (select max(price) from airlineprice where cid = new.cid)) where cid = new.cid;
                    else
                        update customer set frequent_miles = (select a3.airline_abbreviation from ties inner join airline a3 on ties.airline_id = a3.airline_id inner join airlineprice a4 on a3.airline_abbreviation = a4.airline_abbreviation where cid = new.cid order by price desc limit 1) where cid = new.cid;
                    end if;
                end if;
        end if;
    end if;
    return new;
end;

$$ LANGUAGE plpgsql;



Drop trigger if exists frequentFlyer on reservation;
create trigger frequentFlyer
    after update
    on reservation
    for each row
    execute procedure updateFlyer();

update reservation set ticketed = true where cid = 1;


create or replace function adjustPrices()
returns trigger as
    $$
    declare
        i record;
        f record;
        j record;
        tripcost float;
    begin
        tripcost=0;
        drop table if exists affectedress;
        create temporary table affectedRess as
            select cid,reservation_number,cost,flight_date,departure_time,arrival_time,high_price,low_price,airline_abbreviation,frequent_miles,ticketed from reservation_detail natural join reservation natural join customer natural join flight natural join airline natural join price
            where reservation_number in (select reservation_number  from reservation_detail
                                        where flight_number=1);-- in (select flight_number from flight natural join price
                                                               --   where flight.departure_city = new.departure_city and flight.arrival_city=new.arrival_city));
        for i in select distinct reservation_number from affectedRess  where ticketed=false loop
            for f in select * from affectedRess where reservation_number=i.reservation_number loop
                    drop table if exists dates;
                    create temporary table dates as select flight_date from affectedRess where reservation_number=f.reservation_number;
                    if (select distinct count(flight_date::timestamp::date) from dates) = 1 then
                            if f.airline_abbreviation = f.frequent_miles then
                                tripcost=tripcost+f.high_price*.9;
                            else
                                tripcost=tripcost+f.high_price;
                            end if;
                    else
                            if f.airline_abbreviation = f.frequent_miles then
                                tripcost=tripcost+f.low_price*.9;
                            else
                                tripcost=tripcost+f.low_price;
                            end if;
                    end if;
            end loop;
        update reservation set cost = tripcost where cid = (select cid from reservation where reservation_number=f.reservation_number);
        end loop;
    return new;
    end;

    $$ language plpgsql;

drop trigger if exists adjustTicket on price;
create trigger adjustTicket
    after update
    on price
    for each row
    execute function adjustPrices();

-- update reservation set ticketed = true where cid = 3;
-- update price set low_price=165 where departure_city = 'PIT' and arrival_city='JFK';
-- commit;


