import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

ApplicationWindow {
    id: window
    visible: true
    width: 760
    height: 680
    minimumWidth: 640
    minimumHeight: 520
    title: "Lunova Assistant"
    color: "#080D1C"

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 12

        // Top Navigation & Provider Bar
        RowLayout {
            spacing: 14
            Image {
                Layout.preferredWidth: 32
                Layout.preferredHeight: 32
                source: "qrc:/icons/lunova-icon.svg"
            }
            ColumnLayout {
                spacing: 2
                Text { text: "Lunova Assistant"; color: "#F5F7FF"; font.weight: Font.Bold; font.pixelSize: 15 }
                Text { text: assistantBackend.modelName + " (" + assistantBackend.provider + ")"; color: "#59D9F8"; font.pixelSize: 11 }
            }
            Item { Layout.fillWidth: true }
            Button {
                text: "Settings"
                onClicked: settingsDrawer.open()
            }
            Button {
                text: "Clear"
                onClicked: assistantBackend.clearHistory()
            }
        }

        // Approval Banner for Pending Commands
        Rectangle {
            id: approvalBanner
            visible: assistantBackend.pendingCommand.length > 0
            Layout.fillWidth: true
            Layout.preferredHeight: 110
            radius: 12
            color: "#16203C"
            border.color: "#59D9F8"
            border.width: 1.5

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 12
                spacing: 6
                Text {
                    text: "Action Requires Approval: The assistant requested to run the following system command:"
                    color: "#F5F7FF"
                    font.weight: Font.Bold
                    font.pixelSize: 12
                }
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 32
                    color: "#080D1C"
                    radius: 6
                    Text {
                        anchors.fill: parent
                        anchors.margins: 6
                        text: assistantBackend.pendingCommand
                        color: "#59D9F8"
                        font.family: "JetBrains Mono"
                        font.pixelSize: 12
                        elide: Text.ElideRight
                    }
                }
                RowLayout {
                    spacing: 12
                    Button {
                        text: "Approve & Execute"
                        highlighted: true
                        onClicked: assistantBackend.approvePendingCommand()
                    }
                    Button {
                        text: "Reject"
                        onClicked: assistantBackend.rejectPendingCommand()
                    }
                }
            }
        }

        // Messages Conversation View
        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            radius: 14
            color: "#10182D"
            border.color: Qt.rgba(255, 255, 255, 0.08)

            ListView {
                id: msgList
                anchors.fill: parent
                anchors.margins: 16
                model: assistantBackend.messages
                spacing: 14
                clip: true
                onCountChanged: msgList.positionViewAtEnd()

                delegate: ColumnLayout {
                    width: msgList.width - 24
                    spacing: 4

                    Text {
                        text: modelData.sender === "user" ? "You" : (modelData.sender === "system" ? "System" : "Lunova Assistant")
                        color: modelData.sender === "user" ? "#5478FF" : (modelData.sender === "system" ? "#9270FF" : "#59D9F8")
                        font.weight: Font.Bold
                        font.pixelSize: 12
                        horizontalAlignment: modelData.sender === "user" ? Text.AlignRight : Text.AlignLeft
                        Layout.alignment: modelData.sender === "user" ? Qt.AlignRight : Qt.AlignLeft
                    }

                    Rectangle {
                        Layout.maximumWidth: parent.width * 0.85
                        Layout.alignment: modelData.sender === "user" ? Qt.AlignRight : Qt.AlignLeft
                        radius: 12
                        color: modelData.sender === "user" ? "#1A2748" : (modelData.sender === "system" ? "#0F1A30" : "#141E38")
                        border.color: Qt.rgba(255, 255, 255, 0.06)
                        implicitWidth: contentText.implicitWidth + 24
                        implicitHeight: contentText.implicitHeight + 20

                        Text {
                            id: contentText
                            anchors.fill: parent
                            anchors.margins: 12
                            text: modelData.text
                            color: "#F5F7FF"
                            font.family: "Inter"
                            font.pixelSize: 13
                            wrapMode: Text.WordWrap
                        }
                    }
                }
            }
        }

        // Status Line
        Text {
            text: assistantBackend.statusMessage
            color: "#A7B2C9"
            font.pixelSize: 11
        }

        // Chat Input Row
        RowLayout {
            Layout.fillWidth: true
            spacing: 10

            TextField {
                id: inputField
                Layout.fillWidth: true
                placeholderText: "Type a prompt or system question..."
                color: "#F5F7FF"
                placeholderTextColor: "#A7B2C9"
                background: Rectangle {
                    radius: 10
                    color: "#10182D"
                    border.color: inputField.activeFocus ? "#59D9F8" : Qt.rgba(255, 255, 255, 0.15)
                }
                onAccepted: {
                    assistantBackend.sendMessage(inputField.text);
                    inputField.clear();
                }
            }

            Button {
                text: "Send"
                enabled: !assistantBackend.isProcessing && inputField.text.trim().length > 0
                onClicked: {
                    assistantBackend.sendMessage(inputField.text);
                    inputField.clear();
                }
            }
        }
    }

    // Settings Drawer
    Drawer {
        id: settingsDrawer
        width: 380
        height: window.height
        edge: Qt.RightEdge

        Rectangle {
            anchors.fill: parent
            color: "#10182D"

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 24
                spacing: 16

                Text { text: "Assistant Configuration"; font.pixelSize: 18; font.weight: Font.Bold; color: "#F5F7FF" }

                Text { text: "AI Provider"; color: "#A7B2C9"; font.pixelSize: 12 }
                ComboBox {
                    id: providerBox
                    Layout.fillWidth: true
                    model: ["Local (Ollama / Llama.cpp)", "Custom OpenAI Endpoint", "Google Gemini API"]
                    currentIndex: 0
                    onActivated: assistantBackend.provider = currentText
                }

                Text { text: "Endpoint URL"; color: "#A7B2C9"; font.pixelSize: 12 }
                TextField {
                    id: endpointField
                    Layout.fillWidth: true
                    text: assistantBackend.endpointUrl
                    onEditingFinished: assistantBackend.endpointUrl = text
                }

                Text { text: "Model Name"; color: "#A7B2C9"; font.pixelSize: 12 }
                TextField {
                    id: modelField
                    Layout.fillWidth: true
                    text: assistantBackend.modelName
                    onEditingFinished: assistantBackend.modelName = text
                }

                Text { text: "API Key (Stored securely)"; color: "#A7B2C9"; font.pixelSize: 12 }
                TextField {
                    id: keyField
                    Layout.fillWidth: true
                    echoMode: TextInput.Password
                    text: assistantBackend.getApiKey()
                    onEditingFinished: assistantBackend.setApiKey(text)
                }

                Item { Layout.fillHeight: true }

                Button {
                    Layout.fillWidth: true
                    text: "Done"
                    onClicked: settingsDrawer.close()
                }
            }
        }
    }
}
