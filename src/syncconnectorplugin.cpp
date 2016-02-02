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
    //    connect(mpSyncConnector.get(), &SyncConnector::onNetworkActivityChanged, this,
    //          &QQuickSyncConnector::onNetworkActivity);

    testUrl();
}

//------------------------------------------------------------------------------------//


QList<QObject *> QQuickSyncConnector::folders()
{
    QList<QObject *> foldersActions;
    if (mCurrentFoldersLocations.size() > 0 )
    {
//        mCurrentFoldersLocations = mpSyncConnector->getFolders();
        for (std::list<std::pair<std::string,
             std::string>>::iterator it=mCurrentFoldersLocations.begin();
             it != mCurrentFoldersLocations.end(); ++it)
        {
            foldersActions.append(new QFolderNameFullPath(tr(it->first.c_str()), tr(it->second.c_str())));
        }
//        mCurrentFoldersActions = foldersActions;
//        emit foldersChanged();
//        emit filesChanged();
    }
    return foldersActions;
}

//------------------------------------------------------------------------------------//

QList<QObject *> QQuickSyncConnector::files()
{
    QList<QObject *> syncedFilesActions;
    using namespace qst::utilities;
    if (mLastSyncedFiles.size() > 0)
    {
        for (LastSyncedFileList::iterator it=mLastSyncedFiles.begin();
             it != mLastSyncedFiles.end(); it++)
        {
            std::string curFile = getCleanFileName(std::get<2>(*it));
            syncedFilesActions.append(new QFolderNameFullPath(tr(curFile.c_str()), getFilePath(curFile), std::get<3>(*it)));
        }
    }
    return syncedFilesActions;
}

//------------------------------------------------------------------------------------//

QString QQuickSyncConnector::getFilePath(std::string findFile)
{
    using namespace qst::utilities;
    using namespace qst::sysutils;

    if (folders().length() > 0) {
      LastSyncedFileList::iterator fileIterator =
              std::find_if(mLastSyncedFiles.begin(), mLastSyncedFiles.end(),
                           [&findFile](DateFolderFile const& elem) {
              return getCleanFileName(std::get<2>(elem)) == findFile;
  });

      // get full path to folder
      std::list<FolderNameFullPath>::iterator folder =
              std::find_if(mCurrentFoldersLocations.begin(), mCurrentFoldersLocations.end(),
                           [&fileIterator](FolderNameFullPath const& elem) {
              return getFullCleanFileName(elem.first) == std::get<1>(*fileIterator);
  });
      std::string fullPath = folder->second + getPathToFileName(std::get<2>(*fileIterator))
              + SystemUtility().getPlatformDelimiter();
//      std::cout << "FineFile " << findFile << "Opening " << fullPath << std::endl;
//      QDesktopServices::openUrl(QUrl::fromLocalFile(tr(fullPath.c_str())));
      return tr(fullPath.c_str());
    }
    else return "";
}

//------------------------------------------------------------------------------------//

void QQuickSyncConnector::updateConnectionHealth(ConnectionHealthStatus status)
{
    if (status.at("state") == "1")
    {
        std::string activeConnections = status.at("activeConnections");
        std::string totalConnections = status.at("totalConnections");
        mpNumberOfConnectionsAction = (tr("Connections: ")
                                       + activeConnections.c_str()
                                       + "/" + totalConnections.c_str());
        emit numberOfConnectionsChanged();
        mpConnectedState = tr("Connected");
        emit statusChanged();
        mpCurrentTrafficAction = (tr("Total: ")
                                  + status.at("globalTraffic").c_str());
        mpTrafficInAction = (tr("In: ") + status.at("inTraffic").c_str());
        mpTrafficOutAction = (tr("Out: ") + status.at("outTraffic").c_str());
        emit trafficChanged();

        if (mCurrentFoldersLocations != mpSyncConnector->getFolders())
        {
            mCurrentFoldersLocations = mpSyncConnector->getFolders();
            emit foldersChanged();
        }

        if (mLastSyncedFiles != mpSyncConnector->getLastSyncedFiles())
        {
            mLastSyncedFiles = mpSyncConnector->getLastSyncedFiles();
            emit filesChanged();
        }
    }
    else
    {
        mpConnectedState = tr("Not Connected");
        emit statusChanged();
    }
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
            mpConnectedState = tr("Connected");
            emit statusChanged();
        }
        else
        {
            mpConnectedState = (tr("Status: ") + result.first.c_str());
            emit statusChanged();
        }
    });
    saveSettings();
}

//------------------------------------------------------------------------------------//

void QQuickSyncConnector::createActions()
{
    mpConnectedState = tr("Not Connected");
    emit statusChanged();

    mpNumberOfConnectionsAction = tr("Connections: 0");
    emit numberOfConnectionsChanged();

    mpCurrentTrafficAction = tr("Total: 0.00 KB/s");
    mpTrafficInAction = tr("In: 0 KB/s");
    mpTrafficOutAction = tr("Out: 0 KB/s");
    emit trafficChanged();
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

void QQuickSyncConnector::createDefaultSettings()
{
    mSettings.setValue("url", tr("http://127.0.0.1:8384"));
    mSettings.setValue("startStopWithWifi", true);
    mSettings.setValue("doSettingsExist", true);
}

