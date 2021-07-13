#include "clientwindow.h"
#include "ui_clientwindow.h"

#include <QShortcut>

ClientWindow::ClientWindow(QWidget *parent)
    : QMainWindow(parent)
    , ui(new Ui::ClientWindow)
{
    ui->setupUi(this);
}

DataBase* ClientWindow::getDataBase()
{
    return &database;
}

void ClientWindow::showWindow()
{
    if(database.checkUser() == "Admin"){
        ui->tabWidget->removeTab(1);
        ui->tabWidget->removeTab(0);
        PrepareForAdmin();
        ui->tabWidget->setCurrentIndex(0);
        this->show();
    }
    else if(database.checkUser() == "Client"){
        ui->tabWidget->removeTab(9);
        ui->tabWidget->removeTab(8);
        ui->tabWidget->removeTab(7);
        ui->tabWidget->removeTab(6);
        ui->tabWidget->removeTab(5);
        ui->tabWidget->removeTab(4);
        ui->tabWidget->removeTab(3);
        ui->tabWidget->removeTab(2);
        PrepareForClient();
        ui->tabWidget->setCurrentIndex(0);
        this->show();
    }
    else
        return;
}

void ClientWindow::PrepareForClient()
{
    QSqlQuery userInfoQuery;
        userInfoQuery.exec("SELECT passportdata, fullname, mobilephone, email, bill "
                   "FROM passengers WHERE passengerid = '" + database.getLogin() + "';");
        userInfoQuery.next();
        ui->Client_line_passport->setText(userInfoQuery.value(0).toString());
        ui->Client_line_fullname->setText(userInfoQuery.value(1).toString());
        ui->Client_line_phone->setText(userInfoQuery.value(2).toString());
        ui->Client_line_email->setText(userInfoQuery.value(3).toString());
        ui->bill_label->setText(userInfoQuery.value(4).toString() + " ₽");

     QSqlQuery flightsHistoryQuery;
        flightsHistoryQuery.exec("SELECT R.departure AS Вылет, R.arrival AS Прилет, F.aircraftnumber AS Рейс, "
                    "F.departuredate AS \"Дата вылета\", F.arrivaldate AS \"Дата прилета\" FROM tickets Ti "
                    "JOIN passengers Pa ON Pa.passengerid = Ti.passengerid "
                    "JOIN flights F ON F.flightid = Ti.flightid "
                    "JOIN routs R ON F.routeid = R.routeid WHERE Pa.passengerid = '" + database.getLogin() +
                    "' AND F.arrivaldate < localtimestamp ORDER BY F.flightid;");

    Client_historyModel = new QSqlQueryModel(this);
    Client_historyModel->setQuery(flightsHistoryQuery);
    ui->Client_history_tableView->setModel(Client_historyModel);
    setTableViewResize(Client_historyModel, ui->Client_history_tableView);

    QSqlQuery futureFlightsQuery;
        futureFlightsQuery.exec("SELECT R.departure AS Вылет, R.arrival AS Прилет, F.aircraftnumber AS Рейс, "
                    "Ti.placenumber AS Место, F.departuredate AS \"Дата вылета\", F.arrivaldate AS \"Дата прилета\" "
                    "FROM tickets Ti JOIN passengers Pa ON Pa.passengerid = Ti.passengerid "
                    "JOIN flights F ON F.flightid = Ti.flightid "
                    "JOIN routs R ON F.routeid = R.routeid WHERE Pa.passengerid = '" + database.getLogin() +
                    "' AND F.arrivaldate > localtimestamp ORDER BY F.flightid;");

    Client_flightsModel = new QSqlQueryModel(this);
    ui->Client_flights_tableView->setModel(Client_flightsModel);
    Client_flightsModel->setQuery(futureFlightsQuery);
    setTableViewResize(Client_flightsModel, ui->Client_flights_tableView);

    Client_currentFlights = new QSqlQueryModel(this);
    ui->Client_currentFlights_tableView->setModel(Client_currentFlights);

    Client_ticketsModel = new QSqlQueryModel(this);
    ui->Client_tickets_tableView->setModel(Client_ticketsModel);

    QSqlQuery departuresQuery;
        departuresQuery.exec("SELECT R.departure FROM routs R "
                   "JOIN flights F ON F.routeid = R.routeid "
                   "WHERE F.departuredate > localtimestamp GROUP BY R.departure;");
    fillComboBox(ui->Client_departure_comboBox, departuresQuery);

    QSqlQuery arrivalsQuery;
        arrivalsQuery.exec("SELECT R.arrival FROM routs R "
                   "JOIN flights F ON F.routeid = R.routeid "
                   "WHERE F.departuredate > localtimestamp GROUP BY R.arrival;");
    fillComboBox(ui->Client_arrival_comboBox, arrivalsQuery);

    ui->Client_flightDate_edit->setDate(QDate::currentDate());

    passengerPassport = ui->Client_line_passport->text();
    passengerName = ui->Client_line_fullname->text();
    passengerPhone = ui->Client_line_phone->text();
    passengerEmail = ui->Client_line_email->text();

    QShortcut* switchTabShortCut = new QShortcut(QKeySequence("Ctrl+Tab"), this);

    connect(ui->Client_departure_comboBox, QOverload<int>::of(&QComboBox::activated), this, &ClientWindow::on_Client_flight_info_changed);

    connect(ui->Client_arrival_comboBox, QOverload<int>::of(&QComboBox::activated), this, &ClientWindow::on_Client_flight_info_changed);

    connect(ui->Client_flightDate_edit, &QDateEdit::dateChanged, this, &ClientWindow::on_Client_flight_info_changed);

    connect(ui->Client_currentFlights_tableView->selectionModel(), &QItemSelectionModel::selectionChanged,
            this, &ClientWindow::on_Client_current_flight_selected);

    connect(ui->Client_tickets_tableView->selectionModel(), &QItemSelectionModel::selectionChanged,
            this, &ClientWindow::on_Client_ticket_selected);

    connect(ui->Client_flights_tableView->selectionModel(), &QItemSelectionModel::selectionChanged,
            this, &ClientWindow::on_Client_refund_selected);

    connect(switchTabShortCut, &QShortcut::activated,
            this, &ClientWindow::on_shortcut_pressed);
}

