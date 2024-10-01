import QtQuick
import QtQuick.Layouts
import org.kde.quickcharts as Charts

import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.plasmoid
import org.kde.plasma.components 3.0 as PlasmaComponents

Item {

    ColumnLayout {
        id: layout
        anchors.fill: parent
        spacing: 6
        Rectangle {
            color: 'teal'
            Layout.fillWidth: true
            Layout.preferredWidth: 100
            //Layout.minimumHeight: 150
            Text {
                anchors.centerIn: parent
                text: parent.width + 'x' + parent.height
            }
        }
        Rectangle {
            color: 'plum'
            Layout.fillWidth: true
            Layout.minimumWidth: 100
            Layout.preferredHeight: 100
            Text {
                anchors.centerIn: parent
                text: parent.width + 'x' + parent.height
            }
        }
    }

}
