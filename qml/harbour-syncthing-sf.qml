/*
  Copyright (C) 2013 Jolla Ltd.
  Contact: Thomas Perl <thomas.perl@jollamobile.com>
  All rights reserved.

  You may use this file under the terms of BSD license as follows:

  Redistribution and use in source and binary forms, with or without
  modification, are permitted provided that the following conditions are met:
    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.
    * Neither the name of the Jolla Ltd nor the
      names of its contributors may be used to endorse or promote products
      derived from this software without specific prior written permission.

  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
  ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
  WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
  DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDERS OR CONTRIBUTORS BE LIABLE FOR
  ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
  (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
  LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
  ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

import QtQuick 2.0
import Sailfish.Silica 1.0
import "pages"

import org.nemomobile.dbus 2.0
import SyncConnector 1.0

ApplicationWindow
{
    id: app

    SyncConnector {
        id: sc
        onStatusChanged: syncthingService.refreshState()
        onStartStopWithWifiChanged: connman_wifi.toggleServiceDueToWifiState()
    }

    DBusInterface {
        id: syncthingServiceListener

        service: "org.freedesktop.systemd1"
        path: "/org/freedesktop/systemd1/unit/syncthing_2eservice"
        iface: "org.freedesktop.DBus.Properties"

        property string polledInterface: syncthingService.iface

        signalsEnabled: true

        //        function propertiesChanged(ifc, changed_properties,
        //                                   invalidated_properties) {
        //            console.log("signal PropertiesChanged caught")
        //        if (ifc === polledInterface) {
        //            console.log(syncthingService.getProperty("ActiveState"))
        //        }
        //        }
        onPropertiesChanged: {
            console.log("signal!")
        }


        //        property var allProps
        ////        onAllPropsChanged: console.log(JSON.stringify(allProps))

        //        function getAll(ifc) {
        //            typedCall('GetAll',
        //                      {'type': 's', 'value': ifc},
        //                      function(result){
        //                          allProps = result;
        //                          console.log(result['ActiveState'])
        //                      },
        //                      function() {
        //                          console.log('call failed')
        //                      })
        //        }

        //        Component.onCompleted: getAll(polledInterface)
    }

    DBusInterface {
        id: syncthingService

        service: "org.freedesktop.systemd1"
        path: "/org/freedesktop/systemd1/unit/syncthing_2eservice"
        iface: "org.freedesktop.systemd1.Unit"

        property string state: getProperty("ActiveState")
        property bool runOnlyOnWifiConnection: true
        //        signalsEnabled: true

        //        onPropertiesChanged: {
        //            console.log(getProperty("ActiveState"))
        //        }

        function refreshState() {
            state = getProperty("ActiveState")
        }
        function toggle() {
            syncthingService.call(
                        syncthingService.state != "active" ? "Start" : "Stop"
                        , ["replace"])
            refreshState()
        }
    }


    DBusInterface {
        id: connman_wifi
        bus: DBus.SystemBus
        service: "net.connman"
//        path: "/net/connman/technology/ethernet" //Emulator hat kein Wifi
        path: "/net/connman/technology/wifi" //<--- richtiger Pfad am Jolla
        iface: "net.connman.Technology"

        property bool wifiConnected
        onWifiConnectedChanged: toggleServiceDueToWifiState();

        function toggleServiceDueToWifiState() {
            if (sc.startStopWithWifi) {
                if (!wifiConnected && syncthingService.state == "active") {
                    syncthingService.toggle()
                }
                if (wifiConnected && syncthingService.state == "inactive") {
                    syncthingService.toggle()
                }
            }
        }

        signalsEnabled: true
        function propertyChanged(name, value) {
            console.log(name, value)
            if (name === "Connected") {
                wifiConnected = value
            }
        }

        function getProperties() {
            typedCall('GetProperties', undefined, function(result) {wifiConnected = result['Connected']})
        }
        Component.onCompleted: getProperties();
    }


    initialPage: Component { FirstPage { id: fp } }
    cover: Qt.resolvedUrl("cover/CoverPage.qml")
    allowedOrientations: Orientation.All
    _defaultPageOrientations: Orientation.All
}