void ClientWindow::PrepareForAdmin()
{
    Admin_routsModel = new QSqlQueryModel(this);
    Admin_routsModel->setQuery(database.SelectAll("routs"));
    ui->Admin_routs_tableView->setModel(Admin_routsModel);
    SetHeadersNames(Admin_routsModel, routeHeadersNames);
    setTableViewResize(Admin_routsModel, ui->Admin_routs_tableView);
    ui->Admin_routs_tableView->hideColumn(0);

    Admin_flightsModel = new QSqlQueryModel(this);
    Admin_flightsModel->setQuery(database.SelectAll("flights"));
    ui->Admin_flights_tableView->setModel(Admin_flightsModel);
    SetHeadersNames(Admin_flightsModel, flightsHeadersNames);
    setTableViewResize(Admin_flightsModel, ui->Admin_flights_tableView);
    ui->Admin_flights_tableView->hideColumn(0);
    ui->Admin_flights_tableView->hideColumn(7);

    Admin_ticketsModel = new QSqlQueryModel(this);
    Admin_ticketsModel->setQuery(database.SelectAll("tickets"));
    ui->Admin_tickets_tableView->setModel(Admin_ticketsModel);
    SetHeadersNames(Admin_ticketsModel, ticketsHeadersNames);
    setTableViewResize(Admin_ticketsModel, ui->Admin_tickets_tableView);
    ui->Admin_tickets_tableView->hideColumn(0);
    ui->Admin_tickets_tableView->hideColumn(5);
    ui->Admin_tickets_tableView->hideColumn(6);
    ui->Admin_tickets_tableView->hideColumn(7);

    Admin_usersModel = new QSqlQueryModel(this);
    Admin_usersModel->setQuery("SELECT *, "
                               "CASE "
                                   "WHEN (SELECT count(groname) FROM aviasales.pg_catalog.pg_group WHERE "
                                        "(SELECT usesysid FROM aviasales.pg_catalog.pg_user WHERE usename = passengers.passengerid) = ANY(grolist)) > 1 "
                                        "THEN 'Admin' "
                                        "ELSE 'Client' "
                               "END Роль "
                               "FROM passengers ORDER BY passengers.passengerid;");
    ui->Admin_users_tableView->setModel(Admin_usersModel);
    SetHeadersNames(Admin_usersModel, passengersHeadersNames);
    setTableViewResize(Admin_usersModel, ui->Admin_users_tableView);
    ui->Admin_users_tableView->hideColumn(0);

    Admin_salesModel = new QSqlQueryModel(this);
    Admin_salesModel->setQuery(database.SelectAll("sales"));
    ui->Admin_sales_tableView->setModel(Admin_salesModel);
    SetHeadersNames(Admin_salesModel, salesHeadersNames);
    setTableViewResize(Admin_salesModel, ui->Admin_sales_tableView);
    ui->Admin_sales_tableView->hideColumn(0);
    ui->Admin_sales_tableView->hideColumn(3);

    Admin_refundsModel = new QSqlQueryModel(this);
    Admin_refundsModel->setQuery(database.SelectAll("refunds"));
    ui->Admin_refunds_tableView->setModel(Admin_refundsModel);
    SetHeadersNames(Admin_refundsModel, refundsHeadersNames);
    setTableViewResize(Admin_refundsModel, ui->Admin_refunds_tableView);
    ui->Admin_refunds_tableView->hideColumn(0);
    ui->Admin_refunds_tableView->hideColumn(3);

    Admin_technicalModel = new QSqlQueryModel(this);
    ui->Admin_selects_tableView->setModel(Admin_technicalModel);

    Admin_viewModel = new QSqlQueryModel(this);
    Admin_viewModel->setQuery("SELECT * FROM tickets_n_passengers_info "
                              "ORDER BY aircraftnumber;");
    ui->Admin_view_tableView->setModel(Admin_viewModel);
    SetHeadersNames(Admin_viewModel, viewHeadersNames);
    setTableViewResize(Admin_viewModel, ui->Admin_view_tableView);
    ui->Admin_view_tableView->hideColumn(0);
    ui->Admin_view_tableView->hideColumn(8);
    ui->Admin_view_tableView->hideColumn(9);


    QSqlQuery updateFlightStatusQuery;
        updateFlightStatusQuery.exec("SELECT unnest(enum_range(NULL::flightstatus));");
        fillComboBox(ui->Admin_update_status_comboBox, updateFlightStatusQuery);
    QSqlQuery insertFlightStatusQuery;
        insertFlightStatusQuery.exec("SELECT unnest(enum_range(NULL::flightstatus));");
        fillComboBox(ui->Admin_insert_status_comboBox, insertFlightStatusQuery);

    QSqlQuery updateRouteIdsQuery;
        updateRouteIdsQuery.exec("SELECT departure, arrival, routeid FROM routs;");
        routeIDs = fillComboBoxWithIds(ui->Admin_update_routeid_comboBox, updateRouteIdsQuery, routeIDs);
    QSqlQuery insertRouteIdsQuery;
        insertRouteIdsQuery.exec("SELECT departure, arrival, routeid FROM routs;");
        fillComboBoxWithIds(ui->Admin_insert_routeid_comboBox, insertRouteIdsQuery, routeIDs);

    QSqlQuery updateReservedQuery;
        updateReservedQuery.exec("SELECT reserved FROM tickets GROUP BY reserved;");
        fillComboBox(ui->Admin_update_reserved_comboBox, updateReservedQuery);
    QSqlQuery insertReservedQuery;
        insertReservedQuery.exec("SELECT reserved FROM tickets GROUP BY reserved;");
        fillComboBox(ui->Admin_insert_reserved_comboBox, insertReservedQuery);

    QSqlQuery updateSeatClassQuery;
        updateSeatClassQuery.exec("SELECT unnest(enum_range(NULL::seatclass));");
        fillComboBox(ui->Admin_update_ticketClass_comboBox, updateSeatClassQuery);
    QSqlQuery insertSeatClassQuery;
        insertSeatClassQuery.exec("SELECT unnest(enum_range(NULL::seatclass));");
        fillComboBox(ui->Admin_insert_ticketClass_comboBox, insertSeatClassQuery);

    QSqlQuery updateTiRouteIdsQuery;
        updateTiRouteIdsQuery.exec("SELECT departure, arrival, routeid FROM routs;");
        fillComboBoxWithIds(ui->Admin_update_Ti_routeid_comboBox, updateTiRouteIdsQuery, routeIDs);
    QSqlQuery insertTiRouteIdsQuery;
        insertTiRouteIdsQuery.exec("SELECT departure, arrival, routeid FROM routs;");
        fillComboBoxWithIds(ui->Admin_insert_Ti_routeid_comboBox, insertTiRouteIdsQuery, routeIDs);

    QSqlQuery updateTiPassengerIdsQuery;
        updateTiPassengerIdsQuery.exec("SELECT passengerid FROM passengers;");
        fillComboBox(ui->Admin_update_Ti_passengerid_comboBox, updateTiPassengerIdsQuery);
    QSqlQuery insertTiPassengerIdsQuery;
        insertTiPassengerIdsQuery.exec("SELECT passengerid FROM passengers;");
        fillComboBox(ui->Admin_insert_Ti_passengerid_comboBox, insertTiPassengerIdsQuery);

    QSqlQuery updateTiFlightIdsQuery;
        updateTiFlightIdsQuery.exec("SELECT aircraftnumber, departuredate, flightid FROM flights;");
        flightIDs = fillComboBoxWithIds(ui->Admin_update_Ti_flightid_comboBox, updateTiFlightIdsQuery, flightIDs);
    QSqlQuery insertTiFlightIdsQuery;
        insertTiFlightIdsQuery.exec("SELECT aircraftnumber, departuredate, flightid FROM flights;");
        fillComboBoxWithIds(ui->Admin_insert_Ti_flightid_comboBox, insertTiFlightIdsQuery, flightIDs);

    QSqlQuery updateSTicketIdsQuery;
        updateSTicketIdsQuery.exec("SELECT F.aircraftnumber, Ti.placenumber, Ti.ticketid FROM tickets Ti "
                    "JOIN flights F ON F.flightid = Ti.flightid;");
        ticketIDs = fillComboBoxWithIds(ui->Admin_update_S_ticketid_comboBox, updateSTicketIdsQuery, ticketIDs);
    QSqlQuery insertSTicketIdsQuery;
        insertSTicketIdsQuery.exec("SELECT F.aircraftnumber, Ti.placenumber, Ti.ticketid FROM tickets Ti "
                    "JOIN flights F ON F.flightid = Ti.flightid;");
        fillComboBoxWithIds(ui->Admin_insert_S_ticketid_comboBox, insertSTicketIdsQuery, ticketIDs);

    QSqlQuery updateRTicketIdsQuery;
        updateRTicketIdsQuery.exec("SELECT F.aircraftnumber, Ti.placenumber, Ti.ticketid FROM tickets Ti "
                    "JOIN flights F ON F.flightid = Ti.flightid;");
        fillComboBoxWithIds(ui->Admin_update_R_ticketid_comboBox, updateRTicketIdsQuery, ticketIDs);
    QSqlQuery insertRTicketIdsQuery;
        insertRTicketIdsQuery.exec("SELECT F.aircraftnumber, Ti.placenumber, Ti.ticketid FROM tickets Ti "
                    "JOIN flights F ON F.flightid = Ti.flightid;");
        fillComboBoxWithIds(ui->Admin_insert_R_ticketid_comboBox, insertRTicketIdsQuery, ticketIDs);

    QSqlQuery orderViewQuery;
        orderViewQuery.exec("SELECT column_name "
                            "FROM information_schema.columns "
                            "WHERE table_schema = 'public' "
                            "AND table_name   = 'tickets_n_passengers_info' "
                            "AND column_name <> 'ticketid' AND column_name <> 'flightid' "
                            "AND column_name <> 'passengerid';");
        fillComboBox(ui->Admin_view_sort_comboBox, orderViewQuery);
    QSqlQuery viewTicketClassQuery;
        viewTicketClassQuery.exec("SELECT unnest(enum_range(NULL::seatclass));");
        fillComboBox(ui->Admin_view_ticketClass_comboBox, viewTicketClassQuery);

    ui->Admin_insert_flighttime_DateTimeEdit->setTime(QTime::currentTime());
    ui->Admin_insert_departuredate_DateTime->setDateTime(QDateTime::currentDateTime());
    ui->Admin_insert_arrivaldate_DateTime->setDateTime(QDateTime::currentDateTime());
    ui->Admin_insert_sales_dateTimeEdit->setDateTime(QDateTime::currentDateTime());
    ui->Admin_insert_refund_DateTimeEdit->setDateTime(QDateTime::currentDateTime());


    QShortcut* switchTabShortCut = new QShortcut(QKeySequence("Ctrl+Tab"), this);

    connect(ui->Admin_routs_tableView->selectionModel(), &QItemSelectionModel::selectionChanged,
            this, &ClientWindow::on_Admin_route_selected);

    connect(ui->Admin_flights_tableView->selectionModel(), &QItemSelectionModel::selectionChanged,
            this, &ClientWindow::on_Admin_flight_selected);

    connect(ui->Admin_tickets_tableView->selectionModel(), &QItemSelectionModel::selectionChanged,
            this, &ClientWindow::on_Admin_ticket_selected);

    connect(ui->Admin_users_tableView->selectionModel(), &QItemSelectionModel::selectionChanged,
            this, &ClientWindow::on_Admin_user_selected);

    connect(ui->Admin_sales_tableView->selectionModel(), &QItemSelectionModel::selectionChanged,
            this, &ClientWindow::on_Admin_sale_selected);

    connect(ui->Admin_refunds_tableView->selectionModel(), &QItemSelectionModel::selectionChanged,
            this, &ClientWindow::on_Admin_refund_selected);

    connect(ui->Admin_view_tableView->selectionModel(), &QItemSelectionModel::selectionChanged,
            this, &ClientWindow::on_Admin_view_selected);

    connect(ui->Admin_view_sort_comboBox, QOverload<int>::of(&QComboBox::activated),
            this, &ClientWindow::on_Admin_order_changed);

    connect(ui->Admin_routes_updInfo_button, &QAbstractButton::clicked,
            this, &ClientWindow::on_update_table_info_clicked);

    connect(ui->Admin_flights_updInfo_button, &QAbstractButton::clicked,
            this, &ClientWindow::on_update_table_info_clicked);

    connect(ui->Admin_tickets_updInfo_button, &QAbstractButton::clicked,
            this, &ClientWindow::on_update_table_info_clicked);

    connect(ui->Admin_users_updInfo_button, &QAbstractButton::clicked,
            this, &ClientWindow::on_update_table_info_clicked);

    connect(ui->Admin_sales_updInfo_button, &QAbstractButton::clicked,
            this, &ClientWindow::on_update_table_info_clicked);

    connect(ui->Admin_refunds_updInfo_button, &QAbstractButton::clicked,
            this, &ClientWindow::on_update_table_info_clicked);

    connect(ui->Admin_view_updInfo_button, &QAbstractButton::clicked,
            this, &ClientWindow::on_update_table_info_clicked);

    connect(switchTabShortCut, &QShortcut::activated,
            this, &ClientWindow::on_shortcut_pressed);

}

void ClientWindow::fillComboBox(QComboBox* combobox, QSqlQuery query)
{
    QStandardItemModel* model =
            qobject_cast<QStandardItemModel*>(combobox->model());
    QModelIndex firstIndex = model->index(0, combobox->modelColumn(),
            combobox->rootModelIndex());
    QStandardItem* firstItem = model->itemFromIndex(firstIndex);
    firstItem->setSelectable(false);
    combobox->setItemData(0, QBrush(Qt::gray), Qt::TextColorRole);

    while(query.next()){
        combobox->addItem(query.value(0).toString());
    }
}

QMap<QString, int> ClientWindow::fillComboBoxWithIds(QComboBox *combobox, QSqlQuery query, QMap<QString, int> map)
{
    QStandardItemModel* model =
            qobject_cast<QStandardItemModel*>(combobox->model());
    QModelIndex firstIndex = model->index(0, combobox->modelColumn(),
            combobox->rootModelIndex());
    QStandardItem* firstItem = model->itemFromIndex(firstIndex);
    firstItem->setSelectable(false);
    combobox->setItemData(0, QBrush(Qt::gray), Qt::TextColorRole);

    while(query.next()){
        combobox->addItem(query.value(0).toString() + " " + query.value(1).toString());
        map[query.value(0).toString() + " " + query.value(1).toString()] = query.value(2).toInt();
    }
    return map;
}

void ClientWindow::setTableViewResize(QSqlQueryModel *model, QTableView* view)
{
    for(int i = 0; i < model->columnCount(); i++){
        view->horizontalHeader()->setSectionResizeMode(
               i, QHeaderView::Stretch);
    }
}

void ClientWindow::SetHeadersNames(QSqlQueryModel *model, QList<QString> headers)
{
    for(int i = 0; i < headers.size(); i++){
        model->setHeaderData(i, Qt::Horizontal, headers[i]);
    }
}

