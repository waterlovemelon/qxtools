// SPDX-FileCopyrightText: 2023 UnionTech Software Technology Co., Ltd.
//
// SPDX-License-Identifier: LGPL-3.0-or-later

#include "LogManager.h"
#include "Logger.h"

#include <QCoreApplication>
#include <QDebug>
#include <QDir>

DCORE_USE_NAMESPACE

int main(int argc, char **argv)
{
    QCoreApplication app(argc, argv);
    #define USE_APPLICATION_NAME
#ifdef USE_APPLICATION_NAME
    app.setOrganizationName("com.waterlovemelon");
    app.setApplicationName("qxtools-log-example");
    qInfo() << "Log file path:" << DLogManager::getlogFilePath();
#else
    DLogManager::setlogFilePath( QDir::currentPath() + "/qxtools-log-example.log");
#endif

#ifdef Q_OS_LINUX
    DLogManager::registerJournalAppender();
#endif
    DLogManager::registerFileAppender();
    DLogManager::registerConsoleAppender();
    

    qDebug() << "This is a debug message";
    qInfo() << "This is a info message";
    qWarning() << "This is a warning message";
    qCritical() << "This is a critical message";

    return app.exec();
}
