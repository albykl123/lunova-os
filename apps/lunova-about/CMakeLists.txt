cmake_minimum_required(VERSION 3.16)
project(lunova-about VERSION 1.0.2 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)

find_package(QT NAMES Qt6 Qt5 REQUIRED COMPONENTS Core Gui Quick Widgets)
find_package(Qt${QT_VERSION_MAJOR} REQUIRED COMPONENTS Core Gui Quick Widgets)

set(SOURCES
    src/main.cpp
    src/hardwareinfo.cpp
    src/hardwareinfo.h
    qml.qrc
)

add_executable(lunova-about ${SOURCES})

target_link_libraries(lunova-about PRIVATE
    Qt${QT_VERSION_MAJOR}::Core
    Qt${QT_VERSION_MAJOR}::Gui
    Qt${QT_VERSION_MAJOR}::Quick
    Qt${QT_VERSION_MAJOR}::Widgets
)

install(TARGETS lunova-about DESTINATION /usr/bin)
install(FILES org.lunova.about.desktop DESTINATION /usr/share/applications)
