cmake_minimum_required(VERSION 3.16)
project(lunova-assistant VERSION 1.0.2 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)

find_package(QT NAMES Qt6 Qt5 REQUIRED COMPONENTS Core Gui Quick Widgets Network)
find_package(Qt${QT_VERSION_MAJOR} REQUIRED COMPONENTS Core Gui Quick Widgets Network)

set(SOURCES
    src/main.cpp
    src/assistantbackend.cpp
    src/assistantbackend.h
    qml.qrc
)

add_executable(lunova-assistant ${SOURCES})

target_link_libraries(lunova-assistant PRIVATE
    Qt${QT_VERSION_MAJOR}::Core
    Qt${QT_VERSION_MAJOR}::Gui
    Qt${QT_VERSION_MAJOR}::Quick
    Qt${QT_VERSION_MAJOR}::Widgets
    Qt${QT_VERSION_MAJOR}::Network
)

install(TARGETS lunova-assistant DESTINATION /usr/bin)
install(FILES org.lunova.assistant.desktop DESTINATION /usr/share/applications)
