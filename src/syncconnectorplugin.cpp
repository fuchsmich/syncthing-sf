#include <QDebug>

#include "syncconnectorplugin.h"


SyncConnectorPlugin::SyncConnectorPlugin(QObject *parent) : QObject(parent)
{

}

//------------------------------------------------------------------------------------//
//------------------------------------------------------------------------------------//

QQuickSyncConnector::QQuickSyncConnector(QObject *parent)
    : QObject(parent),
      mpSyncConnector(new qst::connector::SyncConnector(QUrl(tr("http://127.0.0.1:8384"))))
    , mSettings("fuxl", "QSyncthingTray")

{
    loadSettings();

    createActions();

//    mpSyncConnector->setConnectionHealthCallback(std::bind(
//      &QQuickSyncConnector::updateConnectionHealth,
//      this,
//      std::placeholders::_1));
//    mpSyncConnector->setNetworkActivityCallback(std::bind(
//      &QQuickSyncConnector::onNetworkActivity,
//      this,
//      std::placeholders::_1));
    // Setup SyncthingConnector
    using namespace qst::connector;
    connect(mpSyncConnector.get(), &SyncConnector::onConnectionHealthChanged, this,
      &QQuickSyncConnector::updateConnectionHealth);
    connect(mpSyncConnector.get(), &SyncConnector::onNetworkActivityChanged, this,
          &QQuickSyncConnector::onNetworkActivity);

    testUrl();

//    mpStartupTab->spawnSyncthingApp(); ->
//    mpSyncConnector->spawnSyncthingProcess(mCurrentSyncthingPath, mShouldLaunchSyncthing);
}

//------------------------------------------------------------------------------------//

QList<QObject *> QQuickSyncConnector::files()
{
//    qDebug() << "Reading Files";
    QList<QObject *> syncedFilesActions;
    using namespace qst::utilities;
    if (mLastSyncedFiles.size() > 0)
    {
//      std::list<QSharedPointer<QAction>> syncedFilesActions;
      for (LastSyncedFileList::iterator it=mLastSyncedFiles.begin();
           it != mLastSyncedFiles.end(); ++it)
      {
//        QSharedPointer<QAction> aAction = QSharedPointer<QAction>(
//          new QAction(tr(getCleanFileName(std::get<2>(*it)).c_str()), this));

        // 4th item of tuple is file-erased-bool
//TODO        aAction->setDisabled(std::get<3>(*it));
//        connect(aAction.data(), SIGNAL(triggered()), this, SLOT(syncedFileClicked()));
        syncedFilesActions.append(new QFolderNameFullPath(tr(getCleanFileName(std::get<2>(*it)).c_str()),""));
      }
    }
    // Update Menu
    return syncedFilesActions;
//    createTrayIcon();
}

//------------------------------------------------------------------------------------//

void QQuickSyncConnector::updateConnectionHealth(ConnectionHealthStatus status)
{
//    if (mpProcessMonitor->isPausingProcessRunning())
//    {
//      mpNumberOfConnectionsAction->setVisible(false);
//      mpConnectedState->setText(tr("Paused"));
//      if (mLastConnectionState != 99)
//      {
//        showMessage("Paused", "Syncthing is pausing.");
//        setIcon(1);
//        mLastConnectionState = 99;
//      }
//      return;
//    }
//    else
    if (status.at("state") == "1")
    {
      std::string activeConnections = status.at("activeConnections");
      std::string totalConnections = status.at("totalConnections");
      mpNumberOfConnectionsAction->setVisible(true);
      mpNumberOfConnectionsAction->setText(tr("Connections: ")
        + activeConnections.c_str()
        + "/" + totalConnections.c_str());
      emit numberOfConnectionsChanged();
      mpConnectedState->setText(tr("Connected"));
      statusChanged();
      mpCurrentTrafficAction->setText(tr("Total: ")
        + status.at("globalTraffic").c_str());
      mpTrafficInAction->setText(tr("In: ") + status.at("inTraffic").c_str());
      mpTrafficOutAction->setText(tr("Out: ") + status.at("outTraffic").c_str());
      trafficChanged();

      if (mLastSyncedFiles != mpSyncConnector->getLastSyncedFiles())
      {
        mLastSyncedFiles = mpSyncConnector->getLastSyncedFiles();
//        createLastSyncedMenu();
        emit filesChanged();
      }
//      setIcon(0);
//      if (mLastConnectionState != 1)
//      {
//          Könnte man über Notifications ausgeben
//        showMessage("Connected", "Syncthing is running.");
//      }
    }
    else
    {
      mpConnectedState->setText(tr("Not Connected"));
      statusChanged();
//      if (mLastConnectionState != 0)
//      {
//        showMessage("Not Connected", "Could not find Syncthing.");
//      }
      // syncthing takes a while to shut down, in case someone
      // would reopen qsyncthingtray it wouldnt restart the process
//      mpStartupTab->spawnSyncthingApp();
//      setIcon(1);
    }
//    try
//    {
//      mLastConnectionState = std::stoi(status.at("state"));
//    }
//    catch (std::exception &e)
//    {
//      std::cerr << "Unable to get current Connection Status!" << std::endl;
//    }
    createFoldersMenu();
}

//------------------------------------------------------------------------------------//
void QQuickSyncConnector::onNetworkActivity(bool activity)
{

}

//------------------------------------------------------------------------------------//

