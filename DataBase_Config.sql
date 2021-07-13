CREATE TYPE FlightStatus AS ENUM ('Waiting', 'Check-in open', 'Now boarding', 'In air', 'Arrived');

CREATE TYPE SeatClass AS ENUM ('Economy', 'Business', 'First');

CREATE TABLE Routs (
   	RouteID serial NOT NULL PRIMARY KEY,
   	Departure varchar(50) NOT NULL,
    	DepartureAirport varchar(50) NOT NULL,
    	Arrival varchar(50) NOT NULL,
	ArrivalAirport varchar(50) NOT NULL,
	TravelTime time NOT NULL
);

CREATE TABLE Flights (
    	FlightID serial NOT NULL PRIMARY KEY,
	AircraftNumber varchar(10) NOT NULL,
    	DepartureDate timestamp NOT NULL,
	ArrivalDate timestamp NOT NULL,
	Status FlightStatus NOT NULL,
	TicketsCount int,
	PassengersCount int, 
	RouteID int NOT NULL,
    CONSTRAINT FK_RouteID FOREIGN KEY (RouteID)
	REFERENCES Routs(RouteID) ON DELETE CASCADE
);

CREATE TABLE Passengers (
    	PassengerID varchar(50) NOT NULL PRIMARY KEY UNIQUE,
    	PassportData varchar(20) NOT NULL,
	FullName varchar(50) NOT NULL,
	MobilePhone varchar(20) NOT NULL,
	Email varchar(50) NOT NULL,
	Bill int
);

CREATE TABLE Tickets (
    	TicketID serial NOT NULL PRIMARY KEY,
    	PlaceNumber varchar(3) NOT NULL,
	Reserved boolean NOT NULL,
	TicketPrice int NOT NULL,
	Sclass SeatClass NOT NULL,
    RouteID int NOT NULL,
    CONSTRAINT FK_RouteID FOREIGN KEY (RouteID)
    REFERENCES Routs(RouteID) ON DELETE CASCADE,
    PassengerID varchar(50),
    CONSTRAINT FK_PassengerID FOREIGN KEY (PassengerID)
    REFERENCES Passengers(PassengerID) ON DELETE SET NULL,
    FlightID int NOT NULL,
    CONSTRAINT FK_FlightID FOREIGN KEY (FlightID)
    REFERENCES Flights(FlightID) ON DELETE CASCADE
);

CREATE TABLE Sales (
    	SaleID serial NOT NULL PRIMARY KEY,
    	SaleDate timestamp NOT NULL,
	VAT int NOT NULL,
        TicketID int NOT NULL,
    CONSTRAINT FK_TicketID FOREIGN KEY (TicketID)
    REFERENCES Tickets(TicketID) ON DELETE CASCADE
);

CREATE TABLE Refunds (
    	RefundID serial NOT NULL PRIMARY KEY,
    	RefundDate timestamp NOT NULL,
	RefundReason varchar(50),
	TicketID int NOT NULL,
    CONSTRAINT FK_TicketID FOREIGN KEY (TicketID)
    REFERENCES Tickets(TicketID) ON DELETE CASCADE
);

INSERT INTO Routs(Departure, DepartureAirport, Arrival, ArrivalAirport, TravelTime) VALUES 
('Москва', 'Шереметьево', 'Санкт-Петербург', 'Пулково', '01:25'),
('Москва', 'Шереметьево', 'Рим', 'Фьюмичино', '03:35');

INSERT INTO Flights(AircraftNumber, DepartureDate, ArrivalDate, Status, TicketsCount, PassengersCount, RouteID) VALUES 
('SU2458', '2021-04-28 20:00:00', '2021-04-28 21:25:00', 'Waiting', 9, 5, 1),
('FV6363', '2021-04-28 15:00:00', '2021-04-28 18:25:00', 'In air', 13, 10, 1);
INSERT INTO Flights(AircraftNumber, DepartureDate, ArrivalDate, Status, TicketsCount, PassengersCount, RouteID) VALUES 
('KL3179', '2021-04-28 16:30:00', '2021-04-28 17:55:00', 'In air', 9, 5, 2),
('N41091', '2021-04-28 18:30:00', '2021-04-28 22:05:00', 'Waiting', 14, 10, 2);

INSERT INTO Passengers(PassengerID , PassportData, FullName, MobilePhone, email, Bill) VALUES 
('test1', '3418667904', 'Иванов Иван Иванович', '+7(926)233-34-16', 'IIIvanov@mail.ru', 50000),
('test2', '4618457904', 'Пупкин Пупка Пупович', '+7(926)143-11-87', 'Pupa@gmail.com', 50000),
('test3', '5218127734', 'Болотов Александр Юрьевич', '+7(903)189-19-34', 'Boloto@yandex.ru', 50000),
('test4', '3671657251', 'Казанцев Вадим Юрьевич', '+7(985)566-97-14', 'KazVad@mail.ru', 50000),
('test5', '1931471439', 'Пуртов Даниил Владимирович', '+7(911)116-28-69', 'DanPurtov@yandex.ru', 50000);

