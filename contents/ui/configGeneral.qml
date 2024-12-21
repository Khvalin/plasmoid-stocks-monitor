import QtQuick
import QtQuick.Controls 2.2 as Controls
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.plasma.components 3.0 as PlasmaComponents
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.plasmoid

Kirigami.FormLayout {
    property var cfg_selectedSymbols: []
    property var loaded: false

    id: configGeneralForm


    Component.onCompleted: {
        for (const text of cfg_selectedSymbols) {
            chips.append({
                "text": text
            });
        }
        insertTextField.forceActiveFocus();
        configGeneralForm.loaded = true;
    }


    ListModel {
        id: chips

        onCountChanged: {
            if (!configGeneralForm.loaded) {
                return;
            }

            console.log(chips.count)

            const res = []
            for( var i = 0; i < chips.count; i++ ) {
                res.push(chips.get(i).text)
            }

            configGeneralForm.cfg_selectedSymbols = res
        }
    }

    Controls.TextField {
        id: insertTextField

        Kirigami.FormData.label: "Symbol:"

        function onEnterPressed(event)
        {
            event.accepted = true // prevent further processing of the event

            const text = insertTextField.text.trim();
            if (text !== "") {
                chips.append({ "text": text })
                insertTextField.clear()
            }
        }


        Keys.onReturnPressed: event => { onEnterPressed(event) }
        Keys.onEnterPressed: event =>  { onEnterPressed(event) }
    }

    Flow {
        id: chipsContainer
        width: parent.width
        height: chips.count * Kirigami.Units.gridUnit

        flow :Flow.LeftToRight
        spacing: Kirigami.Units.smallSpacing

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
