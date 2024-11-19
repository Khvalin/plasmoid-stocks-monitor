import QtQuick
import QtQuick.Controls 2.2 as Controls
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.plasma.components 3.0 as PlasmaComponents
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.plasmoid

Kirigami.FormLayout {
    //property alias cfg_polygonApiKey: polygonApiKey.text

    id: page

    Component.onCompleted: {
        for (const text of plasmoid.configuration.selectedSymbols) {
            chips.append({
                "text": text
            });
        }
    }

    ListModel {
        id: chips

        onCountChanged: {
            console.log("Symbols changed:", JSON.stringify(chips));
        }
    }

    Controls.TextField {
        id: insertTextField

        Kirigami.FormData.label: "Item:"
        onAccepted: chips.append({
            "text": insertTextField.text
        })
    }
    // Wrapped in ColumnLayout to prevent binding loops.

    GridLayout {
        Layout.alignment: Qt.AlignLeading

        Repeater {
            model: chips

            Kirigami.Chip {
                id: chip

                text: modelData
                onRemoved: chips.remove(index)
            }

        }

    }

}