INSERT INTO Passengers(PassengerID , PassportData, FullName, MobilePhone, email, Bill) VALUES 
('test6', '1235323567', 'Ахметов Максат Анурович', '+7(976)178-56-11', 'Ahmet@gmail.com', 50000),
('test7', '7651457114', 'Громов Юрий Анатольевич', '+7(985)912-65-56', 'Kchau@mail.ru', 50000),
('test8', '1782743787', 'Кириллов Степан Сергеевич', '+7(976)789-13-92', 'StepaKrut@gmail.com', 50000),
('test9', '8478112456', 'Пронина Елена Михайловна', '+7(925)772-05-19', 'Pron@mail.ru', 50000),
('test10', '7659237324', 'Рыженков Артем Юрьевич', '+7(985)892-67-43', 'Rijenkovv@yandex.ru', 50000),
('test11', '6724221482', 'Лососева Галина Сергеевна', '+7(903)673-98-74', 'LososGa@gmail.com', 50000),
('test12', '1936771791', 'Козина Светлана Игоревна', '+7(985)119-47-17', 'KozSvetYa@yandex.ru', 50000),
('test13', '9470351724', 'Светов Геннадий Яковлевич', '+7(926)778-45-08', 'YakSvetGen@mail.ru', 50000),
('test14', '9081735735', 'Смешнов Василий Петрович', '+7(925)682-16-83', 'SmehVasya@mail.ru', 50000),
('test15', '8761524023', 'Панов Кирилл Георгиевич', '+7(903)563-16-03', 'kPanov@gmail.com', 50000);

INSERT INTO Passengers(PassengerID , PassportData, FullName, MobilePhone, email, Bill) VALUES 
('test16', '8350293502', 'Кошина Ирина Антоновна', '+7(985)167-24-18', 'Kosha@yandex.ru', 50000),
('test17', '4293479237', 'Гончарова Светлана Алексеевна', '+7(926)923-56-11', 'SvetAlex@gmail.com', 50000),
('test18', '1295437934', 'Смирнов Павел Дмитриевич', '+7(976)612-43-56', 'MirPavel@mail.ru', 50000),
('test19', '6456846563', 'Иванова Таисия Петровна', '+7(926)455-32-06', 'TasyaIva@mail.ru', 50000),
('test20', '4857975957', 'Дудкин Алексей Русланович', '+7(925)345-45-15', 'DudAlex@yandex.ru', 50000);

INSERT INTO Passengers(PassengerID , PassportData, FullName, MobilePhone, email, Bill) VALUES 
('test21','9523572233', 'Сердюков Антон Максимович', '+7(925)624-15-02', 'LoveAnton@gmail.com', 50000),
('test22','8325982352', 'Жомов Илья Дмитриевич', '+7(912)374-82-32', 'JimJim@mail.ru', 50000),
('test23','2392359926', 'Буробин Святослав Викторович', '+7(925)125-10-12', 'Buroba@yandex.ru', 50000),
('test24','6578275482', 'Соболева Ирина Павловна', '+7(925)902-11-03', 'SobolIra@mail.ru', 50000),
('test25','5827549829', 'Ковыршина Зинаида Андреевна', '+7(903)187-65-44', 'ZinaKova@mail.ru', 50000),
('test26','2489182791', 'Пожаев Руслан Максимович', '+7(926)463-87-15', 'Rusik223@gmail.com', 50000),
('test27','7932598235', 'Рублева Варвара Артемовна', '+7(903)324-67-72', 'Varva@yandex.ru', 50000),
('test28','8871645810', 'Веселов Максим Александрович', '+7(925)711-72-01', 'VeseloVsegda@mail.ru', 50000),
('test29','3982375987', 'Сулохин Родион Сергеевич', '+7(916)311-25-78', 'Sulohinn12@gmail.com', 50000),
('test30','6126498101', 'Цепордей Кристиан Виорелович', '+7(999)912-12-99', 'CepKriss@gmail.com', 50000),
('test_a', '777777777', 'admin admin admin', '+8(800)555-35-35', 'qqqq@mail.ru', 100000000);

INSERT INTO Tickets(PlaceNumber, Reserved, TicketPrice, Sclass, RouteID, PassengerID, FlightID) VALUES 
('11A', 'True', 20500, 'Economy', 1, 'test1', 1),
('16C', 'True', 32500, 'Business', 1, 'test2', 1),
('6A', 'True', 20500, 'Economy', 1, 'test3', 1),
('10B', 'True', 20500, 'Economy', 1, 'test4', 1),
('13C', 'True', 45000, 'First', 1, 'test5', 1);

INSERT INTO Tickets(PlaceNumber, Reserved, TicketPrice, Sclass, RouteID, PassengerID, FlightID) VALUES 
('19C', 'True', 38000, 'Economy', 1, 'test6', 2),
('11E', 'True', 56000, 'Business', 1, 'test7', 2),
('12F', 'True', 38000, 'Economy', 1, 'test8', 2),
('16A', 'True', 56000, 'Business', 1, 'test9', 2),
('9C', 'True', 56000, 'Business', 1, 'test10', 2),
('3A', 'True', 87500, 'First', 1, 'test11', 2),
('16B', 'True', 38000, 'Economy', 1, 'test12', 2),
('18F', 'True', 38000, 'Economy', 1, 'test13', 2),
('11D', 'True', 38000, 'Economy', 1, 'test14', 2),
('3A', 'True', 87500, 'First', 1, 'test15', 2);

