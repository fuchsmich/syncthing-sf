import QtQuick 2.0
import QtQuick.XmlListModel 2.0

Item {
    id: root
    property string guiUrl: 'http://localhost:8384'
    property string apiKey //: '0KtQMct7bdCeSI6nE08UE-AP2y-jxges'
    

    Timer {
        id: timer
        interval: 2000
        repeat: true
        onTriggered: init();
    }


    XmlListModel {
        id: apiKeyModel
        source: "file:///" + genericConfigPath + '/syncthing/config.xml'
        query: "/configuration/gui"
        XmlRole { name: "key"; query: "apikey/string()"}
        onStatusChanged: {
//            console.log("apiKey", status, count, errorString(), apiKey, XmlListModel.Ready);
            if ( status === XmlListModel.Ready && count >= 1 ) root.apiKey = get(0).key;
//            console.log(apiKey);
        }
    }

    onApiKeyChanged: timer.start();
    function init() {
        console.log('init');
        requestGet(guiUrl + '/rest/system/config', function (json) { root.config = json; });
        requestGet(guiUrl + '/rest/system/status', function (json) { systemStatus = json; });
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
        //source = guiUrl + source;
        if (source === '' || apiKey === '') return;
        var xhr = new XMLHttpRequest;
        xhr.open("GET", source);
        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE && xhr.status === 200) {
                //                 console.log("rg", xhr.responseText);
                cbf(JSON.parse(xhr.responseText));
            }
        }
        xhr.setRequestHeader('X-API-Key', apiKey);

        xhr.send();
    }
    
    property var systemStatus
    property var config
    
    onConfigChanged: folder.getFolders();
    

    property ListModel folder:
        ListModel {
        property var stats
        function getFolders() {
            var folders = config['folders'];
            root.folder.clear();
            for (var i in folders) {
                var folder = folders[i];
                var name = (folder['label'] === '' ? folder['id'] : folder['label']);
                root.folder.append({"name" : name, "folderId": folder['id'], "path" : "file://" + folder['path']});
            }
            requestGet(guiUrl + '/rest/stats/folder', function(json){stats = json})
        }
//        onStatsChanged: console.log(JSON.stringify(stats))
    }


    property ListModel connections:
        ListModel {
        property string source: guiUrl + '/rest/system/connections'
        property var json
        property int devTot: (count > 0 ? count - 1 : count)
        property int devConnected: 0
        property real inBytesTotal
        property real inBytesTotalRate
        property real outBytesTotal
        property real outBytesTotalRate
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
        }

        function setJSON(json) {
            connections.json = json;
            devConnected = 0;
            clear();
            for (var i in json['connections']) {
                append({"deviceID": i});
                if (json['connections'][i]['connected'] === true) devConnected++;
            }
        }

        function formatBytes(bytes) {
            var units=[];
            units[1024^3] = "GiB";
            units[1024^2] = "MiB";
            units[1024] = "KiB";
            for (var i in units)
                if (bytes > i) return Number(bytes/i).toLocaleString(Qt.locale(), 'f') + " " + units[i];
            return Number(bytes).toLocaleString(Qt.locale(), 'f') + " B";
        }
    }
}
