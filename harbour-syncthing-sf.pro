TARGET = harbour-syncthing-sf

CONFIG += sailfishapp
CONFIG += c++11

HEADERS       =     src/syncconnectorplugin.h
SOURCES       =   src/syncconnectorplugin.cpp \
    src/harbour-syncthing-sf.cpp

HEADERS += qst/syncconnector.h \
    qst/platforms/darwin/macUtils.hpp \
    qst/platforms/windows/winUtils.hpp \
    qst/platforms/linux/posixUtils.hpp \
    qst/platforms.hpp \
    qst/apihandler.hpp \
    qst/utilities.hpp

SOURCES += qst/syncconnector.cpp

#QT += widgets
QT += network

DISTFILES += \
    qml/pages/FirstPage.qml \
    qml/pages/Settings.qml \
    qml/cover/CoverPage.qml \
    qml/harbour-syncthing-sf.qml \
    qml/pages/FileBrowser.qml \
    qml/pages/FolderDelegate.qml \
    harbour-syncthing-sf.desktop \
    rpm/harbour-syncthing-sf.yaml \
    rpm/harbour-syncthing-sf.spec \
    qml/tools/AC.qml \
    qml/pages/SyncthingWebGUI.qml \
    qml/tools/ItemSelector.qml

SAILFISHAPP_ICONS = 86x86 108x108 128x128 256x256

INSTALLS += cover-icon
  cover-icon.path = /usr/share/harbour-syncthing-sf
  cover-icon.files = harbour-syncthing-sf.png


INSTALLS += service
  service.path = /usr/lib/systemd/user
  service.files = syncthing.net/etc/linux-systemd/user/syncthing.service

INSTALLS += syncthing
  syncthing.path = /usr/share/harbour-syncthing-sf/libexec
#  syncthing.files = syncthing.net/386/syncthing  #emulator
  syncthing.files = syncthing.net/arm/syncthing  #jolla
