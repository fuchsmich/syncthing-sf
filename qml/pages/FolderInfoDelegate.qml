import QtQuick 2.1
import Sailfish.Silica 1.0
import Qt.labs.folderlistmodel 2.0

Page {
    property string fid: ''
    property string name: ''

    Column {
        DetailItem{
            label: "name"
            value: name
        }
        DetailItem{
            label: "ID"
            value: fid
        }

    }
}
