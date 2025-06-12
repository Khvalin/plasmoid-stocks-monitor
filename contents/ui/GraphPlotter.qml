import QtQuick 2.15
import QtQuick.Layouts 1.15
import org.kde.kirigami 2.12 as Kirigami
import org.kde.plasma.components 3.0 as PlasmaComponents
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.extras as PlasmaExtras

Rectangle {
    id: graphPlotter

    // Public properties
    property var dataPoints: []  // Array of numeric values
    property var labels: []      // Optional array of labels for x-axis
    property string title: ""    // Graph title
    property color lineColor: Kirigami.Theme.highlightColor
    property color fillColor: Qt.rgba(lineColor.r, lineColor.g, lineColor.b, 0.2)
    property color gridColor: Qt.rgba(Kirigami.Theme.textColor.r, Kirigami.Theme.textColor.g, Kirigami.Theme.textColor.b, 0.05)
    property color backgroundColor: "transparent"
    property color textColor: Kirigami.Theme.textColor
    property int lineWidth: 1
    property bool showGrid: false
    property bool showFill: true
    property bool showPoints: false
    property bool showLabels: false
    property bool showValues: false
    property real marginTop: 2
    property real marginBottom: 2
    property real marginLeft: 2
    property real marginRight: 2
    property int maxGridLines: 3

    // Private properties
    property real minValue: 0
    property real maxValue: 100
    property real valueRange: maxValue - minValue
    property real plotWidth: width - marginLeft - marginRight
    property real plotHeight: height - marginTop - marginBottom

    color: backgroundColor

    onDataPointsChanged: calculateBounds()

    Component.onCompleted: calculateBounds()

    function calculateBounds() {
        if (dataPoints.length === 0) {
            minValue = 0;
            maxValue = 100;
            valueRange = 100;
            return;
        }

        minValue = Math.min(...dataPoints);
        maxValue = Math.max(...dataPoints);

        // Minimal padding for very compact display
        var padding = (maxValue - minValue) * 0.02;
        if (padding === 0)
            padding = Math.abs(maxValue) * 0.02 || 0.1;

        minValue -= padding;
        maxValue += padding;
        valueRange = maxValue - minValue;
    }

    function mapX(index) {
        if (dataPoints.length <= 1)
            return marginLeft;
        return marginLeft + (index / (dataPoints.length - 1)) * plotWidth;
    }

    function mapY(value) {
        if (valueRange === 0)
            return marginTop + plotHeight / 2;
        return marginTop + plotHeight - ((value - minValue) / valueRange) * plotHeight;
    }

    function formatValue(value) {
        if (Math.abs(value) >= 1000000) {
            return (value / 1000000).toFixed(1) + "M";
        } else if (Math.abs(value) >= 1000) {
            return (value / 1000).toFixed(1) + "K";
        } else {
            return value.toFixed(1);
        }
    }

    // Compact title (only show if explicitly requested)
    PlasmaComponents.Label {
        id: titleLabel
        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter
        text: title
        font.bold: false
        font.pointSize: Kirigami.Theme.smallFont.pointSize
        color: textColor
        visible: title !== "" && height > 40
    }

    // Minimal grid lines
    Canvas {
        id: gridCanvas
        anchors.fill: parent
        visible: showGrid

        onPaint: {
            var ctx = getContext("2d");
            ctx.clearRect(0, 0, width, height);

            if (!showGrid || dataPoints.length === 0)
                return;

            ctx.strokeStyle = gridColor;
            ctx.lineWidth = 0.5;
            ctx.setLineDash([1, 1]);

            // Only horizontal grid lines for compact view
            var gridLineCount = Math.min(maxGridLines, 3);
            for (var i = 1; i < gridLineCount; i++) {
                var y = marginTop + (i / gridLineCount) * plotHeight;
                ctx.beginPath();
                ctx.moveTo(marginLeft, y);
                ctx.lineTo(marginLeft + plotWidth, y);
                ctx.stroke();
            }
        }
    }

    // Compact Y-axis labels (only show if space allows)
    Repeater {
        model: showLabels && width > 60 ? Math.min(maxGridLines, 3) : 0
        delegate: PlasmaComponents.Label {
            property real value: maxValue - (index / (parent.model - 1)) * valueRange
            x: 0
            y: marginTop + (index / (parent.model - 1)) * plotHeight - height / 2
            text: formatValue(value)
            font.pointSize: Kirigami.Theme.smallFont.pointSize - 1
            color: textColor
            horizontalAlignment: Text.AlignLeft
            width: 20
        }
    }

    // Graph area
    Canvas {
        id: graphCanvas
        anchors.fill: parent

        onPaint: {
            var ctx = getContext("2d");
            ctx.clearRect(0, 0, width, height);

            if (dataPoints.length === 0)
                return;

            // Draw filled area
            if (showFill) {
                ctx.fillStyle = fillColor;
                ctx.beginPath();
                ctx.moveTo(mapX(0), marginTop + plotHeight);

                for (var i = 0; i < dataPoints.length; i++) {
                    ctx.lineTo(mapX(i), mapY(dataPoints[i]));
                }

                ctx.lineTo(mapX(dataPoints.length - 1), marginTop + plotHeight);
                ctx.closePath();
                ctx.fill();
            }

            // Draw line
            ctx.strokeStyle = lineColor;
            ctx.lineWidth = lineWidth;
            ctx.setLineDash([]);
            ctx.beginPath();

            for (var j = 0; j < dataPoints.length; j++) {
                if (j === 0) {
                    ctx.moveTo(mapX(j), mapY(dataPoints[j]));
                } else {
                    ctx.lineTo(mapX(j), mapY(dataPoints[j]));
                }
            }

            ctx.stroke();
        }

        onWidthChanged: requestPaint()
        onHeightChanged: requestPaint()
    }

    // Compact data points (only show if space allows)
    Repeater {
        model: showPoints && width > 30 && height > 30 ? dataPoints.length : 0
        delegate: Rectangle {
            width: 3
            height: 3
            radius: 1.5
            color: lineColor
            border.width: 0
            x: mapX(index) - width / 2
            y: mapY(dataPoints[index]) - height / 2

            // Simplified tooltip
            MouseArea {
                anchors.fill: parent
                anchors.margins: -2
                hoverEnabled: true

                PlasmaComponents.ToolTip {
                    visible: parent.containsMouse
                    text: formatValue(dataPoints[index])
                }
            }
        }
    }

    // Redraw when data changes
    Connections {
        target: graphPlotter
        function onDataPointsChanged() {
            gridCanvas.requestPaint();
            graphCanvas.requestPaint();
        }
        function onLineColorChanged() {
            graphCanvas.requestPaint();
        }
        function onShowGridChanged() {
            gridCanvas.requestPaint();
        }
        function onShowFillChanged() {
            graphCanvas.requestPaint();
        }
    }
}
