#include "database.h"

#include <QMessageBox>
#include <QSqlQuery>
#include <QSqlError>
#include <QSqlDriver>
#include <QVariant>
#include <QProcess>
#include <QDebug>
#include <QTime>

DataBase::DataBase()
{
}

bool DataBase::makeConnection(const QString& login, const QString& password)
{
    database = QSqlDatabase::addDatabase("QPSQL7");
    database.setDatabaseName("aviasales");
    database.setUserName(login);
    database.setHostName("127.0.0.1");
    database.setPort(5432);
    database.setPassword(password);

    if (!database.open()) return false;

    return true;
}

void DataBase::closeDataBase()
{
    database.close();
}

QSqlQuery DataBase::SelectAll(const QString &table)
{
    QString temp = table;
    if(temp == "routs")
        temp = "route";
    else
        temp = temp.remove(temp.length() - 1, 1);

    QString query = "SELECT * FROM " + table + " ORDER BY " + temp + "id;";

    QSqlQuery selectAllQuery;
        selectAllQuery.exec(query);
        return selectAllQuery;
}

bool DataBase::registerUser(const QString &login, const QString &password,
                            const QString &passportData, const QString &fullName,
                            const QString &phoneNumber, const QString &email)
{
    QString validation = validateUser(login, passportData, fullName, phoneNumber, email);
    if(validation != QString()){
        QMessageBox::warning(nullptr, "Ошибка регистрации!", validation); return false;}

    QSqlQuery registerQuery;
    registerQuery.exec("CALL register_user('" + login +"','" + password + "','" + passportData + "','" +
                   fullName + "','" + phoneNumber + "','" + email +"');");
    return true;
}

QString DataBase::checkUser()
{
    QSqlQuery rolesCountQuery;
    rolesCountQuery.exec("SELECT "
               "CASE "
                   "WHEN (SELECT count(groname) FROM aviasales.pg_catalog.pg_group WHERE "
                        "(SELECT usesysid FROM aviasales.pg_catalog.pg_user WHERE usename = passengers.passengerid) = ANY(grolist)) > 1 "
                        "THEN 'Admin' "
                        "ELSE 'Client' "
               "END user_role "
               "FROM passengers WHERE passengerid = '" + _login + "';");
    rolesCountQuery.next();
    return rolesCountQuery.value(0).toString();
}

QString DataBase::validateRoute(const QString &departure, const QString &departureAirport, const QString &arrival, const QString &arrivalAirport)
{
    QRegExp depart(R"([a-zA-Zа-яА-Я\s\-]+)");
    QRegExp departAir(R"([a-zA-Zа-яА-Я\-\s\d]+)");
    QRegExp arriv(R"([a-zA-Zа-яА-Я\-\s]+)");
    QRegExp arrivAir(R"([a-zA-Zа-яА-Я\-\s\d]+)");

    if(!depart.exactMatch(departure))
        return "Неверный формат пункта отправления!";
    else if(!departAir.exactMatch(departureAirport))
        return "Неверный формат аэропорта отправления!";
    else if(!arriv.exactMatch(arrival))
        return "Неверный формат пункта прибытия!";
    else if(!arrivAir.exactMatch(arrivalAirport))
        return "Неверный формат аэропорта прибытия!";
    else return QString();
}

QString DataBase::validateFlight(const QString& aircraftNumber, const QString& ticketsCount, const QString& passengersCount)
{
    QRegExp flightNumber(R"([A-Z]{1,2}\d+)");
    QRegExp ticketsCnt(R"(\d+)");
    QRegExp passengersCnt(R"(\d+)");

    if(!flightNumber.exactMatch(aircraftNumber))
        return "Неверный формат бортового номера самолета!";
    else if(!ticketsCnt.exactMatch(ticketsCount))
        return "Неверный формат количества билетов!";
    else if(!passengersCnt.exactMatch(passengersCount))
        return "Неверный формат количества пассажиров!";
    else return QString();
}

QString DataBase::validateTicket(const QString &placeNumber, const QString &flightID, const QString& ticketPrice)
{
    QRegExp place(R"(\d{1,2}[A-Z])");
    QRegExp price(R"(\d+)");

    QSqlQuery ticketsCountQuery;
        ticketsCountQuery.exec("SELECT COUNT(ticketid) FROM tickets Ti "
                               "JOIN flights ON flights.flightid = Ti.flightid "
                               "WHERE Ti.placenumber = '" + placeNumber + "' AND Ti.flightid = '" + flightID + "';");
        ticketsCountQuery.next();

    if(!place.exactMatch(placeNumber))
        return "Неверный формат номера места!";
    else if(ticketsCountQuery.value(0).toInt() != 0)
        return "Аналогичный билет уже присутствует в таблице!";
    else if(!price.exactMatch(ticketPrice))
        return "Неверный формат стоимости билета!";
    else return QString();
}