void ClientWindow::on_Client_flight_info_changed()
{
    QString departureDate = ui->Client_flightDate_edit->date().toString("yyyy-MM-dd");
    QString departure = ui->Client_departure_comboBox->currentText();
    QString arrival = ui->Client_arrival_comboBox->currentText();

    QSqlQuery flightInfoQuery;
        flightInfoQuery.exec("SELECT F.flightid, R.departure AS Вылет, R.arrival AS Прилет, F.aircraftnumber AS Рейс, "
                                "F.departuredate AS \"Дата вылета\", F.arrivaldate AS \"Дата прилета\" FROM flights F "
                                "JOIN routs R ON F.routeid = R.routeid WHERE F.departuredate >= '" + departureDate +
                                "' AND R.departure = '" + departure + "' AND R.arrival = '" + arrival + "' ORDER BY F.flightid;");

    Client_currentFlights->setQuery(flightInfoQuery);
    ui->Client_currentFlights_tableView->hideColumn(0);
    setTableViewResize(Client_currentFlights, ui->Client_currentFlights_tableView);

}

void ClientWindow::on_Client_current_flight_selected()
{
    Client_flight_index = ui->Client_currentFlights_tableView->selectionModel()->selectedIndexes().first();
}

void ClientWindow::on_Client_ticket_selected()
{
    Client_ticket_index = ui->Client_tickets_tableView->selectionModel()->selectedIndexes().first();
}

void ClientWindow::on_Client_refund_selected()
{
    Client_refund_index = ui->Client_flights_tableView->selectionModel()->selectedIndexes().first();
}

void ClientWindow::on_Client_ticket_button_clicked()
{
    if(Client_ticket_index != QModelIndex()){

        QString placeNumber = Client_ticketsModel->record(Client_ticket_index.row()).value("Место").toString();
        QString aircraftNumber = Client_ticketsModel->record(Client_ticket_index.row()).value("Рейс").toString();
        QString flightID = Client_ticketsModel->record(Client_ticket_index.row()).value("flightid").toString();
        QString validation = database.validateTicketSale(placeNumber, aircraftNumber);

        if(validation == QString()){

            QSqlQuery saleTicketQuery;
                saleTicketQuery.exec("CALL sale_ticket('" + database.getLogin() + "', '" + aircraftNumber + "', '" + placeNumber + "');");

            QSqlQuery billQuery;
                billQuery.exec("SELECT  bill FROM passengers WHERE "
                               "passengerid = '" + database.getLogin() + "';");
                billQuery.next();
                ui->bill_label->setText(billQuery.value(0).toString() + " ₽");

            QSqlQuery ticketsQuery;
                ticketsQuery.exec("SELECT F.flightid, F.aircraftnumber AS Рейс, Ti.placenumber AS Место, "
                           "Ti.ticketprice AS \"Цена билета\", Ti.sclass AS Класс "
                           "FROM tickets Ti JOIN flights F ON F.flightid = Ti.flightid "
                           "WHERE Ti.reserved <> true AND Ti.flightid = " + flightID + " ORDER BY Ti.ticketid;");
            Client_ticketsModel->setQuery(ticketsQuery);
            ui->Client_tickets_tableView->hideColumn(0);
            setTableViewResize(Client_ticketsModel, ui->Client_tickets_tableView);

            QSqlQuery flightInfoQuery;
                flightInfoQuery.exec("SELECT R.departure AS Вылет, R.arrival AS Прилет, F.aircraftnumber AS Рейс, "
                            "Ti.placenumber AS Место, F.departuredate AS \"Дата вылета\", F.arrivaldate AS \"Дата прилета\" "
                            "FROM tickets Ti JOIN passengers Pa ON Pa.passengerid = Ti.passengerid "
                            "JOIN flights F ON F.flightid = Ti.flightid "
                            "JOIN routs R ON F.routeid = R.routeid WHERE Pa.passengerid = '" +
                            database.getLogin() + "' AND F.arrivaldate > localtimestamp ORDER BY F.flightid;");

            Client_flightsModel->setQuery(flightInfoQuery);
            setTableViewResize(Client_flightsModel, ui->Client_flights_tableView);
        }
        else
            QMessageBox::warning(nullptr, "Ошибка покупки!", validation);
    }
    else
        QMessageBox::warning(nullptr, "Внимание!", "Выберите билет!");
}

void ClientWindow::on_Client_topUp_button_clicked()
{
    QRegExp billValidation(R"(\d+)");

    if(billValidation.exactMatch(ui->Client_amount_line->text())){

        long long amount = ui->Client_amount_line->text().toLongLong();

        QSqlQuery billQuery;
            billQuery.exec("SELECT  bill FROM passengers WHERE "
                           "passengerid = '" + database.getLogin() + "';");
            billQuery.next();
            long long bill = billQuery.value(0).toInt();

        if(bill + amount <= 1000000){

            QSqlQuery fillBillQuery;
                fillBillQuery.exec("CALL fill_bill('" + database.getLogin() + "', " + QString::number(amount) + ");");

            QSqlQuery newBillQuery;
                newBillQuery.exec("SELECT  bill FROM passengers WHERE "
                               "passengerid = '" + database.getLogin() + "';");
                newBillQuery.next();

            ui->bill_label->setText(newBillQuery.value(0).toString() + " ₽");
        }
        else
            QMessageBox::warning(nullptr, "Ошибка пополнения!", "Счет не может превышать 1000000");
    }
    else
        QMessageBox::warning(nullptr, "Ошибка пополнения!", "Неверный формат суммы пополнения!");

    ui->Client_amount_line->clear();
}

void ClientWindow::on_Client_saveChanges_button_clicked()
{
    QString passport = ui->Client_line_passport->text();
    QString fullName = ui->Client_line_fullname->text();
    QString phone = ui->Client_line_phone->text();
    QString email = ui->Client_line_email->text();

    QString validation = database.validateUser(database.getLogin(), passport, fullName,
                                               phone, email);
    if(validation == QString()){

        QSqlQuery updatePassengerQuery;
            updatePassengerQuery.exec("CALL update_passenger_data('" + database.getLogin() + "', '" + passport +
                       "', '" + fullName + "', '" + phone + "', '" + email + "');");

        passengerPassport = passport;
        passengerName = fullName;
        passengerPhone = phone;
        passengerEmail = email;
    }
    else{
        QMessageBox::warning(nullptr, "Ошибка изменения данных!", validation);
        ui->Client_line_passport->setText(passengerPassport);
        ui->Client_line_fullname->setText(passengerName);
        ui->Client_line_phone->setText(passengerPhone);
        ui->Client_line_email->setText(passengerEmail);
    }
}

void ClientWindow::on_Client_flight_button_clicked()
{
    if(Client_flight_index != QModelIndex()){

        QString flightID = Client_currentFlights->record(Client_flight_index.row()).value("flightid").toString();

        QSqlQuery ticketsInfoQuery;
            ticketsInfoQuery.exec("SELECT F.flightid, F.aircraftnumber AS Рейс, Ti.placenumber AS Место, "
                       "Ti.ticketprice AS \"Цена билета\", Ti.sclass AS Класс "
                       "FROM tickets Ti JOIN flights F ON F.flightid = Ti.flightid "
                       "WHERE Ti.reserved <> true AND Ti.flightid = " + flightID + " ORDER BY Ti.ticketid;");

        Client_ticketsModel->setQuery(ticketsInfoQuery);
        ui->Client_tickets_tableView->hideColumn(0);
        setTableViewResize(Client_ticketsModel, ui->Client_tickets_tableView);
    }
    else
        QMessageBox::warning(nullptr, "Внимание!", "Выберите рейс!");
}

void ClientWindow::on_Client_refund_button_clicked()
{
    if(Client_refund_index != QModelIndex()){

        QString placeNumber = Client_flightsModel->record(Client_refund_index.row()).value("Место").toString();
        QString aircraftNumber = Client_flightsModel->record(Client_refund_index.row()).value("Рейс").toString();
        QString validation = database.validateTicketRefund(placeNumber, aircraftNumber);
        QString refunReason = ui->Client_refundReason_line->text();

        if(validation == QString()){

            QSqlQuery refundTicketQuery;
                refundTicketQuery.exec("CALL refund_ticket('" + database.getLogin() + "', '" + aircraftNumber + "', '" + placeNumber +
                           "', '" + refunReason + "');");

            QSqlQuery billQuery;
                billQuery.exec("SELECT  bill FROM passengers WHERE "
                               "passengerid = '" + database.getLogin() + "';");
                billQuery.next();
                ui->bill_label->setText(billQuery.value(0).toString() + " ₽");

            QSqlQuery flightInfoQuery;
                flightInfoQuery.exec("SELECT R.departure AS Вылет, R.arrival AS Прилет, F.aircraftnumber AS Рейс, "
                            "Ti.placenumber AS Место, F.departuredate AS \"Дата вылета\", F.arrivaldate AS \"Дата прилета\" "
                            "FROM tickets Ti JOIN passengers Pa ON Pa.passengerid = Ti.passengerid "
                            "JOIN flights F ON F.flightid = Ti.flightid "
                            "JOIN routs R ON F.routeid = R.routeid WHERE Pa.passengerid = '" +
                            database.getLogin() + "' AND F.arrivaldate > localtimestamp ORDER BY F.flightid;");

            Client_flightsModel->setQuery(flightInfoQuery);
            setTableViewResize(Client_flightsModel, ui->Client_flights_tableView);
            ui->Client_refundReason_line->clear();
       }
       else
           QMessageBox::warning(nullptr, "Ошибка возврата!", validation);
    }
    else
        QMessageBox::warning(nullptr, "Внимание!", "Выберите билет!");
}

void ClientWindow::on_Admin_route_selected()
{
    Admin_routs_index = ui->Admin_routs_tableView->selectionModel()->selectedIndexes().first();

    QString departure = Admin_routsModel->record(Admin_routs_index.row()).value("departure").toString();
    QString departureAirport = Admin_routsModel->record(Admin_routs_index.row()).value("departureairport").toString();
    QString arrival = Admin_routsModel->record(Admin_routs_index.row()).value("arrival").toString();
    QString arrivalAirport = Admin_routsModel->record(Admin_routs_index.row()).value("arrivalairport").toString();
    QTime time = QTime::fromString(Admin_routsModel->record(Admin_routs_index.row()).value("traveltime").toString(), "HH:mm:ss.zzz");

    ui->Admin_update_departure_lineEdit->setText(departure);
    ui->Admin_update_departureairport_lineEdit->setText(departureAirport);
    ui->Admin_update_arrival_lineEdit->setText(arrival);
    ui->Admin_update_arrivalairport_lineEdit->setText(arrivalAirport);
    ui->Admin_update_flighttime_DateTimeEdit->setTime(time);
}

