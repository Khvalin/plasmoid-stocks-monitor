import QtQuick 2.15
import QtQuick.Controls 2.15 as Controls
import QtQuick.Layouts 1.15
import org.kde.kirigami 2.12 as Kirigami
import org.kde.plasma.components 3.0 as PlasmaComponents
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.plasmoid 2.0

ColumnLayout {
    id: root
    property var cfg_selectedSymbols: []
    property var loaded: false
    spacing: Kirigami.Units.largeSpacing
    
    Kirigami.FormLayout {
        id: configGeneralForm
        Layout.fillWidth: true
        
        Component.onCompleted: {
            for (const text of cfg_selectedSymbols) {
                chips.append({
                    "text": text
                });
            }
            insertTextField.forceActiveFocus();
            root.loaded = true;
        }


        ListModel {
            id: chips

            onCountChanged: {
                if (!root.loaded) {
                    return;
                }

                const res = []
                for( var i = 0; i < chips.count; i++ ) {
                    res.push(chips.get(i).text)
                }

                root.cfg_selectedSymbols = res
            }
        }

        RowLayout {
            Kirigami.FormData.label: "Symbol:"
            spacing: Kirigami.Units.smallSpacing
            
            Controls.TextField {
                id: insertTextField
                Layout.fillWidth: true
                placeholderText: "Enter stock symbol (e.g., AAPL)"

                function onEnterPressed(event) {
                    event.accepted = true // prevent further processing of the event

                    const text = insertTextField.text.trim().toUpperCase();
                    if (text !== "") {
                        chips.append({ "text": text })
                        insertTextField.clear()
                    }
                }

                Keys.onReturnPressed: event => { onEnterPressed(event) }
                Keys.onEnterPressed: event =>  { onEnterPressed(event) }
            }
            
            Controls.Button {
                text: "Add"
                icon.name: "list-add"
                onClicked: {
                    const text = insertTextField.text.trim().toUpperCase();
                    if (text !== "") {
                        chips.append({ "text": text })
                        insertTextField.clear()
                    }
                }
            }
        }

        Item {
            Kirigami.FormData.label: "Selected Symbols:"
            Kirigami.FormData.labelAlignment: Qt.AlignTop
            implicitHeight: chipsContainer.implicitHeight
            implicitWidth: parent.width
            
            Flow {
                id: chipsContainer
                anchors.fill: parent
                spacing: Kirigami.Units.smallSpacing
                
                Repeater {
                    model: chips
                    
                    delegate: Kirigami.Chip {
                        required property int index
                        required property var model
                        
                        text: model.text
                        icon.name: "edit-delete-remove"
                        onClicked: chips.remove(index)
                        display: PlasmaComponents.Button.TextBesideIcon
                        Layout.preferredHeight: Kirigami.Units.gridUnit * 1.5
                    }
                }
            }
        }
        
        PlasmaComponents.Label {
            Layout.fillWidth: true
            text: "Note: Changes will take effect after you click Apply or OK"
            opacity: 0.7
            font.italic: true
        }
    }
    
    Item {
        Layout.fillHeight: true
    }
}
