import QtQuick 2.15
import org.kde.kirigami 2.12 as Kirigami

Rectangle {
    id: miniGraph

    // Public properties
    property var dataPoints: []
    property color lineColor: Kirigami.Theme.highlightColor
    property color fillColor: Qt.rgba(lineColor.r, lineColor.g, lineColor.b, 0.1)
    property color backgroundColor: "transparent"
    property int lineWidth: 1
    property bool showFill: true

    // Ultra-minimal margins
    property real margin: 1

    // Private properties
    property var processedDataPoints: []
    property real minValue: 0
    property real maxValue: 100
    property real valueRange: maxValue - minValue
    property real plotWidth: width - (margin * 2)
    property real plotHeight: height - (margin * 2)

    color: backgroundColor

    onDataPointsChanged: {
        processDataPoints();
        calculateBounds();
    }

    Component.onCompleted: {
        processDataPoints();
        calculateBounds();
    }

    function processDataPoints() {
        processedDataPoints = [];

        if (!dataPoints) {
            return;
        }

        // Handle QQmlListModel
        if (typeof dataPoints.count !== 'undefined') {
            for (var i = 0; i < dataPoints.count; i++) {
                var item = dataPoints.get(i);
                if (typeof item === 'number') {
                    processedDataPoints.push(item);
                } else if (item && typeof item.value === 'number') {
                    processedDataPoints.push(item.value);
                } else if (item && typeof item.modelData === 'number') {
                    processedDataPoints.push(item.modelData);
                } else if (item && Object.keys(item).length === 1) {
                    // Sometimes the item is an object with a single numeric property
                    var key = Object.keys(item)[0];
                    if (typeof item[key] === 'number') {
                        processedDataPoints.push(item[key]);
                    }
                }
            }
        } else
        // Handle regular JavaScript array
        if (Array.isArray(dataPoints)) {
            processedDataPoints = dataPoints.slice(); // Create a copy
        } else
        // Handle single values or other formats
        if (typeof dataPoints === 'number') {
            processedDataPoints = [dataPoints];
        }
    }

    function calculateBounds() {
        if (!processedDataPoints.length) {
            minValue = 0;
            maxValue = 100;
            valueRange = 100;
            return;
        }

        minValue = Math.min(...processedDataPoints);
        maxValue = Math.max(...processedDataPoints);

        // Minimal padding for ultra-compact display
        var padding = (maxValue - minValue) * 0.05;
        if (padding === 0)
            padding = Math.abs(maxValue) * 0.05 || 0.1;

        minValue -= padding;
        maxValue += padding;
        valueRange = maxValue - minValue;
    }

    function mapX(index) {
        if (processedDataPoints.length <= 1)
            return margin;
        return margin + (index / (processedDataPoints.length - 1)) * plotWidth;
    }

    function mapY(value) {
        if (valueRange === 0)
            return margin + plotHeight / 2;
        return margin + plotHeight - ((value - minValue) / valueRange) * plotHeight;
    }

    // Ultra-compact graph canvas
    Canvas {
        id: miniCanvas
        anchors.fill: parent

        onPaint: {
            var ctx = getContext("2d");
            ctx.clearRect(0, 0, width, height);

            if (!processedDataPoints.length)
                return;

            // Draw filled area if requested
            if (showFill && processedDataPoints.length > 1) {
                ctx.fillStyle = fillColor;
                ctx.beginPath();
                ctx.moveTo(mapX(0), margin + plotHeight);

                for (var i = 0; i < processedDataPoints.length; i++) {
                    ctx.lineTo(mapX(i), mapY(processedDataPoints[i]));
                }

                ctx.lineTo(mapX(processedDataPoints.length - 1), margin + plotHeight);
                ctx.closePath();
                ctx.fill();
            }

            // Draw line
            if (processedDataPoints.length > 1) {
                ctx.strokeStyle = lineColor;
                ctx.lineWidth = lineWidth;
                ctx.beginPath();

                for (var j = 0; j < processedDataPoints.length; j++) {
                    if (j === 0) {
                        ctx.moveTo(mapX(j), mapY(processedDataPoints[j]));
                    } else {
                        ctx.lineTo(mapX(j), mapY(processedDataPoints[j]));
                    }
                }

                ctx.stroke();
            } else if (processedDataPoints.length === 1) {
                // Single point - draw a small circle
                ctx.fillStyle = lineColor;
                ctx.beginPath();
                ctx.arc(width / 2, mapY(processedDataPoints[0]), 1, 0, 2 * Math.PI);
                ctx.fill();
            }
        }

        onWidthChanged: requestPaint()
        onHeightChanged: requestPaint()
    }

    // Redraw when data changes
    Connections {
        target: miniGraph
        function onDataPointsChanged() {
            miniCanvas.requestPaint();
        }
        function onLineColorChanged() {
            miniCanvas.requestPaint();
        }
        function onShowFillChanged() {
            miniCanvas.requestPaint();
        }
        function onProcessedDataPointsChanged() {
            miniCanvas.requestPaint();
        }
    }
}
