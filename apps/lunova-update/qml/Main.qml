import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

ApplicationWindow {
    id: window
    visible: true
    width: 720
    height: 560
    minimumWidth: 620
    minimumHeight: 480
    title: "Lunova Update"
    color: "#080D1C"

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 28
        spacing: 18

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
                Text { text: "System Update"; font.pixelSize: 22; font.weight: Font.Bold; color: "#F5F7FF" }
                Text { text: "Debian Verified Package Updates"; font.pixelSize: 12; color: "#A7B2C9" }
            }
            Item { Layout.fillWidth: true }
            Button {
                text: "Check for Updates"
                enabled: !updateManager.isBusy
                onClicked: updateManager.checkForUpdates()
            }
        }

        // Reboot Required Alert Banner
        Rectangle {
            visible: updateManager.rebootRequired
            Layout.fillWidth: true
            Layout.preferredHeight: 52
            radius: 10
            color: Qt.rgba(255/255, 107/255, 107/255, 0.2)
            border.color: "#FF6B6B"

            RowLayout {
                anchors.fill: parent
                anchors.margins: 12
                Text {
                    text: "System Restart Required: A kernel or core library update was applied."
                    color: "#FFFFFF"
                    font.weight: Font.DemiBold
                }
                Item { Layout.fillWidth: true }
                Button {
                    text: "Restart Now"
                    onClicked: updateManager.rebootSystem()
                }
            }
        }

        // Status Card & Progress
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 80
            radius: 12
            color: "#10182D"
            border.color: Qt.rgba(84/255, 120/255, 255/255, 0.2)

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 14
                spacing: 8
                Text {
                    text: updateManager.statusText
                    color: "#F5F7FF"
                    font.pixelSize: 13
                }
                ProgressBar {
                    Layout.fillWidth: true
                    from: 0
                    to: 100
                    value: updateManager.progressPercent
                    visible: updateManager.isBusy
                }
            }
        }

        // Package Updates List
        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            radius: 12
            color: "#10182D"
            border.color: Qt.rgba(255, 255, 255, 0.08)

            ListView {
                id: updateList
                anchors.fill: parent
                anchors.margins: 12
                model: updateManager.updates
                spacing: 8
                clip: true

                delegate: Rectangle {
                    width: updateList.width - 16
                    height: 52
                    radius: 8
                    color: "#16203C"

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 12
                        spacing: 12

                        ColumnLayout {
                            spacing: 2
                            Text {
                                text: modelData.package
                                font.weight: Font.Bold
                                font.pixelSize: 13
                                color: "#F5F7FF"
                            }
                            Text {
                                text: modelData.currentVersion + " → " + modelData.newVersion
                                font.family: "JetBrains Mono"
                                font.pixelSize: 11
                                color: "#A7B2C9"
                            }
                        }

                        Item { Layout.fillWidth: true }

                        Rectangle {
                            visible: modelData.isSecurity
                            radius: 4
                            color: Qt.rgba(255/255, 107/255, 107/255, 0.25)
                            border.color: "#FF6B6B"
                            implicitWidth: 64
                            implicitHeight: 24
                            Text {
                                anchors.centerIn: parent
                                text: "Security"
                                font.pixelSize: 10
                                font.weight: Font.Bold
                                color: "#FF6B6B"
                            }
                        }
                    }
                }
            }
        }

        // Footer Actions
        RowLayout {
            Layout.fillWidth: true
            Text {
                text: updateManager.updateCount > 0 ? updateManager.updateCount + " updates ready to install" : "No pending updates"
                color: "#A7B2C9"
                font.pixelSize: 12
            }
            Item { Layout.fillWidth: true }
            Button {
                text: "Install All Updates"
                highlighted: true
                enabled: !updateManager.isBusy && updateManager.updateCount > 0
                onClicked: updateManager.applyUpdates()
            }
        }
    }
}
