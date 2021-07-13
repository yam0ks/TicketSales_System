#ifndef DATABASE_H
#define DATABASE_H

#include <QObject>
#include <QSqlDatabase>

class DataBase : public QObject
{
public:
    DataBase();
    bool makeConnection(const QString& login, const QString& password);

    void closeDataBase();

    QSqlQuery SelectAll(const QString& table);

    bool registerUser(const QString& login, const QString& password,
                      const QString& passportData, const QString& fullName,
                      const QString& phoneNumber, const QString& email);

    QString checkUser();

    QString validateRoute(const QString& departure, const QString& departureAirport,
                          const QString& arrival, const QString& arrivAlirport);

    QString validateFlight(const QString& aircraftNumber, const QString& ticketsCount, const QString& passengersCount);

    QString validateTicket(const QString& placeNumber, const QString& flightID, const QString& ticketPrice);

    QString validateUser(const QString& login, const QString& passportData, const QString& fullName,
                         const QString& phoneNumber, const QString& email);

    QString validateTicketSale(const QString& placeNumber, const QString& aircraftNumber);

    QString validateTicketRefund(const QString& placeNumber, const QString& aircraftNumber);

    void setLogin(QString newLogin);

    QString getLogin();

private:
    QSqlDatabase database;
    QString _login;
};

#endif // DATABASE_H
