#include "loginwindow.h"
#include "ui_loginwindow.h"

#include <QMessageBox>
#include <QShortcut>

LoginWindow::LoginWindow(ClientWindow* window, DataBase* database, QWidget *parent) :
    QWidget(parent),
    ui(new Ui::LoginWindow), database(database), client(window)
{
    ui->setupUi(this);
    ui->line_login->setFocus();
    setWindowFlags(Qt::Window | Qt::WindowCloseButtonHint | Qt::MSWindowsFixedSizeDialogHint);
    ui->tabWidget->setCurrentIndex(0);
}

void LoginWindow::on_Login_button_clicked()
{
    if(database->makeConnection(ui->line_login->text(), ui->line_password->text())){
        database->setLogin(ui->line_login->text());
        client->showWindow();
        this->close();
    }
    else
        QMessageBox::warning(nullptr, "Ошибка авторизации!","Неверный логин или пароль!");
}

void LoginWindow::on_registration_button_clicked()
{
    if(!database->makeConnection("guest", "test")){
        QMessageBox::warning(nullptr, "Внимание!","Не удалось установить соединение с базой данных!");return;}

    QString login = ui->line_newLogin->text();
    QString password = ui->line_newPassword->text();
    QString passport = ui->line_passport->text();
    QString fullName = ui->line_fullname->text();
    QString phone = ui->line_phone->text();
    QString email = ui->line_email->text();

    if(!database->registerUser(login, password, passport, fullName, phone, email)){
      database->closeDataBase();return;
    }

    database->closeDataBase();

    ui->line_newLogin->clear();
    ui->line_newPassword->clear();
    ui->line_passport->clear();
    ui->line_fullname->clear();
    ui->line_phone->clear();
    ui->line_email->clear();
    ui->tabWidget->setCurrentWidget(ui->sign_in);
}

LoginWindow::~LoginWindow()
{
    delete ui;
}
