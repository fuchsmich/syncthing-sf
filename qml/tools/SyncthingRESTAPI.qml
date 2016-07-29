import QtQuick 2.0
import QtQuick.XmlListModel 2.0

Item {
    id: root
    readonly property string restVersion: '0.14'
    property string guiUrl: 'http://localhost:8384'
    property string apiKey: '' //: '0KtQMct7bdCeSI6nE08UE-AP2y-jxges'
    property string myId: ''

    signal refreshEndpoints();

    Timer {
        id: timer
        interval: 2000
        repeat: true
//        onTriggered: refreshEndpoints();//refresh();
    }


    XmlListModel {
        id: apiKeyModel
        source: "file://" + genericConfigPath + '/syncthing/config.xml'
        query: "/configuration/gui"
        XmlRole { name: "key"; query: "apikey/string()"}
        onStatusChanged: {
//            console.log("apiKey", status, count, errorString(), apiKey, XmlListModel.Ready);
            if ( status === XmlListModel.Ready && count >= 1 ) root.apiKey = get(0).key;
//            console.log(apiKey);
        }
    }

    onApiKeyChanged: if (apiKey !== '') timer.start();
    function refresh() {
        console.log('refresh');
        systemVersion.refresh();
        config.refresh();
        status.refresh();
        requestGet(connections.source, connections.setJSON);
    }

    
    function getName4ID(id) {
        var devices = config['devices']
        for (var i in devices) {
            console.log(devices[i]['deviceID']);
            if ( devices[i]['deviceID'] === id ) return devices[i]['name'];
        }
    }
    
    function requestGet(source, cbf) {
        if (source === '' || apiKey === '') return;
        var xhr = new XMLHttpRequest;
        xhr.open("GET", source);
        xhr.onreadystatechange = function() {
//            console.log("rg", xhr.readyState, xhr.status, xhr.statusText, xhr.responseText);
            if (xhr.readyState === XMLHttpRequest.DONE && xhr.status === 200) {
//                console.log("rg", xhr.responseText);
                cbf(JSON.parse(xhr.responseText));
            }
        }
        xhr.setRequestHeader('X-API-Key', apiKey);

        xhr.send();
    }


    property RestEndpoint systemVersion: RestEndpoint {
        apiKey: root.apiKey
        source: guiUrl + '/rest/system/version'
    }

    property RestEndpoint status: RestEndpoint {
        apiKey: root.apiKey
        source: guiUrl + '/rest/system/status'
        onJsonChanged: myId = json['myID']
    }

    property RestEndpoint config: RestEndpoint {
        apiKey: root.apiKey
        source: guiUrl + '/rest/system/config'
        onJsonChanged: folderModel.getFolders();
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
            var folders = config.json['folders'];
            root.folderModel.clear();
            for (var i in folders) {
                var folder = folders[i];
                var name = (folder['label'] === '' ? folder['id'] : folder['label']);
                root.folderModel.append({"name" : name, "folderId": folder['id'], "path" : "file://" + folder['path']});
            }
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
            devTot = 0;
            for (var i in json['connections']) {
                devTot++;
                if (json['connections'][i]['connected'] === true) devConnected++;
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
    }
}
