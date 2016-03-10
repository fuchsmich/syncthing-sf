/*
 * Copyright (C) 2011 Nokia Corporation and/or its subsidiary(-ies)
 *
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
 *
 * THIS SOFTWARE IS PROVIDED BY APPLE COMPUTER, INC. ``AS IS'' AND ANY
 * EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
 * PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL APPLE COMPUTER, INC. OR
 * CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
 * EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
 * PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
 * PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY
 * OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

import QtQuick 2.0
import Sailfish.Silica 1.0


Item {
    id: selectorItem
    anchors.fill: parent
    property QtObject selectorModel: model

    Component.onCompleted: {
        pageStack.push(menuDialogComponent)
    }

    Component {
        id: menuDialogComponent

        Page {


            SilicaListView {
                id: view
                model: selectorModel.items
                anchors.fill: parent
                delegate: BackgroundItem {
                    id: delegateItem
                    onClicked: {
                        selectorModel.accept(model.index)
                        pageStack.pop()
//                        selectorItem.destroy()
                    }
                    Label {
                        x: Theme.horizontalPageMargin
                        anchors.verticalCenter: parent.verticalCenter
                        width: parent.width - x*2
                        wrapMode: Text.Wrap
                        text: model.text
                        color: (delegateItem.highlighted || model.item === selectorModel.currentItem)
                               ? Theme.highlightColor
                               : Theme.primaryColor
                    }
                }
                VerticalScrollDecorator {}

                Component.onCompleted: {
                    console.log(selectorModel)
                }

            }
        }
    }
}
