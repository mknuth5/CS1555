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
            select cid,reservation_number,cost,flight_date,departure_time,arrival_time,high_price,low_price,airline_abbreviation,frequent_miles from reservation_detail natural join reservation natural join customer natural join flight natural join airline natural join price
            where reservation_number in (select reservation_number  from reservation_detail
                                        where flight_number in (select flight_number from flight natural join price
                                                                  where flight.departure_city = new.departure_city and flight.arrival_city=new.arrival_city));
        for i in select distinct reservation_number from affectedRess loop
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
                                raise notice 'adding freq miles';
                                tripcost=tripcost+f.low_price*.9;
                            else
                                tripcost=tripcost+f.low_price;
                                raise notice '%',tripcost;
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

update price set high_price=200 where departure_city = 'PIT' and arrival_city='JFK';

CREATE OR REPLACE FUNCTION updateFlyer()
    RETURNS TRIGGER AS
$$
DECLARE
    newCid integer;
    numLegs integer;
    cidMax integer;
    firstTie integer;
    secondTie integer;
    priceMax integer;
BEGIN
    --drop view if exists tiebreaker;
    create or replace view tiebreaker as
        select count(airline_id),airline_id,cid from reservations_customers_details
        where cid = new.cid group by cid,airline_id
        having count(airline_id) = (select max(countLegs) from (select count(airline_id) as countLegs from reservations_customers_details where cid = new.cid group by cid,airline_id ORDER BY count(airline_id) DESC) as legs);
    select count(*) into firstTie from tiebreaker;
    IF(firstTie = 1) then
        update customer set frequent_miles = (select airline_abbreviation from tiebreaker natural join airline) where cid = new.cid;
    end if;
    IF(firstTie > 1) then
        drop materialized view if exists tiebreaker2;
        create materialized view tiebreaker2 as select * from airlineprice where cid = new.cid and price = (select max(a.price) from tiebreaker natural join airline inner join airlineprice a on airline.airline_abbreviation = a.airline_abbreviation and tiebreaker.cid = a.cid);
        select count(*) into secondTie from tiebreaker2;
        IF(secondTie = 1) then
            update customer set frequent_miles = (select airline_abbreviation from tiebreaker2) where cid = new.cid;
        end if;
        IF(secondTie > 1) then
            select * from tiebreaker2;
            drop materialized view if exists tiebreaker2;
            create materialized view tiebreaker3 as select airline_abbreviation,frequent_miles from tiebreaker2 natural join reservation natural join reservation_detail natural join flight natural join airline natural join customer where cid = new.cid and airline_abbreviation = frequent_miles;
            IF((select count(*) from tiebreaker3) = 0) then
                update customer set frequent_miles = (select airline_abbreviation from tiebreaker2 limit 1) where cid = new.cid;
            end if;
        end if;
    end if;


END;
$$ LANGUAGE plpgsql;


Drop trigger if exists frequentFlyer on reservation;
create trigger frequentFlyer
    after update
    on reservation
    for each row
    execute function updateFlyer();

update reservation set ticketed=false where cid = 1;

--4
select flight_number, departure_time, arrival_time from flight where departure_city = 'PIT' and arrival_city='JFK';

select * from flight where departure_city = 'PIT';
Select * from flight where arrival_city = 'LAX';
--Then compare each arrival and departure city and connect ones with same city

--5.
select flight_number, departure_time, arrival_time,airline_name
from flight natural left join airline
where departure_city = 'PIT' and arrival_city='JFK' and airline_name='alaska Airlines';

--6
select *
from flight natural join reservation_detail;

--11
select *
from reservation natural left join reservation_detail
    natural left join flight
    left join price on (flight.departure_city,flight.arrival_city)=(price.departure_city,price.arrival_city);

--Figure out cost
select cid,reservation_number,frequent_miles,airline_abbreviation,flight_date,departure_time,arrival_time,high_price,low_price
from reservation_detail natural join reservation natural join flight natural join airline natural join price natural join customer;

drop table airlinePrice;
create table airlinePrice(
    cid integer,
    airline_abbreviation varchar,
    price float,
    primary key (cid,airline_abbreviation),
    foreign key (cid) references customer(cid),
    foreign key (airline_abbreviation) references airline(airline_abbreviation)
);

select cid from airlineprice where airline_abbreviation='ALASKA' order by price desc limit 2;
select * from airlineprice where airline_abbreviation='DELTA';



update airlinePrice set price=price+300 where cid = 3 and airline_abbreviation='DELTA';

insert into airlinePrice select 3,'DELTA',300 where not exists(select 1 from airlinePrice where cid=3 and airline_abbreviation='DELTA');

create or replace procedure getPricing(cid)
 language plpgsql
 as
    $$
declare
    cur cursor for  select *
                    from reservation_detail natural join reservation natural join flight natural join airline natural join price natural join customer
                    where cid = cid;
    start date;

begin
    select flight_date into start from cur.next();

end;
    $$;

select getPricing();


--12
select count(airline_id) as cnt,cid
from reservation natural left join reservation_detail natural left join flight natural join airline
where airline_id = ?
group by reservation_number
order by cnt desc
limit ?;

select * from reservation natural left join reservation_detail natural left join flight natural join airline;

--13
select airline_id, count(reservation_number) as cnt
from reservation natural left join reservation_detail natural left join flight natural join airline
where ticketed
group by airline_id
order by cnt desc;