INSERT INTO Tickets(PlaceNumber, Reserved, TicketPrice, Sclass, RouteID, PassengerID, FlightID) VALUES 
('3A', 'True', 34500, 'Economy', 2, 'test16', 3),
('3B', 'True', 34500, 'Economy', 2, 'test17', 3),
('10C', 'True', 45600, 'Business', 2, 'test18', 3),
('14B', 'True', 34500, 'Economy', 2, 'test19', 3),
('8F', 'True', 34500, 'Economy', 2, 'test20', 3);

INSERT INTO Tickets(PlaceNumber, Reserved, TicketPrice, Sclass, RouteID, PassengerID, FlightID) VALUES 
('16D', 'True', 42000, 'Economy', 2, 'test21', 4),
('16C', 'True', 42000, 'Economy', 2, 'test22', 4),
('16B', 'True', 42000, 'Economy', 2, 'test23', 4),
('19A', 'True', 61500, 'First', 2, 'test24', 4),
('8F', 'True', 42000, 'Economy', 2, 'test25', 4),
('6B', 'True', 42000, 'Economy', 2, 'test26', 4),
('11A', 'True', 42000, 'Economy', 2, 'test27', 4),
('11B', 'True', 42000, 'Economy', 2, 'test28', 4),
('18F', 'True', 54500, 'Business', 2, 'test29', 4),
('10C', 'True', 54500, 'Business', 2, 'test30', 4);

INSERT INTO Tickets(PlaceNumber, Reserved, TicketPrice, Sclass, RouteID, FlightID) VALUES 
('3A', 'False', 20500, 'Economy', 1, 1),
('12C', 'False', 32500, 'Business', 1, 1),
('8B', 'False', 45000, 'First', 1, 1),
('4A', 'False', 45000, 'First', 1, 1),
('16B', 'False', 38000, 'Economy', 1, 2),
('12C', 'False', 38000, 'Economy', 1, 2),
('3C', 'False', 56000, 'Business', 1, 2),
('4A', 'False', 34500, 'Economy', 2, 3),
('12F', 'False', 34500, 'Economy', 2, 3),
('6C', 'False', 34500, 'Economy', 2, 3),
('8A', 'False', 80000, 'First', 2, 3),
('12A', 'False', 42000, 'Economy', 2, 4),
('12B', 'False', 54500, 'Business', 2, 4),
('7C', 'False', 54500, 'Business', 2, 4),
('14B', 'False', 61500, 'First', 2, 4);

INSERT INTO Sales(SaleDate, VAT, TicketId) VALUES 
('2021-02-08 16:27:32', (SELECT ticketprice from tickets where ticketid = 1) * 0.2, 1),
('2021-03-04 13:15:42', (SELECT ticketprice from tickets where ticketid = 2) * 0.2, 2),
('2021-04-14 08:42:26', (SELECT ticketprice from tickets where ticketid = 3) * 0.2, 3),
('2021-04-25 22:57:35', (SELECT ticketprice from tickets where ticketid = 4) * 0.2, 4),
('2021-01-11 23:23:58', (SELECT ticketprice from tickets where ticketid = 5) * 0.2, 5),
('2021-04-06 22:45:21', (SELECT ticketprice from tickets where ticketid = 6) * 0.2, 6),
('2020-11-30 06:59:42', (SELECT ticketprice from tickets where ticketid = 7) * 0.2, 7),
('2020-11-15 12:21:56', (SELECT ticketprice from tickets where ticketid = 8) * 0.2, 8),
('2020-12-04 17:18:01', (SELECT ticketprice from tickets where ticketid = 9) * 0.2, 9),
('2020-10-07 18:06:14', (SELECT ticketprice from tickets where ticketid = 10) * 0.2, 10),
('2020-09-25 12:09:35', (SELECT ticketprice from tickets where ticketid = 11) * 0.2, 11),
('2020-09-21 09:18:23', (SELECT ticketprice from tickets where ticketid = 12) * 0.2, 12),
('2020-08-18 12:36:47', (SELECT ticketprice from tickets where ticketid = 13) * 0.2, 13),
('2020-05-19 12:29:36', (SELECT ticketprice from tickets where ticketid = 14) * 0.2, 14),
('2020-06-12 23:10:44', (SELECT ticketprice from tickets where ticketid = 15) * 0.2, 15),
('2020-12-03 21:31:12', (SELECT ticketprice from tickets where ticketid = 16) * 0.2, 16),
('2020-07-05 20:48:03', (SELECT ticketprice from tickets where ticketid = 17) * 0.2, 17),
('2020-10-19 11:51:07', (SELECT ticketprice from tickets where ticketid = 18) * 0.2, 18),
('2020-06-11 10:24:11', (SELECT ticketprice from tickets where ticketid = 19) * 0.2, 19),
('2020-06-20 10:07:46', (SELECT ticketprice from tickets where ticketid = 20) * 0.2, 20),
('2020-07-13 19:14:12', (SELECT ticketprice from tickets where ticketid = 21) * 0.2, 21),
('2020-05-18 14:03:52', (SELECT ticketprice from tickets where ticketid = 22) * 0.2, 22),
('2020-03-29 12:47:01', (SELECT ticketprice from tickets where ticketid = 23) * 0.2, 23),
('2020-02-24 17:59:21', (SELECT ticketprice from tickets where ticketid = 24) * 0.2, 24),
('2020-02-27 14:32:18', (SELECT ticketprice from tickets where ticketid = 25) * 0.2, 25),
('2020-02-03 12:51:25', (SELECT ticketprice from tickets where ticketid = 26) * 0.2, 26),
('2020-01-05 20:26:57', (SELECT ticketprice from tickets where ticketid = 27) * 0.2, 27),
('2020-01-02 23:15:31', (SELECT ticketprice from tickets where ticketid = 28) * 0.2, 28),
('2020-10-15 12:02:47', (SELECT ticketprice from tickets where ticketid = 29) * 0.2, 29),
('2020-11-29 09:28:24', (SELECT ticketprice from tickets where ticketid = 30) * 0.2, 30),
('2021-02-11 19:24:46', (SELECT ticketprice from tickets where ticketid = 31) * 0.2, 31),
('2020-05-25 14:06:34', (SELECT ticketprice from tickets where ticketid = 32) * 0.2, 32),
('2020-09-30 07:41:14', (SELECT ticketprice from tickets where ticketid = 33) * 0.2, 33);

