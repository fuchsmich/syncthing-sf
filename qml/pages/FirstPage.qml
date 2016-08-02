
import QtQuick 2.2
import Sailfish.Silica 1.0
import '../items' as MyItems



Page {
    id: page
    //    property string sTstatus: stra.status
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
                onClicked: pageStack.push(Qt.resolvedUrl("MyID.qml"));
                enabled: stra.connected
            }
            MenuItem {
                text: qsTr("SyncThing Web UI")
                onClicked: Qt.openUrlExternally(stra.guiUrl)
                enabled: stra.connected
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
                visible: false
                enabled: false
                x: Theme.paddingLarge
                text: "start/stop service with Wifi connection"
                description: "Wifi state: " + (connmanWifi.wifiConnected ? "connected" : "not connected")
                checked: settings.startStopWithWifi
                onCheckedChanged: settings.startStopWithWifi = checked
            }
            TextSwitch {
                visible: false
                enabled: false
                x: Theme.paddingLarge
                text: "start/stop service with AC connection"
                description: "AC state: " + (ac.online ? "connected" : "not connected")
                checked: settings.startStopWithAC
                onCheckedChanged: settings.startStopWithAC = checked
            }


            SectionHeader {
                text: qsTr("Service - State")
            }
            DetailItem {
//                visible: false
                label: qsTr("Status")
                value: (stra.connected ? qsTr('connected') : qsTr('not connected'))
            }
            DetailItem {
//                visible: false
                enabled: stra.connected
                label: qsTr("Client Version")
                value: (stra.connected ? stra.systemVersion.json['version']:'')
            }
            DetailItem {
//                visible: false
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

            ColumnView {
                width: parent.width
//                height: Theme.itemSizeLarge*(count +3)
                itemHeight: Theme.itemSizeMedium
                model: stra.folderModel
                delegate:
                    ListItem {
                    contentHeight: Theme.itemSizeMedium
                    Label {
                        x: Theme.paddingLarge
                        text: ( model.name === '' ? model.folderId : model.name)
                    }
//                    Label {
//                        x: Theme.paddingLarge
//                        text: model.folderId
//                        font.pixelSize: Theme.fontSizeTiny
//                    }
                    menu: ContextMenu {
                        MenuItem {
                            text: "Browse Folder"
                        }

//                        MenuItem {
//                            text: "Last File"
//                            //                            value: stra.statsFolder.json[folderId]['lastFile']['filename']
//                            font.pixelSize: Theme.fontSizeTiny
//                        }
//                        MenuItem {
//                            text: "Completed"
//                            //                            value: "XX %"
//                            //                            fontPixelSize: Theme.fontSizeTiny
//                        }
                    }
                }
                //                contentHeight: Theme.itemSizeMedium
                //                    //                        onClicked: {
                //                    //                            fp.selectedFolder = path
                //                    //                            pageStack.push(Qt.resolvedUrl("FileBrowser.qml"), {rootFolder: path})
                //                    //                        }
                //                }
            }
        }
    }
}


