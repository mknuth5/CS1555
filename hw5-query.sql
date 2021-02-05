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
SELECT getCancellationTime(1);


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
--TEST: Check that Function is working as expected
SELECT getNumberOfSeats(3,
                        TO_TIMESTAMP('2020-11-05 14:15:00', 'YYYY-MM-DD HH24:MI')::timestamp without time zone); -- should return 2
-- Returns true if the plane is full for a specific flight and datetime
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
SELECT isPlaneFull(1,
                   TO_TIMESTAMP('2020-11-02 13:55:00', 'YYYY-MM-DD HH24:MI')::timestamp without time zone); -- should return false
SELECT isPlaneFull(1, TO_TIMESTAMP('2020-11-02 13:56:00', 'YYYY-MM-DD HH24:MI')::timestamp without time zone);
-- should return true with error message


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

SELECT validateReservationInfo(1, 1); -- should return true
SELECT validateReservationInfo(1, 4); -- should return false

-- Get a letter if there is a flight or '-' if there isn't one
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
SELECT getDayLetterFromSchedule(TO_DATE('2020-11-03', 'YYYY-MM-DD'), 1); -- should return T
SELECT getDayLetterFromSchedule(TO_DATE('2020-11-01', 'YYYY-MM-DD'), 1); -- should return S

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
SELECT getCalculatedDepartureDate(TO_DATE('2020-11-03', 'YYYY-MM-DD'), 1); -- should return M

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
BEGIN;
CALL makeReservation(4, 1, to_date('11-01-2020', 'MM-DD-YYYY'), 3); -- ok
END;
BEGIN;
CALL makeReservation(5, 1, to_date('11-01-2020', 'MM-DD-YYYY'), 3); -- Error
END;


DELETE FROM AIRLINE WHERE airline_id =10;
