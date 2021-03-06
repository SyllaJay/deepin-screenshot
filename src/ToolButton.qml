/**
 * Copyright (C) 2015 Deepin Technology Co., Ltd.
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 3 of the License, or
 * (at your option) any later version.
 **/
import QtQuick 2.1

Item {
    id: toolButton
    width: 30
    height: 28
    state: "off"

    property url dirAction: "../image/action/"
    property url dirActionMenu: "../image/action_menu/"
    property url dirSizeImage: "../image/size/"
    property url dirColor_big: "../image/color_big/"
    property url dirShareImage:"../image/share/"
    property url dirSave: "../image/save/"

    property string imageName: ""
    property string dirImage: dirAction
    property alias imageIcon: toolImage
    property alias selectDisArea: selectArea
    property bool switchable: true
    property var group: null

    signal entered()
    signal exited()
    signal clicked()
    states: [
            State {
                    name : "on"
                    PropertyChanges {
                        target:toolImage
                        source: toolButton.dirImage + toolButton.imageName + "_press.svg"
                     }
            },
            State {
                    name : "off"
                    PropertyChanges {
                        target:toolImage
                        source: toolButton.dirImage + toolButton.imageName + ".svg"
                    }
        }
    ]

    onStateChanged: if (group&&state == "on") group.checkState(toolButton)

    Rectangle {
        id: selectArea
        anchors.centerIn: parent
        width: 24
        height: 20
        radius: 4
        visible: false

        color: "white"
        opacity: 0.2
    }
    Image {
        id: toolImage
        width: 24
        height: 24
        anchors.centerIn: parent
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        onEntered: {
            selectArea.visible = true
            if (toolButton.state == "off") {
                toolImage.source = toolButton.dirImage + toolButton.imageName + "_hover.svg"
            }
            toolButton.entered()
        }

        onExited: {
            selectArea.visible = false
            toolButton.exited()
        }

        onClicked:{
            if (switchable) {
                toolButton.state = toolButton.state == "on" ? "off" : "on"
            } else {
                toolButton.state = "on"
            }
            toolButton.clicked()
        }
    }
}
