#ifndef SYNCCONNECTORPLUGIN_H
#define SYNCCONNECTORPLUGIN_H

#include "../qst/syncconnector.h"
#include "../qst/platforms.hpp"
//#include <QAction>
#include <QNetworkAccessManager>
#include <QNetworkRequest>
#include <QNetworkReply>
#include <QSettings>
#include <QDebug>

#include <memory>

class QFolderNameFullPath : public QObject {
    Q_OBJECT
    Q_PROPERTY(QString name MEMBER m_name NOTIFY nameChanged)
    Q_PROPERTY(QString path MEMBER m_path NOTIFY pathChanged)
    Q_PROPERTY(bool deleted MEMBER m_deleted NOTIFY deletedChanged)

public:
    explicit QFolderNameFullPath(QObject *parent = 0);
    QFolderNameFullPath(QString name, QString path) : m_deleted(true) {
        m_name = name;
        m_path = path;
    }
    QFolderNameFullPath(QString name, QString path, bool deleted) {
        m_name = name;
        m_path = path;
        m_deleted = deleted;
    }

signals:
    void nameChanged();
    void pathChanged();
    void deletedChanged();

private:
    QString m_name;
    QString m_path;
    bool m_deleted;
};


//--------------------------------------------------------------------------------//
//--------------------------------------------------------------------------------//
class QQuickSyncConnector : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QList<QObject*> folders READ folders NOTIFY foldersChanged)
    Q_PROPERTY(QList<QObject*> files READ files NOTIFY filesChanged)
    Q_PROPERTY(QString status READ status NOTIFY statusChanged)
    Q_PROPERTY(QString trafficIn READ trafficIn NOTIFY trafficChanged)
    Q_PROPERTY(QString trafficOut READ trafficOut NOTIFY trafficChanged)
    Q_PROPERTY(QString trafficTot READ trafficTot NOTIFY trafficChanged)
    Q_PROPERTY(QString numberOfConnections READ numberOfConnections NOTIFY numberOfConnectionsChanged)
    Q_PROPERTY(QUrl guiUrl READ guiUrl WRITE setGuiUrl NOTIFY guiUrlChanged)
    Q_PROPERTY(bool startStopWithWifi READ startStopWithWifi WRITE setStartStopWithWifi NOTIFY startStopWithWifiChanged)
    Q_PROPERTY(bool startStopWithApp READ startStopWithApp WRITE setStartStopWithApp NOTIFY startStopWithAppChanged)
    Q_PROPERTY(bool startStopWithAC READ startStopWithAC WRITE setStartStopWithAC NOTIFY startStopWithACChanged)

public:
    explicit QQuickSyncConnector(QObject *parent = 0);

    // QtQucik Properties
    QList<QObject*> folders();
    QList<QObject*> files();
    QString getFilePath(std::string findFile);
    QString status() { return mpConnectedState; }
    QString numberOfConnections() { return mpNumberOfConnectionsAction; }
    QString trafficIn() { return mpTrafficInAction; }
    QString trafficOut() { return mpTrafficOutAction; }
    QString trafficTot() { return mpCurrentTrafficAction; }
    QUrl guiUrl() { return mCurrentUrl; }
    bool startStopWithWifi() { return mStartStopWithWifi; }
    bool startStopWithApp() { return mStartStopWithApp; }
    bool startStopWithAC() { return mStartStopWithAC; }

    void updateConnectionHealth(ConnectionHealthStatus status);
    void setGuiUrl(QString url) {
        mCurrentUrl.setUrl(url);
        emit guiUrlChanged();
        saveSettings();
    }
    void setGuiUrl(QUrl url) {
        mCurrentUrl = url;
        emit guiUrlChanged();
        saveSettings();
    }

    void setStartStopWithWifi(bool newValue) {
        mStartStopWithWifi = newValue;
        emit startStopWithWifiChanged();
        saveSettings();
    }
    void setStartStopWithApp(bool newValue) {
        mStartStopWithApp = newValue;
        emit startStopWithAppChanged();
        saveSettings();
    }
    void setStartStopWithAC(bool newValue) {
        mStartStopWithAC = newValue;
        emit startStopWithACChanged();
        saveSettings();
    }

signals:
    void foldersChanged();
    void filesChanged();
    void statusChanged();
    void numberOfConnectionsChanged();
    void trafficChanged();
    void guiUrlChanged();
    void startStopWithWifiChanged();
    void startStopWithAppChanged();
    void startStopWithACChanged();

public slots:
    void testUrl();

private slots:

private:
    void createActions();
    void saveSettings();
    void loadSettings();
    void createDefaultSettings();

    QString mpConnectedState;
    QString mpNumberOfConnectionsAction;
    QString mpCurrentTrafficAction;
    QString mpTrafficInAction;
    QString mpTrafficOutAction;

    std::list<FolderNameFullPath> mCurrentFoldersLocations;
    LastSyncedFileList mLastSyncedFiles;

    QUrl mCurrentUrl;

    std::string mCurrentUserName;
    std::string mCurrentUserPassword;
    std::shared_ptr<qst::connector::SyncConnector> mpSyncConnector;

    QSettings mSettings;
    bool mSettingsLoaded;

    bool mStartStopWithWifi;
    bool mStartStopWithApp;
    bool mStartStopWithAC;
//    int mLastConnectionState;

};


//--------------------------------------------------------------------------------//
class SyncConnectorPlugin : public QObject
{
    Q_OBJECT
public:
    explicit SyncConnectorPlugin(QObject *parent = 0);


public slots:


};

#endif // SYNCCONNECTORPLUGIN_H
