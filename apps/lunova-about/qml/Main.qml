import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

ApplicationWindow {
    id: window
    visible: true
    width: 680
    height: 620
    minimumWidth: 640
    minimumHeight: 580
    maximumWidth: 800
    maximumHeight: 700
    title: "About Lunova OS"
    color: "#080D1C"

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 32
        spacing: 20

        // Top Header
        RowLayout {
            spacing: 24
            Layout.alignment: Qt.AlignHCenter

            Image {
                Layout.preferredWidth: 80
                Layout.preferredHeight: 80
                source: "qrc:/icons/lunova-icon.svg"
                fillMode: Image.PreserveAspectFit
            }

            ColumnLayout {
                spacing: 4
                Text {
                    text: "LUNOVA OS"
                    font.family: "Inter"
                    font.pixelSize: 26
                    font.weight: Font.Bold
                    letterSpacing: 2
                    color: "#F5F7FF"
                }
                Text {
                    text: "Version 1.0.0 Aurora (x86-64)"
                    font.family: "Inter"
                    font.pixelSize: 14
                    color: "#59D9F8"
                }
                Text {
                    text: "Beyond the Desktop."
                    font.family: "Inter"
                    font.pixelSize: 12
                    font.italic: true
                    color: "#A7B2C9"
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            height: 1
            color: Qt.rgba(255, 255, 255, 0.08)
        }

        // Hardware & Software Specifications Glass Card
        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            radius: 16
            color: "#10182D"
            border.color: Qt.rgba(84/255, 120/255, 255/255, 0.25)

            ScrollView {
                anchors.fill: parent
                anchors.margins: 20
                clip: true

                GridLayout {
                    columns: 2
                    columnSpacing: 20
                    rowSpacing: 14
                    width: parent.width

                    // Helper label function
                    function makeRow(label, value) {
                        return [label, value];
                    }

                    Text { text: "Operating System:"; font.weight: Font.DemiBold; color: "#A7B2C9"; font.pixelSize: 13 }
                    Text { text: hardwareInfo.osVersion; color: "#F5F7FF"; font.pixelSize: 13 }

                    Text { text: "Debian Base:"; font.weight: Font.DemiBold; color: "#A7B2C9"; font.pixelSize: 13 }
                    Text { text: hardwareInfo.debianBase; color: "#F5F7FF"; font.pixelSize: 13 }

                    Text { text: "Desktop Environment:"; font.weight: Font.DemiBold; color: "#A7B2C9"; font.pixelSize: 13 }
                    Text { text: hardwareInfo.plasmaVersion; color: "#F5F7FF"; font.pixelSize: 13 }

                    Text { text: "Linux Kernel:"; font.weight: Font.DemiBold; color: "#A7B2C9"; font.pixelSize: 13 }
                    Text { text: hardwareInfo.kernelVersion; color: "#F5F7FF"; font.pixelSize: 13 }

                    Text { text: "Architecture:"; font.weight: Font.DemiBold; color: "#A7B2C9"; font.pixelSize: 13 }
                    Text { text: hardwareInfo.architecture; color: "#F5F7FF"; font.pixelSize: 13 }

                    Text { text: "Processor (CPU):"; font.weight: Font.DemiBold; color: "#A7B2C9"; font.pixelSize: 13 }
                    Text { text: hardwareInfo.cpuModel + " (" + hardwareInfo.cpuCores + " Threads)"; color: "#F5F7FF"; font.pixelSize: 13; wrapMode: Text.WordWrap; Layout.fillWidth: true }

                    Text { text: "System Memory (RAM):"; font.weight: Font.DemiBold; color: "#A7B2C9"; font.pixelSize: 13 }
                    Text { text: hardwareInfo.totalRam; color: "#F5F7FF"; font.pixelSize: 13 }

                    Text { text: "Graphics (GPU):"; font.weight: Font.DemiBold; color: "#A7B2C9"; font.pixelSize: 13 }
                    Text { text: hardwareInfo.gpuRenderer; color: "#F5F7FF"; font.pixelSize: 13; wrapMode: Text.WordWrap; Layout.fillWidth: true }

                    Text { text: "System Storage:"; font.weight: Font.DemiBold; color: "#A7B2C9"; font.pixelSize: 13 }
                    Text { text: hardwareInfo.storageSize; color: "#F5F7FF"; font.pixelSize: 13 }
                }
            }
        }

        // Footer / Attribution Notice
        Text {
            Layout.fillWidth: true
            text: hardwareInfo.licenseNotice
            font.family: "Inter"
            font.pixelSize: 11
            color: "#A7B2C9"
            wrapMode: Text.WordWrap
            horizontalAlignment: Text.AlignHCenter
        }
    }
}
