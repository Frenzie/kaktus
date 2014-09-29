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
import QtWebKit 3.0

Page {
    id: root

    property bool showBar: false

    property string title
    property string entryId
    property string offlineUrl
    property string onlineUrl
    property bool stared
    property bool read
    property int index
    property int feedindex
    property bool cached
    property int markAsReadTime: 4000

    ActiveDetector {}

    onForwardNavigationChanged: {
        if (forwardNavigation)
            forwardNavigation = false;
    }

    /*onBackNavigationChanged: {
        if (backNavigation)
            backNavigation = false;
    }*/

    showNavigationIndicator: false

    allowedOrientations: {
        switch (settings.allowedOrientations) {
        case 1:
            return Orientation.Portrait;
        case 2:
            return Orientation.Landscape;
        }
        return Orientation.Landscape | Orientation.Portrait;
    }

    SilicaWebView {
        id: view

        anchors { top: parent.top; left: parent.left; right: parent.right; bottom: parent.bottom }

        /*height: {
            if ((dm.busy||fetcher.busy||controlbar.open) && bar.open)
                return isPortrait ? app.height-Theme.itemSizeMedium : app.width-1.6*Theme.itemSizeMedium;
            if (dm.busy||fetcher.busy||controlbar.open)
                return isPortrait ? app.height-Theme.itemSizeMedium : app.width-0.8*Theme.itemSizeMedium;
            if (bar.open)
                return isPortrait ? app.height-Theme.itemSizeMedium : app.width-0.8*Theme.itemSizeMedium;
            return isPortrait ? app.height : app.width;
        }

        Behavior on height {
            enabled: !root.orientationTransitionRunning
            NumberAnimation { duration: 200; easing.type: Easing.InOutQuad }
        }

        clip: true*/

        url:  {
            if (settings.offlineMode) {
                /*console.log(view.width);
                if (isPortrait)
                    return offlineUrl+"?width=540px";
                return offlineUrl+"?width=960px";*/
                if (settings.offlineMode)
                    return offlineUrl+"?width="+view.width+"px"+"&fontsize=24px";
            }
            return onlineUrl;
        }

        experimental.userAgent: settings.getDmUserAgent()

        onLoadingChanged: {
            if (loadRequest.status == WebView.LoadStartedStatus) {

                proggressPanel.text = qsTr("Loading page content...");
                proggressPanel.open = true;

            } else if (loadRequest.status == WebView.LoadFailedStatus) {

                if (settings.offlineMode)
                    notification.show(qsTr("Failed to load item from local cache :-("));
                else
                    notification.show(qsTr("Failed to load page content :-("));
                proggressPanel.open = false;

            } else {

                proggressPanel.open = false;

                // Start timer to mark as read
                if (!root.read && settings.getAutoMarkAsRead())
                    timer.start();

            }
        }

        /*onNavigationRequested: {
            // In Off-Line mode navigation is disabled
            if (settings.offlineMode) {
                if (request.url != offlineUrl) {
                    request.action = WebView.IgnoreRequest;
                }
            }
        }*/

        onNavigationRequested: {
            if (!Qt.application.active) {
                request.action = WebView.IgnoreRequest;
            }
        }
    }

    ControlBarWebPreview {
        id: controlbar
        flick: view
        canBack: true
        canStar: true
        canOpenBrowser: true
        stared: root.stared
        transparent: false
        //y: view.height

        onBackClicked: pageStack.pop()

        onStarClicked: {
            if (stared) {
                stared=false;
                entryModel.setData(root.index, "readlater", 0);
            } else {
                stared=true;
                entryModel.setData(root.index, "readlater", 1);
            }
        }

        onBrowserClicked: {
            notification.show(qsTr("Launching an external browser..."));
            Qt.openUrlExternally(onlineUrl);
        }

        onOfflineClicked: {
            if (settings.offlineMode) {
                if (dm.online)
                    settings.offlineMode = false;
                else
                    notification.show(qsTr("Cannot switch to Online mode.\nNetwork connection is unavailable."));
            } else {
                if (root.cached)
                    settings.offlineMode = true;
                else
                  notification.show(qsTr("Offline version not available."));
            }
        }
    }

    ProgressPanel {
        id: proggressPanel
        transparent: false
        anchors.left: parent.left
        anchors.bottom: parent.bottom
        height: isPortrait ? app.panelHeightPortrait : app.panelHeightLandscape
        cancelable: true
        onCloseClicked: view.stop()
    }

    Timer {
        id: timer
        interval: root.markAsReadTime
        onTriggered: {
            if (!root.read && settings.getAutoMarkAsRead()) {
                read=true;
                entryModel.setData(root.index, "read", 1);
            }
        }
    }

    Connections {
        target: fetcher
        onBusyChanged: pageStack.pop()
    }

    Connections {
        target: dm
        onBusyChanged: pageStack.pop()
    }

    // Workaround for 'High Power Consumption' webkit bug
    Connections {
        target: Qt.application
        onActiveChanged: {
            if(!Qt.application.active && settings.powerSaveMode) {
                pageStack.pop();
            }
        }
    }
}