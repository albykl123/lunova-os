import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Window 2.15

ApplicationWindow {
    id: window
    visible: true
    width: 960
    height: 640
    minimumWidth: 840
    minimumHeight: 560
    title: "Welcome to Lunova OS 1.0 Aurora"
    color: "#080D1C"

    RowLayout {
        anchors.fill: parent
        spacing: 0

        // Sidebar Navigation
        Rectangle {
            Layout.fillHeight: true
            Layout.preferredWidth: 240
            color: "#10182D"

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 20
                spacing: 12

                // Header Branding
                RowLayout {
                    spacing: 12
                    Image {
                        Layout.preferredWidth: 42
                        Layout.preferredHeight: 42
                        source: "qrc:/icons/lunova-icon.svg"
                    }
                    ColumnLayout {
                        spacing: 2
                        Text {
                            text: "LUNOVA OS"
                            font.family: "Inter"
                            font.pixelSize: 18
                            font.weight: Font.Bold
                            color: "#F5F7FF"
                        }
                        Text {
                            text: "1.0.1 Aurora"
                            font.family: "Inter"
                            font.pixelSize: 12
                            color: "#59D9F8"
                        }
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    height: 1
                    color: Qt.rgba(255, 255, 255, 0.08)
                    Layout.topMargin: 10
                    Layout.bottomMargin: 10
                }

                // Nav Items
                ButtonGroup { id: navGroup }

                Repeater {
                    model: [
                        { name: "Overview", icon: "view-dashboard" },
                        { name: "Appearance", icon: "preferences-desktop-theme" },
                        { name: "Connectivity", icon: "network-wireless" },
                        { name: "Software", icon: "applications-other" },
                        { name: "System Updates", icon: "system-software-update" },
                        { name: "Hardware Specs", icon: "dialog-information" },
                        { name: "Documentation", icon: "help-browser" }
                    ]

                    Button {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 40
                        checkable: true
                        checked: index === 0
                        ButtonGroup.group: navGroup
                        text: modelData.name

                        contentItem: Text {
                            text: modelData.name
                            font.family: "Inter"
                            font.pixelSize: 13
                            font.weight: checked ? Font.DemiBold : Font.Normal
                            color: checked ? "#59D9F8" : "#A7B2C9"
                            verticalAlignment: Text.AlignVCenter
                            leftPadding: 12
                        }

                        background: Rectangle {
                            radius: 8
                            color: checked ? Qt.rgba(84/255, 120/255, 255/255, 0.22) : (parent.hovered ? Qt.rgba(255, 255, 255, 0.05) : "transparent")
                            border.color: checked ? Qt.rgba(89/255, 217/255, 248/255, 0.4) : "transparent"
                        }

                        onClicked: stackLayout.currentIndex = index
                    }
                }

                Item { Layout.fillHeight: true }

                // Checkbox: Open at startup
                CheckBox {
                    text: "Launch on startup"
                    checked: systemInfo.autostartEnabled
                    onToggled: systemInfo.autostartEnabled = checked
                }
            }
        }

        // Main Content Area
        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: "#080D1C"

            StackLayout {
                id: stackLayout
                anchors.fill: parent
                anchors.margins: 40
                currentIndex: 0

                // 0. Overview Page
                ColumnLayout {
                    spacing: 24
                    Text {
                        text: "Welcome to Lunova OS"
                        font.family: "Inter"
                        font.pixelSize: 28
                        font.weight: Font.Bold
                        color: "#F5F7FF"
                    }
                    Text {
                        text: "Beyond the Desktop. Combining Linux freedom, Windows familiarity, and macOS elegance."
                        font.family: "Inter"
                        font.pixelSize: 15
                        color: "#A7B2C9"
                        wrapMode: Text.WordWrap
                        Layout.fillWidth: true
                    }

                    GridLayout {
                        columns: 2
                        rowSpacing: 16
                        columnSpacing: 16
                        Layout.fillWidth: true

                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 120
                            radius: 16
                            color: "#10182D"
                            border.color: Qt.rgba(84/255, 120/255, 255/255, 0.3)
                            ColumnLayout {
                                anchors.fill: parent
                                anchors.margins: 20
                                Text { text: "Aurora Glass Desktop"; font.pixelSize: 16; font.weight: Font.Bold; color: "#59D9F8" }
                                Text { text: "Floating dock, translucent styling, and dynamic themes."; color: "#A7B2C9"; wrapMode: Text.WordWrap; Layout.fillWidth: true }
                            }
                        }

                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 120
                            radius: 16
                            color: "#10182D"
                            border.color: Qt.rgba(84/255, 120/255, 255/255, 0.3)
                            ColumnLayout {
                                anchors.fill: parent
                                anchors.margins: 20
                                Text { text: "Debian Rock-Solid Core"; font.pixelSize: 16; font.weight: Font.Bold; color: "#5478FF" }
                                Text { text: "Debian 13 Trixie foundation with KDE Plasma 6, PipeWire, and Wayland."; color: "#A7B2C9"; wrapMode: Text.WordWrap; Layout.fillWidth: true }
                            }
                        }
                    }

                    Item { Layout.fillHeight: true }

                    RowLayout {
                        spacing: 16
                        Button {
                            text: "Explore Desktop Settings"
                            background: Rectangle { radius: 10; color: "#5478FF" }
                            contentItem: Text { text: "Explore Desktop Settings"; color: "white"; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
                            onClicked: systemInfo.launchCommand("systemsettings")
                        }
                        Button {
                            text: "Install Lunova OS"
                            background: Rectangle { radius: 10; color: "#9270FF" }
                            contentItem: Text { text: "Install Lunova OS"; color: "white"; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
                            onClicked: systemInfo.launchCommand("pkexec calamares")
                        }
                    }
                }

                // 1. Appearance Page
                ColumnLayout {
                    spacing: 20
                    Text { text: "Personalize Aurora Glass"; font.pixelSize: 26; font.weight: Font.Bold; color: "#F5F7FF" }
                    Text { text: "Choose between dark space elegance or bright pearl clarity."; color: "#A7B2C9" }

                    RowLayout {
                        spacing: 24
                        Button {
                            Layout.preferredWidth: 200
                            Layout.preferredHeight: 100
                            text: "Aurora Dark Mode"
                            background: Rectangle { radius: 12; color: "#10182D"; border.color: "#5478FF"; border.width: 2 }
                            contentItem: Text { text: "Aurora Dark Mode"; color: "#F5F7FF"; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
                            onClicked: systemInfo.switchTheme(true)
                        }
                        Button {
                            Layout.preferredWidth: 200
                            Layout.preferredHeight: 100
                            text: "Aurora Light Mode"
                            background: Rectangle { radius: 12; color: "#F5F7FF"; border.color: "#A7B2C9"; border.width: 1 }
                            contentItem: Text { text: "Aurora Light Mode"; color: "#10182D"; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
                            onClicked: systemInfo.switchTheme(false)
                        }
                    }

                    Item { Layout.fillHeight: true }
                }

                // 2. Connectivity Page
                ColumnLayout {
                    spacing: 20
                    Text { text: "Network & Connectivity"; font.pixelSize: 26; font.weight: Font.Bold; color: "#F5F7FF" }
                    Text { text: "Manage Wi-Fi, Ethernet, VPNs, and Bluetooth devices."; color: "#A7B2C9" }
                    Button {
                        text: "Open Network Connections"
                        onClicked: systemInfo.launchCommand("systemsettings kcm_networkmanagement")
                    }
                    Button {
                        text: "Open Bluetooth Settings"
                        onClicked: systemInfo.launchCommand("systemsettings kcm_bluetooth")
                    }
                    Item { Layout.fillHeight: true }
                }

                // 3. Software Page
                ColumnLayout {
                    spacing: 20
                    Text { text: "Install Software"; font.pixelSize: 26; font.weight: Font.Bold; color: "#F5F7FF" }
                    Text { text: "Browse thousands of native Linux apps, developer tools, and Flatpaks."; color: "#A7B2C9" }
                    Button {
                        text: "Launch Software Center (Discover)"
                        onClicked: systemInfo.launchCommand("plasma-discover")
                    }
                    Button {
                        text: "Enable Flathub Repository"
                        onClicked: systemInfo.launchCommand("flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo")
                    }
                    Item { Layout.fillHeight: true }
                }

                // 4. Updates Page
                ColumnLayout {
                    spacing: 20
                    Text { text: "System Updates"; font.pixelSize: 26; font.weight: Font.Bold; color: "#F5F7FF" }
                    Text { text: "Keep Lunova OS secure, fast, and up-to-date with Debian security patches."; color: "#A7B2C9" }
                    Button {
                        text: "Check for Updates"
                        onClicked: systemInfo.launchCommand("lunova-update")
                    }
                    Item { Layout.fillHeight: true }
                }

                // 5. Specs Page
                ColumnLayout {
                    spacing: 20
                    Text { text: "System Information"; font.pixelSize: 26; font.weight: Font.Bold; color: "#F5F7FF" }
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 180
                        radius: 12
                        color: "#10182D"
                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: 20
                            Text { text: "OS: " + systemInfo.osName; color: "#F5F7FF"; font.pixelSize: 14 }
                            Text { text: "Kernel: " + systemInfo.kernelRelease; color: "#F5F7FF"; font.pixelSize: 14 }
                            Text { text: "Host: " + systemInfo.hostname; color: "#F5F7FF"; font.pixelSize: 14 }
                            Text { text: "Codename: " + systemInfo.codename; color: "#F5F7FF"; font.pixelSize: 14 }
                        }
                    }
                    Button {
                        text: "Open Lunova About for Complete Specs"
                        onClicked: systemInfo.launchCommand("lunova-about")
                    }
                    Item { Layout.fillHeight: true }
                }

                // 6. Docs Page
                ColumnLayout {
                    spacing: 20
                    Text { text: "Documentation & Community"; font.pixelSize: 26; font.weight: Font.Bold; color: "#F5F7FF" }
                    Text { text: "Join the community and explore comprehensive documentation."; color: "#A7B2C9" }
                    Button {
                        text: "Official Repository & Docs"
                        onClicked: systemInfo.openUrl("https://github.com/lunova-os/lunova-os")
                    }
                    Button {
                        text: "File an Issue or Feature Request"
                        onClicked: systemInfo.openUrl("https://github.com/lunova-os/lunova-os/issues")
                    }
                    Item { Layout.fillHeight: true }
                }
            }
        }
    }
}
