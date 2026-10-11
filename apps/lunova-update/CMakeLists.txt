cmake_minimum_required(VERSION 3.16)
project(lunova-update VERSION 1.0.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)

find_package(QT NAMES Qt6 Qt5 REQUIRED COMPONENTS Core Gui Quick Widgets)
find_package(Qt${QT_VERSION_MAJOR} REQUIRED COMPONENTS Core Gui Quick Widgets)

set(SOURCES
    src/main.cpp
    src/updatemanager.cpp
    src/updatemanager.h
    qml.qrc
)

add_executable(lunova-update ${SOURCES})

target_link_libraries(lunova-update PRIVATE
    Qt${QT_VERSION_MAJOR}::Core
    Qt${QT_VERSION_MAJOR}::Gui
    Qt${QT_VERSION_MAJOR}::Quick
    Qt${QT_VERSION_MAJOR}::Widgets
)

install(TARGETS lunova-update DESTINATION /usr/bin)
install(FILES org.lunova.update.desktop DESTINATION /usr/share/applications)
