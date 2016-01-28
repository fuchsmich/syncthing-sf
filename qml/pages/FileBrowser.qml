import QtQuick 2.0
import Qt.labs.folderlistmodel 2.1
import Sailfish.Silica 1.0


Page {
    id: fileBrowser
    property string folder

    FolderListModel {
        id: folderModel
        folder: "file://" + fileBrowser.folder
        showDirsFirst: true
    }

    SilicaListView {
        model: folderModel
        header: PageHeader {
            title: fileBrowser.folder
        }
        VerticalScrollDecorator {}

        delegate: ListItem {
            Label {
                text: fileName
            }
            menu: ContextMenu {
                MenuItem {
                    text: "Delete"
                }
            }
        }

    }
    Component.onCompleted: console.log(parent.objectName)

}