void ClientWindow::on_Admin_flight_selected()
{
    Admin_flights_index = ui->Admin_flights_tableView->selectionModel()->selectedIndexes().first();

    int StatusIndex = ui->Admin_update_status_comboBox->findText(Admin_flightsModel->record(Admin_flights_index.row()).value("status").toString());
    ui->Admin_update_status_comboBox->setCurrentIndex(StatusIndex);

    QDateTime departuredate = QDateTime::fromString(Admin_flightsModel->record(Admin_flights_index.row()).value("departuredate").toString().replace("T", " "), "yyyy-MM-dd HH:mm:ss.zzz");
    QDateTime arrivalDate = QDateTime::fromString(Admin_flightsModel->record(Admin_flights_index.row()).value("arrivaldate").toString().replace("T", " "), "yyyy-MM-dd HH:mm:ss.zzz");
    QString ticketsCount = Admin_flightsModel->record(Admin_flights_index.row()).value("ticketscount").toString();
    QString passengersCount = Admin_flightsModel->record(Admin_flights_index.row()).value("passengerscount").toString();
    QString aircraftNumber = Admin_flightsModel->record(Admin_flights_index.row()).value("aircraftnumber").toString();
    int routeID = Admin_flightsModel->record(Admin_flights_index.row()).value("routeid").toInt();

    ui->Admin_update_departuredate_DateTime->setDateTime(departuredate);
    ui->Admin_update_arrivaldate_DateTime->setDateTime(arrivalDate);
    ui->Admin_update_ticketscount_lineEdit->setText(ticketsCount);
    ui->Admin_update_passengerscount_lineEdit->setText(passengersCount);
    ui->Admin_update_aircraftnumber_lineEdit->setText(aircraftNumber);
    this->ticketsCount = ticketsCount;
    this->passengersCount = passengersCount;

    int routeIndex = ui->Admin_update_routeid_comboBox->findText(routeIDs.key(routeID));
    ui->Admin_update_routeid_comboBox->setCurrentIndex(routeIndex);
}

void ClientWindow::on_Admin_ticket_selected()
{
    Admin_tickets_index = ui->Admin_tickets_tableView->selectionModel()->selectedIndexes().first();

    QString placeNumber = Admin_ticketsModel->record(Admin_tickets_index.row()).value("placenumber").toString();
    QString ticketPrice = Admin_ticketsModel->record(Admin_tickets_index.row()).value("ticketprice").toString();
    QString passengerID = Admin_ticketsModel->record(Admin_tickets_index.row()).value("passengerid").toString();

    int ReservedIndex = ui->Admin_update_reserved_comboBox->findText(Admin_ticketsModel->record(Admin_tickets_index.row()).value("reserved").toString());
    ui->Admin_update_reserved_comboBox->setCurrentIndex(ReservedIndex);

    int ClassIndex = ui->Admin_update_ticketClass_comboBox->findText(Admin_ticketsModel->record(Admin_tickets_index.row()).value("sclass").toString());
    ui->Admin_update_ticketClass_comboBox->setCurrentIndex(ClassIndex);

    int routeID = Admin_ticketsModel->record(Admin_tickets_index.row()).value("routeid").toInt();
    int routeIndex = ui->Admin_update_Ti_routeid_comboBox->findText(routeIDs.key(routeID));
    ui->Admin_update_Ti_routeid_comboBox->setCurrentIndex(routeIndex);

    int flightID = Admin_ticketsModel->record(Admin_tickets_index.row()).value("flightid").toInt();
    int FlightIndex = ui->Admin_update_Ti_flightid_comboBox->findText(flightIDs.key(flightID));
    ui->Admin_update_Ti_flightid_comboBox->setCurrentIndex(FlightIndex);

    int passengerIndex = ui->Admin_update_Ti_passengerid_comboBox->findText(passengerID);
    ui->Admin_update_Ti_passengerid_comboBox->setCurrentIndex(passengerIndex);

    ui->Admin_update_placenumber_lineEdit->setText(placeNumber);
    ui->Admin_update_ticketprice_lineEdit->setText(ticketPrice);
    this->reserved = ui->Admin_update_reserved_comboBox->currentText();
}

void ClientWindow::on_Admin_user_selected()
{
    Admin_users_index = ui->Admin_users_tableView->selectionModel()->selectedIndexes().first();

    QString passport = Admin_usersModel->record(Admin_users_index.row()).value("passportdata").toString();
    QString fullname = Admin_usersModel->record(Admin_users_index.row()).value("fullname").toString();
    QString phone = Admin_usersModel->record(Admin_users_index.row()).value("mobilephone").toString();
    QString email = Admin_usersModel->record(Admin_users_index.row()).value("email").toString();
    QString bill = Admin_usersModel->record(Admin_users_index.row()).value("bill").toString();

    ui->Admin_update_passport_lineEdit->setText(passport);
    ui->Admin_update_fullname_lineEdit->setText(fullname);
    ui->Admin_update_phone_libeEdit->setText(phone);
    ui->Admin_update_email_lineEdit->setText(email);
    ui->Admin_update_amount_lineEdit->setText(bill);
}

void ClientWindow::on_Admin_sale_selected()
{
    Admin_sales_index = ui->Admin_sales_tableView->selectionModel()->selectedIndexes().first();

    QDateTime saleDate = QDateTime::fromString(Admin_salesModel->record(Admin_sales_index.row()).value("saledate").toString().replace("T", " "), "yyyy-MM-dd HH:mm:ss.zzz");
    QString VAT = Admin_salesModel->record(Admin_sales_index.row()).value("vat").toString();

    int ticketID = Admin_salesModel->record(Admin_sales_index.row()).value("ticketid").toInt();
    int ticketIndex = ui->Admin_update_S_ticketid_comboBox->findText(ticketIDs.key(ticketID));
    ui->Admin_update_S_ticketid_comboBox->setCurrentIndex(ticketIndex);

    ui->Admin_update_sales_dateTimeEdit->setDateTime(saleDate);
    ui->Admin_update_VAT_lineEdit->setText(VAT);
}

void ClientWindow::on_Admin_refund_selected()
{
    Admin_refunds_index = ui->Admin_refunds_tableView->selectionModel()->selectedIndexes().first();

    QDateTime refundDate = QDateTime::fromString(Admin_refundsModel->record(Admin_refunds_index.row()).value("refunddate").toString().replace("T", " "), "yyyy-MM-dd HH:mm:ss.zzz");
    QString refundReason = Admin_refundsModel->record(Admin_refunds_index.row()).value("refundreason").toString();

    int ticketID = Admin_refundsModel->record(Admin_refunds_index.row()).value("ticketid").toInt();
    int ticketIndex = ui->Admin_update_R_ticketid_comboBox->findText(ticketIDs.key(ticketID));
    ui->Admin_update_R_ticketid_comboBox->setCurrentIndex(ticketIndex);

    ui->Admin_update_refunds_DateTimeEdit->setDateTime(refundDate);
    ui->Admin_update_refundreason_lineEdit->setText(refundReason);
}

void ClientWindow::on_Admin_order_changed()
{
    Admin_viewModel->setQuery("SELECT * FROM tickets_n_passengers_info "
                              "ORDER BY " + ui->Admin_view_sort_comboBox->currentText() + ";");
    setTableViewResize(Admin_viewModel, ui->Admin_view_tableView);
}

void ClientWindow::on_Admin_view_selected()
{
    Admin_view_index = ui->Admin_view_tableView->selectionModel()->selectedIndexes().first();

    QString aircraftNumber = Admin_viewModel->record(Admin_view_index.row()).value("aircraftnumber").toString();
    QString placeNumber = Admin_viewModel->record(Admin_view_index.row()).value("placenumber").toString();
    QString ticketPrice = Admin_viewModel->record(Admin_view_index.row()).value("ticketprice").toString();
    QString ticketClass = Admin_viewModel->record(Admin_view_index.row()).value("sclass").toString();
    QString fullName = Admin_viewModel->record(Admin_view_index.row()).value("fullname").toString();
    QString phone = Admin_viewModel->record(Admin_view_index.row()).value("mobilephone").toString();
    QString email = Admin_viewModel->record(Admin_view_index.row()).value("email").toString();

    ui->Admin_view_aircraftnumber_lineEdit->setText(aircraftNumber);
    ui->Admin_view_placenumber_lineEdit->setText(placeNumber);
    int ticketClassIndex = ui->Admin_view_ticketClass_comboBox->findText(ticketClass);
    ui->Admin_view_ticketClass_comboBox->setCurrentIndex(ticketClassIndex);
    ui->Admin_view_ticketPrice_lineEdit->setText(ticketPrice);
    ui->Admin_view_fullName_lineEdit->setText(fullName);
    ui->Admin_view_phone_lineEdit->setText(phone);
    ui->Admin_view_email_lineEdit->setText(email);
}

void ClientWindow::on_Admin_delete_routs_button_clicked()
{
    if(Admin_routs_index != QModelIndex()){

        auto reply = QMessageBox::question(nullptr, "Внимание!", "Вы уверены, что хотите удалить запись?",
                                           QMessageBox::Yes|QMessageBox::No, QMessageBox::No);
        if(reply == QMessageBox::No)
            return;

        QString routeID = Admin_routsModel->record(Admin_routs_index.row()).value("routeid").toString();
        QSqlQuery deleteRouteQuery;
            deleteRouteQuery.exec("CALL delete_route(" + routeID + ");");

        Admin_routsModel->setQuery(database.SelectAll("routs"));
        setTableViewResize(Admin_routsModel, ui->Admin_routs_tableView);
    }
    else
        QMessageBox::warning(nullptr, "Внимание!", "Выберите рейс!");
}

void ClientWindow::on_Admin_update_routs_button_clicked()
{
    if(Admin_routs_index != QModelIndex()){

        QString departure = ui->Admin_update_departure_lineEdit->text();
        QString departureAirport = ui->Admin_update_departureairport_lineEdit->text();
        QString arrival = ui->Admin_update_arrival_lineEdit->text();
        QString arrivalAirport = ui->Admin_update_arrivalairport_lineEdit->text();
        QString travelTime = ui->Admin_update_flighttime_DateTimeEdit->time().toString("HH:mm:ss");

        QString validation = database.validateRoute(departure, departureAirport,
                                                   arrival, arrivalAirport);

        if(validation == QString()){

            QString routeID = Admin_routsModel->record(Admin_routs_index.row()).value("routeid").toString();

            QSqlQuery updateRouteQuery;
                updateRouteQuery.exec("CALL update_route(" + routeID + ", '" + departure +
                           "', '" + departureAirport + "', '" + arrival + "', '" + arrivalAirport +
                           "', '" +  travelTime + "');");

            Admin_routsModel->setQuery(database.SelectAll("routs"));
            setTableViewResize(Admin_routsModel, ui->Admin_routs_tableView);
        }
        else
            QMessageBox::warning(nullptr, "Ошибка обновления маршрута!", validation);
    }
    else
        QMessageBox::warning(nullptr, "Внимание!", "Выберите маршрут!");
}

