HEADERS       = qst/syncconnector.h \
                qst/platforms/darwin/macUtils.hpp \
                qst/platforms/windows/winUtils.hpp \
                qst/platforms/linux/posixUtils.hpp \
                qst/platforms.hpp \
                qst/apihandler.hpp \
                qst/utilities.hpp \
    src/syncconnectorplugin.h
SOURCES       = src/syncthing-sf.cpp \
                qst/syncconnector.cpp \
    src/syncconnectorplugin.cpp
#RESOURCES     = \
#                qsyncthing.qrc

QT += widgets
QT += network
#QT += webenginewidgets

TARGET = syncthing-sf
# install
#target.path = binary/
#INSTALLS += target
CONFIG += sailfishapp

CONFIG += c++11
#ICON = Syncthing.icns

DISTFILES += \
    qml/syncthing-sf.qml \
    qml/pages/FirstPage.qml \
    qml/pages/Settings.qml \
    qml/cover/CoverPage.qml \
    rpm/syncthing-sf.yaml \
    rpm/syncthing-sf.spec
