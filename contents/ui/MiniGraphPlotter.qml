import QtQuick
import org.kde.kirigami as Kirigami

Rectangle {
    id: miniGraph

    // Public properties
    property var dataPoints: null  // Expects array or ListModel of objects with 'value' property
    property color lineColor: Kirigami.Theme.highlightColor
    property color fillColor: Qt.rgba(lineColor.r, lineColor.g, lineColor.b, 0.1)
    property color backgroundColor: "transparent"
    property int lineWidth: 1
    property bool showFill: true

    // Ultra-minimal margins
    property real margin: 1

    // Private properties
    property var values: []
    property real minValue: 0
    property real maxValue: 100
    property real valueRange: maxValue - minValue
    property real plotWidth: width - (margin * 2)
    property real plotHeight: height - (margin * 2)

    color: backgroundColor

    // Update triggers
    onDataPointsChanged: updateData()
    onWidthChanged: requestDeferredPaint()
    onHeightChanged: requestDeferredPaint()
    onVisibleChanged: if (visible) requestDeferredPaint()
    onShowFillChanged: requestDeferredPaint()
    onLineColorChanged: requestDeferredPaint()

    Component.onCompleted: updateData()

    Timer {
        id: paintTimer
        interval: 16
        repeat: false
        onTriggered: miniCanvas.requestPaint()
    }

    function requestDeferredPaint() {
        paintTimer.restart()
    }

    function updateData() {
        extractValues()
        calculateBounds()
        requestDeferredPaint()
    }

    function extractValues() {
        values = []

        if (!dataPoints) {
            return
        }

        try {
            // Handle ListModel
            if (dataPoints.count !== undefined) {
                for (var i = 0; i < dataPoints.count; i++) {
                    var item = dataPoints.get(i)
                    if (item && item.value !== undefined) {
                        var val = Number(item.value)
                        if (!isNaN(val)) {
                            values.push(val)
                        }
                    }
                }
            }
            // Handle plain array
            else if (Array.isArray(dataPoints)) {
                for (var j = 0; j < dataPoints.length; j++) {
                    if (typeof dataPoints[j] === 'number') {
                        values.push(dataPoints[j])
                    } else if (dataPoints[j] && dataPoints[j].value !== undefined) {
                        var val2 = Number(dataPoints[j].value)
                        if (!isNaN(val2)) {
                            values.push(val2)
                        }
                    }
                }
            }
        } catch (e) {
            console.error("MiniGraphPlotter: Error processing dataPoints:", e)
        }
    }

    function calculateBounds() {
        if (values.length === 0) {
            minValue = 0
            maxValue = 100
            valueRange = 100
            return
        }

        minValue = values[0]
        maxValue = values[0]

        for (var i = 1; i < values.length; i++) {
            if (values[i] < minValue) minValue = values[i]
            if (values[i] > maxValue) maxValue = values[i]
        }

        // Add padding
        var padding = (maxValue - minValue) * 0.05
        if (padding === 0 || isNaN(padding)) {
            padding = Math.abs(maxValue) * 0.05 || 0.1
        }

        minValue -= padding
        maxValue += padding
        valueRange = maxValue - minValue
    }

    function mapX(index) {
        if (values.length <= 1) return margin
        return margin + (index / (values.length - 1)) * plotWidth
    }

    function mapY(value) {
        if (valueRange === 0) return margin + plotHeight / 2
        return margin + plotHeight - ((value - minValue) / valueRange) * plotHeight
    }

    function drawGraph() {
        var ctx = miniCanvas.getContext("2d")
        if (!ctx) return

        ctx.clearRect(0, 0, miniCanvas.width, miniCanvas.height)

        if (values.length === 0) return

        try {
            // Draw filled area
            if (showFill && values.length > 1) {
                ctx.fillStyle = fillColor
                ctx.beginPath()
                ctx.moveTo(mapX(0), margin + plotHeight)

                for (var i = 0; i < values.length; i++) {
                    ctx.lineTo(mapX(i), mapY(values[i]))
                }

                ctx.lineTo(mapX(values.length - 1), margin + plotHeight)
                ctx.closePath()
                ctx.fill()
            }

            if (values.length === 1) {
                // Single point - draw a circle
                ctx.fillStyle = lineColor
                ctx.beginPath()
                ctx.arc(miniCanvas.width / 2, mapY(values[0]), 1.5, 0, 2 * Math.PI)
                ctx.fill()
            }

            // Draw line
            if (values.length > 1) {
                ctx.strokeStyle = lineColor
                ctx.lineWidth = lineWidth
                ctx.beginPath()

                ctx.moveTo(mapX(0), mapY(values[0]))
                for (var j = 1; j < values.length; j++) {
                    ctx.lineTo(mapX(j), mapY(values[j]))
                }

                ctx.stroke()
            }
        } catch (e) {
            console.error("MiniGraphPlotter: Error during drawing:", e)
        }
    }

    Canvas {
        id: miniCanvas
        anchors.fill: parent

        // These settings help Qt6 render more reliably
        renderTarget: Canvas.FramebufferObject
        renderStrategy: Canvas.Cooperative

        onPaint: drawGraph()
    }
}
