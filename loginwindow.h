#ifndef LOGINWINDOW_H
#define LOGINWINDOW_H

#include "database.h"
#include "clientwindow.h"

#include <QWidget>

namespace Ui {
class LoginWindow;
}

class LoginWindow : public QWidget
{
    Q_OBJECT

public:
    explicit LoginWindow(ClientWindow* window, DataBase* database, QWidget *parent = nullptr);
    ~LoginWindow();

private slots:
    void on_Login_button_clicked();

    void on_registration_button_clicked();

private:
    Ui::LoginWindow *ui;
    DataBase* database;
    ClientWindow* client;
};

#endif // LOGINWINDOW_H