void ClientWindow::on_Admin_insert_routs_button_clicked()
{
    QString departure = ui->Admin_insert_departure_lineEdit->text();
    QString departureAirport = ui->Admin_insert_departureairport_lineEdit->text();
    QString arrival = ui->Admin_insert_arrival_lineEdit->text();
    QString arrivalAirport = ui->Admin_insert_arrivalairport_lineEdit->text();
    QString travelTime = ui->Admin_insert_flighttime_DateTimeEdit->time().toString("HH:mm:ss");

    QString validation = database.validateRoute(departure, departureAirport,
                                               arrival, arrivalAirport);

    if(validation == QString()){

        QSqlQuery insertRouteQuery;
            insertRouteQuery.exec("CALL insert_route(""'" + departure + "', '" + departureAirport + "', '" +
                                    arrival + "', '" + arrivalAirport + "', '" +  travelTime + "');");

        Admin_routsModel->setQuery(database.SelectAll("routs"));
        setTableViewResize(Admin_routsModel, ui->Admin_routs_tableView);
    }
    else
        QMessageBox::warning(nullptr, "Ошибка добавления маршрута!", validation);
}

void ClientWindow::on_Admin_delete_flights_button_clicked()
{
    if(Admin_flights_index != QModelIndex()){

        auto reply = QMessageBox::question(nullptr, "Внимание!", "Вы уверены, что хотите удалить запись?",
                                           QMessageBox::Yes|QMessageBox::No, QMessageBox::No);
        if(reply == QMessageBox::No)
            return;

        QString flightID = Admin_flightsModel->record(Admin_flights_index.row()).value("flightid").toString();
        QSqlQuery deleteFlightQuery;
            deleteFlightQuery.exec("CALL delete_flight(" + flightID + ");");

        Admin_flightsModel->setQuery(database.SelectAll("flights"));
        setTableViewResize(Admin_flightsModel, ui->Admin_flights_tableView);
    }
    else
        QMessageBox::warning(nullptr, "Внимание!", "Выберите рейс!");

}

void ClientWindow::on_Admin_update_flights_button_clicked()
{
    if(Admin_flights_index != QModelIndex()){

        QString routeID = QString::number(routeIDs.value(ui->Admin_update_routeid_comboBox->currentText()));
        QString aircraftNumber = ui->Admin_update_aircraftnumber_lineEdit->text();
        QString departureDate = ui->Admin_update_departuredate_DateTime->dateTime().toString("yyyy-MM-dd HH:mm:ss");
        QString arrivalDate = ui->Admin_update_arrivaldate_DateTime->dateTime().toString("yyyy-MM-dd HH:mm:ss");
        QString status = ui->Admin_update_status_comboBox->currentText();
        QString ticketsCount = ui->Admin_update_ticketscount_lineEdit->text();
        QString passengersCount = ui->Admin_update_passengerscount_lineEdit->text();

        QString validation = database.validateFlight(aircraftNumber, ticketsCount, passengersCount);

        if(validation == QString()){

            if(this->ticketsCount != ticketsCount){

                auto ticketsCountReply = QMessageBox::question(nullptr, "Внимание!", "Поле \"Количество билетов\" заполняется автоматически.\n"
                                                            "Вы уверены, что хотите изменить его?", QMessageBox::Yes|QMessageBox::No, QMessageBox::No);
                if(ticketsCountReply == QMessageBox::No)
                    return;
            }

            if(this->passengersCount != passengersCount){

                auto passengersCountReply = QMessageBox::question(nullptr, "Внимание!", "Поле \"Количество пассажиров\" заполняется автоматически.\n "
                                                                        "Вы уверены, что хотите изменить его?", QMessageBox::Yes|QMessageBox::No, QMessageBox::No);
                if(passengersCountReply == QMessageBox::No)
                    return;
            }

            QString flightID = Admin_flightsModel->record(Admin_flights_index.row()).value("flightid").toString();
            QSqlQuery updateFlightQuery;
                updateFlightQuery.exec("CALL update_flight(" + flightID + ", " + routeID +
                                        ", '" + aircraftNumber + "', '" + departureDate +
                                        "', '" + arrivalDate + "', '" +  status + "', " +
                                        ticketsCount + ", " + passengersCount + ");");

            Admin_flightsModel->setQuery(database.SelectAll("flights"));
            setTableViewResize(Admin_flightsModel, ui->Admin_flights_tableView);
        }
        else
            QMessageBox::warning(nullptr, "Ошибка обновления рейса!", validation);
    }
    else
        QMessageBox::warning(nullptr, "Внимание!", "Выберите рейс!");
}

void ClientWindow::on_Admin_insert_flights_button_clicked()
{
    if(ui->Admin_insert_status_comboBox->currentIndex() == 0){
        QMessageBox::warning(nullptr, "Внимание!", "Выберите статус рейса!");return;
    }

    if(ui->Admin_insert_routeid_comboBox->currentIndex() == 0){
        QMessageBox::warning(nullptr, "Внимание!", "Выберите идентификатор маршрута!");return;
    }

    QString routeID = QString::number(routeIDs.value(ui->Admin_insert_routeid_comboBox->currentText()));
    QString aircraftNumber = ui->Admin_insert_aircraftnumber_lineEdit->text();
    QString departureDate = ui->Admin_insert_departuredate_DateTime->dateTime().toString("yyyy-MM-dd HH:mm:ss");
    QString arrivalDate = ui->Admin_insert_arrivaldate_DateTime->dateTime().toString("yyyy-MM-dd HH:mm:ss");
    QString status = ui->Admin_insert_status_comboBox->currentText();
    QString ticketsCount = ui->Admin_insert_ticketscount_lineEdit->text();
    QString passengersCount = ui->Admin_insert_passengerscount_lineEdit->text();

    QString validation = database.validateFlight(aircraftNumber, ticketsCount, passengersCount);

    if(validation == QString()){

        QSqlQuery insertFlightQuery;
            insertFlightQuery.exec("CALL insert_flight('" + aircraftNumber + "', '" + departureDate +
                                    "', '" + arrivalDate + "', '" +  status + "', " + ticketsCount + ", " +
                                    passengersCount + ", " + routeID + ");");

        Admin_flightsModel->setQuery(database.SelectAll("flights"));
        setTableViewResize(Admin_flightsModel, ui->Admin_flights_tableView);
    }
    else
        QMessageBox::warning(nullptr, "Ошибка добавления рейса!", validation);
}

void ClientWindow::on_Admin_delete_tickets_button_clicked()
{
    if(Admin_tickets_index != QModelIndex()){

        auto reply = QMessageBox::question(nullptr, "Внимание!", "Вы уверены, что хотите удалить запись?",
                                           QMessageBox::Yes|QMessageBox::No, QMessageBox::No);
        if(reply == QMessageBox::No)
            return;

        QString ticketID = Admin_ticketsModel->record(Admin_tickets_index.row()).value("ticketid").toString();
        QSqlQuery deleteTicketQuery;
            deleteTicketQuery.exec("CALL delete_ticket(" + ticketID + ");");

        Admin_ticketsModel->setQuery(database.SelectAll("tickets"));
        setTableViewResize(Admin_ticketsModel, ui->Admin_tickets_tableView);
    }
    else
        QMessageBox::warning(nullptr, "Внимание!", "Выберите билет!");
}

void ClientWindow::on_Admin_update_tickets_button_clicked()
{
    if(Admin_tickets_index != QModelIndex()){

        QString placeNumber = ui->Admin_update_placenumber_lineEdit->text();
        QString flightID = QString::number(flightIDs.value(ui->Admin_update_Ti_flightid_comboBox->currentText()));
        QString routeID = QString::number(routeIDs.value(ui->Admin_update_Ti_routeid_comboBox->currentText()));
        QString reserved = ui->Admin_update_reserved_comboBox->currentText();
        QString ticketPrice = ui->Admin_update_ticketprice_lineEdit->text();
        QString ticketClass = ui->Admin_update_ticketClass_comboBox->currentText();
        QString passengerID = ui->Admin_update_Ti_passengerid_comboBox->currentText();

        QString validation = database.validateTicket(placeNumber, QString(), ticketPrice);

        if(validation == QString()){

            if(this->reserved != reserved){

                auto reply = QMessageBox::question(nullptr, "Внимание!", "Поле \"Зарезервирован\" заполняется автоматически.\n"
                                                    "Вы уверены, что хотите изменить его?", QMessageBox::Yes|QMessageBox::No, QMessageBox::No);

                if(reply == QMessageBox::No)
                    return;
            }

            QString ticketID = Admin_ticketsModel->record(Admin_tickets_index.row()).value("ticketid").toString();
            QSqlQuery updateTicketQuery;

            if(ui->Admin_update_Ti_passengerid_comboBox->currentIndex() == 0 || ui->Admin_update_Ti_passengerid_comboBox->currentIndex() == 1){

                ui->Admin_update_Ti_passengerid_comboBox->setCurrentIndex(1);

                    updateTicketQuery.exec("CALL update_ticket(" + ticketID + ", " + routeID +
                                                                ", " + flightID + ", '" +
                                                                placeNumber + "', " + reserved +
                                                                ", " + ticketPrice + ", '" + ticketClass + "', NULL);");
            }
            else{
                updateTicketQuery.exec("CALL update_ticket(" + ticketID + ", " + routeID +
                                                            ", " + flightID + ", '" +
                                                            placeNumber + "', " + reserved +
                                                            ", " + ticketPrice + ", '" + ticketClass +
                                                            "', '" + passengerID + "');");
            }

            Admin_ticketsModel->setQuery(database.SelectAll("tickets"));
            setTableViewResize(Admin_ticketsModel, ui->Admin_tickets_tableView);

            Admin_flightsModel->setQuery(database.SelectAll("flights"));
            setTableViewResize(Admin_flightsModel, ui->Admin_flights_tableView);
        }
        else
            QMessageBox::warning(nullptr, "Ошиибка обновления билета!", validation);
    }
    else
        QMessageBox::warning(nullptr, "Внимание!", "Выберите билет!");
}

