// ==============================================================================
// Lunova OS 1.0 Aurora - Plasma Desktop Layout Automation
// ==============================================================================

var desktopsArray = desktopsForActivity(currentActivity());
for (var j = 0; j < desktopsArray.length; j++) {
    var desktop = desktopsArray[j];
    desktop.wallpaperPlugin = "org.kde.image";
    desktop.currentConfigGroup = new Array("Wallpaper", "org.kde.image", "General");
    desktop.writeConfig("Image", "file:///usr/share/wallpapers/Lunova-Aurora/contents/images/3840x2160.svg");
    desktop.writeConfig("FillMode", 2);
}

// Remove default panels to guarantee clean slate
var existingPanels = panels();
for (var i = 0; i < existingPanels.length; i++) {
    existingPanels[i].remove();
}

// Create Aurora Glass Floating Bottom Dock / Panel
var dock = new Panel("org.kde.plasma.panel");
dock.location = "bottom";
dock.alignment = "center";
dock.height = 56;
dock.floating = true;
dock.hiding = "windowscover";

// 1. Lunova Application Launcher
var launcher = dock.addWidget("org.kde.plasma.kickoff");
launcher.currentConfigGroup = new Array("General");
launcher.writeConfig("icon", "lunova-icon");
launcher.writeConfig("favoritesPortedToKAstats", true);
launcher.writeConfig("paneDisplayMode", 1);
launcher.writeConfig("pin", false);

// 2. Icons-Only Task Manager (Pinned Lunova & Core Applications)
var taskManager = dock.addWidget("org.kde.plasma.icontasks");
taskManager.currentConfigGroup = new Array("General");
taskManager.writeConfig("launchers", [
    "applications:org.lunova.welcome.desktop",
    "applications:org.kde.dolphin.desktop",
    "applications:firefox-esr.desktop",
    "applications:org.kde.kate.desktop",
    "applications:org.kde.discover.desktop",
    "applications:org.kde.konsole.desktop",
    "applications:org.lunova.controlcenter.desktop"
]);
taskManager.writeConfig("showOnlyCurrentScreen", true);
taskManager.writeConfig("showOnlyCurrentDesktop", true);
taskManager.writeConfig("indicateAudioStreams", true);

// 3. Panel Spacer
dock.addWidget("org.kde.plasma.panelspacer");

// 4. System Tray
var tray = dock.addWidget("org.kde.plasma.systemtray");

// 5. Digital Clock
var clock = dock.addWidget("org.kde.plasma.digitalclock");
clock.currentConfigGroup = new Array("Appearance");
clock.writeConfig("dateFormat", "shortDate");
clock.writeConfig("showDate", true);
clock.writeConfig("fontFamily", "Inter");

// 6. Show Desktop Peeker
dock.addWidget("org.kde.plasma.showdesktop");
