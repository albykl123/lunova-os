import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtGraphicalEffects 1.15

Rectangle {
    id: root
    width: 1920
    height: 1080
    color: "#080D1C"

    // Background Image with Aurora Glass Dimming
    Image {
        id: bgImage
        anchors.fill: parent
        source: config.background || "/usr/share/wallpapers/Lunova-Aurora/contents/images/3840x2160.svg"
        fillMode: Image.PreserveAspectCrop
        asynchronous: true
    }

    Rectangle {
        anchors.fill: parent
        color: "#080D1C"
        opacity: 0.35
    }

    // Top Bar (Clock & Session Info)
    RowLayout {
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.margins: 32
        spacing: 16

        Label {
            id: clockLabel
            text: Qt.formatTime(new Date(), "hh:mm AP")
            color: "#F5F7FF"
            font.family: "Inter"
            font.pixelSize: 18
            font.weight: Font.DemiBold
        }

        Timer {
            interval: 1000
            running: true
            repeat: true
            onTriggered: clockLabel.text = Qt.formatTime(new Date(), "hh:mm AP")
        }
    }

    // Central Aurora Glass Login Card
    Rectangle {
        id: loginCard
        anchors.centerIn: parent
        width: 420
        height: 520
        radius: 24
        color: Qt.rgba(16/255, 24/255, 45/255, 0.78)
        border.color: Qt.rgba(89/217, 248/255, 0.35)
        border.width: 1.5

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 40
            spacing: 20

            // Lunova Emblem
            Image {
                Layout.alignment: Qt.AlignHCenter
                Layout.preferredWidth: 84
                Layout.preferredHeight: 84
                source: "file:///usr/share/icons/Lunova-Aurora/apps/scalable/lunova-icon.svg"
                fillMode: Image.PreserveAspectFit
            }

            Text {
                Layout.alignment: Qt.AlignHCenter
                text: "LUNOVA OS"
                font.family: "Inter"
                font.pixelSize: 22
                font.weight: Font.Bold
                font.letterSpacing: 3
                color: "#F5F7FF"
            }

            Text {
                Layout.alignment: Qt.AlignHCenter
                text: "Aurora • Desktop Edition"
                font.family: "Inter"
                font.pixelSize: 12
                color: "#A7B2C9"
            }

            Item { Layout.fillHeight: true }

            // User Selection
            ComboBox {
                id: userSelect
                Layout.fillWidth: true
                model: userModel
                textRole: "realName"
                currentIndex: userModel.lastIndex
                background: Rectangle {
                    color: Qt.rgba(24/255, 36/255, 68/255, 0.8)
                    radius: 12
                    border.color: Qt.rgba(84/217, 255/255, 0.2)
                }
            }

            // Password Field
            TextField {
                id: passwordField
                Layout.fillWidth: true
                placeholderText: "Enter Password"
                echoMode: TextInput.Password
                focus: true
                color: "#F5F7FF"
                placeholderTextColor: "#A7B2C9"
                background: Rectangle {
                    color: Qt.rgba(8/255, 13/255, 28/255, 0.85)
                    radius: 12
                    border.color: passwordField.activeFocus ? "#59D9F8" : Qt.rgba(84/217, 255/255, 0.3)
                    border.width: passwordField.activeFocus ? 2 : 1
                }
                onAccepted: sddm.login(userSelect.currentText, passwordField.text, sessionSelect.currentIndex)
            }

            // Login Button
            Button {
                id: loginButton
                Layout.fillWidth: true
                Layout.preferredHeight: 44
                text: "Sign In"
                contentItem: Text {
                    text: loginButton.text
                    font.family: "Inter"
                    font.pixelSize: 15
                    font.weight: Font.DemiBold
                    color: "#FFFFFF"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
                background: Rectangle {
                    radius: 12
                    gradient: Gradient {
                        GradientStop { position: 0.0; color: "#5478FF" }
                        GradientStop { position: 1.0; color: "#9270FF" }
                    }
                }
                onClicked: sddm.login(userSelect.currentText, passwordField.text, sessionSelect.currentIndex)
            }

            Item { Layout.fillHeight: true }

            // Session Select (Wayland / X11)
            RowLayout {
                Layout.fillWidth: true
                Text {
                    text: "Session:"
                    font.family: "Inter"
                    font.pixelSize: 12
                    color: "#A7B2C9"
                }
                ComboBox {
                    id: sessionSelect
                    Layout.fillWidth: true
                    model: sessionModel
                    textRole: "name"
                    currentIndex: sessionModel.lastIndex
                }
            }
        }
    }

    // Bottom Power Controls
    RowLayout {
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        anchors.margins: 32
        spacing: 16

        Button {
            text: "Sleep"
            onClicked: sddm.suspend()
        }
        Button {
            text: "Restart"
            onClicked: sddm.reboot()
        }
        Button {
            text: "Shut Down"
            onClicked: sddm.powerOff()
        }
    }
}
