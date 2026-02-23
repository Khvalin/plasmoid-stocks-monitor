import QtQuick 2.15
import QtQuick.Controls 2.15 as Controls
import QtQuick.Layouts 1.15
import org.kde.kirigami 2 as Kirigami
import org.kde.plasma.components 3.0 as PlasmaComponents
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.plasmoid 2.0

ColumnLayout {
    id: root
    property var cfg_selectedSymbols: []
    property var loaded: false
    spacing: Kirigami.Units.largeSpacing

    signal configurationChanged

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

            function updateSelectedSymbols() {
                if (!root.loaded) {
                    return;
                }

                const res = [];
                for (var i = 0; i < chips.count; i++) {
                    res.push(chips.get(i).text);
                }

                root.cfg_selectedSymbols = res;
            }

            onCountChanged: {
                updateSelectedSymbols();
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
                    event.accepted = true; // prevent further processing of the event

                    const text = insertTextField.text.trim().toUpperCase();
                    if (text !== "") {
                        chips.append({
                            "text": text
                        });
                        insertTextField.clear();
                    }
                }

                Keys.onReturnPressed: event => {
                    onEnterPressed(event);
                }
                Keys.onEnterPressed: event => {
                    onEnterPressed(event);
                }
            }

            Controls.Button {
                text: "Add"
                icon.name: "list-add"
                onClicked: {
                    const text = insertTextField.text.trim().toUpperCase();
                    if (text !== "") {
                        chips.append({
                            "text": text
                        });
                        insertTextField.clear();
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

                    delegate: Item {
                        required property int index
                        required property var model

                        width: chip.width
                        height: chip.height

                        DropArea {
                            anchors.fill: parent

                            onEntered: function (drag) {
                                if (drag.source.chipIndex !== parent.index) {
                                    // Move the dragged item to this position
                                    chips.move(drag.source.chipIndex, parent.index, 1);
                                    // Update the drag source index
                                    drag.source.chipIndex = parent.index;
                                    // Emit signal to make Apply button active
                                    root.configurationChanged();
                                }
                            }
                        }

                        Kirigami.Chip {
                            id: chip
                            text: parent.model.text
                            icon.name: "edit-delete-remove"
                            onClicked: chips.remove(parent.index)
                            display: PlasmaComponents.Button.TextBesideIcon
                            Layout.preferredHeight: Kirigami.Units.gridUnit * 1.5

                            property int chipIndex: parent.index

                            // Make it draggable
                            Drag.active: dragArea.drag.active
                            Drag.source: chip
                            Drag.hotSpot.x: width / 2
                            Drag.hotSpot.y: height / 2

                            // Visual feedback during drag
                            opacity: Drag.active ? 0.7 : 1.0
                            scale: Drag.active ? 1.1 : 1.0

                            Behavior on opacity {
                                NumberAnimation {
                                    duration: 150
                                }
                            }
                            Behavior on scale {
                                NumberAnimation {
                                    duration: 150
                                }
                            }

                            MouseArea {
                                id: dragArea
                                anchors.fill: parent

                                drag.target: parent
                                drag.axis: Drag.XAndYAxis

                                onPressed: function (mouse) {
                                    // Store original position
                                    chip.Drag.start();
                                    chip.chipIndex = chip.parent.index;
                                }

                                onReleased: function (mouse) {
                                    chip.Drag.drop();
                                    // Reset position
                                    chip.x = 0;
                                    chip.y = 0;
                                }

                                // Prevent chip click when dragging
                                onClicked: function (mouse) {
                                    if (!dragArea.drag.active) {
                                        chips.remove(chip.parent.index);
                                    }
                                }
                            }
                        }
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
