--
-- PostgreSQL database dump
--

-- Dumped from database version 13.2
-- Dumped by pg_dump version 13.2

-- Started on 2021-07-13 09:26:47

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
-- TOC entry 678 (class 1247 OID 58802)
-- Name: flightstatus; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.flightstatus AS ENUM (
    'Waiting',
    'Check-in open',
    'Now boarding',
    'In air',
    'Arrived'
);


ALTER TYPE public.flightstatus OWNER TO postgres;

--
-- TOC entry 675 (class 1247 OID 58795)
-- Name: seatclass; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.seatclass AS ENUM (
    'Economy',
    'Business',
    'First'
);


ALTER TYPE public.seatclass OWNER TO postgres;

--
-- TOC entry 235 (class 1255 OID 58939)
-- Name: change_status(); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.change_status()
    LANGUAGE plpgsql
    AS $$
DECLARE
     cur_info CURSOR FOR select * from get_flights_dates() FOR UPDATE;
	 _flightid int;
	 _departuredate timestamp;
	 _arrivaldate timestamp;
BEGIN
 	OPEN cur_info;
		LOOP
			FETCH FROM cur_info INTO _flightid, _departuredate, _arrivaldate;
			IF NOT FOUND 
				THEN EXIT;
			END IF;
			IF ( (_departuredate - localtimestamp) > '02:00:00')
				THEN UPDATE flights SET status = 'Waiting' WHERE _flightid = flights.flightid;
			END IF;
			IF ( (_departuredate - localtimestamp) <= '02:00:00' AND (_departuredate - localtimestamp) >= '00:30:01')
				THEN UPDATE flights SET status = 'Check-in open' WHERE _flightid = flights.flightid;
			END IF;
			IF ( (_departuredate - localtimestamp) <= '00:30:00' AND (_departuredate - localtimestamp) >= '00:00:01')
				THEN UPDATE flights SET status = 'Now boarding' WHERE _flightid = flights.flightid;
			END IF;
			IF (_departuredate <= localtimestamp)
				THEN UPDATE flights SET status = 'In air' WHERE _flightid = flights.flightid;
			END IF;
			IF (_arrivaldate <= localtimestamp)
				THEN UPDATE flights SET status = 'Arrived' WHERE _flightid = flights.flightid;
			END IF;
		END LOOP;
	CLOSE cur_info;
END;
$$;


ALTER PROCEDURE public.change_status() OWNER TO postgres;

--
-- TOC entry 224 (class 1255 OID 58899)
-- Name: delete_flight(integer); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.delete_flight(_flightid integer)
    LANGUAGE plpgsql
    AS $$
BEGIN
 	DELETE FROM flights WHERE flightid = _flightid;
END;
$$;


ALTER PROCEDURE public.delete_flight(_flightid integer) OWNER TO postgres;

--
-- TOC entry 250 (class 1255 OID 58907)
-- Name: delete_passenger(character varying); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.delete_passenger(_passengerid character varying)
    LANGUAGE plpgsql
    AS $$
BEGIN
 	DELETE FROM passengers WHERE passengerid = _passengerid;
END;
$$;


ALTER PROCEDURE public.delete_passenger(_passengerid character varying) OWNER TO postgres;

--
-- TOC entry 253 (class 1255 OID 58914)
-- Name: delete_refund(integer); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.delete_refund(_refundid integer)
    LANGUAGE plpgsql
    AS $$
BEGIN
 	DELETE FROM refunds WHERE refundid = _refundid;
END;
$$;


ALTER PROCEDURE public.delete_refund(_refundid integer) OWNER TO postgres;

--
-- TOC entry 212 (class 1255 OID 58895)
-- Name: delete_route(integer); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.delete_route(_routeid integer)
    LANGUAGE plpgsql
    AS $$
BEGIN
 	DELETE FROM routs WHERE routeid = _routeid;
END;
$$;


ALTER PROCEDURE public.delete_route(_routeid integer) OWNER TO postgres;

--
-- TOC entry 231 (class 1255 OID 58911)
-- Name: delete_sale(integer); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.delete_sale(_saleid integer)
    LANGUAGE plpgsql
    AS $$
BEGIN
 	DELETE FROM sales WHERE saleid = _saleid;
END;
$$;


ALTER PROCEDURE public.delete_sale(_saleid integer) OWNER TO postgres;

--
-- TOC entry 225 (class 1255 OID 58903)
-- Name: delete_ticket(integer); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.delete_ticket(_ticketid integer)
    LANGUAGE plpgsql
    AS $$
BEGIN
 	DELETE FROM tickets WHERE ticketid = _ticketid;
END;
$$;


ALTER PROCEDURE public.delete_ticket(_ticketid integer) OWNER TO postgres;

--
-- TOC entry 257 (class 1255 OID 58945)
-- Name: drop_user(character varying); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.drop_user(_passengerid character varying)
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
BEGIN
	  	 EXECUTE FORMAT('CALL delete_passenger(''%I'')', _passengerid);
		 EXECUTE FORMAT('REVOKE Client FROM "%I"', _passengerid);
		 EXECUTE FORMAT('REVOKE adm FROM "%I"', _passengerid);
		 EXECUTE FORMAT('DROP USER "%I"', _passengerid);
END;
$$;


ALTER PROCEDURE public.drop_user(_passengerid character varying) OWNER TO postgres;

--
-- TOC entry 259 (class 1255 OID 58943)
-- Name: fill_bill(character varying, integer); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.fill_bill(_passengerid character varying, _amount integer)
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
BEGIN
	IF(_amount > 0)
		THEN UPDATE passengers SET bill = bill + _amount WHERE passengerid = _passengerid;
	END IF;
END;
$$;


ALTER PROCEDURE public.fill_bill(_passengerid character varying, _amount integer) OWNER TO postgres;

