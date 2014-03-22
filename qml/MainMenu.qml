/*
  Copyright (C) 2014 Michal Kosciesza <michal@mkiol.net>

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
import Sailfish.Silica 1.0



PullDownMenu {

    MenuItem {
        text: qsTr("About")

        onClicked: {
            pageStack.push(Qt.resolvedUrl("AboutPage.qml"));
        }
    }

    MenuItem {
        text: qsTr("Settings")

        onClicked: {
            pageStack.push(Qt.resolvedUrl("SettingsPage.qml"));
        }
    }

    MenuItem {
        text: qsTr("Sync")

        onClicked: {
            dm.cancel();
            fetcher.cancel();
            fetcher.update();
        }
    }

    /*MenuItem {
        text: qsTr("Test")
        onClicked: notification.show("Abcd")
    }*/

    MenuLabel {
        function update() {
            var lastSync = settings.getNetvibesLastUpdateDate();
            if (lastSync>0)
                text = qsTr("Last sync: %1").arg(app.getHumanFriendlyTimeString(lastSync));
            else
                text = qsTr("Not yet synced");
        }

        Component.onCompleted: {
            update();
        }

        Connections {
            target: fetcher
            onReady: update()
        }

        Timer {
            id: timer
            running: true
            interval: 20000
            repeat: true
            onTriggered: {
                parent.update();
            }
        }

    }

}
