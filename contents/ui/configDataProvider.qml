import QtQuick
import QtQuick.Controls as Controls
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.plasma.components as PlasmaComponents
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.plasmoid

ColumnLayout {
    id: root
    property alias cfg_dataProvider: dataProviderField.text
    property alias cfg_apiKey: apiKeyField.text
    property alias cfg_apiSecret: apiSecretField.text

    spacing: Kirigami.Units.largeSpacing

    Kirigami.FormLayout {
        id: configDataProviderForm
        Layout.fillWidth: true

        Controls.TextField {
            id: dataProviderField
            Kirigami.FormData.label: "Data Provider:"
            placeholderText: "e.g., alpaca.markets"
        }

        Controls.TextField {
            id: apiKeyField
            Kirigami.FormData.label: "API Key:"
            placeholderText: "Enter your API key"
        }

        Controls.TextField {
            id: apiSecretField
            Kirigami.FormData.label: "API Secret:"
            placeholderText: "Enter your API secret"
            echoMode: Controls.TextInput.Password
        }

        PlasmaComponents.Label {
            Layout.fillWidth: true
            text: "Note: Your API credentials are stored locally and used to fetch stock data."
            opacity: 0.7
            font.italic: true
            wrapMode: Text.WordWrap
        }
    }

    Item {
        Layout.fillHeight: true
    }
}
