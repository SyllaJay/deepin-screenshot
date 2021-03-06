/**
 * Copyright (C) 2015 Deepin Technology Co., Ltd.
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 3 of the License, or
 * (at your option) any later version.
 **/
import QtQuick 2.1
import "calculateRect.js" as CalcEngine
import "drawing_utils.js" as DrawingUtils

Item {
    property bool selected: false
    property bool reSized: false
    property bool rotated: false
    property bool firstDraw: false
    property bool isHovered: false

    property point clickedPoint
    property var points: []
    property var mainPoints: [Qt.point(0, 0), Qt.point(0, 0), Qt.point(0, 0), Qt.point(0,0)]
    property var minorPoints: [Qt.point(0, 0), Qt.point(0, 0), Qt.point(0, 0), Qt.point(0,0)]
    property int numberOrder
    property string shape: "ellipse"
    property int bigPointRadius: 2
    property int smallPointRadius: 1
    property var minPadding: 10
    property int clickedKey: 0
    property int linewidth: 3
    property int drawColor: 2

    property bool processBlur: false
    property bool processMosaic: false
    property bool isShiftPressed: false

    onDrawColorChanged: windowView.set_save_config("ellipse", "color_index", drawColor)
    onLinewidthChanged: windowView.set_save_config("ellipse", "linewidth_index", linewidth)
    function _initMainPoints() {
        var startPoint = points[0]
        var endPoint = points[points.length - 1]
        mainPoints = DrawingUtils.shiftMainPoints(startPoint, endPoint, isShiftPressed)
        CalcEngine.changePointsOrder(mainPoints[0], mainPoints[1], mainPoints[2], mainPoints[3])
    }

    function deselect() {
        selected = false
        rotated = false
        reSized = false
    }
    function _minPadding() {
        switch (linewidth) {
            case 2: { minPadding = 7;}
            case 4: { minPadding = 11;}
            case 6: { minPadding = 15;}
        }
    }
    function _draw(ctx) {
        if (!firstDraw) { _initMainPoints() }
        minorPoints = CalcEngine.getAnotherFourPoint(mainPoints[0], mainPoints[1], mainPoints[2], mainPoints[3])
        var points1 = CalcEngine.getEightControlPoint(mainPoints[0], mainPoints[1], mainPoints[2], mainPoints[3])

        ctx.lineWidth = linewidth
        ctx.strokeStyle = ((processBlur||processMosaic)&& !(selected || reSized || rotated)) ? "transparent": screen.colorCard(drawColor)
        ctx.fillStyle = "transparent"
        ctx.beginPath()
        if (DrawingUtils.isPointsSameX(mainPoints)) {
            ctx.moveTo(mainPoints[0].x, mainPoints[0].y)
            DrawingUtils.draw_line((selected || reSized || rotated), ctx, mainPoints[1].x, mainPoints[1].y)
        } else if (DrawingUtils.isPointsSameY(mainPoints)) {
            DrawingUtils.draw_line((selected || reSized || rotated), ctx, mainPoints[2].x, mainPoints[2].y)
        } else {
            ctx.moveTo(minorPoints[0].x, minorPoints[0].y);
            ctx.bezierCurveTo(points1[0].x, points1[0].y, points1[1].x, points1[1].y, minorPoints[1].x, minorPoints[1].y);
            ctx.bezierCurveTo(points1[4].x, points1[4].y, points1[5].x, points1[5].y , minorPoints[2].x, minorPoints[2].y );
            ctx.bezierCurveTo(points1[6].x, points1[6].y, points1[7].x, points1[7].y, minorPoints[3].x, minorPoints[3].y);
            ctx.bezierCurveTo(points1[3].x, points1[3].y, points1[2].x, points1[2].y, minorPoints[0].x, minorPoints[0].y);
            ctx.shadowBlur = (selected || reSized || rotated) ? 2 : 0
            ctx.shadowColor = (selected || reSized || rotated) ? Qt.rgba(0, 0, 0, 0.2) : "transparent"
        }
        ctx.closePath()
        ctx.stroke()

        if (processBlur||processMosaic) {
            ctx.save()
            ctx.clip()
            if (processBlur) {
                ctx.drawImage(parent.blurImageData, 0, 0, parent.width, parent.height)
            } else {
                ctx.drawImage(parent.mosaicImageData, 0, 0, parent.width, parent.height)
            }
            ctx.restore()
        }
        if (isHovered) {
            ctx.lineWidth = 1
            ctx.strokeStyle = "#01bdff"
            ctx.stroke()
        }
        if (selected||reSized||rotated) {
            ctx.lineWidth = 1
            ctx.strokeStyle = Qt.rgba(1, 1, 1, 0.6)
            ctx.beginPath()
            ctx.moveTo(mainPoints[0].x, mainPoints[0].y)
            DrawingUtils.draw_line((selected || reSized || rotated), ctx, mainPoints[2].x, mainPoints[2].y)
            DrawingUtils.draw_line((selected || reSized || rotated), ctx, mainPoints[3].x, mainPoints[3].y)
            DrawingUtils.draw_line((selected || reSized || rotated), ctx, mainPoints[1].x, mainPoints[1].y)
            DrawingUtils.draw_line((selected || reSized || rotated), ctx, mainPoints[0].x, mainPoints[0].y)
            ctx.closePath()
            ctx.stroke()

            /* Rotate point */
            var rotatePoint = CalcEngine.getRotatePoint(mainPoints[0], mainPoints[1], mainPoints[2], mainPoints[3])
            ctx.lineWidth = 1
            ctx.strokeStyle = Qt.rgba(1, 1, 1, 0.6)
            var middlePoint = Qt.point((mainPoints[0].x + mainPoints[2].x) / 2,(mainPoints[0].y + mainPoints[2].y) / 2)
            ctx.moveTo(rotatePoint.x, rotatePoint.y)
            DrawingUtils.draw_line((selected || reSized || rotated), ctx, middlePoint.x, middlePoint.y)
            ctx.stroke()
            ctx.drawImage(canvas.rotateImage, rotatePoint.x - 12, rotatePoint.y - 12)

            ctx.lineWidth = 1
            ctx.strokeStyle = "white"
            ctx.fillStyle = "white"
            /* Top left */
            DrawingUtils.draw_point(ctx, mainPoints[0].x, mainPoints[0].y,bigPointRadius + linewidth / 2)

            /* Top right */
            DrawingUtils.draw_point(ctx, mainPoints[3].x, mainPoints[3].y, bigPointRadius + linewidth / 2)

            /* Bottom left */
            DrawingUtils.draw_point(ctx, mainPoints[1].x, mainPoints[1].y, bigPointRadius + linewidth / 2)

            /* Bottom right */
            DrawingUtils.draw_point(ctx, mainPoints[2].x, mainPoints[2].y, bigPointRadius + linewidth / 2)

            minorPoints = CalcEngine.getAnotherFourPoint(mainPoints[0], mainPoints[1], mainPoints[2], mainPoints[3])
            /* Top */
            DrawingUtils.draw_point(ctx, minorPoints[0].x, minorPoints[0].y, linewidth / 2)

            /* Bottom */
            DrawingUtils.draw_point(ctx, minorPoints[1].x, minorPoints[1].y, linewidth / 2)

            /* Left */
            DrawingUtils.draw_point(ctx, minorPoints[2].x, minorPoints[2].y, linewidth / 2)

            /* Right */
            DrawingUtils.draw_point(ctx, minorPoints[3].x, minorPoints[3].y, linewidth / 2)

        }
    }
    function draw(ctx) {
        var startPoint = points[0]
        var endPoint = points[points.length - 1]
        _minPadding()
        if (points.length < 2) {
            return
        } else if (points.length == 2 && CalcEngine.getDistance(startPoint, endPoint) < 5) {
            return
        } else if (!CalcEngine.startDraw(startPoint, endPoint, minPadding)){
            if (startPoint.x < endPoint.x) {
                if (startPoint.y < endPoint.y) {
                    endPoint = Qt.point(startPoint.x + minPadding, startPoint.y + minPadding)
                } else {
                    endPoint = Qt.point(startPoint.x + minPadding, startPoint.y - minPadding)
                }
            } else {
                if (startPoint.y < endPoint.y) {
                    endPoint = Qt.point(startPoint.x - minPadding, startPoint.y + minPadding)
                } else {
                    endPoint = Qt.point(startPoint.x - minPadding, startPoint.y - minPadding)
                }
            }
            points[points.length -1] = endPoint
            _draw(ctx)
        } else {
            _draw(ctx)
        }
    }
    function clickOnPoint(p) {
        selected = false
        reSized = false
        rotated = false
        clickedPoint = Qt.point(0, 0)
        if (CalcEngine.pointClickIn(mainPoints[0], p)) {
            reSized = true
            clickedKey = 1
            canvas.cursorDirection = "TopLeft"
            clickedPoint = p
            return true
        }
        if (CalcEngine.pointClickIn(mainPoints[1], p)) {
            reSized = true
            clickedKey = 2
            canvas.cursorDirection = "BottomLeft"
            clickedPoint = p
            return true
        }
        if (CalcEngine.pointClickIn(mainPoints[2], p)) {
            reSized = true
            clickedKey = 3
            canvas.cursorDirection = "TopRight"
            clickedPoint = p
            return true
        }
        if (CalcEngine.pointClickIn(mainPoints[3], p)) {
            reSized = true
            clickedKey = 4
            canvas.cursorDirection = "BottomRight"
            clickedPoint = p
            return true
        }
        if (CalcEngine.pointClickIn(minorPoints[0], p)) {
            reSized = true
            clickedKey = 5
            canvas.cursorDirection = "Left"
            clickedPoint = p
            return true
        }
        if (CalcEngine.pointClickIn(minorPoints[1], p)) {
            reSized = true
            clickedKey = 6
            canvas.cursorDirection = "Top"
            clickedPoint = p
            return true
        }
        if (CalcEngine.pointClickIn(minorPoints[2], p)) {
            reSized = true
            clickedKey = 7
            canvas.cursorDirection = "Right"
            clickedPoint = p
            return true
        }
        if (CalcEngine.pointClickIn(minorPoints[3], p)) {
            reSized = true
            clickedKey = 8
            canvas.cursorDirection = "Bottom"
            clickedPoint = p
            return true
        }
        if (rotateOnPoint(p)) {
            rotated = true
            clickedPoint = p
            return true
        }
        if (!(processBlur||processMosaic)) {
            if (CalcEngine.pointOnEllipse(mainPoints[0], mainPoints[1], mainPoints[2], mainPoints[3], p)) {
                selected = true

                clickedPoint = p
                return true
            }
        } else {
            if (CalcEngine.pointInEllipse(mainPoints[0], mainPoints[1], mainPoints[2], mainPoints[3], p)) {
                selected = true

                clickedPoint = p
                return true
            }
        }
        return false
    }

    function handleDrag(p) {
        var delX = p.x - clickedPoint.x
        var delY = p.y - clickedPoint.y
        for (var i = 0; i < mainPoints.length; i++) {
            mainPoints[i] = Qt.point(mainPoints[i].x + delX, mainPoints[i].y + delY)
        }

        clickedPoint = p
    }
    function handleResize(p, key) {

        if (reSized) {
            var points = CalcEngine.reSizePointPosition(mainPoints[0], mainPoints[1], mainPoints[2], mainPoints[3], p, key, minPadding, isShiftPressed)
            for (var i = 0; i < 4; i ++) { mainPoints[i] = points[i] }
        }
        clickedPoint = p

    }
    function rotateOnPoint(p) {
        return hoverOnRotatePoint(p)
    }

    function handleRotate(p) {
        var centerInPoint = Qt.point((mainPoints[0].x + mainPoints[3].x) / 2, (mainPoints[0].y + mainPoints[3].y) / 2)
        var rotatePoint = CalcEngine.getRotatePoint(mainPoints[0], mainPoints[1], mainPoints[2], mainPoints[3])
        var angle = CalcEngine.calcutateAngle(clickedPoint, p, centerInPoint)
        for (var i = 0; i < 4; i++) {
            mainPoints[i] = CalcEngine.pointRotate(centerInPoint, mainPoints[i], angle)
        }

        clickedPoint = p
    }
    function hoverOnRotatePoint(p) {
        var rotatePoint = CalcEngine.getRotatePoint(mainPoints[0], mainPoints[1], mainPoints[2], mainPoints[3])
        /* don't know why when hover on the rotatepoint, the cursor is on the lower coordinate*/
        rotatePoint = Qt.point(rotatePoint.x - 5, rotatePoint.y - 5)
        if (p.x >= rotatePoint.x - 12 && p.x <= rotatePoint.x + 12 && p.y >= rotatePoint.y - 12 && p.y <= rotatePoint.y + 12) {
            var result = true
        } else {
            var result = false
        }
        clickedPoint = rotatePoint
        return  result
    }
    function hoverOnShape(p) {
        var result = false
        if (selected || reSized || rotated) {
            if (CalcEngine.pointClickIn(mainPoints[0], p)) {
                result =  true
                clickedKey = 1
                canvas.cursorDirection = "TopLeft"
                clickedPoint = p
                isHovered = result
                return result
            }
            else if (CalcEngine.pointClickIn(mainPoints[1], p)) {
                result =  true
                clickedKey = 2
                canvas.cursorDirection = "BottomLeft"
                clickedPoint = p
                isHovered = result
                return result
            }
            else if (CalcEngine.pointClickIn(mainPoints[2], p)) {
                result =  true
                clickedKey = 3
                canvas.cursorDirection = "TopRight"
                clickedPoint = p
                isHovered = result
                return result
            }
            else if (CalcEngine.pointClickIn(mainPoints[3], p)) {
                result =  true
                clickedKey = 4
                canvas.cursorDirection = "BottomRight"
                clickedPoint = p
                isHovered = result
                return result
            } else {
                if (CalcEngine.pointClickIn(minorPoints[0], p)) {
                    result =  true
                    clickedKey = 5
                    canvas.cursorDirection = "Left"
                    clickedPoint = p
                    isHovered = result
                    return result
                }
                else if (CalcEngine.pointClickIn(minorPoints[1], p)) {
                    result =  true
                    clickedKey = 6
                    canvas.cursorDirection = "Top"
                    clickedPoint = p
                    isHovered = result
                    return result
                }
                else if (CalcEngine.pointClickIn(minorPoints[2], p)) {
                    result =  true
                    clickedKey = 7
                    canvas.cursorDirection = "Right"
                    clickedPoint = p
                    isHovered = result
                    return result
                }
                else if (CalcEngine.pointClickIn(minorPoints[3], p)) {
                    result =  true
                    clickedKey = 8
                    canvas.cursorDirection = "Bottom"
                    clickedPoint = p
                    isHovered = result
                    return result
                }
                else {
                    if (CalcEngine.pointOnEllipse(mainPoints[0], mainPoints[1], mainPoints[2], mainPoints[3], p)) {
                        result = true
                        isHovered = result
                        canvas.cursorDirection = ""
                    }
                }
            }
        } else {
            if (CalcEngine.pointOnEllipse(mainPoints[0], mainPoints[1], mainPoints[2], mainPoints[3], p)) {
                result = true
                isHovered = result
                canvas.cursorDirection = ""
            }
        }
        isHovered = result
        return result
    }
}
