
import QtQuick 2.2
import Sailfish.Silica 1.0
import '../items' as MyItems



Page {
    id: page
    //    property string sTstatus: rest.status
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
                enabled: rest.connected
            }
            MenuItem {
                text: qsTr("SyncThing Web UI")
                onClicked: Qt.openUrlExternally(rest.guiUrl)
                enabled: rest.connected
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
                value: (rest.connected ? qsTr('connected') : qsTr('not connected'))
            }
            DetailItem {
//                visible: false
                enabled: rest.connected
                label: qsTr("Client Version")
                value: (rest.connected ? rest.systemVersion.json['version']:'')
            }
            DetailItem {
//                visible: false
                label: qsTr("Connections")
                value: rest.connections.devConnected + "/" + rest.connections.devTot
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
                    value: rest.connections.formatBytes(rest.connections.inBytesTotalRate)
                           + "/s (" + rest.connections.formatBytes(rest.connections.inBytesTotal) + ")"
                    fontPixelSize: Theme.fontSizeTiny
                }
                MyItems.DetailItem {
                    width: parent.width/2
                    label: "Out"
                    value: rest.connections.formatBytes(rest.connections.outBytesTotalRate)
                           + "/s (" + rest.connections.formatBytes(rest.connections.outBytesTotal) + ")"
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
                model: rest.folderModel
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
//                            //                            value: rest.statsFolder.json[folderId]['lastFile']['filename']
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


