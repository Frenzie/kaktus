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

ListItem {
    id: root

    property string uid
    property string title
    property string author
    property string onlineurl
    property string offlineurl
    property int date
    property int read: 0
    property int readlater: 0
    property string content
    property string contentall
    property string contentraw
    property string image
    property bool friendStream
    property string feedIcon
    property string feedTitle
    property int maxWords: 20
    property int maxChars: 200
    property bool cached: false
    property bool broadcast
    property bool liked
    property bool fresh
    property string annotations
    property bool expanded: false
    property int index
    property bool last: false
    property bool daterow: false
    property bool landscapeMode: false
    property bool showMarkedAsRead: true
    property bool hidden: read>0 && readlater==0
    property bool showIcon: settings.viewMode==1 || settings.viewMode==3 || settings.viewMode==4 || settings.viewMode==5 ? true : false
    property bool defaultIcon: feedIcon === "http://s.theoldreader.com/icons/user_icon.png"
    property color highlightedColor: Theme.rgba(Theme.highlightBackgroundColor, Theme.highlightBackgroundOpacity)
    readonly property alias expandable: box.expandable
    property bool expandedMode: settings.expandedMode

    property int evaluation: 0

    signal markedAsRead
    signal markedAsUnread
    signal markedReadlater
    signal unmarkedReadlater
    signal markedBroadcast
    signal unmarkedBroadcast
    signal markedLike
    signal unmarkedLike
    signal markedAboveAsRead
    signal openInViewer
    signal openInBrowser
    signal showFeedContent
    signal evaluated(int evaluation)
    signal share
    signal pocketAdd

    enabled: !last && !daterow

    contentHeight: last ? app.stdHeight : daterow ? dateRowbox.height : box.height + expander.height

    onMenuOpenChanged: { if(menuOpen) app.hideBar() }

    menu: last ? null : iconContextMenu

    onHiddenChanged: {
        if (hidden && expanded) {
            expanded = false;
        }
    }

    Rectangle {
        id: background
        anchors.fill: parent
        gradient: Gradient {
            GradientStop { position: 0.0; color: Theme.rgba(Theme.highlightColor, 0.0) }
            GradientStop { position: 1.0; color: Theme.rgba(Theme.highlightColor, 0.3) }
        }
        visible: root.readlater
    }

    Rectangle {
        anchors.fill: parent
        visible: opacity > 0.0
        opacity: (landscapeMode || expandable) && expanded && !last && !daterow ? 1.0 : 0.0
        Behavior on opacity { FadeAnimation {} }
        color: Theme.highlightDimmerColor
    }

    Rectangle {
        anchors.top: parent.top; anchors.right: parent.right
        width: Theme.paddingSmall; height: titleLabel.height
        visible: root.fresh && !last && !daterow && !(landscapeMode && expanded)

        gradient: Gradient {
            GradientStop { position: 0.0; color: Theme.rgba(Theme.highlightColor, 0.4) }
            GradientStop { position: 1.0; color: Theme.rgba(Theme.highlightColor, 0.0) }
        }
    }

    /*Item {
        id: likeButton
        anchors.right: star.left; anchors.top: background.top
        height: Theme.iconSizeSmall+2*Theme.paddingMedium
        width: Theme.iconSizeSmall
        visible: !last && !daterow && root.liked

        Image {
            anchors.centerIn: parent;
            width: Theme.iconSizeSmall
            height: Theme.iconSizeSmall
            source: root.down ? "image://icons/like?"+Theme.highlightColor :
                    root.hidden ? "image://icons/like?"+Theme.secondaryColor :
                                  "image://icons/like?"+Theme.primaryColor
        }
    }*/

    /*BackgroundItem {
        id: star
        anchors.right: parent.right; anchors.top: parent.top
        height: Theme.iconSizeSmall + 2*Theme.paddingMedium
        width: Theme.iconSizeSmall + 2*Theme.paddingMedium
        visible: !last && !daterow

        onClicked: {
            if (root.readlater) {
                root.unmarkedReadlater();
            } else {
                root.markedReadlater();
            }
        }

        Image {
            anchors.centerIn: parent;
            width: Theme.iconSizeSmall
            height: Theme.iconSizeSmall
            source: {
                if (root.down) {
                    if (root.readlater)
                        return "image://theme/icon-m-favorite-selected?"+Theme.highlightColor;
                    return "image://theme/icon-m-favorite?"+Theme.highlightColor;
                }
                if (root.readlater)
                    return "image://theme/icon-m-favorite-selected?"+Theme.primaryColor;
                return "image://theme/icon-m-favorite?"+Theme.primaryColor;
            }
        }
    }*/

    SmallIconButton {
        id: star
        anchors.right: parent.right; anchors.top: parent.top
        marginV: 2*Theme.paddingMedium
        visible: !last && !daterow

        icon.source: root.readlater ? "image://theme/icon-m-favorite-selected":
                                      "image://theme/icon-m-favorite"
        onClicked: {
            if (root.readlater)
                root.unmarkedReadlater()
            else
                root.markedReadlater()
        }
    }

    Item {
        id: dateRowbox
        visible: daterow
        height: dateRowLabel.height + 2*Theme.paddingMedium
        width: parent.width

        Label {
            id: dateRowLabel
            anchors.right: parent.right; anchors.rightMargin: Theme.paddingMedium
            anchors.verticalCenter: parent.verticalCenter
            font.pixelSize: Theme.fontSizeSmall
            font.family: Theme.fontFamilyHeading
            truncationMode: TruncationMode.Fade
            text: title
            color: Theme.highlightColor
        }
    }

    Item {
        id: box

        property int sizeHidden: Theme.paddingMedium + titleItem.height
        property int sizeNormal: sizeHidden + (contentLabel.visible ? Math.min(Theme.itemSizeLarge,contentLabel.height) : 0) +
                                 (entryImage.enabled ? entryImage.height + contentItem.spacing : 0) +
                                 (contentLabel.visible ? contentItem.spacing : 0)
        property int sizeExpanded: sizeHidden + (contentLabel.visible ? contentLabel.height : 0) +
                                   (entryImage.enabled ? entryImage.height + contentItem.spacing : 0) +
                                   (contentLabel.visible ? contentItem.spacing : 0)
        property bool expandable: root.landscapeMode || root.expandedMode ? false : root.hidden ? sizeHidden<sizeExpanded : sizeNormal<sizeExpanded

        height: root.expanded || root.expandedMode ? sizeExpanded : root.hidden ? sizeHidden : sizeNormal

        clip: true
        anchors.left: parent.left; anchors.right: parent.right;

        Behavior on height {
            NumberAnimation { duration: 200; easing.type: Easing.InOutQuad }
        }

        visible: !last && !daterow

        Column {
            id: contentItem
            spacing: entryImage.enabled ? Theme.paddingMedium : Theme.paddingSmall
            anchors.top: parent.top; anchors.topMargin: Theme.paddingMedium
            anchors.left: parent.left; anchors.right: parent.right

            Item {
                id: titleItem
                anchors.left: parent.left; anchors.right: parent.right
                anchors.rightMargin: star.width
                height: Math.max(titleLabel.height, icon.height+Theme.paddingSmall, icon.height+Theme.paddingSmall)

                // Title

                Label {
                    id: titleLabel
                    anchors {
                        right: parent.right
                        left: icon.visible ? icon.right : parent.left
                        leftMargin: showIcon ? Theme.paddingMedium : Theme.paddingLarge
                    }
                    font.pixelSize: Theme.fontSizeMedium
                    font.family: Theme.fontFamilyHeading
                    font.bold: !root.read || root.readlater
                    truncationMode: TruncationMode.Fade
                    textFormat: Text.StyledText
                    wrapMode: Text.Wrap
                    text: title

                    color: {
                        if (root.read>0 && root.readlater==0) {
                            if (root.down)
                                return Theme.secondaryHighlightColor;
                            return Theme.secondaryColor;
                        }
                        if (root.down)
                            return Theme.highlightColor;
                        return Theme.primaryColor;
                    }
                }

                FeedIcon {
                    id: icon
                    visible: root.showIcon
                    showPlaceholder: !root.defaultIcon
                    showBackground: true
                    source: root.feedIcon
                    text: root.feedTitle
                    anchors {
                        left: parent.left
                        top: titleLabel.top
                        topMargin: Theme.paddingSmall
                    }
                    width: visible ? 1.2*Theme.iconSizeSmall: 0
                    height: width
                }
            }

            CachedImage {
                id: entryImage
                anchors.left: parent.left
                maxWidth: root.width
                minWidth: Theme.iconSizeMedium
                orgSource: root.image
            }

            Label {
                id: contentLabel
                anchors.left: parent.left; anchors.right: parent.right;
                anchors.leftMargin: Theme.paddingLarge; anchors.rightMargin: Theme.paddingLarge
                text: root.content
                wrapMode: Text.Wrap
                textFormat: Text.PlainText
                font.pixelSize: Theme.fontSizeSmall
                visible: root.content!="" && !root.landscapeMode
                color: {
                    if (root.read>0 && root.readlater==0) {
                        if (root.down)
                            return Theme.secondaryHighlightColor;
                        return Theme.secondaryColor;
                    }
                    if (root.down)
                        return Theme.highlightColor;
                    return Theme.primaryColor;
                }
            }
        }
    }

    Item {
        x: box.x
        y: box.y
        OpacityRampEffect {
            sourceItem: box
            enabled: !root.expanded && box.expandable
            direction: OpacityRamp.TopToBottom
            slope: 2.0
            offset: 5 / 7
            width: box.width
            height: box.height
            anchors.fill: null
        }
    }

    BackgroundItem {
        id: expander
        visible: !last && !daterow
        enabled: box.expandable && !root.landscapeMode

        anchors {
            right: parent.right
            left: parent.left
            bottom: parent.bottom
        }

        height: Math.max(expanderIcon.height,expanderLabel.height)+Theme.paddingMedium

        Image {
            id: expanderIcon
            anchors.verticalCenter: expanderLabel.verticalCenter
            anchors.right: parent.right
            anchors.rightMargin: Theme.paddingMedium
            source: "image://theme/icon-lock-more"
            visible: box.expandable && !root.landscapeMode
        }

        Column {
            id: expanderLabel
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left; anchors.right: expanderIcon.left;
            anchors.leftMargin: Theme.paddingLarge
            anchors.rightMargin: Theme.paddingMedium
            spacing: Theme.paddingSmall

            Item {
                // Broadcast
                anchors.left: parent.left; anchors.right: parent.right
                visible: app.isOldReader && settings.showBroadcast && (!root.hidden || root.expanded) && (root.broadcast || root.annotations!="")
                height: Math.max(broadcastImage.height, broadcastLabel.height)

                /*Image {
                    id: likeImage
                    visible: root.liked
                    anchors.left: parent.left; anchors.top: parent.top
                    width: Theme.iconSizeSmall
                    height: Theme.iconSizeSmall
                    source: root.down ? "image://icons/like?"+Theme.secondaryHighlightColor :
                            root.hidden ? "image://icons/like?"+Theme.secondaryColor : "image://icons/like?"+Theme.primaryColor
                }*/

                Image {
                    id: broadcastImage
                    visible: root.broadcast || root.annotations!=""
                    anchors.left: parent.left; anchors.top: parent.top
                    width: Theme.iconSizeSmall
                    height: Theme.iconSizeSmall
                    source: root.broadcast ? root.down ? "image://theme/icon-m-share?"+Theme.secondaryHighlightColor :
                                                         "image://theme/icon-m-share?"+Theme.secondaryColor :
                                             root.down ? "image://theme/icon-m-chat?"+Theme.secondaryHighlightColor :
                                                         "image://theme/icon-m-chat?"+Theme.secondaryColor
                }

                Label {
                    id: broadcastLabel
                    anchors.left: broadcastImage.right; anchors.right: parent.right; anchors.top: parent.top; anchors.leftMargin: Theme.paddingSmall
                    font.pixelSize: Theme.fontSizeExtraSmall
                    color: root.read>0 && root.readlater==0 ? root.down ? Theme.secondaryHighlightColor : Theme.secondaryColor :
                                                              root.down ? Theme.highlightColor : Theme.primaryColor
                    wrapMode: Text.Wrap
                    text: root.annotations
                }
            }


            Label {
                id: authorLabel
                anchors {left: parent.left; right: parent.right}
                font.pixelSize: Theme.fontSizeExtraSmall
                color: root.down ? Theme.secondaryHighlightColor : Theme.secondaryColor
                truncationMode: TruncationMode.Fade
                text: root.author!=""
                      ? utils.getHumanFriendlyTimeString(date)+" • "+root.author
                      : utils.getHumanFriendlyTimeString(date)
            }

           /*Item {
                anchors.left: parent.left; anchors.right: parent.right
                height: evaluationButtons.height

                Label {
                    id: authorLabel
                    anchors {left: parent.left; right: evaluationButtons.left; verticalCenter: parent.verticalCenter}
                    font.pixelSize: Theme.fontSizeExtraSmall
                    color: root.down ? Theme.secondaryHighlightColor : Theme.secondaryColor
                    truncationMode: TruncationMode.Fade
                    text: root.author!=""
                          ? utils.getHumanFriendlyTimeString(date)+" • "+root.author
                          : utils.getHumanFriendlyTimeString(date)
                }

                Row {
                    id: evaluationButtons
                    anchors {right: parent.right; verticalCenter: parent.verticalCenter}

                    SmallIconButton {
                        icon.source: root.evaluation === 1 ?
                                         "image://icons/icon-m-good-selected" :
                                         "image://icons/icon-m-good"
                        onClicked: {
                            if (root.evaluation === 1)
                                root.evaluation = 0
                            else
                                root.evaluation = 1
                            evaluated(root.evaluation)
                        }
                    }

                    SmallIconButton {
                        icon.source: root.evaluation === -1 ?
                                         "image://icons/icon-m-bad-selected" :
                                         "image://icons/icon-m-bad"
                        onClicked: {
                            if (root.evaluation === -1)
                                root.evaluation = 0
                            else
                                root.evaluation = -1
                            evaluated(root.evaluation)
                        }
                    }
                }
            }*/
        }

        onClicked: {
            if (box.expandable) {
                root.expanded = !root.expanded
            }
        }
    }

    Component {
        id: iconContextMenu
        IconContextMenu {
            id: menu

            IconMenuItem {
                text: qsTr("Toggle Read")
                icon.source: root.read ? 'image://icons/icon-m-read-selected' : 'image://icons/icon-m-read'
                visible: enabled
                enabled: root.showMarkedAsRead
                onClicked: {
                    if (root.read) {
                        root.markedAsUnread();
                    } else {
                        root.markedAsRead();
                        root.expanded = false;
                    }
                    menu.hide();
                }

            }

            IconMenuItem {
                text: app.isNetvibes || app.isFeedly ? qsTr("Toggle Save") : qsTr("Toggle Star")
                icon.source: root.readlater ? 'image://theme/icon-m-favorite-selected' : 'image://theme/icon-m-favorite'
                onClicked: {
                    if (root.readlater) {
                        root.unmarkedReadlater();
                    } else {
                        root.markedReadlater();
                    }
                    menu.hide();
                }
            }

            IconMenuItem {
                text: qsTr("Above as read")
                icon.source: 'image://icons/icon-m-readabove'
                visible: enabled
                enabled: root.showMarkedAsRead && root.index > 1
                onClicked: {
                    root.markedAboveAsRead();
                    root.expanded = false;
                    menu.hide();
                }
            }

            IconMenuItem {
                text: qsTr("Viewer")
                icon.source: 'image://icons/icon-m-webview'
                visible: enabled
                //enabled: settings.clickBehavior !== 0
                onClicked: {
                    root.openInViewer();
                    root.expanded = false;
                    menu.hide();
                }
            }

            IconMenuItem {
                text: qsTr("Browser")
                icon.source: 'image://icons/icon-m-browser'
                visible: enabled
                //enabled: settings.clickBehavior !== 1
                onClicked: {
                    root.openInBrowser();
                    root.expanded = false;
                    menu.hide();
                }
            }

            IconMenuItem {
                text: qsTr("Feed content")
                icon.source: 'image://icons/icon-m-rss'
                visible: enabled
                //enabled: settings.clickBehavior !== 2
                onClicked: {
                    root.showFeedContent()
                    root.expanded = false
                    menu.hide()
                }
            }

            IconMenuItem {
                text: qsTr("Add to Pocket")
                visible: settings.pocketEnabled
                enabled: settings.pocketEnabled && dm.online
                icon.source: "image://icons/icon-m-pocket"
                busy: pocket.busy
                onClicked: root.pocketAdd()
            }

            IconMenuItem {
                text: qsTr("Share link")
                icon.source: "image://theme/icon-m-share"
                onClicked: root.share()
            }

            IconMenuItem {
                id: likeItem
                text: qsTr("Toggle Like")
                icon.source: root.liked ? "image://icons/icon-m-like-selected" : "image://icons/icon-m-like"
                enabled: settings.showBroadcast && app.isOldReader
                visible: enabled
                onClicked: {
                    if (root.liked) {
                        root.unmarkedLike()
                    } else {
                        root.markedLike()
                    }
                    menu.hide()
                }
            }

            IconMenuItem {
                text: qsTr("Toggle Share")
                icon.source: root.broadcast ? "image://icons/icon-m-share-selected" : "image://icons/icon-m-share"
                enabled: settings.showBroadcast && app.isOldReader &&
                         !root.friendStream
                visible: enabled
                onClicked: {
                    if (root.broadcast) {
                        root.unmarkedBroadcast()
                    } else {
                        root.markedBroadcast()
                    }
                    menu.hide()
                }
            }
        }
    }
}
