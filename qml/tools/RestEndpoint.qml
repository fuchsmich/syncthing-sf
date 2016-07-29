import QtQuick 2.0

Item {
    id: re
    property string source: ''
    property string apiKey: '' //parent.apiKey
    property var parameters: []
    property var json//: JSON.parse('')

    function refresh() {
        var parmString = '';
        for (var name in parameters) {
            if (parmString.length > 0) parmString += "&";
            else parmString = "?";
            parmString += name + "=" + parameters[name];
        }
        var source = re.source + parmString;
//        console.log(source);

        if (source === '' || apiKey === '') return;
        var xhr = new XMLHttpRequest;
        xhr.open("GET", source);
        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE && xhr.status === 200) {
                //                 console.log("rg", xhr.responseText);
                json = JSON.parse(xhr.responseText);
            }
        }
        xhr.setRequestHeader('X-API-Key', apiKey);

        xhr.send();
    }
    Connections {
        target: timer
        onTriggered: refresh();
    }

    onParametersChanged: refresh();
    onSourceChanged: refresh();
}