void ClientWindow::on_Admin_insert_tickets_button_clicked()
{
    if(ui->Admin_insert_reserved_comboBox->currentIndex() == 0){
        QMessageBox::warning(nullptr, "Внимание!", "Выберите статус билета!");return;
    }

    if(ui->Admin_insert_ticketClass_comboBox->currentIndex() == 0){
        QMessageBox::warning(nullptr, "Внимание!", "Выберите класс места!");return;
    }

    if(ui->Admin_insert_Ti_routeid_comboBox->currentIndex() == 0){
        QMessageBox::warning(nullptr, "Внимание!", "Выберите идентификатор маршрута!");return;
    }

    if(ui->Admin_insert_Ti_flightid_comboBox->currentIndex() == 0){
        QMessageBox::warning(nullptr, "Внимание!", "Выберите идентификатор рейса!");return;
    }

    QString placeNumber = ui->Admin_insert_placenumber_lineEdit->text();
    QString flightID = QString::number(flightIDs.value(ui->Admin_insert_Ti_flightid_comboBox->currentText()));
    QString routeID = QString::number(routeIDs.value(ui->Admin_insert_Ti_routeid_comboBox->currentText()));
    QString reserved = ui->Admin_insert_reserved_comboBox->currentText();
    QString ticketPrice = ui->Admin_insert_ticketprice_lineEdit->text();
    QString ticketClass = ui->Admin_insert_ticketClass_comboBox->currentText();
    QString passengerID = ui->Admin_insert_Ti_passengerid_comboBox->currentText();

    QString validation = database.validateTicket(placeNumber, flightID, ticketPrice);

    if(validation == QString()){

        QString ticketID = Admin_ticketsModel->record(Admin_tickets_index.row()).value("ticketid").toString();
        QSqlQuery insertTicketQuery;

        if(ui->Admin_insert_Ti_passengerid_comboBox->currentIndex() == 0 || ui->Admin_insert_Ti_passengerid_comboBox->currentIndex() == 1){

            ui->Admin_insert_Ti_passengerid_comboBox->setCurrentIndex(1);

            insertTicketQuery.exec("CALL insert_ticket('" + placeNumber + "', " + reserved +
                                                        ", " + ticketPrice + ", '" + ticketClass +
                                                        "', " + routeID + ", NULL ," + flightID + ");");
        }
        else{

            insertTicketQuery.exec("CALL insert_ticket('" + placeNumber + "', " + reserved +
                                                        ", " + ticketPrice + ", '" + ticketClass +
                                                        "', " + routeID + ", '" + passengerID + "', " + flightID + ");");
        }

        Admin_ticketsModel->setQuery(database.SelectAll("tickets"));
        setTableViewResize(Admin_ticketsModel, ui->Admin_tickets_tableView);

        Admin_flightsModel->setQuery(database.SelectAll("flights"));
        setTableViewResize(Admin_flightsModel, ui->Admin_flights_tableView);
    }
    else
        QMessageBox::warning(nullptr, "Ошиибка добавления билета!", validation);
}

void ClientWindow::on_Admin_delete_users_button_clicked()
{
    if(database.getLogin() == Admin_usersModel->record(Admin_users_index.row()).value("passengerid").toString()){
        QMessageBox::warning(nullptr, "Внимание!", "Вы не можете удалить себя!"); return;
    }

    if(Admin_users_index != QModelIndex()){

        auto reply = QMessageBox::question(nullptr, "Внимание!", "Вы уверены, что хотите удалить запись?",
                                           QMessageBox::Yes|QMessageBox::No, QMessageBox::No);
        if(reply == QMessageBox::No)
            return;

        QString passengerID = Admin_usersModel->record(Admin_users_index.row()).value("passengerid").toString();
        QSqlQuery deleteUserQuery;
            deleteUserQuery.exec("CALL drop_user('" + passengerID + "');");

        Admin_usersModel->setQuery("SELECT *, "
                                   "CASE "
                                       "WHEN (SELECT count(groname) FROM aviasales.pg_catalog.pg_group WHERE "
                                            "(SELECT usesysid FROM aviasales.pg_catalog.pg_user WHERE usename = passengers.passengerid) = ANY(grolist)) > 1 "
                                            "THEN 'Admin' "
                                            "ELSE 'Client' "
                                   "END user_role "
                                   "FROM passengers ORDER BY passengers.passengerid;");
        setTableViewResize(Admin_usersModel, ui->Admin_users_tableView);
    }
    else
        QMessageBox::warning(nullptr, "Внимание!", "Выберите пользователя!");
}

void ClientWindow::on_Admin_update_users_button_clicked()
{
    if(Admin_users_index != QModelIndex()){

        QRegExp bill(R"(\d+)");
        if(bill.exactMatch(ui->Admin_update_amount_lineEdit->text())){

            QString passengerID = Admin_usersModel->record(Admin_users_index.row()).value("passengerid").toString();
            QString passport = ui->Admin_update_passport_lineEdit->text();
            QString fullName = ui->Admin_update_fullname_lineEdit->text();
            QString phone = ui->Admin_update_phone_libeEdit->text();
            QString email = ui->Admin_update_email_lineEdit->text();
            long long amount = ui->Admin_update_amount_lineEdit->text().toLongLong();

            QString validation = database.validateUser(passengerID, passport, fullName, phone, email);

            if(amount > 1000000){
                QMessageBox::warning(nullptr, "Ошибка обновления пользователя!", "Счет не может превышать 1000000!"); return;
            }

            if(validation == QString()){


                QSqlQuery updateUserQuery;
                    updateUserQuery.exec("CALL update_passenger('" + passengerID + "', '" + passport +
                                        "', '" + fullName + "', '" + phone + "', '" + email + "', " + QString::number(amount) + ");");

                Admin_usersModel->setQuery("SELECT *, "
                                           "CASE "
                                               "WHEN (SELECT count(groname) FROM aviasales.pg_catalog.pg_group WHERE "
                                                    "(SELECT usesysid FROM aviasales.pg_catalog.pg_user WHERE usename = passengers.passengerid) = ANY(grolist)) > 1 "
                                                    "THEN 'Admin' "
                                                    "ELSE 'Client' "
                                           "END user_role "
                                           "FROM passengers ORDER BY passengers.passengerid;");
                setTableViewResize(Admin_usersModel, ui->Admin_users_tableView);
            }
            else
                QMessageBox::warning(nullptr, "Ошибка обновления пользователя!", validation);
        }
        else
            QMessageBox::warning(nullptr, "Ошибка обновления пользователя!", "Неверный формат суммы счета!");
    }
    else
        QMessageBox::warning(nullptr, "Внимание!", "Выберите пользователя!");
}

void ClientWindow::on_Admin_insert_users_button_clicked()
{
    QRegExp bill(R"(\d+)");
    if(bill.exactMatch(ui->Admin_update_amount_lineEdit->text())){

        QString passengerID = ui->Admin_insert_passengerid_lineEdit->text();
        QString password = ui->Admin_insert_password_lineEdit->text();
        QString passport = ui->Admin_insert_passport_lineEdit->text();
        QString fullName = ui->Admin_insert_fullname_lineEdit->text();
        QString phone = ui->Admin_insert_phone_lineEdit->text();
        QString email = ui->Admin_insert_email_lineEdit->text();
        long long amount = ui->Admin_insert_amount_lineEdit->text().toLongLong();

        QString validation = database.validateUser(passengerID, passport, fullName, phone, email);

        if(amount > 1000000){
            QMessageBox::warning(nullptr, "Ошибка добавления пользователя!", "Счет не может превышать 1000000!"); return;
        }

        if(validation == QString()){

            QSqlQuery insertUserQuery;
                insertUserQuery.exec("CALL register_user('" + passengerID + "', '" + password
                                        + "', '" + passport + "', '" + fullName + "', '" +
                                        phone + "', '" + email + "');");

            QSqlQuery fillBillQuery;
                fillBillQuery.exec("CALL fill_bill('" + passengerID +
                            "', " + amount + ");");

            Admin_usersModel->setQuery("SELECT *, "
                                       "CASE "
                                           "WHEN (SELECT count(groname) FROM aviasales.pg_catalog.pg_group WHERE "
                                                "(SELECT usesysid FROM aviasales.pg_catalog.pg_user WHERE usename = passengers.passengerid) = ANY(grolist)) > 1 "
                                                "THEN 'Admin' "
                                                "ELSE 'Client' "
                                       "END user_role "
                                       "FROM passengers ORDER BY passengers.passengerid;");
            setTableViewResize(Admin_usersModel, ui->Admin_users_tableView);
        }
        else
            QMessageBox::warning(nullptr, "Ошибка добавления пользователя!", validation);
    }
    else
        QMessageBox::warning(nullptr, "Ошибка добавления пользователя!", "Неверный формат суммы счета!");
}

void ClientWindow::on_Admin_Grant_button_clicked()
{
    if(database.getLogin() == Admin_usersModel->record(Admin_users_index.row()).value("passengerid").toString()){
        QMessageBox::warning(nullptr, "Error", "You can't grant yourself!"); return;
    }

    if(Admin_users_index != QModelIndex()){

            QString passengerID = Admin_usersModel->record(Admin_users_index.row()).value("passengerid").toString();

            QSqlQuery grantAdminQuery;
                grantAdminQuery.exec("GRANT adm TO " + passengerID + " WITH ADMIN OPTION;");

            Admin_usersModel->setQuery("SELECT *, "
                                       "CASE "
                                           "WHEN (SELECT count(groname) FROM aviasales.pg_catalog.pg_group WHERE "
                                                "(SELECT usesysid FROM aviasales.pg_catalog.pg_user WHERE usename = passengers.passengerid) = ANY(grolist)) > 1 "
                                                "THEN 'Admin' "
                                                "ELSE 'Client' "
                                       "END user_role "
                                       "FROM passengers ORDER BY passengers.passengerid;");
            setTableViewResize(Admin_usersModel, ui->Admin_users_tableView);
    }
    else
        QMessageBox::warning(nullptr, "Внимание!", "Выберите пользователя!");
}

void ClientWindow::on_Admin_Revoke_button_clicked()
{
    if(database.getLogin() == Admin_usersModel->record(Admin_users_index.row()).value("passengerid").toString()){
        QMessageBox::warning(nullptr, "Error", "You can't revoke yourself!"); return;
    }

    if(Admin_users_index != QModelIndex()){

        QString passengerID = Admin_usersModel->record(Admin_users_index.row()).value("passengerid").toString();

        QSqlQuery revokeAdminQuery;
            revokeAdminQuery.exec("REVOKE adm FROM " + passengerID + ";");

        Admin_usersModel->setQuery("SELECT *, "
                                   "CASE "
                                       "WHEN (SELECT count(groname) FROM aviasales.pg_catalog.pg_group WHERE "
                                            "(SELECT usesysid FROM aviasales.pg_catalog.pg_user WHERE usename = passengers.passengerid) = ANY(grolist)) > 1 "
                                            "THEN 'Admin' "
                                            "ELSE 'Client' "
                                   "END user_role "
                                   "FROM passengers ORDER BY passengers.passengerid;");
        setTableViewResize(Admin_usersModel, ui->Admin_users_tableView);
    }
    else
        QMessageBox::warning(nullptr, "Внимание!", "Выберите пользователя!");
}

void ClientWindow::on_Admin_delete_sales_button_clicked()
{
    if(Admin_sales_index != QModelIndex()){

        auto reply = QMessageBox::question(nullptr, "Внимание!", "Вы уверены, что хотите удалить запись?",
                                           QMessageBox::Yes|QMessageBox::No, QMessageBox::No);
        if(reply == QMessageBox::No)
            return;

        QString saleID = Admin_salesModel->record(Admin_sales_index.row()).value("saleid").toString();
        QSqlQuery deleteSaleQuery;
            deleteSaleQuery.exec("CALL delete_sale(" + saleID + ");");

        Admin_salesModel->setQuery(database.SelectAll("sales"));
        setTableViewResize(Admin_salesModel, ui->Admin_sales_tableView);
    }
    else
        QMessageBox::warning(nullptr, "Внимание", "Выберите операцию!");
}

