/******************************************************************************
// QSyncThingTray
// Copyright (c) Matthias Frick, All rights reserved.
//
// This library is free software; you can redistribute it and/or
// modify it under the terms of the GNU Lesser General Public
// License as published by the Free Software Foundation; either
// version 3.0 of the License, or (at your option) any later version.
//
// This library is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
// Lesser General Public License for more details.
//
// You should have received a copy of the GNU Lesser General Public
// License along with this library.
******************************************************************************/

//#ifdef QT_QML_DEBUG
#include <QtQuick>
//#endif

#include <sailfishapp.h>

#include "syncconnectorplugin.h"


//#include <QApplication>

//#include <QMessageBox>
//#include "window.h"

// settings für qml: https://lists.sailfishos.org/pipermail/devel/2013-December/002321.html

int main(int argc, char *argv[])
{
//    Q_INIT_RESOURCE(qsyncthing);

//    QApplication app(argc, argv);

    qmlRegisterType<QQuickSyncConnector>("SyncConnector", 1, 0, "SyncConnector");
    return SailfishApp::main(argc, argv);

}
