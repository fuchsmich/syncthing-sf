import QtQuick 2.1
import Sailfish.Silica 1.0
import Qt.labs.folderlistmodel 2.0
import '../qqr'

Page {
    property string fid: ''
    property string name: ''

    Column {
        anchors.fill: parent
        spacing: 10

        PageHeader {
            title: qsTr("SyncThing - My ID")
        }

        DetailItem{
            width: parent.width
            label: "ID"
            value: stra.myId
        }
        QRCode {
            anchors.centerIn: parent
            width: 320
            height: 320
            value: stra.myId
        }
    }
}