void QQuickSyncConnector::testUrl()
{
//    std::string validateUrl = mpSyncthingUrlLineEdit->text().toStdString();
//    std::size_t foundSSL = validateUrl.find("https");
//    if (foundSSL!=std::string::npos)
//    {
//      validateSSLSupport();
//    }
//    mCurrentUrl = QUrl(mpSyncthingUrlLineEdit->text());
//    mCurrentUserName = mpUserNameLineEdit->text().toStdString();
//    mCurrentUserPassword = userPassword->text().toStdString();
    mpSyncConnector->setURL(mCurrentUrl, mCurrentUserName,
       mCurrentUserPassword, [&](std::pair<std::string, bool> result)
    {
      if (result.second)
      {
//        mpUrlTestResultLabel->setText(tr("Status: Connected"));
        mpConnectedState->setText(tr("Connected"));
        emit statusChanged();
//        setIcon(0);
      }
      else
      {
          mpConnectedState->setText(tr("Status: ") + result.first.c_str());
          emit statusChanged();
//        mpUrlTestResultLabel->setText(tr("Status: ") + result.first.c_str());
//        setIcon(1);
      }
    });
    saveSettings();
}

//------------------------------------------------------------------------------------//

void QQuickSyncConnector::pauseSyncthingClicked(int state)
{
//    qDebug() << "pause " << state;
    mpSyncConnector->pauseSyncthing(state == 1);
}

//------------------------------------------------------------------------------------//

void QQuickSyncConnector::createActions()
{

    //TODO Actions mit signale mit verbinden
    mpConnectedState = new QAction(tr("Not Connected"), this);
    mpConnectedState->setDisabled(true);

    mpNumberOfConnectionsAction = new QAction(tr("Connections: 0"), this);
    mpNumberOfConnectionsAction->setDisabled(true);

    mpCurrentTrafficAction = new QAction(tr("Total: 0.00 KB/s"), this);
    mpTrafficInAction = new QAction(tr("In: 0 KB/s"), this);
    mpTrafficOutAction = new QAction(tr("Out: 0 KB/s"), this);

//    mpShowWebViewAction = new QAction(tr("Open Syncthing"), this);
//    connect(mpShowWebViewAction, SIGNAL(triggered()), this, SLOT(showWebView()));

//    mpPreferencesAction = new QAction(tr("Preferences"), this);
//    connect(mpPreferencesAction, SIGNAL(triggered()), this, SLOT(showNormal()));

//    mpShowGitHubAction = new QAction(tr("Help"), this);
//    connect(mpShowGitHubAction, SIGNAL(triggered()), this, SLOT(showGitPage()));

//    mpQuitAction = new QAction(tr("&Quit"), this);
//    connect(mpQuitAction, SIGNAL(triggered()), qApp, SLOT(quit()));
}

//------------------------------------------------------------------------------------//

void QQuickSyncConnector::saveSettings()
{
    mSettings.setValue("url", mCurrentUrl.toString());
    mSettings.setValue("username", "");
    mSettings.setValue("userpassword", "");
//    mSettings.setValue("monochromeIcon", mIconMonochrome);
//    mSettings.setValue("notificationsEnabled", mNotificationsEnabled);
//    mSettings.setValue("animationEnabled", mShouldAnimateIcon);
}

//------------------------------------------------------------------------------------//

void QQuickSyncConnector::loadSettings()
{
    if (!mSettings.value("doSettingsExist").toBool())
    {
      createDefaultSettings();
    }

    setGuiUrl(mSettings.value("url").toString());
    if (mCurrentUrl.toString().length() == 0)
    {
      setGuiUrl(tr("http://127.0.0.1:8384"));
    }
    mCurrentUserPassword = mSettings.value("userpassword").toString().toStdString();
    mCurrentUserName = mSettings.value("username").toString().toStdString();
//    mIconMonochrome = mSettings.value("monochromeIcon").toBool();
//    mNotificationsEnabled = mSettings.value("notificationsEnabled").toBool();
    //    mShouldAnimateIcon = mSettings.value("animationEnabled").toBool();
}

//------------------------------------------------------------------------------------//

void QQuickSyncConnector::createFoldersMenu()
{
//    std::list<QSharedPointer<QAction>> foldersActions;
    QList<QObject *> foldersActions;
    if (mCurrentFoldersLocations != mpSyncConnector->getFolders())
    {
      mCurrentFoldersLocations = mpSyncConnector->getFolders();
      for (std::list<std::pair<std::string,
        std::string>>::iterator it=mCurrentFoldersLocations.begin();
        it != mCurrentFoldersLocations.end(); ++it)
      {
//        QSharedPointer<QAction> aAction = QSharedPointer<QAction>(
//          new QAction(tr(it->first.c_str()), this));
//        connect(aAction.data(), SIGNAL(triggered()), this, SLOT(folderClicked()));
//        foldersActions.emplace_back(aAction);
          foldersActions.append(new QFolderNameFullPath(tr(it->first.c_str()), tr(it->second.c_str())));
      }
      mCurrentFoldersActions = foldersActions;
      // Update Menu
//      createTrayIcon();
      foldersChanged();
    }
}

//------------------------------------------------------------------------------------//

void QQuickSyncConnector::createDefaultSettings()
{
    mSettings.setValue("url", tr("http://127.0.0.1:8384"));
//    mSettings.setValue("monochromeIcon", false);
//    mSettings.setValue("notificationsEnabled", true);
    mSettings.setValue("doSettingsExist", true);
    mSettings.setValue("launchSyncthingAtStartup", false);
//    mSettings.setValue("animationEnabled", false);
}