void ClientWindow::on_Admin_update_sale_button_clicked()
{
    if(Admin_sales_index != QModelIndex()){

        QRegExp vatValidate(R"(\d+)");

        QString saleID = Admin_salesModel->record(Admin_sales_index.row()).value("saleid").toString();
        QString ticketID = QString::number(ticketIDs.value(ui->Admin_update_S_ticketid_comboBox->currentText()));
        QString saleDate = ui->Admin_update_sales_dateTimeEdit->dateTime().toString("yyyy-MM-dd HH:mm:ss");
        QString VAT = ui->Admin_update_VAT_lineEdit->text();

        if(vatValidate.exactMatch(VAT)){

            QSqlQuery updateSaleQuery;
                updateSaleQuery.exec("CALL update_sale(" + saleID + ", " + ticketID + ", '" + saleDate + "', " + VAT + ");");

            Admin_salesModel->setQuery(database.SelectAll("sales"));
            setTableViewResize(Admin_salesModel, ui->Admin_sales_tableView);
        }
        else
            QMessageBox::warning(nullptr, "Ошибка обновления операции!", "Неверный формат суммы налога!");
    }
    else
        QMessageBox::warning(nullptr, "Внимание", "Выберите операцию!");
}

void ClientWindow::on_Admin_insert_sales_button_clicked()
{
    if(ui->Admin_insert_S_ticketid_comboBox->currentIndex() == 0){
        QMessageBox::warning(nullptr, "Внимание!", "Выберите идентификатор билета!");return;
    }

    QRegExp vatValidate(R"(\d+)");

    QString saleDate = ui->Admin_insert_sales_dateTimeEdit->dateTime().toString("yyyy-MM-dd HH:mm:ss");
    QString ticketID = QString::number(ticketIDs.value(ui->Admin_insert_S_ticketid_comboBox->currentText()));
    QString VAT = ui->Admin_insert_VAT_lineEdit->text();

    if(vatValidate.exactMatch(VAT)){

        QSqlQuery insertSaleQuery;
            insertSaleQuery.exec("CALL insert_sale('" + saleDate + "', " + VAT + ", " + ticketID + ");");

        Admin_salesModel->setQuery(database.SelectAll("sales"));
        setTableViewResize(Admin_salesModel, ui->Admin_sales_tableView);

        Admin_ticketsModel->setQuery(database.SelectAll("tickets"));
        setTableViewResize(Admin_ticketsModel, ui->Admin_tickets_tableView);

        Admin_flightsModel->setQuery(database.SelectAll("flights"));
        setTableViewResize(Admin_flightsModel, ui->Admin_flights_tableView);
    }
    else
        QMessageBox::warning(nullptr, "Ошибка обновления операции!", "Неверный формат суммы налога!");
}

void ClientWindow::on_Admin_delete_refunds_button_clicked()
{
    if(Admin_refunds_index != QModelIndex()){

        auto reply = QMessageBox::question(nullptr, "Внимание!", "Вы уверены, что хотите удалить запись?",
                                           QMessageBox::Yes|QMessageBox::No, QMessageBox::No);
        if(reply == QMessageBox::No)
            return;

        QString refundID = Admin_refundsModel->record(Admin_refunds_index.row()).value("refundid").toString();
        QSqlQuery deleteRefundQuery;
            deleteRefundQuery.exec("CALL delete_refund(" + refundID + ");");

        Admin_refundsModel->setQuery(database.SelectAll("refunds"));
        setTableViewResize(Admin_refundsModel, ui->Admin_refunds_tableView);
    }
    else
        QMessageBox::warning(nullptr, "Внимание", "Выберите операцию!");
}

void ClientWindow::on_Admin_update_refunds_button_clicked()
{
    if(Admin_refunds_index != QModelIndex()){

        QString refundID = Admin_refundsModel->record(Admin_refunds_index.row()).value("refundid").toString();
        QString ticketID = QString::number(ticketIDs.value(ui->Admin_update_R_ticketid_comboBox->currentText()));
        QString refundDate = ui->Admin_update_refunds_DateTimeEdit->dateTime().toString("yyyy-MM-dd HH:mm:ss");
        QString refundReason = ui->Admin_update_refundreason_lineEdit->text();

        QSqlQuery updateRefundQuery;

        if(refundReason == QString()){
            updateRefundQuery.exec("CALL update_refund(" + refundID + ", " + ticketID +
                                   ", '" + refundDate + "', NULL);");}
        else{
            updateRefundQuery.exec("CALL update_refund(" + refundID + ", " + ticketID +
                                    ", '" + refundDate + "','" + refundReason + "');");}

            Admin_refundsModel->setQuery(database.SelectAll("refunds"));
            setTableViewResize(Admin_refundsModel, ui->Admin_refunds_tableView);
    }
    else
        QMessageBox::warning(nullptr, "Внимание", "Выберите операцию!");
}

void ClientWindow::on_Admin_insert_refunds_button_clicked()
{
    if(ui->Admin_insert_R_ticketid_comboBox->currentIndex() == 0){
        QMessageBox::warning(nullptr, "Внимание!", "Выберите идентификатор билета!");return;
    }

    QString refundDate = ui->Admin_insert_refund_DateTimeEdit->dateTime().toString("yyyy-MM-dd HH:mm:ss");
    QString refundReason = ui->Admin_insert_refundreason_lineEdit->text();
    QString ticketID = QString::number(ticketIDs.value(ui->Admin_insert_R_ticketid_comboBox->currentText()));

    QSqlQuery insertRefundQuery;
    if(refundReason == QString())
        insertRefundQuery.exec("CALL insert_refund('" + refundDate + "', NULL, " + ticketID + ");");
    else
        insertRefundQuery.exec("CALL insert_refund('" + refundDate + "', '" + refundReason + "', " + ticketID + ");");

    Admin_refundsModel->setQuery(database.SelectAll("refunds"));
    setTableViewResize(Admin_refundsModel, ui->Admin_refunds_tableView);

    Admin_ticketsModel->setQuery(database.SelectAll("tickets"));
    setTableViewResize(Admin_ticketsModel, ui->Admin_tickets_tableView);

    Admin_flightsModel->setQuery(database.SelectAll("flights"));
    setTableViewResize(Admin_flightsModel, ui->Admin_flights_tableView);
}

void ClientWindow::on_Admin_select_case_button_clicked()
{
    QSqlQuery caseQuery;
        caseQuery.exec("SELECT F.aircraftnumber AS \"Номер рейса\", R.departure AS \"Пункт отправления\", R.arrival AS \"Пункт прибытия\" "
                       ", F.departuredate AS \"Дата вылета\", F.arrivaldate AS \"Дата прибытия\", Ti.placenumber AS \"Номер места\", "
                       " F.status AS Статус, Ti.ticketprice AS \"Цена билета\", Ti.sclass AS \"Класс места\", "
                       "CASE "
                       "WHEN Ti.reserved = false AND (F.status = 'Waiting' OR F.status = 'Check-in open') "
                       "THEN 'Билет доступен' "
                       "ELSE 'Билет недоступен' "
                       "END Доступность "
                       "FROM tickets Ti "
                       "JOIN Flights F ON Ti.flightid = F.flightid "
                       "JOIN Routs R ON R.routeid = F.routeid "
                       "WHERE R.departure = 'Москва' AND R.arrival = 'Санкт-Петербург' "
                       "ORDER BY Доступность, F.aircraftnumber;");

    Admin_technicalModel->setQuery(caseQuery);
    setTableViewResize(Admin_technicalModel, ui->Admin_selects_tableView);
}

void ClientWindow::on_Admin_select_C_WHERE_button_clicked()
{
        QSqlQuery cWhereQuery;
        cWhereQuery.exec("SELECT Ti.ticketprice AS \"Цена билета\", Ti.sclass AS \"Класс места\" "
                         "FROM tickets Ti "
                         "WHERE (SELECT vat FROM sales S WHERE S.ticketid = Ti.ticketid) > 1000;");

        Admin_technicalModel->setQuery(cWhereQuery);
        setTableViewResize(Admin_technicalModel, ui->Admin_selects_tableView);
}

void ClientWindow::on_Admin_select_C_FROM_button_clicked()
{
    QSqlQuery cFromQuery;
        cFromQuery.exec("SELECT refunddate AS \"Дата операции\", refundreason AS \"Причина возврата\", placenumber AS \"Номер места\", "
                        "ticketprice AS \"Цена билета\", sclass AS \"Класс места\" "
                        "FROM Tickets Ti, LATERAL (SELECT * FROM Refunds WHERE Ti.ticketid = ticketid) AS refunds_n_tickets_info, "
                        "LATERAL (SELECT * FROM flights WHERE flightid = Ti.flightid) AS flights_n_tickets_info "
                        "WHERE aircraftnumber = 'SU2458' AND sclass = 'Business';");

        Admin_technicalModel->setQuery(cFromQuery);
        setTableViewResize(Admin_technicalModel, ui->Admin_selects_tableView);
}

void ClientWindow::on_Admin_select_C_SELEC_button_clicked()
{
    QSqlQuery cSelectQuery;
        cSelectQuery.exec("SELECT R.departure AS \"Пункт вылета\", R.arrival AS \"Пункт прибытия\", "
                          "(SELECT COUNT(*) FROM Flights F WHERE F.routeid = R.routeid) AS \"Количество рейсов\" "
                          "FROM Routs R;");

        Admin_technicalModel->setQuery(cSelectQuery);
        setTableViewResize(Admin_technicalModel, ui->Admin_selects_tableView);
}

void ClientWindow::on_Admin_change_status_button_clicked()
{
    QSqlQuery changeStatusQuery;
        changeStatusQuery.exec("CALL change_status();");

    Admin_flightsModel->setQuery(database.SelectAll("flights"));
    setTableViewResize(Admin_flightsModel, ui->Admin_flights_tableView);
}

void ClientWindow::on_Admin_select_WHERE_button_clicked()
{
    QSqlQuery whereQuery;
        whereQuery.exec("SELECT Re.refundreason AS \"Причина возврата\" "
                        "FROM refunds Re JOIN "
                        "tickets Ti ON Ti.ticketid = Re.ticketid "
                        "WHERE Ti.ticketprice < (SELECT AVG(ticketprice) FROM tickets);");

        Admin_technicalModel->setQuery(whereQuery);
        setTableViewResize(Admin_technicalModel, ui->Admin_selects_tableView);
}

