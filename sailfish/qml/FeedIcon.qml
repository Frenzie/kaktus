/*
  Copyright (C) 2017 Michal Kosciesza <michal@mkiol.net>

  This file is part of Kaktus.

  Kaktus is free software: you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published by
  the Free Software Foundation, either version 3 of the License, or
  (at your option) any later version.

  Kaktus is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU General Public License for more details.

  You should have received a copy of the GNU General Public License
  along with Kaktus.  If not, see <http://www.gnu.org/licenses/>.
*/

import QtQuick 2.0

Item {
    id: root

    property bool showPlaceholder: false
    property bool showBackground: false
    property alias backgroundColor: background.color
    property alias text: placeholder.text
    property alias source: icon.orgSource

    Rectangle {
        // icon background
        id: background
        enabled: root.showBackground && !placeholder.visible && icon.enabled
        anchors.fill: parent
        color: "white"
        visible: opacity > 0 && enabled
        opacity: enabled ? 1.0 : 0.0
        Behavior on opacity {
            NumberAnimation { duration: 200 }
        }
    }

    CachedImage {
        // feed icon
        id: icon
        anchors.fill: parent
    }

    IconPlaceholder {
        // placeholder
        id: placeholder
        visible: root.showPlaceholder && !icon.enabled
        anchors.fill: parent
    }
}