INSERT INTO Refunds(RefundDate, RefundReason, TicketId) VALUES 
('2021-04-02 18:21:13', 'Купил билет на другой самолет', 31),
('2021-03-30 16:32:11', 'Поменялись планы', 32),
('2021-04-11 12:03:40', 'Перепутал класс места', 33);

CREATE VIEW tickets_n_passengers_info AS
SELECT  Ti.ticketid, F.aircraftnumber, Ti.placenumber, Ti.ticketprice,
		Ti.sclass, Pa.fullname, Pa.mobilephone, Pa.email, Pa.passengerid, F.flightid
FROM flights F
JOIN tickets Ti ON Ti.flightid = F.flightid
JOIN passengers Pa ON Ti.passengerid = Pa.passengerid;

CREATE OR REPLACE FUNCTION instead_of_update() RETURNS TRIGGER AS
$instead_of_update$
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
$instead_of_update$
LANGUAGE 'plpgsql';

CREATE TRIGGER update_tickets_n_passengers_info 
INSTEAD OF UPDATE ON tickets_n_passengers_info 
FOR EACH ROW
EXECUTE PROCEDURE instead_of_update();

CREATE OR REPLACE PROCEDURE delete_route (_routeid int)
					LANGUAGE plpgsql AS
$delete_route$
BEGIN
 	DELETE FROM routs WHERE routeid = _routeid;
END;
$delete_route$

CREATE OR REPLACE FUNCTION validate_route (_departure varchar(50),
										   _departureairport varchar(50),
										   _arrival varchar(50),
										   _arrivalairport varchar(50)) RETURNS boolean AS
$validate_route$ 
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
$validate_route$
LANGUAGE 'plpgsql';

CREATE OR REPLACE PROCEDURE insert_route (_departure varchar(50), _departureairport varchar(50),
										 _arrival varchar(50), _arrivalairport varchar(50), _traveltime time) 
										 LANGUAGE plpgsql AS
$insert_route$
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
$insert_route$

CREATE OR REPLACE PROCEDURE update_route (_routeid int, 
										  _departure varchar(50) DEFAULT NULL, 
										  _departureairport varchar(50) DEFAULT NULL,
										 _arrival varchar(50) DEFAULT NULL, 
										  _arrivalairport varchar(50) DEFAULT NULL, 
										  _traveltime time DEFAULT NULL) 
										 LANGUAGE plpgsql AS
$update_route$
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
$update_route$

CREATE OR REPLACE PROCEDURE delete_flight (_flightid int)
					LANGUAGE plpgsql AS
$delete_flight$
BEGIN
 	DELETE FROM flights WHERE flightid = _flightid;
END;
$delete_flight$

	CREATE OR REPLACE FUNCTION validate_flight (_aircraftnumber varchar(10)) RETURNS boolean AS
$validate_flight$ 
DECLARE
_aircraftnumber_validation boolean := (SELECT _aircraftnumber SIMILAR TO '[A-Z]{1,2}\d+');
	BEGIN
		IF(_aircraftnumber_validation = false) 
			THEN RAISE NOTICE 'Ошибка валидации: неверный формат бортового номера самолета'; RETURN false;
		ELSE RETURN true;
		END IF;
	END
$validate_flight$
LANGUAGE 'plpgsql';

CREATE OR REPLACE PROCEDURE insert_flight (_aircraftnumber varchar(10), 
										   _departuredate timestamp,
										   _arrivaldate timestamp, 
										   _status flightstatus, 
										   _ticketscount int,
										   _passengerscount int, 
										   _routeid int) 
										 LANGUAGE plpgsql AS
$insert_flight$
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
$insert_flight$

CREATE OR REPLACE PROCEDURE update_flight (_flightid int,
										  _routeid int,
										   _aircraftnumber varchar(10) DEFAULT NULL, 
										  _departuredate timestamp DEFAULT NULL,
										 _arrivaldate timestamp DEFAULT NULL, 
										  _status flightstatus DEFAULT NULL,
										  _ticketscount int DEFAULT NULL,
										  _passengerscount int DEFAULT NULL) 
										 LANGUAGE plpgsql AS