QString DataBase::validateUser(const QString &login, const QString &passportData, const QString &fullName, const QString &phoneNumber, const QString &email)
{
    QRegExp log(R"([A-Za-z\d\_]+)");
    QRegExp passport(R"(\d+)");
    QRegExp name(R"([a-zA-Zа-яА-Я\-]+\s[a-zA-Zа-яА-Я\-]+\s{0,1}[a-zA-Zа-яА-Я\-]+)");
    QRegExp phone(R"(\+\d+\(\d+\)\d+-\d+-\d+)");
    QRegExp mail(R"([a-zA-Z\d]+@[a-z]+.[a-z]+)");

    QSqlQuery billQuery;
        billQuery.exec("SELECT bill FROM passengers WHERE passengerid = '" + login + "';");
        billQuery.next();

    if(!log.exactMatch(login))
        return "Неверный формат логина!";
    else if(!passport.exactMatch(passportData))
        return "Неверный формат пасспорта!";
    else if(!name.exactMatch(fullName))
        return "Неверный формат ФИО!";
    else if(!phone.exactMatch(phoneNumber))
        return "Неверный формат номера телефона!";
    else if(!mail.exactMatch(email))
        return "Неверный формат почты!";
    else return QString();
}

QString DataBase::validateTicketSale(const QString &placeNumber, const QString &aircraftNumber)
{
    QSqlQuery findTicketQuery;
        findTicketQuery.exec("SELECT Ti.ticketid "
                             "FROM tickets Ti "
                             "JOIN flights F ON Ti.flightid = F.flightid "
                             "WHERE Ti.placenumber = '" + placeNumber + "' "
                             "AND F.aircraftnumber = '" + aircraftNumber + "' "
                             "AND F.status <> 'Arrived' "
                             "GROUP BY Ti.ticketid");
        findTicketQuery.next();
        QString ticketID = findTicketQuery.value(0).toString();

    QSqlQuery isReservedQuery;
        isReservedQuery.exec("SELECT reserved FROM tickets Ti WHERE Ti.ticketid = '" + ticketID + "';");
        isReservedQuery.next();
        QString isReserved = isReservedQuery.value(0).toString();

    QSqlQuery timeToDepartureQuery;
        timeToDepartureQuery.exec("SELECT EXTRACT(epoch FROM get_interval('" + aircraftNumber + "'));");
        timeToDepartureQuery.next();
        QString timeToDeparture = timeToDepartureQuery.value(0).toString();
        timeToDeparture.truncate(timeToDeparture.lastIndexOf('.'));

    QSqlQuery ticketPriceQuery;
        ticketPriceQuery.exec("SELECT ticketprice FROM tickets WHERE ticketid = '" + ticketID + "';");
        ticketPriceQuery.next();
        int ticketPrice = ticketPriceQuery.value(0).toInt();

    QSqlQuery userBillQuery;
        userBillQuery.exec("SELECT bill from passengers WHERE passengerid = '" + getLogin() + "';");
        userBillQuery.next();
        int bill = userBillQuery.value(0).toInt();

        if(ticketID.isEmpty())
            return "Такого билета не существует!";
        else if(isReserved == "true")
            return "Билет уже зарезервирован!";
        else if(timeToDeparture.toInt() < 2400)
            return "До вылета осталось менее сорока минут или рейс уже отправлен!";
        else if(ticketPrice > bill)
            return "На счету недостаточно средств!";
        else return QString();
}

QString DataBase::validateTicketRefund(const QString &placeNumber, const QString &aircraftNumber)
{
    QSqlQuery findTicketQuery;
        findTicketQuery.exec("SELECT Ti.ticketid "
                             "FROM tickets Ti "
                             "JOIN flights F ON Ti.flightid = F.flightid "
                             "WHERE Ti.placenumber = '" + placeNumber + "' "
                             "AND F.aircraftnumber = '" + aircraftNumber + "' "
                             "AND F.status <> 'Arrived' "
                             "GROUP BY Ti.ticketid");
        findTicketQuery.next();
        QString ticketID = findTicketQuery.value(0).toString();

    QSqlQuery isReservedQuery;
        isReservedQuery.exec("SELECT reserved FROM tickets Ti WHERE Ti.ticketid = '" + ticketID + "';");
        isReservedQuery.next();
        QString isReserved = isReservedQuery.value(0).toString();

    QSqlQuery timeToDepartureQuery;
        timeToDepartureQuery.exec("SELECT EXTRACT(epoch FROM get_interval('" + aircraftNumber + "'));");
        timeToDepartureQuery.next();
        QString timeToDeparture = timeToDepartureQuery.value(0).toString();
        timeToDeparture.truncate(timeToDeparture.lastIndexOf('.'));

    QSqlQuery ticketOwnerQuery;
        ticketOwnerQuery.exec("SELECT passengerid FROM tickets WHERE ticketid = '" + ticketID + "';");
        ticketOwnerQuery.next();
        QString ticketOwner = ticketOwnerQuery.value(0).toString();

    if(ticketID.isEmpty())
        return "Такого билета не существует!";
    else if(isReserved == "false")
        return "Билет не был зарезервирован!";
    else if(timeToDeparture.toInt() < 2400)
        return "До вылета осталось менее сорока минут или рейс уже отправлен!";
    else if(ticketOwner != getLogin())
        return "Вы не являетесь владельцем данного билета!";
    else return QString();
}

void DataBase::setLogin(QString newLogin)
{
    _login = newLogin;
}

QString DataBase::getLogin()
{
    return _login;
}
