/*
  Copyright (C) 2016 Michael Fuchs
  Contact: Michael Fuchs <michfu@gmx.at>
  All rights reserved.

  You may use this file under the terms of BSD license as follows:

  Redistribution and use in source and binary forms, with or without
  modification, are permitted provided that the following conditions are met:
    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.
    * Neither the name of the Jolla Ltd nor the
      names of its contributors may be used to endorse or promote products
      derived from this software without specific prior written permission.

  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
  ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
  WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
  DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDERS OR CONTRIBUTORS BE LIABLE FOR
  ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
  (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
  LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
  ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

import QtQuick 2.0
import Sailfish.Silica 1.0

Item {
//    readonly property string stateFile: "/sys/class/power_supply/AC/online" //->SailEmu
    readonly property string dcStateFile: "/sys/class/power_supply/pm8921-dc/online" //->Jolla
    readonly property string usbStateFile: "/sys/class/power_supply/usb/online" //->Jolla
    property bool dcOnline: false
    property bool usbOnline: false
    property bool online: dcOnline || usbOnline

    function readState() {
        var dcRequest =  new XMLHttpRequest();
        dcRequest.open('GET', dcStateFile);
        dcRequest.onreadystatechange = function(event) {
            if (dcRequest.readyState === XMLHttpRequest.DONE) {
//                console.log("AC state file", (dcRequest.responseText.trim() === "1"), online);
                if (dcOnline !== (dcRequest.responseText.trim() === "1")) {
                    dcOnline = (dcRequest.responseText.trim() === "1");
                }
            }
        }
        dcRequest.send()

        var usbRequest =  new XMLHttpRequest();
        usbRequest.open('GET', usbStateFile);
        usbRequest.onreadystatechange = function(event) {
            if (usbRequest.readyState === XMLHttpRequest.DONE) {
//                console.log("AC state file", (usbRequest.responseText.trim() === "1"), online);
                if (usbOnline !== (usbRequest.responseText.trim() === "1")) {
                    usbOnline = (usbRequest.responseText.trim() === "1");
                }
            }
        }
        usbRequest.send()
    }

    Component.onCompleted: readState();
}
