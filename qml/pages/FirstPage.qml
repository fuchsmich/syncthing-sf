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



Page {
    id: page
    property string sTstatus: sc.status

    SilicaFlickable {
        anchors.fill: parent

        // PullDownMenu and PushUpMenu must be declared in SilicaFlickable, SilicaListView or SilicaGridView
        PullDownMenu {
            MenuItem {
                text: qsTr("About")
                onClicked: pageStack.push(Qt.resolvedUrl("About.qml"))
            }
            MenuItem {
                text: qsTr("Einstellungen")
                onClicked: pageStack.push(Qt.resolvedUrl("Settings.qml"))
            }
            MenuItem {
                text: qsTr("SyncThing Web UI")
                onClicked: Qt.openUrlExternally(sc.guiUrl)
            }
        }

        // Tell SilicaFlickable the height of its content.
        contentHeight: column.height
        VerticalScrollDecorator {}

        Column {
            id: column

            width: page.width
            spacing: Theme.paddingLarge
            PageHeader {
                title: qsTr("SyncThing")
            }
            SectionHeader {
                text: qsTr("Service")
            }
            Button {
                text: syncthingService.state //!= "active" ? "Start" : "Stop"
                anchors.horizontalCenter: parent.horizontalCenter
                onClicked: syncthingService.toggle()
            }
            TextSwitch {
                x: Theme.paddingLarge
                text: "Start/stop service with Wifi-connection"
                description: "Wifi status: " + (connman_wifi.wifiConnected ? "connected" : "not connected")
                checked: sc.startStopWithWifi
                onCheckedChanged: sc.startStopWithWifi = checked
            }


            SectionHeader {
                text: qsTr("Service")
            }
            Label {
                x: Theme.paddingLarge
                text: qsTr("Status")
                color: Theme.secondaryHighlightColor
                font.pixelSize: Theme.fontSizeExtraLarge
            }
            Label {
                x: Theme.paddingLarge
                text: sc.status
                //                color: Theme.secondaryHighlightColor
                //                font.pixelSize: Theme.fontSizeExtraLarge
            }
            Label {
                x: Theme.paddingLarge
                text: sc.numberOfConnections
            }
            Row {
                x: Theme.paddingLarge
                spacing: Theme.paddingLarge
                Label {
                    //                x: Theme.paddingLarge
                    text: qsTr("In: 0,00 KB/s")
                    //                color: Theme.secondaryHighlightColor
                    //                font.pixelSize: Theme.fontSizeExtraLarge
                }
                Label {
                    //                x: Theme.paddingLarge
                    text: qsTr("Out: 0,00 KB/s")
                    //                color: Theme.secondaryHighlightColor
                    //                font.pixelSize: Theme.fontSizeExtraLarge
                }
            }
            Label {
                x: Theme.paddingLarge
                text: qsTr("Total: 0,00 KB/s")
                //                color: Theme.secondaryHighlightColor
                //                font.pixelSize: Theme.fontSizeExtraLarge
            }
            Label {
                x: Theme.paddingLarge
                text: qsTr("Shared Folders")
                color: Theme.secondaryHighlightColor
                font.pixelSize: Theme.fontSizeExtraLarge
            }
            Repeater {
                model: sc.folders
                Label {
                    x: Theme.paddingLarge
                    text: modelData.name + " (" + modelData.path + ")"
                    //                    text: name + " (" + path + ")"
                }
            }
            Label {
                x: Theme.paddingLarge
                text: qsTr("Last Synced Files")
                color: Theme.secondaryHighlightColor
                font.pixelSize: Theme.fontSizeExtraLarge
            }
            Repeater {
                model: sc.files
                Label {
                    x: Theme.paddingLarge
                    text: modelData.name + " (" + modelData.path + ")"
                    //                    text: name + " (" + path + ")"
                }
            }
        }
    }
}


