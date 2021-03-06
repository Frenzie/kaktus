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
import Sailfish.Silica 1.0

Image {
    id: root

    property int maxWidth: 0
    property int minWidth: 0
    property string orgSource: ""
    property bool cached: true

    fillMode: Image.PreserveAspectFit
    width: sourceSize.width >= maxWidth ? maxWidth : sourceSize.width
    enabled: status === Image.Ready &&
             (minWidth === 0 || (sourceSize.width > minWidth && sourceSize.height > minWidth))
    visible: opacity > 0 && enabled
    opacity: enabled ? 1.0 : 0.0
    Behavior on opacity {
        NumberAnimation { duration: 200 }
    }

    onOrgSourceChanged: {
        if (orgSource !== "") {
            if (cached) {
                var cachedUrl = app._cache.getUrlbyUrl(orgSource)
                if (cachedUrl === "") {
                    if (!settings.offlineMode && dm.online) {
                        cached = false
                        source = orgSource
                    }
                } else {
                    source = cachedUrl
                }
            } else {
                source = orgSource
            }
        } else {
            source = ""
        }
    }

    onStatusChanged: {
        if (cached && orgSource !== "" && status===Image.Error &&
                !settings.offlineMode && dm.online) {
            cached = false
            source = orgSource
        }
    }
}
