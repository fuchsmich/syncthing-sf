TARGET = harbour-syncthing-sf
CONFIG += c++11
CONFIG += sailfishapp
HEADERS       += syncconnector.h \
                platforms/darwin/macUtils.hpp \
                platforms/windows/winUtils.hpp \
                platforms/linux/posixUtils.hpp \
                platforms.hpp \
                apihandler.hpp \
                utilities.hpp

SOURCES       += syncconnector.cpp

QT += widgets
QT += network