$update_flight$
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
$update_flight$

CREATE OR REPLACE PROCEDURE delete_ticket (_ticketid int)
					LANGUAGE plpgsql AS
$delete_ticket$
BEGIN
 	DELETE FROM tickets WHERE ticketid = _ticketid;
END;
$delete_ticket$

CREATE OR REPLACE FUNCTION validate_ticket (_placenumber varchar(3), 
										    _flightid int) RETURNS boolean AS
$validate_ticket$ 
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
$validate_ticket$
LANGUAGE 'plpgsql';

CREATE OR REPLACE PROCEDURE insert_ticket (_placenumber varchar(3), _reserved boolean,
										 _ticketprice int, _sclass seatclass, _routeid int,
										  _passengerid varchar(50), _flightid int)
										 LANGUAGE plpgsql AS
$insert_ticket$
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
$insert_ticket$

CREATE OR REPLACE PROCEDURE update_ticket (_ticketid int,
										   _routeid int,
										   _flightid int,
										   _placenumber varchar(3) DEFAULT NULL, 
										   _reserved boolean DEFAULT NULL,
										   _ticketprice int DEFAULT NULL, 
										   _sclass seatclass DEFAULT NULL,
										   _passengerid varchar(50) DEFAULT NULL) 
										   LANGUAGE plpgsql AS
$update_ticket$
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
$update_ticket$

CREATE OR REPLACE PROCEDURE delete_passenger (_passengerid varchar(50))
					LANGUAGE plpgsql AS
$delete_passenger$
BEGIN
 	DELETE FROM passengers WHERE passengerid = _passengerid;
END;
$delete_passenger$

CREATE OR REPLACE FUNCTION validate_passenger (_passportdata varchar(20), 
											   _fullname varchar(50),
										 	   _mobilephone varchar(20), 
											   _email char(50), _bill int) RETURNS boolean AS
$validate_passenger$ 
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
$validate_passenger$
LANGUAGE 'plpgsql';

CREATE OR REPLACE PROCEDURE insert_passenger (_passengerid varchar(50), _passportdata varchar(20), _fullname varchar(50),
										 _mobilephone varchar(20), _email char(50), _bill int)
										 LANGUAGE plpgsql AS
$insert_passenger$
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
$insert_passenger$

CREATE OR REPLACE PROCEDURE update_passenger (_passengerid varchar(50),
											  _passportdata varchar(20) DEFAULT NULL, 
										  	  _fullname varchar(50) DEFAULT NULL,
										      _mobilephone varchar(20) DEFAULT NULL, 
										      _email varchar(50) DEFAULT NULL,
											  _bill int DEFAULT NULL) 
										      LANGUAGE plpgsql AS
$update_passenger$
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
$update_passenger$

CREATE OR REPLACE PROCEDURE delete_sale (_saleid int)
					LANGUAGE plpgsql AS
$delete_sale$
BEGIN
 	DELETE FROM sales WHERE saleid = _saleid;
END;
$delete_sale$

CREATE OR REPLACE PROCEDURE insert_sale (_saledate timestamp, _vat int, _ticketid int)
										 LANGUAGE plpgsql AS
$insert_sale$
BEGIN
 	INSERT INTO sales(saledate, vat, ticketid) VALUES
	(_saledate, _vat, _ticketid);
END;
$insert_sale$

CREATE OR REPLACE PROCEDURE update_sale (_saleid int, 
										 _ticketid int,
										 _saledate timestamp DEFAULT NULL, 
										  _vat int DEFAULT NULL) 
										 LANGUAGE plpgsql AS
$update_sale$
BEGIN
	UPDATE sales
       SET saledate = COALESCE(_saledate, saledate),
           vat    = COALESCE(_vat, vat),
		   ticketid = COALESCE(_ticketid, ticketid)
		   WHERE saleid = _saleid;
END;
$update_sale$

CREATE OR REPLACE PROCEDURE delete_refund (_refundid int)
					LANGUAGE plpgsql AS
$delete_refund$
BEGIN
 	DELETE FROM refunds WHERE refundid = _refundid;
END;
$delete_refund$

CREATE OR REPLACE PROCEDURE insert_refund (_refunddate timestamp, _refundreason varchar(50), _ticketid int)
										 LANGUAGE plpgsql AS
$insert_refund$
BEGIN
 	INSERT INTO refunds(refunddate, refundreason, ticketid) VALUES
	(_refunddate, _refundreason, _ticketid);
END;
$insert_refund$

CREATE OR REPLACE PROCEDURE update_refund (_refundid int,
										   _ticketid int,
										   _refunddate timestamp DEFAULT NULL, 
										   _refundreason varchar(50) DEFAULT NULL) 
										   LANGUAGE plpgsql AS
$update_refund$
BEGIN
	UPDATE refunds
       SET refunddate = COALESCE(_refunddate, refunddate),
           refundreason    = _refundreason,
		   ticketid = COALESCE(_ticketid, ticketid)
		   WHERE refundid = _refundid;
END;
$update_refund$

