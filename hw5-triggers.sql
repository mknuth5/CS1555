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

INSERT INTO plane (plane_type, manufacturer, plane_capacity, last_service, year, owner_id)
VALUES ('t001', 'Plane 01', 1, '2020-12-12', 2020, 3);
INSERT INTO plane (plane_type, manufacturer, plane_capacity, last_service, year, owner_id)
VALUES ('t002', 'Plane 02', 2, '2020-12-12', 2020, 3);
INSERT INTO plane (plane_type, manufacturer, plane_capacity, last_service, year, owner_id)
VALUES ('t003', 'Plane 03', 3, '2020-12-12', 2020, 3);
UPDATE flight
SET plane_type = 't001'
WHERE flight_number = 3;




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

update reservation set ticketed = true where cid = 3;
update price set low_price=165 where departure_city = 'PIT' and arrival_city='JFK';
commit;


