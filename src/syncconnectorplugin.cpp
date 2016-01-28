#include <QDebug>

#include "syncconnectorplugin.h"


SyncConnectorPlugin::SyncConnectorPlugin(QObject *parent) : QObject(parent)
{

}

//------------------------------------------------------------------------------------//
//------------------------------------------------------------------------------------//

QQuickSyncConnector::QQuickSyncConnector(QObject *parent)
    : QObject(parent)
    , mpSyncConnector(new qst::connector::SyncConnector(QUrl(tr("http://127.0.0.1:8384"))))
    , mSettings("fuxl", "QSyncthingTray")
    , mSettingsLoaded(false)

{
    loadSettings();

    createActions();

    // Setup SyncthingConnector
    using namespace qst::connector;
    connect(mpSyncConnector.get(), &SyncConnector::onConnectionHealthChanged, this,
      &QQuickSyncConnector::updateConnectionHealth);
    connect(mpSyncConnector.get(), &SyncConnector::onNetworkActivityChanged, this,
          &QQuickSyncConnector::onNetworkActivity);

    testUrl();
}

//------------------------------------------------------------------------------------//

QList<QObject *> QQuickSyncConnector::files()
{
    QList<QObject *> syncedFilesActions;
    using namespace qst::utilities;
    if (mLastSyncedFiles.size() > 0)
    {
      for (LastSyncedFileList::iterator it=mLastSyncedFiles.begin();
           it != mLastSyncedFiles.end(); ++it)
      {
        syncedFilesActions.append(new QFolderNameFullPath(tr(getCleanFileName(std::get<2>(*it)).c_str()),""));
      }
    }
    return syncedFilesActions;
}

//------------------------------------------------------------------------------------//

void QQuickSyncConnector::updateConnectionHealth(ConnectionHealthStatus status)
{
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
        emit filesChanged();
      }
    }
    else
    {
      mpConnectedState->setText(tr("Not Connected"));
      statusChanged();
    }
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

}

//------------------------------------------------------------------------------------//

void QQuickSyncConnector::saveSettings()
{
    if (mSettingsLoaded) {
        mSettings.setValue("url", mCurrentUrl.toString());
        mSettings.setValue("username", "");
        mSettings.setValue("userpassword", "");
        mSettings.setValue("startStopWithWifi", mStartStopWithWifi);
    }
}

//------------------------------------------------------------------------------------//

void QQuickSyncConnector::loadSettings()
{
    mSettingsLoaded = false;
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
    mStartStopWithWifi = mSettings.value("startStopWithWifi").toBool();
    mSettingsLoaded = true;
}

//------------------------------------------------------------------------------------//

void QQuickSyncConnector::createFoldersMenu()
{
    QList<QObject *> foldersActions;
    if (mCurrentFoldersLocations != mpSyncConnector->getFolders())
    {
      mCurrentFoldersLocations = mpSyncConnector->getFolders();
      for (std::list<std::pair<std::string,
        std::string>>::iterator it=mCurrentFoldersLocations.begin();
        it != mCurrentFoldersLocations.end(); ++it)
      {
          foldersActions.append(new QFolderNameFullPath(tr(it->first.c_str()), tr(it->second.c_str())));
      }
      mCurrentFoldersActions = foldersActions;
      emit foldersChanged();
    }
}

//------------------------------------------------------------------------------------//

void QQuickSyncConnector::createDefaultSettings()
{
    mSettings.setValue("url", tr("http://127.0.0.1:8384"));
    mSettings.setValue("startStopWithWifi", true);
    mSettings.setValue("doSettingsExist", true);
}

