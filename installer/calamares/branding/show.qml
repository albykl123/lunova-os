import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Item {
    id: presentation
    anchors.fill: parent

    property int currentSlide: 0
    property int slideCount: 5

    Timer {
        interval: 8000
        running: true
        repeat: true
        onTriggered: {
            presentation.currentSlide = (presentation.currentSlide + 1) % presentation.slideCount
        }
    }

    Rectangle {
        anchors.fill: parent
        gradient: Gradient {
            GradientStop { position: 0.0; color: "#0B1021" }
            GradientStop { position: 1.0; color: "#141C38" }
        }
    }

    SwipeView {
        id: view
        currentIndex: presentation.currentSlide
        anchors.fill: parent
        interactive: true
        onCurrentIndexChanged: presentation.currentSlide = currentIndex

        // Slide 1: Welcome to Aurora
        Item {
            ColumnLayout {
                anchors.centerIn: parent
                spacing: 20
                width: parent.width * 0.85

                Text {
                    text: "Welcome to Lunova OS 1.0.2 — Aurora"
                    font.pixelSize: 24
                    font.bold: true
                    color: "#59D9F8"
                    Layout.alignment: Qt.AlignHCenter
                }

                Text {
                    text: "A premium desktop operating system combining the flexibility of Linux, the familiar ease of Windows, and the refined design of modern desktops."
                    font.pixelSize: 14
                    color: "#E2E8F0"
                    wrapMode: Text.WordWrap
                    Layout.fillWidth: true
                    horizontalAlignment: Text.AlignHCenter
                }
            }
        }

        // Slide 2: KDE Plasma 6
        Item {
            ColumnLayout {
                anchors.centerIn: parent
                spacing: 20
                width: parent.width * 0.85

                Text {
                    text: "KDE Plasma 6 with Aurora Glass"
                    font.pixelSize: 24
                    font.bold: true
                    color: "#A78BFA"
                    Layout.alignment: Qt.AlignHCenter
                }

                Text {
                    text: "Experience fluid Wayland graphics, refined window management, adaptive dark/light themes, and smooth typography optimized for modern high-resolution displays."
                    font.pixelSize: 14
                    color: "#E2E8F0"
                    wrapMode: Text.WordWrap
                    Layout.fillWidth: true
                    horizontalAlignment: Text.AlignHCenter
                }
            }
        }

        // Slide 3: Native Applications
        Item {
            ColumnLayout {
                anchors.centerIn: parent
                spacing: 20
                width: parent.width * 0.85

                Text {
                    text: "Integrated Native Applications"
                    font.pixelSize: 24
                    font.bold: true
                    color: "#34D399"
                    Layout.alignment: Qt.AlignHCenter
                }

                Text {
                    text: "Lunova OS includes custom Qt 6 native applications: Welcome Center, System About, Unified Control Center, Smart Assistant, and Non-Destructive Update Manager."
                    font.pixelSize: 14
                    color: "#E2E8F0"
                    wrapMode: Text.WordWrap
                    Layout.fillWidth: true
                    horizontalAlignment: Text.AlignHCenter
                }
            }
        }

        // Slide 4: Debian 13 Foundation
        Item {
            ColumnLayout {
                anchors.centerIn: parent
                spacing: 20
                width: parent.width * 0.85

                Text {
                    text: "Debian 13 (Trixie) Architecture"
                    font.pixelSize: 24
                    font.bold: true
                    color: "#F472B6"
                    Layout.alignment: Qt.AlignHCenter
                }

                Text {
                    text: "Rock-solid stability with modern Linux 6.12 kernel, standard APT package management, sandboxed updates, and native Flatpak integration for thousands of applications."
                    font.pixelSize: 14
                    color: "#E2E8F0"
                    wrapMode: Text.WordWrap
                    Layout.fillWidth: true
                    horizontalAlignment: Text.AlignHCenter
                }
            }
        }

        // Slide 5: Ready for Daily Use
        Item {
            ColumnLayout {
                anchors.centerIn: parent
                spacing: 20
                width: parent.width * 0.85

                Text {
                    text: "Finishing Your Installation..."
                    font.pixelSize: 24
                    font.bold: true
                    color: "#FBBF24"
                    Layout.alignment: Qt.AlignHCenter
                }

                Text {
                    text: "Writing bootloader, generating fstab, and preparing your desktop environment. Once completed, restart your computer and remove the live installation media."
                    font.pixelSize: 14
                    color: "#E2E8F0"
                    wrapMode: Text.WordWrap
                    Layout.fillWidth: true
                    horizontalAlignment: Text.AlignHCenter
                }
            }
        }
    }

    PageIndicator {
        count: view.count
        currentIndex: view.currentIndex
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 24
        anchors.horizontalCenter: parent.horizontalCenter
    }
}