CREATE INDEX idx_status ON flights USING btree(status);
CREATE INDEX idx_aircraftnumber ON flights USING btree(aircraftnumber);
CREATE INDEX idx_departuredate ON flights USING btree(departuredate);
CREATE INDEX idx_arrivaldate ON flights USING btree(arrivaldate);
CREATE INDEX idx_departure ON routs USING btree(departure);
CREATE INDEX idx_arrival ON routs USING btree(arrival);
CREATE INDEX idx_ticketprice ON tickets USING btree(ticketprice);
CREATE INDEX idx_sclass ON tickets USING btree(sclass);
CREATE INDEX idx_fullname ON passengers USING btree(fullname);

CREATE OR REPLACE FUNCTION is_reserved()
RETURNS TRIGGER SECURITY DEFINER AS
$is_reserved$
     BEGIN
	UPDATE tickets
	SET reserved = 'True' WHERE ticketid = NEW.ticketid;
	RETURN NEW;
     END
$is_reserved$
LANGUAGE plpgsql;

CREATE TRIGGER on_sale_added
AFTER INSERT ON sales FOR EACH ROW
EXECUTE PROCEDURE is_reserved();

CREATE OR REPLACE FUNCTION is_not_reserved()
RETURNS TRIGGER SECURITY DEFINER AS
$is_not_reserved$
     BEGIN
	UPDATE tickets
	SET reserved = 'False' WHERE ticketid = NEW.ticketid;
	RETURN NEW;
     END
$is_not_reserved$
LANGUAGE plpgsql;

CREATE TRIGGER on_refund_added
AFTER INSERT ON refunds FOR EACH ROW
EXECUTE PROCEDURE is_not_reserved();

CREATE OR REPLACE FUNCTION ticketscount_changed()
RETURNS TRIGGER SECURITY DEFINER AS
$ticketscount_changed$
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
$ticketscount_changed$ 
LANGUAGE plpgsql;

CREATE TRIGGER on_ticketscount_changed
AFTER INSERT OR DELETE ON tickets FOR EACH ROW
EXECUTE PROCEDURE ticketscount_changed();

CREATE OR REPLACE FUNCTION ticket_changed()
RETURNS TRIGGER SECURITY DEFINER AS
$ticket_changed$
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
$ticket_changed$ 
LANGUAGE plpgsql;

CREATE TRIGGER on_ticket_changed
AFTER UPDATE ON tickets FOR EACH ROW
EXECUTE PROCEDURE ticket_changed();

CREATE OR REPLACE FUNCTION get_ticket_id (_placenumber varchar(3), _aircraftnumber varchar(10))
	RETURNS int SECURITY DEFINER AS
$get_ticket_id$ 
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
$get_ticket_id$
LANGUAGE 'plpgsql';

CREATE OR REPLACE PROCEDURE sale_ticket (_passengerid varchar(50),
										 _aircraftnumber varchar(10),
										 _placenumber varchar(3)
										 ) LANGUAGE plpgsql AS
$sale_ticket$
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
$sale_ticket$

CREATE OR REPLACE PROCEDURE refund_ticket (_passengerid varchar(50),
										   _aircraftnumber varchar(10),
										   _placenumber varchar(3),
										   _refundreason varchar(50)) LANGUAGE plpgsql AS
$refund_ticket$
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
$refund_ticket$

CREATE OR REPLACE FUNCTION to_usd (value int, amount numeric)
	RETURNS numeric(7, 2) AS
$to_usd$ 
	BEGIN
      	RETURN CAST(value / amount as numeric(7, 2));
	END
$to_usd$
LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION get_flights_dates ()
  	RETURNS TABLE (_flightid int, _departuredate timestamp, 
				   _arrivaldate timestamp) AS
$get_flights_dates$ 
	BEGIN
	 	RETURN QUERY
      	SELECT flightid, departuredate, arrivaldate 
		FROM flights;
	END
$get_flights_dates$
LANGUAGE 'plpgsql';

CREATE OR REPLACE PROCEDURE change_status () LANGUAGE plpgsql AS
$change_status$
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
$change_status$

CREATE OR REPLACE FUNCTION get_dif_people ()
  	RETURNS TABLE (_dif_people numeric(3,1), _ticketid int) AS
$get_dif_people$ 
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
$get_dif_people$
LANGUAGE 'plpgsql';

CREATE OR REPLACE PROCEDURE make_sales () LANGUAGE plpgsql AS
$make_sales$
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
$make_sales$

CREATE OR REPLACE PROCEDURE register_user (_passengerid varchar(50),
										   _password varchar(50),
										   _passportdata varchar(20), 
									       _fullname varchar(50),
									       _mobilephone varchar(20), 
									       _email char(50)
										 ) LANGUAGE plpgsql SECURITY DEFINER AS
$register_user$
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
$register_user$

CREATE OR REPLACE PROCEDURE fill_bill (_passengerid varchar(50),
									   _amount int
										 ) LANGUAGE plpgsql SECURITY DEFINER AS
$fill_bill$
BEGIN
	IF(_amount > 0)
		THEN UPDATE passengers SET bill = bill + _amount WHERE passengerid = _passengerid;
	END IF;
END;
$fill_bill$

CREATE OR REPLACE PROCEDURE update_passenger_data (_passengerid varchar(50),
											  _passportdata varchar(20) DEFAULT NULL, 
										  	  _fullname varchar(50) DEFAULT NULL,
										      _mobilephone varchar(20) DEFAULT NULL, 
										      _email varchar(50) DEFAULT NULL) 
										      LANGUAGE plpgsql AS
