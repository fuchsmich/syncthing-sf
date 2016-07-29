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
import '../items' as MyItems



Page {
    id: page
    property string sTstatus: sc.status
    property string selectedFolder

    SilicaFlickable {
        anchors.fill: parent

        // PullDownMenu and PushUpMenu must be declared in SilicaFlickable, SilicaListView or SilicaGridView
        PullDownMenu {
            MenuItem {
                text: qsTr("About")
                onClicked: pageStack.push(Qt.resolvedUrl("About.qml"))
            }
            MenuItem {
                text: qsTr("Settings")
                onClicked: pageStack.push(Qt.resolvedUrl("Settings.qml"))
            }
            MenuItem {
                text: qsTr("Show ID")
                onClicked: ;
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
                text: qsTr("Controller")
            }
            Button {
                text: syncthingService.state //!= "active" ? "Start" : "Stop"
                anchors.horizontalCenter: parent.horizontalCenter
                onClicked: syncthingService.toggle()
            }
            TextSwitch {
                x: Theme.paddingLarge
                text: "start/stop service with Wifi connection"
                description: "Wifi state: " + (connmanWifi.wifiConnected ? "connected" : "not connected")
                checked: sc.startStopWithWifi
                onCheckedChanged: sc.startStopWithWifi = checked
            }
            TextSwitch {
                x: Theme.paddingLarge
                text: "start/stop service with AC connection"
                description: "AC state: " + (ac.online ? "connected" : "not connected")
                checked: sc.startStopWithAC
                onCheckedChanged: sc.startStopWithAC = checked
            }


            SectionHeader {
                text: qsTr("Service - State")
            }
            DetailItem {
                label: qsTr("Status")
                value: (stra.connections.json['total']['connected'] ? qsTr('connected') : qsTr('not connected'))
            }
            DetailItem {
                label: qsTr("Client Version")
                value: (stra.systemVersion.json['version'])
            }
            DetailItem {
                label: qsTr("Connections")
                value: stra.connections.devConnected + "/" + stra.connections.devTot
            }
            Row {
                //                x: Theme.paddingLarge
                //                spacing: Theme.paddingLarge
                width: parent.width
                height: dti.height
                MyItems.DetailItem {
                    id: dti
                    width: parent.width/2
                    label: "In"
                    value: stra.connections.formatBytes(stra.connections.inBytesTotalRate)
                           + "/s (" + stra.connections.formatBytes(stra.connections.inBytesTotal) + ")"
                    fontPixelSize: Theme.fontSizeTiny
                }
                MyItems.DetailItem {
                    width: parent.width/2
                    label: "Out"
                    value: stra.connections.formatBytes(stra.connections.outBytesTotalRate)
                           + "/s (" + stra.connections.formatBytes(stra.connections.outBytesTotal) + ")"
                    fontPixelSize: Theme.fontSizeTiny
                }
            }
            SectionHeader {
                text: qsTr("Shared Folders")
            }
            Repeater {
                model: stra.folderModel
                Column {
                    width: page.width
                    FolderDelegate {
                        x: Theme.paddingLarge
                        text: ( name === '' ? folderID : name)
                        iconSource: "image://theme/icon-m-folder"
                        onClicked: {
                            fp.selectedFolder = path
                            pageStack.push(Qt.resolvedUrl("FileBrowser.qml"), {rootFolder: path})
                        }
                    }
                    MyItems.DetailItem {
                        label: "Last File"
                        value: stra.statsFolder.json[folderId]['lastFile']['filename']
                        fontPixelSize: Theme.fontSizeTiny
                    }
                    MyItems.DetailItem {
                        label: "Completed"
                        value: "XX %"
                        fontPixelSize: Theme.fontSizeTiny
                    }
                }
            }
//            SectionHeader {
//                //                x: Theme.paddingLarge
//                text: qsTr("Last Synced Files")
//                //                color: Theme.secondaryHighlightColor
//                //                font.pixelSize: Theme.fontSizeExtraLarge
//            }
        }
    }
}


