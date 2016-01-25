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

TARGET = harbour-syncthing-sf

CONFIG += sailfishapp

CONFIG += c++11

DISTFILES += \
    qml/pages/FirstPage.qml \
    qml/pages/Settings.qml \
    qml/cover/CoverPage.qml \
    qml/harbour-syncthing-sf.qml \
    rpm/harbour-syncthing-sf.yaml

INSTALLS += cover-icon
  cover-icon.path = /usr/share/harbour-syncthing
  cover-icon.files = harbour-syncthing.png

