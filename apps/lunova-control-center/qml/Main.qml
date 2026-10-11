import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

ApplicationWindow {
    id: window
    visible: true
    width: 820
    height: 640
    minimumWidth: 780
    minimumHeight: 600
    title: "Lunova Control Center"
    color: "#080D1C"

    ScrollView {
        anchors.fill: parent
        anchors.margins: 28
        clip: true

        ColumnLayout {
            width: parent.width
            spacing: 24

            // Header
            RowLayout {
                spacing: 16
                Image {
                    Layout.preferredWidth: 44
                    Layout.preferredHeight: 44
                    source: "qrc:/icons/lunova-icon.svg"
                }
                ColumnLayout {
                    spacing: 2
                    Text { text: "Control Center"; font.pixelSize: 22; font.weight: Font.Bold; color: "#F5F7FF" }
                    Text { text: "System Preferences & Quick Controls"; font.pixelSize: 12; color: "#A7B2C9" }
                }
            }

            // Quick Controls Grid (Glass Cards)
            GridLayout {
                columns: 2
                columnSpacing: 16
                rowSpacing: 16
                Layout.fillWidth: true

                // Volume Card
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 90
                    radius: 14
                    color: "#10182D"
                    border.color: Qt.rgba(84/255, 120/255, 255/255, 0.25)
                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 14
                        RowLayout {
                            Text { text: "Audio Volume"; color: "#F5F7FF"; font.weight: Font.DemiBold }
                            Item { Layout.fillWidth: true }
                            Text { text: controlBackend.volume + "%"; color: "#59D9F8" }
                        }
                        Slider {
                            Layout.fillWidth: true
                            from: 0
                            to: 100
                            value: controlBackend.volume
                            onMoved: controlBackend.volume = value
                        }
                    }
                }

                // Brightness Card
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 90
                    radius: 14
                    color: "#10182D"
                    border.color: Qt.rgba(84/255, 120/255, 255/255, 0.25)
                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 14
                        RowLayout {
                            Text { text: "Display Brightness"; color: "#F5F7FF"; font.weight: Font.DemiBold }
                            Item { Layout.fillWidth: true }
                            Text { text: controlBackend.brightness + "%"; color: "#59D9F8" }
                        }
                        Slider {
                            Layout.fillWidth: true
                            from: 5
                            to: 100
                            value: controlBackend.brightness
                            onMoved: controlBackend.brightness = value
                        }
                    }
                }
            }

            // Power Mode Selector Card
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 70
                radius: 14
                color: "#10182D"
                border.color: Qt.rgba(84/255, 120/255, 255/255, 0.25)
                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 16
                    Text { text: "Power Profile:"; color: "#F5F7FF"; font.weight: Font.DemiBold }
                    Item { Layout.fillWidth: true }
                    Button {
                        text: "Power Saver"
                        highlighted: controlBackend.powerProfile === "power-saver"
                        onClicked: controlBackend.powerProfile = "power-saver"
                    }
                    Button {
                        text: "Balanced"
                        highlighted: controlBackend.powerProfile === "balanced"
                        onClicked: controlBackend.powerProfile = "balanced"
                    }
                    Button {
                        text: "Performance"
                        highlighted: controlBackend.powerProfile === "performance"
                        onClicked: controlBackend.powerProfile = "performance"
                    }
                }
            }

            Text { text: "System Configuration Modules"; font.pixelSize: 18; font.weight: Font.Bold; color: "#F5F7FF"; Layout.topMargin: 10 }

            // Category Modules List
            GridLayout {
                columns: 2
                columnSpacing: 16
                rowSpacing: 14
                Layout.fillWidth: true

                Repeater {
                    model: [
                        { title: "Appearance & Themes", desc: "Colors, Aurora Glass styles, and icons", action: "kcm_lookandfeel" },
                        { title: "Displays & Scaling", desc: "Resolution, refresh rate, and HiDPI", action: "kcm_kscreen" },
                        { title: "Network & Internet", desc: "Wi-Fi, Ethernet, VPN, and proxies", action: "kcm_networkmanagement" },
                        { title: "Bluetooth & Devices", desc: "Pair and manage wireless peripherals", action: "kcm_bluetooth" },
                        { title: "Audio & Microphones", desc: "PipeWire routing and sound devices", action: "kcm_pulseaudio" },
                        { title: "Energy & Battery", desc: "Sleep timers and display dimming", action: "powerdevilprofilesconfig" },
                        { title: "Users & Accounts", desc: "Passwords, avatars, and privileges", action: "kcm_users" },
                        { title: "System Updates", desc: "Check and apply security updates", app: "lunova-update" }
                    ]

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 74
                        radius: 12
                        color: "#10182D"
                        border.color: moduleMouse.containsMouse ? "#5478FF" : Qt.rgba(255, 255, 255, 0.08)

                        MouseArea {
                            id: moduleMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                if (modelData.app) {
                                    controlBackend.openApp(modelData.app)
                                } else {
                                    controlBackend.openModule(modelData.action)
                                }
                            }
                        }

                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: 14
                            spacing: 12
                            ColumnLayout {
                                spacing: 2
                                Text { text: modelData.title; font.weight: Font.DemiBold; color: "#F5F7FF"; font.pixelSize: 14 }
                                Text { text: modelData.desc; color: "#A7B2C9"; font.pixelSize: 11 }
                            }
                            Item { Layout.fillWidth: true }
                            Text { text: "›"; color: "#59D9F8"; font.pixelSize: 20; font.weight: Font.Bold }
                        }
                    }
                }
            }

            // Bottom Bar with Lunova About
            RowLayout {
                Layout.fillWidth: true
                Item { Layout.fillWidth: true }
                Button {
                    text: "About Lunova OS"
                    onClicked: controlBackend.openApp("lunova-about")
                }
            }
        }
    }
}