void ClientWindow::on_Admin_select_FROM_button_clicked()
{
    QSqlQuery fromQuery;
        fromQuery.exec("SELECT rout.departure AS \"Пункт вылета\", rout.arrival AS \"Пункт прибытия\", flig.aircraftnumber AS \"Номер рейса\", "
                       "tick.placenumber AS \"Номер места\", tick.usd_ticketprice AS \"Цена билета в долларах\" "
                       "FROM (SELECT to_usd(ticketprice, 74.84) AS usd_ticketprice,placenumber,flightid "
                       "FROM tickets "
                       "WHERE to_usd(ticketprice, 74.84) < 1000) AS tick JOIN "
                       "(SELECT aircraftnumber, flightid, routeid FROM Flights) AS flig "
                       "ON tick.flightid = flig.flightid "
                       "JOIN (SELECT departure, arrival, routeid FROM Routs WHERE departure = 'Москва' AND arrival = 'Рим') AS rout "
                       "ON flig.routeid = rout.routeid;");

        Admin_technicalModel->setQuery(fromQuery);
        setTableViewResize(Admin_technicalModel, ui->Admin_selects_tableView);
}

void ClientWindow::on_Admin_select_SELECT_button_clicked()
{
    QSqlQuery selectQuery;
        selectQuery.exec("SELECT CAST( "
                   "(SELECT AVG(ticketprice) "
                    "FROM tickets "
                    "WHERE sclass = 'Business') as int) - "
               "CAST( "
                   "(SELECT AVG(ticketprice) "
                    "FROM tickets "
                    "WHERE sclass = 'Economy') as int) AS \"Разница в цене\";");

        Admin_technicalModel->setQuery(selectQuery);
        setTableViewResize(Admin_technicalModel, ui->Admin_selects_tableView);
}

void ClientWindow::on_Admin_select_AGR_button_clicked()
{
    QSqlQuery agrQuery;
        agrQuery.exec("SELECT R.departure AS \"Пункт вылета\", R.arrival AS \"Пункт прибытия\", "
                      "COUNT(Pa.fullname) AS \"Количество пассажирова\", MIN(Ti.ticketprice) AS \"Минимальная стоимость билета\" "
                      "FROM passengers Pa "
                      "JOIN tickets Ti ON Ti.passengerid = Pa.passengerid "
                      "JOIN routs R ON R.routeid = Ti.routeid "
                      "GROUP BY R.departure, R.arrival "
                      "HAVING R.departure = 'Москва' "
                      "AND MIN(Ti.ticketprice) > 20000;");

        Admin_technicalModel->setQuery(agrQuery);
        setTableViewResize(Admin_technicalModel, ui->Admin_selects_tableView);
}

void ClientWindow::on_Admin_select_predicate_button_clicked()
{
    QSqlQuery predicateQuery;
        predicateQuery.exec("SELECT R.departure AS \"Пункт вылета\", R.arrival AS \"Пункт прибытия\", F.aircraftnumber AS \"Номер рейса\", "
                            "Ti.placenumber AS \"Номер места\", Ti.sclass AS \"Класс места\", Pa.fullname AS \"ФИО\" "
                            "FROM Routs R "
                            "JOIN Flights F ON R.routeid = F.routeid "
                            "JOIN tickets Ti ON Ti.flightid = F.flightid "
                            "JOIN passengers Pa ON Pa.passengerid = Ti.passengerid "
                            "WHERE Pa.passengerid = ANY(SELECT passengerid FROM passengers WHERE fullname = 'Иванов Иван Иванович');");

        Admin_technicalModel->setQuery(predicateQuery);
        setTableViewResize(Admin_technicalModel, ui->Admin_selects_tableView);
}

void ClientWindow::on_Admin_make_sales_button_clicked()
{
    QSqlQuery makeSalesQuery;
        makeSalesQuery.exec("CALL make_sales();");

    Admin_ticketsModel->setQuery(database.SelectAll("tickets"));
    setTableViewResize(Admin_ticketsModel, ui->Admin_tickets_tableView);
}

void ClientWindow::on_Admin_viewUpdate_button_clicked()
{
    auto reply = QMessageBox::question(nullptr, "Внимание!", "При изменении данных в представлении, будут обновлены данные в связанных таблицах.\n"
                                        "Вы уверены, что хотите изменить его?", QMessageBox::Yes|QMessageBox::No, QMessageBox::No);

    if(reply == QMessageBox::No)
        return;

    if(Admin_view_index != QModelIndex()){

        QString ticketID = Admin_viewModel->record(Admin_view_index.row()).value("ticketid").toString();
        QString aircraftNumber = ui->Admin_view_aircraftnumber_lineEdit->text();
        QString placeNumber = ui->Admin_view_placenumber_lineEdit->text();
        QString ticketPrice = ui->Admin_view_ticketPrice_lineEdit->text();
        QString ticketClass = ui->Admin_view_ticketClass_comboBox->currentText();
        QString fullName = ui->Admin_view_fullName_lineEdit->text();
        QString phone = ui->Admin_view_phone_lineEdit->text();
        QString email = ui->Admin_view_email_lineEdit->text();
        QString currentOrder = ui->Admin_view_sort_comboBox->currentText();

        QString flightValidation = database.validateFlight(aircraftNumber, QString::number(1), QString::number(1));
        QString ticketValidation = database.validateTicket(placeNumber, QString(), ticketPrice);
        QString userValidation = database.validateUser(database.getLogin(), "77777", fullName, phone, email);

        if(flightValidation != QString()){
            QMessageBox::warning(nullptr, "Ошибка обновления представления!", flightValidation); return;
        }

        if(ticketValidation != QString()){
            QMessageBox::warning(nullptr, "Ошибка обновления представления!", ticketValidation); return;
        }

        if(userValidation != QString()){
            QMessageBox::warning(nullptr, "Ошибка обновления представления!", userValidation); return;
        }

        QSqlQuery updateViewQuery;
            updateViewQuery.exec("CALL update_view(" + ticketID + ", '" + aircraftNumber + "', '" + placeNumber + "', " +
                                 ticketPrice + ", '" + ticketClass + "', '" + fullName + "', '" + phone + "', '" + email + "');");

        if(ui->Admin_view_sort_comboBox->currentIndex() == 0){
            Admin_viewModel->setQuery("SELECT * FROM tickets_n_passengers_info "
                                      "ORDER BY aircraftnumber;");}
        else{
            Admin_viewModel->setQuery("SELECT * FROM tickets_n_passengers_info "
                                      "ORDER BY " + currentOrder + ";");}

        setTableViewResize(Admin_viewModel, ui->Admin_view_tableView);

        Admin_flightsModel->setQuery(database.SelectAll("flights"));
        setTableViewResize(Admin_flightsModel, ui->Admin_flights_tableView);

        Admin_ticketsModel->setQuery(database.SelectAll("tickets"));
        setTableViewResize(Admin_ticketsModel, ui->Admin_tickets_tableView);

        Admin_usersModel->setQuery(database.SelectAll("passengers"));
        setTableViewResize(Admin_usersModel, ui->Admin_users_tableView);
    }
    else
        QMessageBox::warning(nullptr, "Ошибка обновления представления!", "Выберите строку!");
}

void ClientWindow::on_Admin_select_view_button_clicked()
{
    QString currentOrder = ui->Admin_view_sort_comboBox->currentText();

    QSqlQuery viewQuery;

    if(ui->Admin_view_sort_comboBox->currentIndex() == 0){
        viewQuery.exec("SELECT aircraftnumber AS \"Номер рейса\", placenumber AS \"Номер места\", fullname AS \"ФИО\" "
                   "FROM tickets_n_passengers_info "
                   "WHERE sclass = 'First' "
                   "AND aircraftnumber = 'FV6363' "
                   "ORDER BY aircraftnumber;");}
    else{
        viewQuery.exec("SELECT aircraftnumber AS \"Номер рейса\", placenumber AS \"Номер места\", fullname AS \"ФИО\" "
                   "FROM tickets_n_passengers_info "
                   "WHERE sclass = 'First' "
                   "AND aircraftnumber = 'FV6363' "
                   "ORDER BY " + currentOrder + ";");}

        Admin_technicalModel->setQuery(viewQuery);
        setTableViewResize(Admin_technicalModel, ui->Admin_selects_tableView);
}

void ClientWindow::on_update_table_info_clicked()
{
    QString sender = QObject::sender()->objectName();

    if(sender == "Admin_routes_updInfo_button"){
        Admin_routsModel->setQuery(database.SelectAll("routs"));
        setTableViewResize(Admin_routsModel, ui->Admin_routs_tableView);
    }
    else if(sender == "Admin_flights_updInfo_button"){
        Admin_flightsModel->setQuery(database.SelectAll("flights"));
        setTableViewResize(Admin_flightsModel, ui->Admin_flights_tableView);
    }
    else if(sender == "Admin_tickets_updInfo_button"){
        Admin_ticketsModel->setQuery(database.SelectAll("tickets"));
        setTableViewResize(Admin_ticketsModel, ui->Admin_tickets_tableView);
    }
    else if(sender == "Admin_users_updInfo_button"){
        Admin_usersModel->setQuery(database.SelectAll("passengers"));
        setTableViewResize(Admin_usersModel, ui->Admin_users_tableView);
    }
    else if(sender == "Admin_sales_updInfo_button"){
        Admin_salesModel->setQuery(database.SelectAll("sales"));
        setTableViewResize(Admin_salesModel, ui->Admin_sales_tableView);
    }
    else if(sender == "Admin_refunds_updInfo_button"){
        Admin_refundsModel->setQuery(database.SelectAll("refunds"));
        setTableViewResize(Admin_refundsModel, ui->Admin_refunds_tableView);
    }
    else if(sender == "Admin_view_updInfo_button"){

        if(ui->Admin_view_sort_comboBox->currentIndex() == 0){
            Admin_viewModel->setQuery("SELECT * FROM tickets_n_passengers_info "
                                      "ORDER BY aircraftnumber;");
            setTableViewResize(Admin_viewModel, ui->Admin_view_tableView);
        }
        else{
            Admin_viewModel->setQuery("SELECT * FROM tickets_n_passengers_info "
                                      "ORDER BY " + ui->Admin_view_sort_comboBox->currentText() + ";");
            setTableViewResize(Admin_viewModel, ui->Admin_view_tableView);
        }
    }
}

void ClientWindow::on_shortcut_pressed()
{
    if(database.checkUser() == "Admin"){
        if(ui->tabWidget->currentIndex() == 7){
            ui->tabWidget->setCurrentIndex(0); return;
        }
    }

    if(database.checkUser() == "Client"){
        if(ui->tabWidget->currentIndex() == 1){
            ui->tabWidget->setCurrentIndex(0); return;
        }
    }

    ui->tabWidget->setCurrentIndex(ui->tabWidget->currentIndex() + 1);
}

ClientWindow::~ClientWindow()
{
    delete ui;
    database.closeDataBase();
}
