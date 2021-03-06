/**
 *
 * gPodder QML UI Reference Implementation
 * Copyright (c) 2013, 2014, Thomas Perl <m@thp.io>
 *
 * Permission to use, copy, modify, and/or distribute this software for any
 * purpose with or without fee is hereby granted, provided that the above
 * copyright notice and this permission notice appear in all copies.
 *
 * THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES WITH
 * REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF MERCHANTABILITY
 * AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY SPECIAL, DIRECT,
 * INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM
 * LOSS OF USE, DATA OR PROFITS, WHETHER IN AN ACTION OF CONTRACT, NEGLIGENCE OR
 * OTHER TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH THE USE OR
 * PERFORMANCE OF THIS SOFTWARE.
 *
 */

import QtQuick 2.0
import Sailfish.Silica 1.0

Item {
    id: root

    property string icon: "image://icons/item"
    property alias enabled: iconButton.enabled
    property alias text: lbl.text
    property string theme: ""

    property string iconColor: root.theme === "transparent" ? Theme.primaryColor :
                               root.theme === "black" ? Theme.primaryColor :
                               root.theme === "highlighted" ? Theme.highlightBackgroundColor :
                               root.theme === "dimmer" ? Theme.primaryColor :
                               Theme.primaryColor

    width: iconButton.width
    height: iconButton.height
    visible: enabled

    signal clicked()
    signal downed()

    onClicked: parent.show()
    onDowned: parent.show()

    Label {
        id: lbl
        opacity: iconButton.down

        Behavior on opacity {
            FadeAnimation {}
        }

        anchors {
            verticalCenter: parent.top
            horizontalCenter: parent.horizontalCenter
        }

        color: Theme.secondaryHighlightColor //iconColor
        font.pixelSize: Theme.fontSizeTiny
        wrapMode: Text.Wrap
        horizontalAlignment: Text.AlignHCenter
    }

    IconButton {
        id: iconButton
        icon.source: root.icon + "?" + iconColor
        onClicked: root.clicked()
        onDownChanged: { if (down){ root.downed() } }
        enabled: root.enabled
        //icon.onSourceChanged: console.log(icon.source)
    }
}
