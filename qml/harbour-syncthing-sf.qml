/*
  Copyright (C) 2016 Michael Fuchs <michfu@gmx.at>
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

import "tools"

ApplicationWindow
{
    id: app

//    SyncConnector {
//        id: sc
//        onStatusChanged: {
//            syncthingService.refreshState();
//            ac.readState();
//        }
//        onStartStopWithWifiChanged: syncthingService.toggleServiceDueToState(startStopWithWifi, connmanWifi.wifiConnected);
//        onStartStopWithACChanged: syncthingService.toggleServiceDueToState(startStopWithAC, ac.online);
//    }

    SyncthingRESTAPI {
        id: stra
        appConfigPath: genericConfigPath
        Component.onCompleted: console.log("stdpath", StandardPaths.genericData);
    }

    AC {
        id: ac
        onOnlineChanged:
            syncthingService.toggleServiceDueToState(settings.startStopWithAC, ac.online);
    }

    Item {
        id: settings
        property bool startStopWithAC: false
        property bool startStopWithWifi: false
        property bool startStopWithApp: false
    }

    DBusInterface {
        id: syncthingService

        service: "org.freedesktop.systemd1"
        path: "/org/freedesktop/systemd1/unit/syncthing_2eservice"
        iface: "org.freedesktop.systemd1.Unit"

        property string state: getProperty("ActiveState")
        property bool readyToStart:
            (!settings.startStopWithWifi || (settings.startStopWithWifi && connmanWifi.wifiConnected)) &&
            (!settings.startStopWithAC || (settings.startStopWithAC && ac.online))
        property bool startMeUp: false

        onReadyToStartChanged: {
            console.log("ReadyToStart", readyToStart);
            if (startMeUp && readyToStart) {
                start();
                startMeUp = false;
            }
        }


        function refreshState() {
            state = getProperty("ActiveState")
        }
        function start() {
            console.log("Starting", readyToStart);
            if (readyToStart && syncthingService.state != "active") {
                syncthingService.call("Start", ["replace"]);
                refreshState()
            }
        }
        function stop() {
            if (syncthingService.state == "active") {
                syncthingService.call("Stop", ["replace"]);
                refreshState()
            }
        }

        function toggle() {
            syncthingService.call(
                        syncthingService.state != "active" ? "Start" : "Stop"
                        , ["replace"]);
            refreshState()
        }

        function toggleServiceDueToState(active, state) {
            if (active) {
                if (!state) {
                    syncthingService.stop()
                }
                if (state) {
                    syncthingService.start()
                }
            }
        }

        Component.onCompleted: {
            console.log("los gehts");
            if (settings.startStopWithApp) syncthingService.startMeUp = true;
        }
        Component.onDestruction: {
            console.log("und tschü");
            if (settings.startStopWithApp) syncthingService.stop();
        }
    }


    DBusInterface {
        id: connmanWifi
        bus: DBus.SystemBus
        service: "net.connman"
        path: "/net/connman/technology/ethernet" //Emulator hat kein Wifi
//        path: "/net/connman/technology/wifi" //<--- richtiger Pfad am Jolla
        iface: "net.connman.Technology"

        property bool wifiConnected
        onWifiConnectedChanged:
            syncthingService.toggleServiceDueToState(settings.startStopWithWifi, wifiConnected);

        signalsEnabled: true
        function propertyChanged(name, value) {
//            console.log(name, value)
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


