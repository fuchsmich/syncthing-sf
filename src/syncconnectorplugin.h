#ifndef SYNCCONNECTORPLUGIN_H
#define SYNCCONNECTORPLUGIN_H

#include "../qst/syncconnector.h"
#include "../qst/platforms.hpp"
#include <QAction>
#include <QNetworkAccessManager>
#include <QNetworkRequest>
#include <QNetworkReply>
#include <QSettings>

#include <memory>

class QFolderNameFullPath : public QObject {
    Q_OBJECT
    Q_PROPERTY(QString name MEMBER m_name NOTIFY nameChanged)
    Q_PROPERTY(QString path MEMBER m_path NOTIFY pathChanged)

public:
    explicit QFolderNameFullPath(QObject *parent = 0);
    QFolderNameFullPath(QString name, QString path) {
        m_name = name;
        m_path = path;
    }

signals:
    void nameChanged();
    void pathChanged();

private:
    QString m_name;
    QString m_path;
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

public:
    explicit QQuickSyncConnector(QObject *parent = 0);

    // QtQucik Properties
    QList<QObject*> folders() { return mCurrentFoldersActions; }
    QList<QObject*> files();
    QString status() { return mpConnectedState->text(); }
    QString numberOfConnections() { return mpNumberOfConnectionsAction->text(); }
    QString trafficIn() { return mpTrafficInAction->text(); }
    QString trafficOut() { return mpTrafficOutAction->text(); }
    QString trafficTot() { return mpCurrentTrafficAction->text(); }
    QUrl guiUrl() { return mCurrentUrl; }

//    void setVisible(bool visible) Q_DECL_OVERRIDE;
    void updateConnectionHealth(ConnectionHealthStatus status);
    void onNetworkActivity(bool activity);
    void setGuiUrl(QString url) {
        mCurrentUrl.setUrl(url);
        emit guiUrlChanged();
    }
    void setGuiUrl(QUrl url) {
        mCurrentUrl = url;
        emit guiUrlChanged();
    }

    Q_INVOKABLE void pauseSyncthingClicked(int state);

signals:
    void foldersChanged();
    void filesChanged();
    void statusChanged();
    void numberOfConnectionsChanged();
    void trafficChanged();
    void guiUrlChanged();

public slots:
    void testUrl();

private slots:

private:
//    void createSettingsGroupBox();
    void createActions();
//    void createTrayIcon();
    void saveSettings();
    void loadSettings();
//    void showAuthentication(bool show);
//    void showMessage(std::string title, std::string body);
    void createFoldersMenu();
//    void createLastSyncedMenu();
    void createDefaultSettings();
//    void validateSSLSupport();
//    int getCurrentVersion(std::string reply);
//    void onStartAnimation(bool animate);

//    QTabWidget *mpSettingsTabsWidget;
//    QGroupBox *mpSettingsGroupBox;
//    QLabel *mpURLLabel;
//    QLineEdit *mpSyncthingUrlLineEdit;

//    QLabel *userNameLabel;
//    QLabel *userPasswordLabel;
//    QLineEdit *mpUserNameLineEdit;
//    QLineEdit *userPassword;
//    QCheckBox *mpAuthCheckBox;

//    QLabel *mpUrlTestResultLabel;
//    QPushButton *mpTestConnectionButton;

//    QGroupBox *mpAppearanceGroupBox;
//    QCheckBox *mpMonochromeIconBox;
//    QCheckBox *mpNotificationsIconBox;
//    QCheckBox *mpShouldAnimateIconBox;

    QAction *mpConnectedState;
    QAction *mpNumberOfConnectionsAction;
    QAction *mpCurrentTrafficAction;
    QAction *mpTrafficInAction;
    QAction *mpTrafficOutAction;
//    QAction *mpShowWebViewAction;
    QAction *mpPreferencesAction;
    QAction *mpShowGitHubAction;
    QAction *mpQuitAction;

//    std::list<QSharedPointer<QAction>> mCurrentFoldersActions;
    QList<QObject *> mCurrentFoldersActions;
//    std::list<QSharedPointer<QAction>> mCurrentSyncedFilesActions;

    std::list<FolderNameFullPath> mCurrentFoldersLocations;
    LastSyncedFileList mLastSyncedFiles;

//    QSystemTrayIcon *mpTrayIcon = nullptr;
//    QMenu *mpTrayIconMenu = nullptr;
    QUrl mCurrentUrl;

    std::string mCurrentUserName;
    std::string mCurrentUserPassword;
    std::shared_ptr<qst::connector::SyncConnector> mpSyncConnector;
//    std::unique_ptr<mfk::monitor::ProcessMonitor> mpProcessMonitor;
//    std::unique_ptr<mfk::settings::StartupTab> mpStartupTab;
    QSettings mSettings;

//    std::unique_ptr<QMovie> mpAnimatedIconMovie;

//    bool mIconMonochrome;
//    bool mNotificationsEnabled;
//    bool mShouldAnimateIcon;
//    bool mShouldStopAnimation;
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