$update_passenger_data$
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
$update_passenger_data$

CREATE OR REPLACE PROCEDURE drop_user (_passengerid varchar(50)   
										 ) LANGUAGE plpgsql SECURITY DEFINER AS
$drop_user$
BEGIN
	  	 EXECUTE FORMAT('CALL delete_passenger(''%I'')', _passengerid);
		 EXECUTE FORMAT('REVOKE Client FROM "%I"', _passengerid);
		 EXECUTE FORMAT('REVOKE adm FROM "%I"', _passengerid);
		 EXECUTE FORMAT('DROP USER "%I"', _passengerid);
END;
$drop_user$

CREATE OR REPLACE PROCEDURE update_view (_ticketid int, 
									     _aircraftnumber varchar(10) DEFAULT NULL, 
										 _placenumber varchar(3) DEFAULT NULL,
										 _ticketprice int DEFAULT NULL, 
										 _seatclass seatclass DEFAULT NULL,
										 _fullname varchar(50) DEFAULT NULL,
										 _mobilephone varchar(20) DEFAULT NULL,
										 _email varchar(50) DEFAULT NULL) 
										 LANGUAGE plpgsql AS
$update_view$
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
$update_view$

CREATE OR REPLACE FUNCTION get_interval (_aircraftnumber varchar(6))
  	RETURNS INTERVAL AS
$get_interval$ 
DECLARE
_interval INTERVAL := (SELECT departuredate  - localtimestamp FROM flights WHERE aircraftnumber = _aircraftnumber AND status <> 'Arrived');
	BEGIN
      	RETURN _interval;
	END
$get_interval$
LANGUAGE 'plpgsql';

CREATE USER Guest WITH PASSWORD 'test';
GRANT INSERT ON passengers to Guest;
GRANT UPDATE ON passengers to Guest;
GRANT EXECUTE ON PROCEDURE register_user TO Guest;

CREATE ROLE Client;
GRANT EXECUTE ON PROCEDURE sale_ticket, refund_ticket, update_passenger, fill_bill, update_passenger_data TO Client;
GRANT SELECT ON flights TO Client;
GRANT SELECT ON routs TO Client;
GRANT SELECT ON tickets TO Client;
GRANT UPDATE ON tickets TO Client;
GRANT SELECT ON passengers TO Client;
GRANT UPDATE ON passengers TO Client;
GRANT INSERT ON sales TO Client;
GRANT INSERT ON refunds TO Client;
GRANT ALL ON sales_saleid_seq TO Client;
GRANT ALL ON refunds_refundid_seq TO Client;

CREATE ROLE Adm WITH CREATEROLE;

GRANT ALL ON ALL TABLES IN SCHEMA public TO adm;
GRANT ALL ON ALL SEQUENCES IN SCHEMA public TO adm;
GRANT ALL ON ALL FUNCTIONS IN SCHEMA public TO adm;
GRANT ALL ON ALL PROCEDURES IN SCHEMA public TO adm;
GRANT ALL ON SCHEMA public TO adm;

CREATE USER test1 WITH PASSWORD 'test';
GRANT Client TO test1;
CREATE USER test2 WITH PASSWORD 'test';
GRANT Client TO test2;
CREATE USER test3 WITH PASSWORD 'test';
GRANT Client TO test3;
CREATE USER test4 WITH PASSWORD 'test';
GRANT Client TO test4;
CREATE USER test5 WITH PASSWORD 'test';
GRANT Client TO test5;
CREATE USER test6 WITH PASSWORD 'test';
GRANT Client TO test6;
CREATE USER test7 WITH PASSWORD 'test';
GRANT Client TO test7;
CREATE USER test8 WITH PASSWORD 'test';
GRANT Client TO test8;
CREATE USER test9 WITH PASSWORD 'test';
GRANT Client TO test9;
CREATE USER test10 WITH PASSWORD 'test';
GRANT Client TO test10;
CREATE USER test11 WITH PASSWORD 'test';
GRANT Client TO test11;
CREATE USER test12 WITH PASSWORD 'test';
GRANT Client TO test12;
CREATE USER test13 WITH PASSWORD 'test';
GRANT Client TO test13;
CREATE USER test14 WITH PASSWORD 'test';
GRANT Client TO test14;
CREATE USER test15 WITH PASSWORD 'test';
GRANT Client TO test15;
CREATE USER test16 WITH PASSWORD 'test';
GRANT Client TO test16;
CREATE USER test17 WITH PASSWORD 'test';
GRANT Client TO test17;
CREATE USER test18 WITH PASSWORD 'test';
GRANT Client TO test18;
CREATE USER test19 WITH PASSWORD 'test';
GRANT Client TO test19;
CREATE USER test20 WITH PASSWORD 'test';
GRANT Client TO test20;
CREATE USER test21 WITH PASSWORD 'test';
GRANT Client TO test21;
CREATE USER test22 WITH PASSWORD 'test';
GRANT Client TO test22;
CREATE USER test23 WITH PASSWORD 'test';
GRANT Client TO test23;
CREATE USER test24 WITH PASSWORD 'test';
GRANT Client TO test24;
CREATE USER test25 WITH PASSWORD 'test';
GRANT Client TO test25;
CREATE USER test26 WITH PASSWORD 'test';
GRANT Client TO test26;
CREATE USER test27 WITH PASSWORD 'test';
GRANT Client TO test27;
CREATE USER test28 WITH PASSWORD 'test';
GRANT Client TO test28;
CREATE USER test29 WITH PASSWORD 'test';
GRANT Client TO test29;
CREATE USER test30 WITH PASSWORD 'test';
GRANT Client TO test30;
CREATE USER test_a WITH PASSWORD 'test';
GRANT Client TO test_a;
GRANT Adm TO test_a WITH ADMIN OPTION;

