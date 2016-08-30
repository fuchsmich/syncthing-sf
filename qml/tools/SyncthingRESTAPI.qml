//TODO Abfragen mit States herstellen? Für Frontpage, Devices, Folder, ...

import QtQuick 2.0
import QtQuick.XmlListModel 2.0

Item {
    id: root
    readonly property string restVersion: '0.14'
    property string guiUrl: 'http://localhost:8384'
    property string apiKey: ''
    property bool connected: false
    property string myId: ''
    property string appConfigPath: ''
    property Timer timer: Timer {
        interval: 2000
        repeat: true
    }

    signal refreshEndpoints();



    XmlListModel {
        id: apiKeyModel
        source: "file://" + appConfigPath + '/syncthing/config.xml'
        query: "/configuration/gui"
        XmlRole { name: "key"; query: "apikey/string()"}
        onStatusChanged: {
            //            console.log("apiKey", status, count, errorString(), apiKey, XmlListModel.Ready);
            if ( status === XmlListModel.Ready && count >= 1 ) root.apiKey = get(0).key;
            console.log(apiKey);
        }
    }

    onApiKeyChanged: if (apiKey !== '') timer.start();
    onConnectedChanged: {
        if (connected) {

        }
    }
    
    function getName4ID(id) {
        var devices = config['devices']
        for (var i in devices) {
            console.log(devices[i]['deviceID']);
            if ( devices[i]['deviceID'] === id ) return devices[i]['name'];
        }
    }
    
    property RestEndpoint checkConnection: RestEndpoint {
        apiKey: root.apiKey
        source: guiUrl + '/rest/system/ping'
        onJsonChanged: {
//            console.log("cc", JSON.stringify(json));
            if (json["ping"] === "pong" && !connected) connected = true;
            else if (connected) connected = false;
        }
        onErrorChanged: console.log("ccerror", error)
        Connections {
            target: timer
            onTriggered: checkConnection.refresh();
        }
    }


    property RestEndpoint version: RestEndpoint {
        apiKey: root.apiKey
        source: guiUrl + '/rest/system/version'
    }

    property RestEndpoint status: RestEndpoint {
        apiKey: root.apiKey
        source: guiUrl + '/rest/system/status'
        onJsonChanged: {
            if (json['myID']) myId = json['myID'];
            else myId = '';
//            console.log(myId);
        }
        Connections {
            target: timer
            onTriggered:  if (root.connected) status.refresh();
        }
    }

    property RestEndpoint config: RestEndpoint {
        apiKey: root.apiKey
        source: guiUrl + '/rest/system/config'
        onJsonChanged: {
            folderModel.getFolders();
        }
        Connections {
            target: root
            onConnectedChanged: if (root.connected) config.refresh();
        }
    }

    property RestEndpoint statsFolder: RestEndpoint {
        apiKey: root.apiKey
        source: guiUrl + '/rest/stats/folder'
    }

    //    property RestEndpoint dbCompletion: RestEndpoint {
    //        apiKey: root.apiKey
    //        source: guiUrl + '/rest/db/completion'
    //        parameters: {"folder": "SkAAF-Lfaow"}
    //        onJsonChanged: console.log(JSON.stringify(json))
    //    }


    property ListModel folderModel: ListModel {
        function getFolders() {
            if (config.json['folders']) {
                var folders = config.json['folders'];
                root.folderModel.clear();
                for (var i in folders) {
                    var folder = folders[i];
                    var name = (folder['label'] === '' ? folder['id'] : folder['label']);
                    root.folderModel.append({"name" : name, "folderId": folder['id'], "path" : "file://" + folder['path']});
                }
            } else clear();
        }
    }


    property RestEndpoint connections: RestEndpoint {
        apiKey: root.apiKey
        source: guiUrl + '/rest/system/connections'
        property int devTot: 0 //(count > 0 ? count - 1 : count) //numb. of remote devices
        property int devConnected: 0 //numb. of remote devices connected to
        property real inBytesTotal: 0  //bytes received
        property real inBytesTotalRate: 0 //b/s received
        property real outBytesTotal: 0 //bytes sent
        property real outBytesTotalRate: 0 //b/s sent
        onJsonChanged: {
            if (json['total']) {
                var ibt = json['total']['inBytesTotal']
                if (typeof inBytesTotal !== 'undefined') {
                    inBytesTotalRate = (ibt-inBytesTotal)/(timer.interval/1000);
                }
                inBytesTotal = ibt;

                var obt = json['total']['outBytesTotal']
                if (typeof outBytesTotal !== 'undefined') {
                    outBytesTotalRate = (obt-outBytesTotal)/(timer.interval/1000);
                }
                outBytesTotal = obt;
                devConnected = 0;
                devTot = -1;
                for (var i in json['connections']) {
                    devTot++;
                    if (json['connections'][i]['connected'] === true) devConnected++;
                }
            } else {
                devTot = 0
                devConnected = 0
                inBytesTotal = 0
                inBytesTotalRate = 0
                outBytesTotal = 0
                outBytesTotalRate = 0
            }
        }

        function formatBytes(bytes) {
            var units=[];
            units[1000^3] = "Gb";
            units[1000^2] = "Mb";
            units[1000] = "Kb";
            for (var i in units)
                if (bytes > i) return Number(bytes/i).toLocaleString(Qt.locale(), 'f') + " " + units[i];
            return Number(bytes).toLocaleString(Qt.locale(), 'f') + " b";
        }
        Connections {
            target: timer
            onTriggered: if (connected) connections.refresh();
        }
    }
}
