#ifndef CLIENTWINDOW_H
#define CLIENTWINDOW_H

#include "database.h"

#include <QMainWindow>
#include <QString>
#include <QMap>
#include <QSqlQueryModel>
#include <QTableView>
#include <QMessageBox>
#include <QSqlError>
#include <QSqlQuery>
#include <QSqlRecord>
#include <QStandardItem>
#include <QDate>
#include <QComboBox>
#include <QObject>
#include <QMessageBox>
#include <QItemSelectionModel>

QT_BEGIN_NAMESPACE
namespace Ui { class ClientWindow; }
QT_END_NAMESPACE

class ClientWindow : public QMainWindow
{
    Q_OBJECT

public:
    explicit ClientWindow(QWidget *parent = nullptr);

    DataBase* getDataBase();

    void showWindow();

    void PrepareForClient();

    void PrepareForAdmin();

    void fillComboBox(QComboBox* combobox, QSqlQuery query);

    QMap<QString, int> fillComboBoxWithIds(QComboBox* combobox, QSqlQuery query,  QMap<QString, int> map);

    void setTableViewResize(QSqlQueryModel* model, QTableView* view);

    void SetHeadersNames(QSqlQueryModel* model, QList<QString> headers);

    ~ClientWindow();

private slots:

    void on_Client_flight_info_changed();

    void on_Client_current_flight_selected();

    void on_Client_ticket_selected();

    void on_Client_refund_selected();

    void on_Client_ticket_button_clicked();

    void on_Client_topUp_button_clicked();

    void on_Client_saveChanges_button_clicked();

    void on_Client_flight_button_clicked();

    void on_Client_refund_button_clicked();

    void on_Admin_route_selected();

    void on_Admin_flight_selected();

    void on_Admin_ticket_selected();

    void on_Admin_user_selected();

    void on_Admin_sale_selected();

    void on_Admin_refund_selected();

    void on_Admin_view_selected();

    void on_Admin_order_changed();

    void on_Admin_delete_routs_button_clicked();

    void on_Admin_update_routs_button_clicked();

    void on_Admin_insert_routs_button_clicked();

    void on_Admin_delete_flights_button_clicked();

    void on_Admin_update_flights_button_clicked();

    void on_Admin_insert_flights_button_clicked();

    void on_Admin_delete_tickets_button_clicked();

    void on_Admin_update_tickets_button_clicked();

    void on_Admin_insert_tickets_button_clicked();

    void on_Admin_delete_users_button_clicked();

    void on_Admin_update_users_button_clicked();

    void on_Admin_insert_users_button_clicked();

    void on_Admin_Grant_button_clicked();

    void on_Admin_Revoke_button_clicked();

    void on_Admin_delete_sales_button_clicked();

    void on_Admin_update_sale_button_clicked();

    void on_Admin_insert_sales_button_clicked();

    void on_Admin_delete_refunds_button_clicked();

    void on_Admin_update_refunds_button_clicked();

    void on_Admin_insert_refunds_button_clicked();

    void on_Admin_select_case_button_clicked();

    void on_Admin_select_view_button_clicked();

    void on_Admin_select_C_WHERE_button_clicked();

    void on_Admin_select_C_FROM_button_clicked();

    void on_Admin_select_C_SELEC_button_clicked();

    void on_Admin_change_status_button_clicked();

    void on_Admin_select_WHERE_button_clicked();

    void on_Admin_select_FROM_button_clicked();

    void on_Admin_select_SELECT_button_clicked();

    void on_Admin_select_AGR_button_clicked();

    void on_Admin_select_predicate_button_clicked();

    void on_Admin_make_sales_button_clicked();

    void on_Admin_viewUpdate_button_clicked();

    void on_update_table_info_clicked();

    void on_shortcut_pressed();

private:
    Ui::ClientWindow *ui;
    DataBase database;

    QString passengerPassport;
    QString passengerName;
    QString passengerPhone;
    QString passengerEmail;

    QString ticketsCount;
    QString passengersCount;
    QString reserved;

    QSqlQueryModel* Client_historyModel;
    QSqlQueryModel* Client_flightsModel;
    QSqlQueryModel* Client_currentFlights;
    QSqlQueryModel* Client_ticketsModel;

    QModelIndex Client_flight_index;
    QModelIndex Client_ticket_index;
    QModelIndex Client_refund_index;

    QSqlQueryModel* Admin_routsModel;
    QSqlQueryModel* Admin_flightsModel;
    QSqlQueryModel* Admin_ticketsModel;
    QSqlQueryModel* Admin_usersModel;
    QSqlQueryModel* Admin_salesModel;
    QSqlQueryModel* Admin_refundsModel;
    QSqlQueryModel* Admin_technicalModel;
    QSqlQueryModel* Admin_viewModel;

    QModelIndex Admin_routs_index;
    QModelIndex Admin_flights_index;
    QModelIndex Admin_tickets_index;
    QModelIndex Admin_users_index;
    QModelIndex Admin_sales_index;
    QModelIndex Admin_refunds_index;
    QModelIndex Admin_view_index;

    QMap<QString, int> routeIDs;
    QMap<QString, int> ticketIDs;
    QMap<QString, int> flightIDs;

    QList<QString> routeHeadersNames= {"routeid", "Пункт Вылета", "Аэропорт вылета", "Пункт прилета", "Аэропорт прилета", "Время в пути"};
    QList<QString> flightsHeadersNames= {"flightid", "Номер рейса", "Дата вылета", "Дата прибытия", "Статус", "Количество билетов", "Количество пассажиров", "routeid"};
    QList<QString> ticketsHeadersNames= {"ticketid", "Номер места", "Зарезервирован", "Цена билета", "Класс места", "routeid", "passengerid", "flightid"};
    QList<QString> passengersHeadersNames= {"passengerid", "Номер пасспорта", "ФИО", "Номер телефона", "Электронная почта", "Сумма счета"};
    QList<QString> salesHeadersNames= {"saleid", "Дата операции", "НДС", "ticketid"};
    QList<QString> refundsHeadersNames= {"refundid", "Дата операции", "Причина возврата", "ticketid"};
    QList<QString> viewHeadersNames= {"ticketid", "Номер рейса", "Номер места", "Цена билета", "Класс места", "ФИО", "Номер телефона", "Электронная почта", "passengerid", "flightid"};

};

#endif // CLIENTWINDOW_H
