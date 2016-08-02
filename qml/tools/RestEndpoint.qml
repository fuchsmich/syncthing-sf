import QtQuick 2.0

Item {
    id: re
    property string source: ''
    property string apiKey: '' //parent.apiKey
    property var parameters: []
    property var json: '' //: JSON.parse('')
    property string error: ''

    function refresh() {
        var parmString = '';
        for (var name in parameters) {
            if (parmString.length > 0) parmString += "&";
            else parmString = "?";
            parmString += name + "=" + parameters[name];
        }
        var source = re.source + parmString;

        if (source === '' || apiKey === '') return;
        console.log(source, apiKey);
        var xhr = new XMLHttpRequest;
        xhr.open("GET", source);
        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                if (xhr.status === 200) {
                    //                 console.log("rg", xhr.responseText);
                    error = '';
                    json = JSON.parse(xhr.responseText);
                } else {
                    error = xhr.statusText;
                    json = '';
                }
            }
        }
        xhr.setRequestHeader('X-API-Key', apiKey);

        xhr.send();
    }

        onParametersChanged: refresh();
        onSourceChanged: refresh();
        onApiKeyChanged: refresh();
}

