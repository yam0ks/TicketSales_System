#include "clientwindow.h"
#include "loginwindow.h"

#include <QApplication>

int main(int argc, char *argv[])
{
    QApplication a(argc, argv);
    ClientWindow w;
    LoginWindow login(&w, w.getDataBase());
    login.show();
    return a.exec();
}
