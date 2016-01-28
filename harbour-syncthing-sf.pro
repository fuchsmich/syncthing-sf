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

QT += widgets
QT += network

DISTFILES += \
    qml/pages/FirstPage.qml \
    qml/pages/Settings.qml \
    qml/cover/CoverPage.qml \
    qml/harbour-syncthing-sf.qml \
    rpm/harbour-syncthing-sf.yaml \
    harbour-syncthing-sf.desktop \
    harbour-syncthing-sf.png \
    qml/pages/FileBrowser.qml

#SAILFISHAPP_ICONS = 86x86 108x108 128x128 256x256

#INSTALLS += cover-icon
#  cover-icon.path = /usr/share/harbour-syncthing
#  cover-icon.files = harbour-syncthing-sf.png