--
-- TOC entry 233 (class 1255 OID 58940)
-- Name: get_dif_people(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_dif_people() RETURNS TABLE(_dif_people numeric, _ticketid integer)
    LANGUAGE plpgsql
    AS $$ 
	BEGIN
	 	RETURN QUERY
      	SELECT  CAST( 100 - ((
	  	CAST( F.passengerscount AS numeric ) / 
		CAST( F.ticketscount AS numeric ) * 100)) 
			 AS numeric(3,1)) AS dif_people, Ti.ticketid
			  FROM flights F
			  JOIN tickets Ti On Ti.flightid = F.flightid 
			  WHERE (F.departuredate - localtimestamp) > '02:00:00';
	END
$$;


ALTER FUNCTION public.get_dif_people() OWNER TO postgres;

--
-- TOC entry 237 (class 1255 OID 58938)
-- Name: get_flights_dates(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_flights_dates() RETURNS TABLE(_flightid integer, _departuredate timestamp without time zone, _arrivaldate timestamp without time zone)
    LANGUAGE plpgsql
    AS $$ 
	BEGIN
	 	RETURN QUERY
      	SELECT flightid, departuredate, arrivaldate 
		FROM flights;
	END
$$;


ALTER FUNCTION public.get_flights_dates() OWNER TO postgres;

--
-- TOC entry 234 (class 1255 OID 58947)
-- Name: get_interval(character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_interval(_aircraftnumber character varying) RETURNS interval
    LANGUAGE plpgsql
    AS $$ 
DECLARE
_interval INTERVAL := (SELECT departuredate  - localtimestamp FROM flights WHERE aircraftnumber = _aircraftnumber AND status <> 'Arrived');
	BEGIN
      	RETURN _interval;
	END
$$;


ALTER FUNCTION public.get_interval(_aircraftnumber character varying) OWNER TO postgres;

--
-- TOC entry 230 (class 1255 OID 58934)
-- Name: get_ticket_id(character varying, character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_ticket_id(_placenumber character varying, _aircraftnumber character varying) RETURNS integer
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$ 
	BEGIN
	RETURN( 
      	SELECT Ti.ticketid 
		FROM tickets Ti 
		JOIN flights F ON Ti.flightid = F.flightid  
		WHERE Ti.placenumber = _placenumber
		AND F.aircraftnumber = _aircraftnumber
		AND F.status <> 'Arrived'
		GROUP BY Ti.ticketid);
	END
$$;


ALTER FUNCTION public.get_ticket_id(_placenumber character varying, _aircraftnumber character varying) OWNER TO postgres;

--
-- TOC entry 245 (class 1255 OID 58901)
-- Name: insert_flight(character varying, timestamp without time zone, timestamp without time zone, public.flightstatus, integer, integer, integer); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.insert_flight(_aircraftnumber character varying, _departuredate timestamp without time zone, _arrivaldate timestamp without time zone, _status public.flightstatus, _ticketscount integer, _passengerscount integer, _routeid integer)
    LANGUAGE plpgsql
    AS $$
DECLARE
_validation boolean := validate_flight(_aircraftnumber);
BEGIN
 	INSERT INTO flights(aircraftnumber, departuredate, arrivaldate, status, ticketscount, passengerscount, routeid) VALUES
	(_aircraftnumber, _departuredate, _arrivaldate, _status, _ticketscount, _passengerscount, _routeid);
	
	IF(_validation = false)
		THEN ROLLBACK;
	END IF;
	COMMIT;
END;
$$;


ALTER PROCEDURE public.insert_flight(_aircraftnumber character varying, _departuredate timestamp without time zone, _arrivaldate timestamp without time zone, _status public.flightstatus, _ticketscount integer, _passengerscount integer, _routeid integer) OWNER TO postgres;

--
-- TOC entry 251 (class 1255 OID 58909)
-- Name: insert_passenger(character varying, character varying, character varying, character varying, character, integer); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.insert_passenger(_passengerid character varying, _passportdata character varying, _fullname character varying, _mobilephone character varying, _email character, _bill integer)
    LANGUAGE plpgsql
    AS $$
DECLARE 
_validation boolean := validate_passenger(_passportdata, _fullname, _mobilephone, _email, _bill);
BEGIN
 	INSERT INTO passengers(passengerid, passportdata, fullname, mobilephone, email, bill) VALUES
	(_passengerid, _passportdata, _fullname, _mobilephone, _email, _bill);
	
	IF(_validation = false)
		THEN ROLLBACK;
	END IF;
	COMMIT;	
END;
$$;


ALTER PROCEDURE public.insert_passenger(_passengerid character varying, _passportdata character varying, _fullname character varying, _mobilephone character varying, _email character, _bill integer) OWNER TO postgres;

--
-- TOC entry 254 (class 1255 OID 58915)
-- Name: insert_refund(timestamp without time zone, character varying, integer); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.insert_refund(_refunddate timestamp without time zone, _refundreason character varying, _ticketid integer)
    LANGUAGE plpgsql
    AS $$
BEGIN
 	INSERT INTO refunds(refunddate, refundreason, ticketid) VALUES
	(_refunddate, _refundreason, _ticketid);
END;
$$;


ALTER PROCEDURE public.insert_refund(_refunddate timestamp without time zone, _refundreason character varying, _ticketid integer) OWNER TO postgres;

--
-- TOC entry 243 (class 1255 OID 58897)
-- Name: insert_route(character varying, character varying, character varying, character varying, time without time zone); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.insert_route(_departure character varying, _departureairport character varying, _arrival character varying, _arrivalairport character varying, _traveltime time without time zone)
    LANGUAGE plpgsql
    AS $$
DECLARE
_validation boolean := validate_route(_departure, _departureairport, _arrival, _arrivalairport);
BEGIN
 	INSERT INTO routs(departure, departureairport, arrival, arrivalairport, traveltime) VALUES
	(_departure, _departureairport, _arrival, _arrivalairport, _traveltime);
	
	IF(_validation = false)
		THEN ROLLBACK;
	END IF;
	COMMIT;
END;
$$;


ALTER PROCEDURE public.insert_route(_departure character varying, _departureairport character varying, _arrival character varying, _arrivalairport character varying, _traveltime time without time zone) OWNER TO postgres;

--
-- TOC entry 232 (class 1255 OID 58912)
-- Name: insert_sale(timestamp without time zone, integer, integer); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.insert_sale(_saledate timestamp without time zone, _vat integer, _ticketid integer)
    LANGUAGE plpgsql
    AS $$
BEGIN
 	INSERT INTO sales(saledate, vat, ticketid) VALUES
	(_saledate, _vat, _ticketid);
END;
$$;


ALTER PROCEDURE public.insert_sale(_saledate timestamp without time zone, _vat integer, _ticketid integer) OWNER TO postgres;

--
-- TOC entry 248 (class 1255 OID 58905)
-- Name: insert_ticket(character varying, boolean, integer, public.seatclass, integer, character varying, integer); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.insert_ticket(_placenumber character varying, _reserved boolean, _ticketprice integer, _sclass public.seatclass, _routeid integer, _passengerid character varying, _flightid integer)
    LANGUAGE plpgsql
    AS $$
DECLARE
_validation boolean := validate_ticket(_placenumber, _flightid);
BEGIN
 	INSERT INTO tickets(placenumber, reserved, ticketprice, sclass, routeid, passengerid, flightid) VALUES
	(_placenumber, _reserved, _ticketprice, _sclass, _routeid, _passengerid, _flightid);
	IF(_validation = false)
		THEN ROLLBACK;
	END IF;
	COMMIT;
END;
$$;


ALTER PROCEDURE public.insert_ticket(_placenumber character varying, _reserved boolean, _ticketprice integer, _sclass public.seatclass, _routeid integer, _passengerid character varying, _flightid integer) OWNER TO postgres;

--
-- TOC entry 238 (class 1255 OID 58893)
-- Name: instead_of_update(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.instead_of_update() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
	IF(NEW.aircraftnumber <> OLD.aircraftnumber)     
  	THEN UPDATE flights SET aircraftnumber = NEW.aircraftnumber WHERE flightid = OLD.flightid;
	END IF;
	IF(NEW.placenumber <> OLD.placenumber)     
  	THEN UPDATE tickets SET placenumber = NEW.placenumber WHERE ticketid = OLD.ticketid;
	END IF;
	IF(NEW.ticketprice <> OLD.ticketprice)     
  	THEN UPDATE tickets SET ticketprice = NEW.ticketprice WHERE ticketid = OLD.ticketid;
	END IF;
	IF(NEW.sclass <> OLD.sclass)     
  	THEN UPDATE tickets SET sclass = NEW.sclass WHERE ticketid = OLD.ticketid;
	END IF;
	IF(NEW.fullname <> OLD.fullname)     
  	THEN UPDATE passengers SET fullname = NEW.fullname WHERE passengerid = OLD.passengerid;
	END IF;
	IF(NEW.mobilephone <> OLD.mobilephone)     
  	THEN UPDATE passengers SET mobilephone = NEW.mobilephone WHERE passengerid = OLD.passengerid;
	END IF;
	IF(NEW.email <> OLD.email)     
  	THEN UPDATE passengers SET email = NEW.email WHERE passengerid = OLD.passengerid;
	END IF;
	IF(NEW.ticketid <> OLD.ticketid)     
  	THEN RAISE EXCEPTION 'Can not update ticketid';
	END IF;
	IF(NEW.passengerid <> OLD.passengerid)     
  	THEN RAISE EXCEPTION 'Can not update passengerid';
	END IF;
	IF(NEW.flightid <> OLD.flightid)     
  	THEN RAISE EXCEPTION 'Can not update flightid';
	END IF;
	RETURN NEW;
END;
$$;


ALTER FUNCTION public.instead_of_update() OWNER TO postgres;

--
-- TOC entry 227 (class 1255 OID 58928)
-- Name: is_not_reserved(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.is_not_reserved() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
     BEGIN
	UPDATE tickets
	SET reserved = 'False' WHERE ticketid = NEW.ticketid;
	RETURN NEW;
     END
$$;


ALTER FUNCTION public.is_not_reserved() OWNER TO postgres;

--
-- TOC entry 226 (class 1255 OID 58926)
-- Name: is_reserved(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.is_reserved() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
     BEGIN
	UPDATE tickets
	SET reserved = 'True' WHERE ticketid = NEW.ticketid;
	RETURN NEW;
     END
$$;


ALTER FUNCTION public.is_reserved() OWNER TO postgres;

--
-- TOC entry 256 (class 1255 OID 58941)
-- Name: make_sales(); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.make_sales()
    LANGUAGE plpgsql
    AS $$
DECLARE
     cur_info CURSOR FOR select * from get_dif_people() FOR UPDATE;
	 _dif_people numeric(3,1);
	 _ticketid int;
BEGIN
 	OPEN cur_info;
		LOOP
			FETCH FROM cur_info INTO _dif_people, _ticketid;
			IF NOT FOUND 
				THEN EXIT;
			END IF;
			IF (_dif_people > 40)
				THEN UPDATE tickets SET ticketprice = ticketprice * 0.95 WHERE _ticketid = tickets.ticketid;
			END IF;
		END LOOP;
	CLOSE cur_info;
END;
$$;


ALTER PROCEDURE public.make_sales() OWNER TO postgres;

--
-- TOC entry 261 (class 1255 OID 58936)
-- Name: refund_ticket(character varying, character varying, character varying, character varying); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.refund_ticket(_passengerid character varying, _aircraftnumber character varying, _placenumber character varying, _refundreason character varying)
    LANGUAGE plpgsql
    AS $$
DECLARE 
_ticketid int := get_ticket_id(_placenumber, _aircraftnumber);
_is_reserved boolean := (SELECT reserved FROM tickets Ti WHERE Ti.ticketid = _ticketid);
_time_to_departure interval := (SELECT departuredate  - localtimestamp FROM flights WHERE aircraftnumber = _aircraftnumber);
_ticketprice int := (SELECT ticketprice FROM tickets WHERE ticketid = _ticketid);
_ticketowner varchar(50) := (SELECT passengerid FROM tickets WHERE ticketid = _ticketid);

BEGIN
	UPDATE tickets SET passengerid = NULL WHERE ticketid = _ticketid;
	UPDATE passengers SET bill = bill + _ticketprice WHERE passengerid = _passengerid;

	IF(_ticketid IS NULL)
		THEN RAISE NOTICE 'Билет не был возвращен: билет не существует'; ROLLBACK;
	ELSEIF
		(_is_reserved = false)
		THEN RAISE NOTICE 'Билет не был возвращен: место не зарезервировано'; ROLLBACK;
	ELSEIF
		(_time_to_departure < '00:40:00') 
		THEN RAISE NOTICE 'Билет не был возвращен: рейс отправлен, либо начата регистрация'; ROLLBACK;
	ELSEIF
		(_ticketowner <> _passengerid) 
		THEN RAISE NOTICE 'Билет не был возвращен: вы не владелец данного билета'; ROLLBACK;
	ELSE RAISE NOTICE 'Билет успешно возвращен';
	END IF;

	IF(_is_reserved = true) 
		THEN INSERT INTO refunds(refunddate, refundreason, ticketid) VALUES
					(localtimestamp, 
					 _refundreason, 
					 _ticketid);
	END IF;
	
 	IF((SELECT passengerid FROM tickets WHERE ticketid = _ticketid) IS NOT NULL)
		THEN RAISE NOTICE 'Билет не был возвращен: не удалось открепить пассажира от билета'; ROLLBACK;
	END IF;
 COMMIT;
END;
$$;


ALTER PROCEDURE public.refund_ticket(_passengerid character varying, _aircraftnumber character varying, _placenumber character varying, _refundreason character varying) OWNER TO postgres;

--
-- TOC entry 246 (class 1255 OID 58942)
-- Name: register_user(character varying, character varying, character varying, character varying, character varying, character); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.register_user(_passengerid character varying, _password character varying, _passportdata character varying, _fullname character varying, _mobilephone character varying, _email character)
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
DECLARE 
_validation boolean := validate_passenger(_passportdata, _fullname, _mobilephone, _email, 1);
BEGIN
	IF(_validation <> false)
		THEN EXECUTE FORMAT('CREATE USER "%I" WITH PASSWORD ''%I'' ', _passengerid, _password);
			 EXECUTE FORMAT('GRANT Client TO "%I"', _passengerid);
			 INSERT INTO passengers(passengerid, passportdata, fullname, mobilephone, email, bill) VALUES 
			 (_passengerid, _passportdata, _fullname, _mobilephone, _email, 0);
	END IF;
END;
$$;


ALTER PROCEDURE public.register_user(_passengerid character varying, _password character varying, _passportdata character varying, _fullname character varying, _mobilephone character varying, _email character) OWNER TO postgres;

--
-- TOC entry 260 (class 1255 OID 58935)
-- Name: sale_ticket(character varying, character varying, character varying); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.sale_ticket(_passengerid character varying, _aircraftnumber character varying, _placenumber character varying)
    LANGUAGE plpgsql
    AS $$
DECLARE 
	_ticketid int := get_ticket_id(_placenumber, _aircraftnumber);
	_is_reserved boolean := (SELECT reserved FROM tickets Ti WHERE Ti.ticketid = _ticketid);
	_time_to_departure interval := (SELECT departuredate  - localtimestamp FROM flights WHERE aircraftnumber = _aircraftnumber);
	_VAT int := (SELECT ticketprice FROM tickets WHERE ticketid = _ticketid) * 0.2;
	_ticketprice int := (SELECT ticketprice FROM tickets WHERE ticketid = _ticketid);
BEGIN

	UPDATE tickets SET passengerid = _passengerid
							WHERE ticketid = _ticketid;
	UPDATE passengers SET bill = bill - _ticketprice WHERE passengerid = _passengerid;
	
	IF(_ticketid  IS NULL)
		THEN RAISE NOTICE 'Билет не был продан: билет не существует'; ROLLBACK;
	ELSEIF
		(_is_reserved = true)
		THEN RAISE NOTICE 'Билет не был продан: место уже зарезервировано'; ROLLBACK;
	ELSEIF
		( (SELECT bill from passengers WHERE passengerid = _passengerid) < 0)
	THEN RAISE NOTICE 'Билет не был продан: на счету недостаточно средств'; ROLLBACK;
	ELSEIF
		(_time_to_departure < '00:40:00') 
		THEN RAISE NOTICE 'Билет не был продан: рейс отправлен, либо начата регистрация'; ROLLBACK;
	ELSE RAISE NOTICE 'Билет успешно продан';
	END IF;
	
	IF(
	(_ticketid  IS NOT NULL) AND 
	(SELECT reserved FROM tickets Ti WHERE Ti.ticketid = _ticketid) = false)
		 
	THEN INSERT INTO sales(saledate, VAT, ticketid) VALUES
				(localtimestamp, 
				 _VAT, 
				 _ticketid);
	END IF;
 	IF((SELECT passengerid FROM tickets WHERE ticketid = _ticketid) IS NULL OR
	    (SELECT reserved FROM tickets Ti WHERE Ti.ticketid = _ticketid) = false) 
		THEN RAISE NOTICE 'Билет не был продан: не удалось закрепить билет за пассажиром'; ROLLBACK;
	END IF;
  COMMIT;
END;
$$;


ALTER PROCEDURE public.sale_ticket(_passengerid character varying, _aircraftnumber character varying, _placenumber character varying) OWNER TO postgres;

--
-- TOC entry 229 (class 1255 OID 58932)
-- Name: ticket_changed(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.ticket_changed() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
    BEGIN
        IF (NEW.reserved = 'True') THEN
			UPDATE Flights
            SET passengerscount = passengerscount + 1 WHERE flightid = NEW.flightid;
			RETURN NEW;
        ELSEIF (NEW.reserved = 'False') THEN
			UPDATE Flights
            SET passengerscount = passengerscount - 1 WHERE flightid = NEW.flightid;
            RETURN NEW;
        END IF;
    END
$$;


ALTER FUNCTION public.ticket_changed() OWNER TO postgres;

--
-- TOC entry 228 (class 1255 OID 58930)
-- Name: ticketscount_changed(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.ticketscount_changed() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
    BEGIN
        IF (TG_OP = 'DELETE') THEN
            UPDATE Flights
            SET ticketscount = ticketscount - 1 WHERE flightid = OLD.flightid;
            RETURN OLD;
        ELSEIF (TG_OP = 'INSERT') THEN
            UPDATE Flights
            SET ticketscount = ticketscount + 1 WHERE flightid = NEW.flightid;
            RETURN NEW;
        END IF;
    END
$$;


ALTER FUNCTION public.ticketscount_changed() OWNER TO postgres;

--
-- TOC entry 236 (class 1255 OID 58937)
-- Name: to_usd(integer, numeric); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.to_usd(value integer, amount numeric) RETURNS numeric
    LANGUAGE plpgsql
    AS $$ 
	BEGIN
      	RETURN CAST(value / amount as numeric(7, 2));
	END
$$;


ALTER FUNCTION public.to_usd(value integer, amount numeric) OWNER TO postgres;

--
-- TOC entry 247 (class 1255 OID 58902)
-- Name: update_flight(integer, integer, character varying, timestamp without time zone, timestamp without time zone, public.flightstatus, integer, integer); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.update_flight(_flightid integer, _routeid integer, _aircraftnumber character varying DEFAULT NULL::character varying, _departuredate timestamp without time zone DEFAULT NULL::timestamp without time zone, _arrivaldate timestamp without time zone DEFAULT NULL::timestamp without time zone, _status public.flightstatus DEFAULT NULL::public.flightstatus, _ticketscount integer DEFAULT NULL::integer, _passengerscount integer DEFAULT NULL::integer)
    LANGUAGE plpgsql
    AS $$
DECLARE
_validation boolean := validate_flight(_aircraftnumber);
BEGIN
	UPDATE flights
       SET aircraftnumber  = COALESCE(_aircraftnumber, aircraftnumber),
           departuredate   = COALESCE(_departuredate, departuredate),
           arrivaldate     = COALESCE(_arrivaldate, arrivaldate),
           passengerscount = COALESCE(_passengerscount, passengerscount),
		   ticketscount    = COALESCE(_ticketscount, ticketscount),
		   status          = COALESCE(_status, status),
		   routeid         = COALESCE(_routeid, routeid)
		   WHERE flightid = _flightid;
		   
   IF(_validation = false)
		THEN ROLLBACK;
   END IF; 
   COMMIT;
END;
$$;


ALTER PROCEDURE public.update_flight(_flightid integer, _routeid integer, _aircraftnumber character varying, _departuredate timestamp without time zone, _arrivaldate timestamp without time zone, _status public.flightstatus, _ticketscount integer, _passengerscount integer) OWNER TO postgres;

--
-- TOC entry 262 (class 1255 OID 58910)
-- Name: update_passenger(character varying, character varying, character varying, character varying, character varying, integer); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.update_passenger(_passengerid character varying, _passportdata character varying DEFAULT NULL::character varying, _fullname character varying DEFAULT NULL::character varying, _mobilephone character varying DEFAULT NULL::character varying, _email character varying DEFAULT NULL::character varying, _bill integer DEFAULT NULL::integer)
    LANGUAGE plpgsql
    AS $$
DECLARE 
_validation boolean := validate_passenger(_passportdata, _fullname, _mobilephone, _email, _bill);
BEGIN
	UPDATE passengers
       SET passportdata = COALESCE(_passportdata, passportdata),
           fullname     = COALESCE(_fullname, fullname),
           mobilephone  = COALESCE(_mobilephone, mobilephone),
           email        = COALESCE(_email, email),
		   bill         = COALESCE(_bill, bill)
		   WHERE passengerid = _passengerid;
		   
   IF(_validation = false)
		THEN ROLLBACK;
   END IF;
   COMMIT;	
END;
$$;


ALTER PROCEDURE public.update_passenger(_passengerid character varying, _passportdata character varying, _fullname character varying, _mobilephone character varying, _email character varying, _bill integer) OWNER TO postgres;

--
-- TOC entry 263 (class 1255 OID 58944)
-- Name: update_passenger_data(character varying, character varying, character varying, character varying, character varying); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.update_passenger_data(_passengerid character varying, _passportdata character varying DEFAULT NULL::character varying, _fullname character varying DEFAULT NULL::character varying, _mobilephone character varying DEFAULT NULL::character varying, _email character varying DEFAULT NULL::character varying)
    LANGUAGE plpgsql
    AS $$
DECLARE 
_validation boolean := validate_passenger(_passportdata, _fullname, _mobilephone, _email, 1);
BEGIN
	UPDATE passengers
       SET passportdata = COALESCE(_passportdata, passportdata),
           fullname     = COALESCE(_fullname, fullname),
           mobilephone  = COALESCE(_mobilephone, mobilephone),
           email        = COALESCE(_email, email)
		   WHERE passengerid = _passengerid;
		   
   IF(_validation = false)
		THEN ROLLBACK;
   END IF;
   COMMIT;	
END;
$$;


ALTER PROCEDURE public.update_passenger_data(_passengerid character varying, _passportdata character varying, _fullname character varying, _mobilephone character varying, _email character varying) OWNER TO postgres;

--
-- TOC entry 255 (class 1255 OID 58916)
-- Name: update_refund(integer, integer, timestamp without time zone, character varying); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.update_refund(_refundid integer, _ticketid integer, _refunddate timestamp without time zone DEFAULT NULL::timestamp without time zone, _refundreason character varying DEFAULT NULL::character varying)
    LANGUAGE plpgsql
    AS $$
BEGIN
	UPDATE refunds
       SET refunddate = COALESCE(_refunddate, refunddate),
           refundreason    = _refundreason,
		   ticketid = COALESCE(_ticketid, ticketid)
		   WHERE refundid = _refundid;
END;
$$;


ALTER PROCEDURE public.update_refund(_refundid integer, _ticketid integer, _refunddate timestamp without time zone, _refundreason character varying) OWNER TO postgres;

--
-- TOC entry 244 (class 1255 OID 58898)
-- Name: update_route(integer, character varying, character varying, character varying, character varying, time without time zone); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.update_route(_routeid integer, _departure character varying DEFAULT NULL::character varying, _departureairport character varying DEFAULT NULL::character varying, _arrival character varying DEFAULT NULL::character varying, _arrivalairport character varying DEFAULT NULL::character varying, _traveltime time without time zone DEFAULT NULL::time without time zone)
    LANGUAGE plpgsql
    AS $$
DECLARE
_validation boolean := validate_route(_departure, _departureairport, _arrival, _arrivalairport);
BEGIN
	UPDATE routs
       SET departure        = COALESCE(_departure, departure),
           departureairport = COALESCE(_departureairport, departureairport),
           arrival          = COALESCE(_arrival, arrival),
           arrivalairport   = COALESCE(_arrivalairport, arrivalairport),
		   traveltime       = COALESCE(_traveltime, traveltime)
		   WHERE routeid = _routeid;
		   
    IF(_validation = false)
		THEN ROLLBACK;
	END IF;
	COMMIT;
END;
$$;


ALTER PROCEDURE public.update_route(_routeid integer, _departure character varying, _departureairport character varying, _arrival character varying, _arrivalairport character varying, _traveltime time without time zone) OWNER TO postgres;

--
-- TOC entry 252 (class 1255 OID 58913)
-- Name: update_sale(integer, integer, timestamp without time zone, integer); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.update_sale(_saleid integer, _ticketid integer, _saledate timestamp without time zone DEFAULT NULL::timestamp without time zone, _vat integer DEFAULT NULL::integer)
    LANGUAGE plpgsql
    AS $$
BEGIN
	UPDATE sales
       SET saledate = COALESCE(_saledate, saledate),
           vat    = COALESCE(_vat, vat),
		   ticketid = COALESCE(_ticketid, ticketid)
		   WHERE saleid = _saleid;
END;
$$;


ALTER PROCEDURE public.update_sale(_saleid integer, _ticketid integer, _saledate timestamp without time zone, _vat integer) OWNER TO postgres;

--
-- TOC entry 249 (class 1255 OID 58906)
-- Name: update_ticket(integer, integer, integer, character varying, boolean, integer, public.seatclass, character varying); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.update_ticket(_ticketid integer, _routeid integer, _flightid integer, _placenumber character varying DEFAULT NULL::character varying, _reserved boolean DEFAULT NULL::boolean, _ticketprice integer DEFAULT NULL::integer, _sclass public.seatclass DEFAULT NULL::public.seatclass, _passengerid character varying DEFAULT NULL::character varying)
    LANGUAGE plpgsql
    AS $$
DECLARE
_validation boolean := validate_ticket(_placenumber, -1);
BEGIN
	UPDATE tickets
       SET placenumber = COALESCE(_placenumber, placenumber),
           ticketprice = COALESCE(_ticketprice, ticketprice),
           sclass      = COALESCE(_sclass, sclass),
		   reserved = COALESCE(_reserved, reserved),
		   routeid = COALESCE(_routeid, routeid),
		   flightid = COALESCE(_flightid, flightid),
		   passengerid = _passengerid
		   WHERE ticketid = _ticketid;
		   
    IF(_validation = false)
		THEN ROLLBACK;
	END IF;
	COMMIT;
END;
$$;


ALTER PROCEDURE public.update_ticket(_ticketid integer, _routeid integer, _flightid integer, _placenumber character varying, _reserved boolean, _ticketprice integer, _sclass public.seatclass, _passengerid character varying) OWNER TO postgres;

--
-- TOC entry 258 (class 1255 OID 58946)
-- Name: update_view(integer, character varying, character varying, integer, public.seatclass, character varying, character varying, character varying); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.update_view(_ticketid integer, _aircraftnumber character varying DEFAULT NULL::character varying, _placenumber character varying DEFAULT NULL::character varying, _ticketprice integer DEFAULT NULL::integer, _seatclass public.seatclass DEFAULT NULL::public.seatclass, _fullname character varying DEFAULT NULL::character varying, _mobilephone character varying DEFAULT NULL::character varying, _email character varying DEFAULT NULL::character varying)
    LANGUAGE plpgsql
    AS $$
DECLARE
_flight_validation boolean := validate_flight(_aircraftnumber);
_ticket_validation boolean := validate_ticket(_placenumber, -1);
_passenger_validation boolean := validate_passenger('777777', _fullname, _mobilephone, _email, 0);
BEGIN
	UPDATE tickets_n_passengers_info
       SET aircraftnumber  = COALESCE(_aircraftnumber, aircraftnumber),
           placenumber     = COALESCE(_placenumber, placenumber),
	   	   ticketprice     = COALESCE(_ticketprice, ticketprice),
		   sclass       = COALESCE(_seatclass, sclass),
		   fullname        = COALESCE(_fullname, fullname),
		   mobilephone     = COALESCE(_mobilephone, mobilephone),
		   email           = COALESCE(_email, email)
		   WHERE ticketid = _ticketid;
		   
   IF(_flight_validation = false)
		THEN ROLLBACK;
   ELSEIF(_ticket_validation = false)
   		THEN ROLLBACK;
   ELSEIF(_passenger_validation = false)
   		THEN ROLLBACK;
   END IF; 
   COMMIT;
END;
$$;


ALTER PROCEDURE public.update_view(_ticketid integer, _aircraftnumber character varying, _placenumber character varying, _ticketprice integer, _seatclass public.seatclass, _fullname character varying, _mobilephone character varying, _email character varying) OWNER TO postgres;

--
-- TOC entry 240 (class 1255 OID 58900)
-- Name: validate_flight(character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.validate_flight(_aircraftnumber character varying) RETURNS boolean
    LANGUAGE plpgsql
    AS $$ 
DECLARE
_aircraftnumber_validation boolean := (SELECT _aircraftnumber SIMILAR TO '[A-Z]{1,2}\d+');
	BEGIN
		IF(_aircraftnumber_validation = false) 
			THEN RAISE NOTICE 'Ошибка валидации: неверный формат бортового номера самолета'; RETURN false;
		ELSE RETURN true;
		END IF;
	END
$$;


ALTER FUNCTION public.validate_flight(_aircraftnumber character varying) OWNER TO postgres;

--
-- TOC entry 242 (class 1255 OID 58908)
-- Name: validate_passenger(character varying, character varying, character varying, character, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.validate_passenger(_passportdata character varying, _fullname character varying, _mobilephone character varying, _email character, _bill integer) RETURNS boolean
    LANGUAGE plpgsql
    AS $$ 
DECLARE
_passport_validation boolean := (SELECT _passportdata SIMILAR TO '\d+');
_fullname_validation boolean := (SELECT _fullname SIMILAR TO '[a-zA-Zа-яА-Я\-]+\s[a-zA-Zа-яА-Я\-]+\s{0,1}[a-zA-Zа-яА-Я\-]+');
_phone_validation boolean := (SELECT _mobilephone SIMILAR TO '\+\d+\(\d+\)\d+-\d+-\d+');
_email_validation boolean := (SELECT _email SIMILAR TO '[a-zA-Z\d]+@[a-z]+.[a-z]+');
	BEGIN
		IF(_passport_validation = false) 
			THEN RAISE NOTICE 'Ошибка валидации: неверный формат пасспорта'; RETURN false;
		ELSEIF
			(_fullname_validation = false) 
			THEN RAISE NOTICE 'Ошибка валидации: неверный формат ФИО'; RETURN false;
		ELSEIF
			(_phone_validation = false) 
			THEN RAISE NOTICE 'Ошибка валидации: неверный формат телефона'; RETURN false;
		ELSEIF
			(_email_validation = false) 
			THEN RAISE NOTICE 'Ошибка валидации: неверный формат электронной почты'; RETURN false;
		ELSEIF
			(_bill < 0) 
		THEN RAISE NOTICE 'Ошибка валидации: счет не может быть отрицательным'; RETURN false;
		ELSE RETURN true;
		END IF;
	END
$$;


ALTER FUNCTION public.validate_passenger(_passportdata character varying, _fullname character varying, _mobilephone character varying, _email character, _bill integer) OWNER TO postgres;

--
-- TOC entry 239 (class 1255 OID 58896)
-- Name: validate_route(character varying, character varying, character varying, character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.validate_route(_departure character varying, _departureairport character varying, _arrival character varying, _arrivalairport character varying) RETURNS boolean
    LANGUAGE plpgsql
    AS $$ 
DECLARE
_departure_validation boolean := (SELECT _departure SIMILAR TO '[a-zA-Zа-яА-Я\s\-]+');
_departure_airport_validation boolean := (SELECT _departureairport SIMILAR TO '[a-zA-Zа-яА-Я\-\s\d]+');
_arrival_validation boolean := (SELECT _arrival SIMILAR TO '[a-zA-Zа-яА-Я\-\s]+');
_arrival_airport_validation boolean := (SELECT _arrivalairport SIMILAR TO '[a-zA-Zа-яА-Я\-\s\d]+');
	BEGIN
		IF(_departure_validation = false) 
			THEN RAISE NOTICE 'Ошибка валидации: неверный формат пункта отправления'; RETURN false;
		ELSEIF
			(_departure_airport_validation = false) 
			THEN RAISE NOTICE 'Ошибка валидации: неверный формат аэропорта отправления'; RETURN false;
		ELSEIF
			(_arrival_validation = false) 
			THEN RAISE NOTICE 'Ошибка валидации: неверный формат пункта прибытия'; RETURN false;
		ELSEIF
			(_arrival_airport_validation = false) 
			THEN RAISE NOTICE 'Ошибка валидации: неверный формат аэропорта прибытия'; RETURN false;
		ELSE RETURN true;
		END IF;
	END
$$;


ALTER FUNCTION public.validate_route(_departure character varying, _departureairport character varying, _arrival character varying, _arrivalairport character varying) OWNER TO postgres;

--
-- TOC entry 241 (class 1255 OID 58904)
-- Name: validate_ticket(character varying, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.validate_ticket(_placenumber character varying, _flightid integer) RETURNS boolean
    LANGUAGE plpgsql
    AS $$ 
DECLARE
_placenumber_validation boolean := (SELECT _placenumber SIMILAR TO '\d{1,2}[A-Z]');
_tickets_count int := (SELECT COUNT(ticketid) FROM tickets Ti 
			JOIN flights ON flights.flightid = Ti.flightid 
			WHERE Ti.flightid = _flightid AND Ti.placenumber = _placenumber);
	BEGIN
		IF(_placenumber_validation = false) 
			THEN RAISE NOTICE 'Ошибка валидации: неверный формат посадочного места'; RETURN false;
		ELSEIF
			(_tickets_count <> 0) 
			THEN RAISE NOTICE 'Ошибка валидации: билет с таким посадочным местом уже есть в таблице'; RETURN false;
		ELSE RETURN true;
		END IF;
	END
$$;


ALTER FUNCTION public.validate_ticket(_placenumber character varying, _flightid integer) OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 203 (class 1259 OID 58823)
-- Name: flights; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.flights (
    flightid integer NOT NULL,
    aircraftnumber character varying(10) NOT NULL,
    departuredate timestamp without time zone NOT NULL,
    arrivaldate timestamp without time zone NOT NULL,
    status public.flightstatus NOT NULL,
    ticketscount integer,
    passengerscount integer,
    routeid integer NOT NULL
);


ALTER TABLE public.flights OWNER TO postgres;

--
-- TOC entry 202 (class 1259 OID 58821)
-- Name: flights_flightid_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.flights_flightid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.flights_flightid_seq OWNER TO postgres;

--
-- TOC entry 3156 (class 0 OID 0)
-- Dependencies: 202
-- Name: flights_flightid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.flights_flightid_seq OWNED BY public.flights.flightid;


--
-- TOC entry 204 (class 1259 OID 58834)
-- Name: passengers; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.passengers (
    passengerid character varying(50) NOT NULL,
    passportdata character varying(20) NOT NULL,
    fullname character varying(50) NOT NULL,
    mobilephone character varying(20) NOT NULL,
    email character varying(50) NOT NULL,
    bill integer
);


ALTER TABLE public.passengers OWNER TO postgres;

--
-- TOC entry 210 (class 1259 OID 58877)
-- Name: refunds; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.refunds (
    refundid integer NOT NULL,
    refunddate timestamp without time zone NOT NULL,
    refundreason character varying(50),
    ticketid integer NOT NULL
);


ALTER TABLE public.refunds OWNER TO postgres;

--
-- TOC entry 209 (class 1259 OID 58875)
-- Name: refunds_refundid_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.refunds_refundid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.refunds_refundid_seq OWNER TO postgres;

--
-- TOC entry 3160 (class 0 OID 0)
-- Dependencies: 209
-- Name: refunds_refundid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.refunds_refundid_seq OWNED BY public.refunds.refundid;


--
-- TOC entry 201 (class 1259 OID 58815)
-- Name: routs; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.routs (
    routeid integer NOT NULL,
    departure character varying(50) NOT NULL,
    departureairport character varying(50) NOT NULL,
    arrival character varying(50) NOT NULL,
    arrivalairport character varying(50) NOT NULL,
    traveltime time without time zone NOT NULL
);


ALTER TABLE public.routs OWNER TO postgres;

--
-- TOC entry 200 (class 1259 OID 58813)
-- Name: routs_routeid_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.routs_routeid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.routs_routeid_seq OWNER TO postgres;

--
-- TOC entry 3163 (class 0 OID 0)
-- Dependencies: 200
-- Name: routs_routeid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.routs_routeid_seq OWNED BY public.routs.routeid;


--
-- TOC entry 208 (class 1259 OID 58864)
-- Name: sales; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.sales (
    saleid integer NOT NULL,
    saledate timestamp without time zone NOT NULL,
    vat integer NOT NULL,
    ticketid integer NOT NULL
);


ALTER TABLE public.sales OWNER TO postgres;

--
-- TOC entry 207 (class 1259 OID 58862)
-- Name: sales_saleid_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.sales_saleid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.sales_saleid_seq OWNER TO postgres;

--
-- TOC entry 3166 (class 0 OID 0)
-- Dependencies: 207
-- Name: sales_saleid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.sales_saleid_seq OWNED BY public.sales.saleid;


--
-- TOC entry 206 (class 1259 OID 58841)
-- Name: tickets; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tickets (
    ticketid integer NOT NULL,
    placenumber character varying(3) NOT NULL,
    reserved boolean NOT NULL,
    ticketprice integer NOT NULL,
    sclass public.seatclass NOT NULL,
    routeid integer NOT NULL,
    passengerid character varying(50),
    flightid integer NOT NULL
);


ALTER TABLE public.tickets OWNER TO postgres;

--
-- TOC entry 211 (class 1259 OID 58888)
-- Name: tickets_n_passengers_info; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.tickets_n_passengers_info AS
 SELECT ti.ticketid,
    f.aircraftnumber,
    ti.placenumber,
    ti.ticketprice,
    ti.sclass,
    pa.fullname,
    pa.mobilephone,
    pa.email,
    pa.passengerid,
    f.flightid
   FROM ((public.flights f
     JOIN public.tickets ti ON ((ti.flightid = f.flightid)))
     JOIN public.passengers pa ON (((ti.passengerid)::text = (pa.passengerid)::text)));


ALTER TABLE public.tickets_n_passengers_info OWNER TO postgres;

--
-- TOC entry 205 (class 1259 OID 58839)
-- Name: tickets_ticketid_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.tickets_ticketid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.tickets_ticketid_seq OWNER TO postgres;

--
-- TOC entry 3170 (class 0 OID 0)
-- Dependencies: 205
-- Name: tickets_ticketid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.tickets_ticketid_seq OWNED BY public.tickets.ticketid;


--
-- TOC entry 2930 (class 2604 OID 58826)
-- Name: flights flightid; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.flights ALTER COLUMN flightid SET DEFAULT nextval('public.flights_flightid_seq'::regclass);


--
-- TOC entry 2933 (class 2604 OID 58880)
-- Name: refunds refundid; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.refunds ALTER COLUMN refundid SET DEFAULT nextval('public.refunds_refundid_seq'::regclass);


--
-- TOC entry 2929 (class 2604 OID 58818)
-- Name: routs routeid; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.routs ALTER COLUMN routeid SET DEFAULT nextval('public.routs_routeid_seq'::regclass);


--
-- TOC entry 2932 (class 2604 OID 58867)
-- Name: sales saleid; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sales ALTER COLUMN saleid SET DEFAULT nextval('public.sales_saleid_seq'::regclass);


--
-- TOC entry 2931 (class 2604 OID 58844)
-- Name: tickets ticketid; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tickets ALTER COLUMN ticketid SET DEFAULT nextval('public.tickets_ticketid_seq'::regclass);


--
-- TOC entry 3100 (class 0 OID 58823)
-- Dependencies: 203
-- Data for Name: flights; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.flights (flightid, aircraftnumber, departuredate, arrivaldate, status, ticketscount, passengerscount, routeid) FROM stdin;
2	FV6363	2021-05-28 22:00:00	2021-05-29 00:00:25	Arrived	13	10	1
3	KL3179	2021-05-28 21:00:00	2021-05-29 00:00:35	Arrived	9	5	2
4	N41091	2021-05-28 21:00:00	2021-05-29 00:00:35	Arrived	14	10	2
1	SU2458	2021-05-28 22:00:00	2021-05-29 00:00:25	Arrived	9	5	1
\.


--
-- TOC entry 3101 (class 0 OID 58834)
-- Dependencies: 204
-- Data for Name: passengers; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.passengers (passengerid, passportdata, fullname, mobilephone, email, bill) FROM stdin;
test1	3418667904	Иванов Иван Иванович	+7(926)233-34-16	IIIvanov@mail.ru	50000
test2	4618457904	Пупкин Пупка Пупович	+7(926)143-11-87	Pupa@gmail.com	50000
test3	5218127734	Болотов Александр Юрьевич	+7(903)189-19-34	Boloto@yandex.ru	50000
test4	3671657251	Казанцев Вадим Юрьевич	+7(985)566-97-14	KazVad@mail.ru	50000
test5	1931471439	Пуртов Даниил Владимирович	+7(911)116-28-69	DanPurtov@yandex.ru	50000
test6	1235323567	Ахметов Максат Анурович	+7(976)178-56-11	Ahmet@gmail.com	50000
test7	7651457114	Громов Юрий Анатольевич	+7(985)912-65-56	Kchau@mail.ru	50000
test8	1782743787	Кириллов Степан Сергеевич	+7(976)789-13-92	StepaKrut@gmail.com	50000
test9	8478112456	Пронина Елена Михайловна	+7(925)772-05-19	Pron@mail.ru	50000
test10	7659237324	Рыженков Артем Юрьевич	+7(985)892-67-43	Rijenkovv@yandex.ru	50000
test11	6724221482	Лососева Галина Сергеевна	+7(903)673-98-74	LososGa@gmail.com	50000
test12	1936771791	Козина Светлана Игоревна	+7(985)119-47-17	KozSvetYa@yandex.ru	50000
test13	9470351724	Светов Геннадий Яковлевич	+7(926)778-45-08	YakSvetGen@mail.ru	50000
test14	9081735735	Смешнов Василий Петрович	+7(925)682-16-83	SmehVasya@mail.ru	50000
test15	8761524023	Панов Кирилл Георгиевич	+7(903)563-16-03	kPanov@gmail.com	50000
test16	8350293502	Кошина Ирина Антоновна	+7(985)167-24-18	Kosha@yandex.ru	50000
test17	4293479237	Гончарова Светлана Алексеевна	+7(926)923-56-11	SvetAlex@gmail.com	50000
test18	1295437934	Смирнов Павел Дмитриевич	+7(976)612-43-56	MirPavel@mail.ru	50000
test19	6456846563	Иванова Таисия Петровна	+7(926)455-32-06	TasyaIva@mail.ru	50000
test20	4857975957	Дудкин Алексей Русланович	+7(925)345-45-15	DudAlex@yandex.ru	50000
test21	9523572233	Сердюков Антон Максимович	+7(925)624-15-02	LoveAnton@gmail.com	50000
test22	8325982352	Жомов Илья Дмитриевич	+7(912)374-82-32	JimJim@mail.ru	50000
test23	2392359926	Буробин Святослав Викторович	+7(925)125-10-12	Buroba@yandex.ru	50000
test24	6578275482	Соболева Ирина Павловна	+7(925)902-11-03	SobolIra@mail.ru	50000
test25	5827549829	Ковыршина Зинаида Андреевна	+7(903)187-65-44	ZinaKova@mail.ru	50000
test26	2489182791	Пожаев Руслан Максимович	+7(926)463-87-15	Rusik223@gmail.com	50000
test27	7932598235	Рублева Варвара Артемовна	+7(903)324-67-72	Varva@yandex.ru	50000
test28	8871645810	Веселов Максим Александрович	+7(925)711-72-01	VeseloVsegda@mail.ru	50000
test29	3982375987	Сулохин Родион Сергеевич	+7(916)311-25-78	Sulohinn12@gmail.com	50000
test30	6126498101	Цепордей Кристиан Виорелович	+7(999)912-12-99	CepKriss@gmail.com	50000
test_a	777777777	admin admin admin	+8(800)555-35-35	qqqq@mail.ru	100000000
\.


--
-- TOC entry 3107 (class 0 OID 58877)
-- Dependencies: 210
-- Data for Name: refunds; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.refunds (refundid, refunddate, refundreason, ticketid) FROM stdin;
1	2021-04-02 18:21:13	Купил билет на другой самолет	31
2	2021-03-30 16:32:11	Поменялись планы	32
3	2021-04-11 12:03:40	Перепутал класс места	33
\.


--
-- TOC entry 3098 (class 0 OID 58815)
-- Dependencies: 201
-- Data for Name: routs; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.routs (routeid, departure, departureairport, arrival, arrivalairport, traveltime) FROM stdin;
1	Москва	Шереметьево	Санкт-Петербург	Пулково	01:25:00
2	Москва	Шереметьево	Рим	Фьюмичино	03:35:00
\.


--
-- TOC entry 3105 (class 0 OID 58864)
-- Dependencies: 208
-- Data for Name: sales; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.sales (saleid, saledate, vat, ticketid) FROM stdin;
1	2021-02-08 16:27:32	4100	1
2	2021-03-04 13:15:42	6500	2
3	2021-04-14 08:42:26	4100	3
4	2021-04-25 22:57:35	4100	4
5	2021-01-11 23:23:58	9000	5
6	2021-04-06 22:45:21	7600	6
7	2020-11-30 06:59:42	11200	7
8	2020-11-15 12:21:56	7600	8
9	2020-12-04 17:18:01	11200	9
10	2020-10-07 18:06:14	11200	10
11	2020-09-25 12:09:35	17500	11
12	2020-09-21 09:18:23	7600	12
13	2020-08-18 12:36:47	7600	13
14	2020-05-19 12:29:36	7600	14
15	2020-06-12 23:10:44	17500	15
16	2020-12-03 21:31:12	6900	16
17	2020-07-05 20:48:03	6900	17
18	2020-10-19 11:51:07	9120	18
19	2020-06-11 10:24:11	6900	19
20	2020-06-20 10:07:46	6900	20
21	2020-07-13 19:14:12	8400	21
22	2020-05-18 14:03:52	8400	22
23	2020-03-29 12:47:01	8400	23
24	2020-02-24 17:59:21	12300	24
25	2020-02-27 14:32:18	8400	25
26	2020-02-03 12:51:25	8400	26
27	2020-01-05 20:26:57	8400	27
28	2020-01-02 23:15:31	8400	28
29	2020-10-15 12:02:47	10900	29
30	2020-11-29 09:28:24	10900	30
31	2021-02-11 19:24:46	4100	31
32	2020-05-25 14:06:34	6500	32
33	2020-09-30 07:41:14	9000	33
\.


--
-- TOC entry 3103 (class 0 OID 58841)
-- Dependencies: 206
-- Data for Name: tickets; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tickets (ticketid, placenumber, reserved, ticketprice, sclass, routeid, passengerid, flightid) FROM stdin;
1	11A	t	20500	Economy	1	test1	1
2	16C	t	32500	Business	1	test2	1
3	6A	t	20500	Economy	1	test3	1
4	10B	t	20500	Economy	1	test4	1
5	13C	t	45000	First	1	test5	1
6	19C	t	38000	Economy	1	test6	2
7	11E	t	56000	Business	1	test7	2
8	12F	t	38000	Economy	1	test8	2
9	16A	t	56000	Business	1	test9	2
10	9C	t	56000	Business	1	test10	2
11	3A	t	87500	First	1	test11	2
12	16B	t	38000	Economy	1	test12	2
13	18F	t	38000	Economy	1	test13	2
14	11D	t	38000	Economy	1	test14	2
15	3A	t	87500	First	1	test15	2
16	3A	t	34500	Economy	2	test16	3
17	3B	t	34500	Economy	2	test17	3
18	10C	t	45600	Business	2	test18	3
19	14B	t	34500	Economy	2	test19	3
20	8F	t	34500	Economy	2	test20	3
21	16D	t	42000	Economy	2	test21	4
22	16C	t	42000	Economy	2	test22	4
23	16B	t	42000	Economy	2	test23	4
24	19A	t	61500	First	2	test24	4
25	8F	t	42000	Economy	2	test25	4
26	6B	t	42000	Economy	2	test26	4
27	11A	t	42000	Economy	2	test27	4
28	11B	t	42000	Economy	2	test28	4
29	18F	t	54500	Business	2	test29	4
30	10C	t	54500	Business	2	test30	4
31	3A	f	20500	Economy	1	\N	1
32	12C	f	32500	Business	1	\N	1
33	8B	f	45000	First	1	\N	1
34	4A	f	45000	First	1	\N	1
35	16B	f	38000	Economy	1	\N	2
36	12C	f	38000	Economy	1	\N	2
37	3C	f	56000	Business	1	\N	2
38	4A	f	34500	Economy	2	\N	3
39	12F	f	34500	Economy	2	\N	3
40	6C	f	34500	Economy	2	\N	3
41	8A	f	80000	First	2	\N	3
42	12A	f	42000	Economy	2	\N	4
43	12B	f	54500	Business	2	\N	4
44	7C	f	54500	Business	2	\N	4
45	14B	f	61500	First	2	\N	4
\.


--
-- TOC entry 3172 (class 0 OID 0)
-- Dependencies: 202
-- Name: flights_flightid_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.flights_flightid_seq', 4, true);


--
-- TOC entry 3173 (class 0 OID 0)
-- Dependencies: 209
-- Name: refunds_refundid_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.refunds_refundid_seq', 3, true);


--
-- TOC entry 3174 (class 0 OID 0)
-- Dependencies: 200
-- Name: routs_routeid_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.routs_routeid_seq', 2, true);


--
-- TOC entry 3175 (class 0 OID 0)
-- Dependencies: 207
-- Name: sales_saleid_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.sales_saleid_seq', 33, true);


--
-- TOC entry 3176 (class 0 OID 0)
-- Dependencies: 205
-- Name: tickets_ticketid_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.tickets_ticketid_seq', 45, true);


--
-- TOC entry 2939 (class 2606 OID 58828)
-- Name: flights flights_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.flights
    ADD CONSTRAINT flights_pkey PRIMARY KEY (flightid);


--
-- TOC entry 2946 (class 2606 OID 58838)
-- Name: passengers passengers_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.passengers
    ADD CONSTRAINT passengers_pkey PRIMARY KEY (passengerid);


--
-- TOC entry 2954 (class 2606 OID 58882)
-- Name: refunds refunds_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.refunds
    ADD CONSTRAINT refunds_pkey PRIMARY KEY (refundid);


--
-- TOC entry 2937 (class 2606 OID 58820)
-- Name: routs routs_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.routs
    ADD CONSTRAINT routs_pkey PRIMARY KEY (routeid);


--
-- TOC entry 2952 (class 2606 OID 58869)
-- Name: sales sales_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sales
    ADD CONSTRAINT sales_pkey PRIMARY KEY (saleid);


--
-- TOC entry 2950 (class 2606 OID 58846)
-- Name: tickets tickets_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tickets
    ADD CONSTRAINT tickets_pkey PRIMARY KEY (ticketid);


--
-- TOC entry 2940 (class 1259 OID 58918)
-- Name: idx_aircraftnumber; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_aircraftnumber ON public.flights USING btree (aircraftnumber);


--
-- TOC entry 2934 (class 1259 OID 58922)
-- Name: idx_arrival; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_arrival ON public.routs USING btree (arrival);


--
-- TOC entry 2941 (class 1259 OID 58920)
-- Name: idx_arrivaldate; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_arrivaldate ON public.flights USING btree (arrivaldate);


--
-- TOC entry 2935 (class 1259 OID 58921)
-- Name: idx_departure; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_departure ON public.routs USING btree (departure);


--
-- TOC entry 2942 (class 1259 OID 58919)
-- Name: idx_departuredate; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_departuredate ON public.flights USING btree (departuredate);


--
-- TOC entry 2944 (class 1259 OID 58925)
-- Name: idx_fullname; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_fullname ON public.passengers USING btree (fullname);


--
-- TOC entry 2947 (class 1259 OID 58924)
-- Name: idx_sclass; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_sclass ON public.tickets USING btree (sclass);


--
-- TOC entry 2943 (class 1259 OID 58917)
-- Name: idx_status; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_status ON public.flights USING btree (status);


--
-- TOC entry 2948 (class 1259 OID 58923)
-- Name: idx_ticketprice; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_ticketprice ON public.tickets USING btree (ticketprice);


--
-- TOC entry 2964 (class 2620 OID 58929)
-- Name: refunds on_refund_added; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER on_refund_added AFTER INSERT ON public.refunds FOR EACH ROW EXECUTE FUNCTION public.is_not_reserved();


--
-- TOC entry 2963 (class 2620 OID 58927)
-- Name: sales on_sale_added; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER on_sale_added AFTER INSERT ON public.sales FOR EACH ROW EXECUTE FUNCTION public.is_reserved();


--
-- TOC entry 2961 (class 2620 OID 58933)
-- Name: tickets on_ticket_changed; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER on_ticket_changed AFTER UPDATE ON public.tickets FOR EACH ROW EXECUTE FUNCTION public.ticket_changed();


--
-- TOC entry 2962 (class 2620 OID 58931)
-- Name: tickets on_ticketscount_changed; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER on_ticketscount_changed AFTER INSERT OR DELETE ON public.tickets FOR EACH ROW EXECUTE FUNCTION public.ticketscount_changed();


--
-- TOC entry 2965 (class 2620 OID 58894)
-- Name: tickets_n_passengers_info update_tickets_n_passengers_info; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER update_tickets_n_passengers_info INSTEAD OF UPDATE ON public.tickets_n_passengers_info FOR EACH ROW EXECUTE FUNCTION public.instead_of_update();


--
-- TOC entry 2958 (class 2606 OID 58857)
-- Name: tickets fk_flightid; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tickets
    ADD CONSTRAINT fk_flightid FOREIGN KEY (flightid) REFERENCES public.flights(flightid) ON DELETE CASCADE;


--
-- TOC entry 2957 (class 2606 OID 58852)
-- Name: tickets fk_passengerid; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tickets
    ADD CONSTRAINT fk_passengerid FOREIGN KEY (passengerid) REFERENCES public.passengers(passengerid) ON DELETE SET NULL;


--
-- TOC entry 2955 (class 2606 OID 58829)
-- Name: flights fk_routeid; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.flights
    ADD CONSTRAINT fk_routeid FOREIGN KEY (routeid) REFERENCES public.routs(routeid) ON DELETE CASCADE;


--
-- TOC entry 2956 (class 2606 OID 58847)
-- Name: tickets fk_routeid; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tickets
    ADD CONSTRAINT fk_routeid FOREIGN KEY (routeid) REFERENCES public.routs(routeid) ON DELETE CASCADE;


--
-- TOC entry 2959 (class 2606 OID 58870)
-- Name: sales fk_ticketid; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sales
    ADD CONSTRAINT fk_ticketid FOREIGN KEY (ticketid) REFERENCES public.tickets(ticketid) ON DELETE CASCADE;


--
-- TOC entry 2960 (class 2606 OID 58883)
-- Name: refunds fk_ticketid; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.refunds
    ADD CONSTRAINT fk_ticketid FOREIGN KEY (ticketid) REFERENCES public.tickets(ticketid) ON DELETE CASCADE;


--
-- TOC entry 3113 (class 0 OID 0)
-- Dependencies: 3
-- Name: SCHEMA public; Type: ACL; Schema: -; Owner: postgres
--

GRANT ALL ON SCHEMA public TO adm;


--
-- TOC entry 3114 (class 0 OID 0)
-- Dependencies: 235
-- Name: PROCEDURE change_status(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON PROCEDURE public.change_status() TO adm;


--
-- TOC entry 3115 (class 0 OID 0)
-- Dependencies: 224
-- Name: PROCEDURE delete_flight(_flightid integer); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON PROCEDURE public.delete_flight(_flightid integer) TO adm;


--
-- TOC entry 3116 (class 0 OID 0)
-- Dependencies: 250
-- Name: PROCEDURE delete_passenger(_passengerid character varying); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON PROCEDURE public.delete_passenger(_passengerid character varying) TO adm;


--
-- TOC entry 3117 (class 0 OID 0)
-- Dependencies: 253
-- Name: PROCEDURE delete_refund(_refundid integer); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON PROCEDURE public.delete_refund(_refundid integer) TO adm;


--
-- TOC entry 3118 (class 0 OID 0)
-- Dependencies: 212
-- Name: PROCEDURE delete_route(_routeid integer); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON PROCEDURE public.delete_route(_routeid integer) TO adm;


--
-- TOC entry 3119 (class 0 OID 0)
-- Dependencies: 231
-- Name: PROCEDURE delete_sale(_saleid integer); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON PROCEDURE public.delete_sale(_saleid integer) TO adm;


--
-- TOC entry 3120 (class 0 OID 0)
-- Dependencies: 225
-- Name: PROCEDURE delete_ticket(_ticketid integer); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON PROCEDURE public.delete_ticket(_ticketid integer) TO adm;


--
-- TOC entry 3121 (class 0 OID 0)
-- Dependencies: 257
-- Name: PROCEDURE drop_user(_passengerid character varying); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON PROCEDURE public.drop_user(_passengerid character varying) TO adm;


--
-- TOC entry 3122 (class 0 OID 0)
-- Dependencies: 259
-- Name: PROCEDURE fill_bill(_passengerid character varying, _amount integer); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON PROCEDURE public.fill_bill(_passengerid character varying, _amount integer) TO client;
GRANT ALL ON PROCEDURE public.fill_bill(_passengerid character varying, _amount integer) TO adm;


--
-- TOC entry 3123 (class 0 OID 0)
-- Dependencies: 233
-- Name: FUNCTION get_dif_people(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.get_dif_people() TO adm;


--
-- TOC entry 3124 (class 0 OID 0)
-- Dependencies: 237
-- Name: FUNCTION get_flights_dates(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.get_flights_dates() TO adm;


--
-- TOC entry 3125 (class 0 OID 0)
-- Dependencies: 234
-- Name: FUNCTION get_interval(_aircraftnumber character varying); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.get_interval(_aircraftnumber character varying) TO adm;


--
-- TOC entry 3126 (class 0 OID 0)
-- Dependencies: 230
-- Name: FUNCTION get_ticket_id(_placenumber character varying, _aircraftnumber character varying); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.get_ticket_id(_placenumber character varying, _aircraftnumber character varying) TO adm;


--
-- TOC entry 3127 (class 0 OID 0)
-- Dependencies: 245
-- Name: PROCEDURE insert_flight(_aircraftnumber character varying, _departuredate timestamp without time zone, _arrivaldate timestamp without time zone, _status public.flightstatus, _ticketscount integer, _passengerscount integer, _routeid integer); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON PROCEDURE public.insert_flight(_aircraftnumber character varying, _departuredate timestamp without time zone, _arrivaldate timestamp without time zone, _status public.flightstatus, _ticketscount integer, _passengerscount integer, _routeid integer) TO adm;


--
-- TOC entry 3128 (class 0 OID 0)
-- Dependencies: 251
-- Name: PROCEDURE insert_passenger(_passengerid character varying, _passportdata character varying, _fullname character varying, _mobilephone character varying, _email character, _bill integer); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON PROCEDURE public.insert_passenger(_passengerid character varying, _passportdata character varying, _fullname character varying, _mobilephone character varying, _email character, _bill integer) TO adm;


--
-- TOC entry 3129 (class 0 OID 0)
-- Dependencies: 254
-- Name: PROCEDURE insert_refund(_refunddate timestamp without time zone, _refundreason character varying, _ticketid integer); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON PROCEDURE public.insert_refund(_refunddate timestamp without time zone, _refundreason character varying, _ticketid integer) TO adm;


--
-- TOC entry 3130 (class 0 OID 0)
-- Dependencies: 243
-- Name: PROCEDURE insert_route(_departure character varying, _departureairport character varying, _arrival character varying, _arrivalairport character varying, _traveltime time without time zone); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON PROCEDURE public.insert_route(_departure character varying, _departureairport character varying, _arrival character varying, _arrivalairport character varying, _traveltime time without time zone) TO adm;


--
-- TOC entry 3131 (class 0 OID 0)
-- Dependencies: 232
-- Name: PROCEDURE insert_sale(_saledate timestamp without time zone, _vat integer, _ticketid integer); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON PROCEDURE public.insert_sale(_saledate timestamp without time zone, _vat integer, _ticketid integer) TO adm;


--
-- TOC entry 3132 (class 0 OID 0)
-- Dependencies: 248
-- Name: PROCEDURE insert_ticket(_placenumber character varying, _reserved boolean, _ticketprice integer, _sclass public.seatclass, _routeid integer, _passengerid character varying, _flightid integer); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON PROCEDURE public.insert_ticket(_placenumber character varying, _reserved boolean, _ticketprice integer, _sclass public.seatclass, _routeid integer, _passengerid character varying, _flightid integer) TO adm;


--
-- TOC entry 3133 (class 0 OID 0)
-- Dependencies: 238
-- Name: FUNCTION instead_of_update(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.instead_of_update() TO adm;


--
-- TOC entry 3134 (class 0 OID 0)
-- Dependencies: 227
-- Name: FUNCTION is_not_reserved(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.is_not_reserved() TO adm;


--
-- TOC entry 3135 (class 0 OID 0)
-- Dependencies: 226
-- Name: FUNCTION is_reserved(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.is_reserved() TO adm;


--
-- TOC entry 3136 (class 0 OID 0)
-- Dependencies: 256
-- Name: PROCEDURE make_sales(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON PROCEDURE public.make_sales() TO adm;


--
-- TOC entry 3137 (class 0 OID 0)
-- Dependencies: 261
-- Name: PROCEDURE refund_ticket(_passengerid character varying, _aircraftnumber character varying, _placenumber character varying, _refundreason character varying); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON PROCEDURE public.refund_ticket(_passengerid character varying, _aircraftnumber character varying, _placenumber character varying, _refundreason character varying) TO client;
GRANT ALL ON PROCEDURE public.refund_ticket(_passengerid character varying, _aircraftnumber character varying, _placenumber character varying, _refundreason character varying) TO adm;


--
-- TOC entry 3138 (class 0 OID 0)
-- Dependencies: 246
-- Name: PROCEDURE register_user(_passengerid character varying, _password character varying, _passportdata character varying, _fullname character varying, _mobilephone character varying, _email character); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON PROCEDURE public.register_user(_passengerid character varying, _password character varying, _passportdata character varying, _fullname character varying, _mobilephone character varying, _email character) TO guest;
GRANT ALL ON PROCEDURE public.register_user(_passengerid character varying, _password character varying, _passportdata character varying, _fullname character varying, _mobilephone character varying, _email character) TO adm;


--
-- TOC entry 3139 (class 0 OID 0)
-- Dependencies: 260
-- Name: PROCEDURE sale_ticket(_passengerid character varying, _aircraftnumber character varying, _placenumber character varying); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON PROCEDURE public.sale_ticket(_passengerid character varying, _aircraftnumber character varying, _placenumber character varying) TO client;
GRANT ALL ON PROCEDURE public.sale_ticket(_passengerid character varying, _aircraftnumber character varying, _placenumber character varying) TO adm;


--
-- TOC entry 3140 (class 0 OID 0)
-- Dependencies: 229
-- Name: FUNCTION ticket_changed(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.ticket_changed() TO adm;


--
-- TOC entry 3141 (class 0 OID 0)
-- Dependencies: 228
-- Name: FUNCTION ticketscount_changed(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.ticketscount_changed() TO adm;


--
-- TOC entry 3142 (class 0 OID 0)
-- Dependencies: 236
-- Name: FUNCTION to_usd(value integer, amount numeric); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.to_usd(value integer, amount numeric) TO adm;


--
-- TOC entry 3143 (class 0 OID 0)
-- Dependencies: 247
-- Name: PROCEDURE update_flight(_flightid integer, _routeid integer, _aircraftnumber character varying, _departuredate timestamp without time zone, _arrivaldate timestamp without time zone, _status public.flightstatus, _ticketscount integer, _passengerscount integer); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON PROCEDURE public.update_flight(_flightid integer, _routeid integer, _aircraftnumber character varying, _departuredate timestamp without time zone, _arrivaldate timestamp without time zone, _status public.flightstatus, _ticketscount integer, _passengerscount integer) TO adm;


--
-- TOC entry 3144 (class 0 OID 0)
-- Dependencies: 262
-- Name: PROCEDURE update_passenger(_passengerid character varying, _passportdata character varying, _fullname character varying, _mobilephone character varying, _email character varying, _bill integer); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON PROCEDURE public.update_passenger(_passengerid character varying, _passportdata character varying, _fullname character varying, _mobilephone character varying, _email character varying, _bill integer) TO client;
GRANT ALL ON PROCEDURE public.update_passenger(_passengerid character varying, _passportdata character varying, _fullname character varying, _mobilephone character varying, _email character varying, _bill integer) TO adm;


--
-- TOC entry 3145 (class 0 OID 0)
-- Dependencies: 263
-- Name: PROCEDURE update_passenger_data(_passengerid character varying, _passportdata character varying, _fullname character varying, _mobilephone character varying, _email character varying); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON PROCEDURE public.update_passenger_data(_passengerid character varying, _passportdata character varying, _fullname character varying, _mobilephone character varying, _email character varying) TO client;
GRANT ALL ON PROCEDURE public.update_passenger_data(_passengerid character varying, _passportdata character varying, _fullname character varying, _mobilephone character varying, _email character varying) TO adm;


--
-- TOC entry 3146 (class 0 OID 0)
-- Dependencies: 255
-- Name: PROCEDURE update_refund(_refundid integer, _ticketid integer, _refunddate timestamp without time zone, _refundreason character varying); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON PROCEDURE public.update_refund(_refundid integer, _ticketid integer, _refunddate timestamp without time zone, _refundreason character varying) TO adm;


--
-- TOC entry 3147 (class 0 OID 0)
-- Dependencies: 244
-- Name: PROCEDURE update_route(_routeid integer, _departure character varying, _departureairport character varying, _arrival character varying, _arrivalairport character varying, _traveltime time without time zone); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON PROCEDURE public.update_route(_routeid integer, _departure character varying, _departureairport character varying, _arrival character varying, _arrivalairport character varying, _traveltime time without time zone) TO adm;


--
-- TOC entry 3148 (class 0 OID 0)
-- Dependencies: 252
-- Name: PROCEDURE update_sale(_saleid integer, _ticketid integer, _saledate timestamp without time zone, _vat integer); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON PROCEDURE public.update_sale(_saleid integer, _ticketid integer, _saledate timestamp without time zone, _vat integer) TO adm;


--
-- TOC entry 3149 (class 0 OID 0)
-- Dependencies: 249
-- Name: PROCEDURE update_ticket(_ticketid integer, _routeid integer, _flightid integer, _placenumber character varying, _reserved boolean, _ticketprice integer, _sclass public.seatclass, _passengerid character varying); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON PROCEDURE public.update_ticket(_ticketid integer, _routeid integer, _flightid integer, _placenumber character varying, _reserved boolean, _ticketprice integer, _sclass public.seatclass, _passengerid character varying) TO adm;


--
-- TOC entry 3150 (class 0 OID 0)
-- Dependencies: 258
-- Name: PROCEDURE update_view(_ticketid integer, _aircraftnumber character varying, _placenumber character varying, _ticketprice integer, _seatclass public.seatclass, _fullname character varying, _mobilephone character varying, _email character varying); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON PROCEDURE public.update_view(_ticketid integer, _aircraftnumber character varying, _placenumber character varying, _ticketprice integer, _seatclass public.seatclass, _fullname character varying, _mobilephone character varying, _email character varying) TO adm;


--
-- TOC entry 3151 (class 0 OID 0)
-- Dependencies: 240
-- Name: FUNCTION validate_flight(_aircraftnumber character varying); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.validate_flight(_aircraftnumber character varying) TO adm;


--
-- TOC entry 3152 (class 0 OID 0)
-- Dependencies: 242
-- Name: FUNCTION validate_passenger(_passportdata character varying, _fullname character varying, _mobilephone character varying, _email character, _bill integer); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.validate_passenger(_passportdata character varying, _fullname character varying, _mobilephone character varying, _email character, _bill integer) TO adm;


--
-- TOC entry 3153 (class 0 OID 0)
-- Dependencies: 239
-- Name: FUNCTION validate_route(_departure character varying, _departureairport character varying, _arrival character varying, _arrivalairport character varying); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.validate_route(_departure character varying, _departureairport character varying, _arrival character varying, _arrivalairport character varying) TO adm;


--
-- TOC entry 3154 (class 0 OID 0)
-- Dependencies: 241
-- Name: FUNCTION validate_ticket(_placenumber character varying, _flightid integer); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.validate_ticket(_placenumber character varying, _flightid integer) TO adm;


--
-- TOC entry 3155 (class 0 OID 0)
-- Dependencies: 203
-- Name: TABLE flights; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.flights TO client;
GRANT ALL ON TABLE public.flights TO adm;


--
-- TOC entry 3157 (class 0 OID 0)
-- Dependencies: 202
-- Name: SEQUENCE flights_flightid_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON SEQUENCE public.flights_flightid_seq TO adm;


--
-- TOC entry 3158 (class 0 OID 0)
-- Dependencies: 204
-- Name: TABLE passengers; Type: ACL; Schema: public; Owner: postgres
--

GRANT INSERT,UPDATE ON TABLE public.passengers TO guest;
GRANT SELECT,UPDATE ON TABLE public.passengers TO client;
GRANT ALL ON TABLE public.passengers TO adm;


--
-- TOC entry 3159 (class 0 OID 0)
-- Dependencies: 210
-- Name: TABLE refunds; Type: ACL; Schema: public; Owner: postgres
--

GRANT INSERT ON TABLE public.refunds TO client;
GRANT ALL ON TABLE public.refunds TO adm;


--
-- TOC entry 3161 (class 0 OID 0)
-- Dependencies: 209
-- Name: SEQUENCE refunds_refundid_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON SEQUENCE public.refunds_refundid_seq TO client;
GRANT ALL ON SEQUENCE public.refunds_refundid_seq TO adm;


--
-- TOC entry 3162 (class 0 OID 0)
-- Dependencies: 201
-- Name: TABLE routs; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.routs TO client;
GRANT ALL ON TABLE public.routs TO adm;


--
-- TOC entry 3164 (class 0 OID 0)
-- Dependencies: 200
-- Name: SEQUENCE routs_routeid_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON SEQUENCE public.routs_routeid_seq TO adm;


--
-- TOC entry 3165 (class 0 OID 0)
-- Dependencies: 208
-- Name: TABLE sales; Type: ACL; Schema: public; Owner: postgres
--

GRANT INSERT ON TABLE public.sales TO client;
GRANT ALL ON TABLE public.sales TO adm;


--
-- TOC entry 3167 (class 0 OID 0)
-- Dependencies: 207
-- Name: SEQUENCE sales_saleid_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON SEQUENCE public.sales_saleid_seq TO client;
GRANT ALL ON SEQUENCE public.sales_saleid_seq TO adm;


--
-- TOC entry 3168 (class 0 OID 0)
-- Dependencies: 206
-- Name: TABLE tickets; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,UPDATE ON TABLE public.tickets TO client;
GRANT ALL ON TABLE public.tickets TO adm;


--
-- TOC entry 3169 (class 0 OID 0)
-- Dependencies: 211
-- Name: TABLE tickets_n_passengers_info; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.tickets_n_passengers_info TO adm;


--
-- TOC entry 3171 (class 0 OID 0)
-- Dependencies: 205
-- Name: SEQUENCE tickets_ticketid_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON SEQUENCE public.tickets_ticketid_seq TO adm;


-- Completed on 2021-07-13 09:26:48

--
-- PostgreSQL database dump complete
--