SELECT F.aircraftnumber, R.departure, R.arrival, F.departuredate, 
F.arrivaldate, Ti.placenumber, F.status, Ti.ticketprice, Ti.sclass,
CASE 
WHEN Ti.reserved = false AND (F.status = 'Waiting' OR F.status = 'Check-in open')
THEN 'Билет доступен'
ELSE 'Билет недоступен'
END availability
FROM tickets Ti 
JOIN Flights F ON Ti.flightid = F.flightid
JOIN Routs R ON R.routeid = F.routeid 
WHERE R.departure = 'Москва' AND R.arrival = 'Санкт-Петербург' 
ORDER BY availability, F.aircraftnumber;

CREATE VIEW tickets_n_passengers_info AS
SELECT  Ti.ticketid, F.aircraftnumber, Ti.placenumber, Ti.ticketprice,
		Ti.sclass, Pa.fullname, Pa.mobilephone, Pa.email, Pa.passengerid, F.flightid
FROM flights F
JOIN tickets Ti ON Ti.flightid = F.flightid
JOIN passengers Pa ON Ti.passengerid = Pa.passengerid
WHERE F.status <> 'Arrived';

CREATE OR REPLACE FUNCTION instead_of_update() RETURNS TRIGGER AS
$instead_of_update$
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
$instead_of_update$
LANGUAGE 'plpgsql';

CREATE TRIGGER update_tickets_n_passengers_info 
INSTEAD OF UPDATE ON tickets_n_passengers_info 
FOR EACH ROW
EXECUTE PROCEDURE instead_of_update();

SELECT aircraftnumber, placenumber, fullname 
FROM tickets_n_passengers_info 
WHERE sclass = 'First' 
AND aircraftnumber = 'FV6363' 
ORDER BY fullname;	

SELECT Ti.ticketprice, Ti.sclass
FROM tickets Ti
WHERE(SELECT vat FROM sales S WHERE S.ticketid = Ti.ticketid) > 1000;

SELECT R.departure, R.arrival,
(SELECT COUNT(*) FROM Flights F WHERE F.routeid = R.routeid) AS flightscount
FROM Routs R;

SELECT refunddate, refundreason, placenumber, ticketprice, sclass
FROM Tickets Ti, LATERAL (SELECT * FROM Refunds WHERE Ti.ticketid = ticketid) AS refunds_n_tickets_info,
LATERAL (SELECT * FROM flights WHERE flightid = Ti.flightid) AS flights_n_tickets_info
WHERE aircraftnumber = 'SU2458' AND sclass = 'Business';

SELECT Re.refundreason
 FROM refunds Re JOIN 
 tickets Ti ON Ti.ticketid = Re.ticketid
 WHERE Ti.ticketprice < (SELECT AVG(ticketprice) FROM tickets);

 SELECT CAST(
	 (SELECT AVG(ticketprice) 
	  FROM tickets 
	  WHERE sclass = 'Business') as int) -
 CAST(
	 (SELECT AVG(ticketprice) 
	  FROM tickets 
	  WHERE sclass = 'Economy') as int) AS difprice;

 SELECT rout.departure, rout.arrival, flig.aircraftnumber, tick.placenumber, tick.usd_ticketprice
 FROM (SELECT to_usd(ticketprice, 74.84) AS usd_ticketprice,placenumber,flightid
 FROM tickets 
 WHERE to_usd(ticketprice, 74.84) < 1000) AS tick JOIN
 (SELECT aircraftnumber, flightid, routeid FROM Flights) AS flig 
 ON tick.flightid = flig.flightid
 JOIN (SELECT departure, arrival, routeid FROM Routs WHERE departure = 'Москва' AND arrival = 'Рим') AS rout
 ON flig.routeid = rout.routeid;

SELECT R.departure, R.arrival,
COUNT(Pa.fullname) AS passengerscount, MIN(Ti.ticketprice) AS min_ticketprice
FROM passengers Pa
JOIN tickets Ti ON Ti.passengerid = Pa.passengerid
JOIN routs R ON R.routeid = Ti.routeid
GROUP BY R.departure, R.arrival
HAVING R.departure = 'Москва' 
AND MIN(Ti.ticketprice) > 20000;

SELECT R.departure, R.arrival, F.aircraftnumber,
Ti.placenumber, Ti.sclass, Pa.fullname
FROM Routs R
JOIN Flights F ON R.routeid = F.routeid
JOIN tickets Ti ON Ti.flightid = F.flightid
JOIN passengers Pa ON Pa.passengerid = Ti.passengerid
WHERE Pa.passengerid = ANY(SELECT passengerid FROM passengers WHERE fullname = 'Иванов Иван Иванович');
