#!/usr/bin/env python
# -*- coding: utf-8 -*-

'''
Created on 14.04.2012

@author: Prapor
'''
import socket
import mZipArchiveFolder
import mFiltrationRules
import mCheckingObjects
import mProcessObjects
import mEqualingObjects
import mArchiveFileNamePerformance

import os

class Sample_ZipAllSofwareProjectsSourceFolder(object):
    """
    """
    def __init__(self, pVersion, pBasePath, pLogFilePath):
        """
        """
        pSofwareName = u"ALL"
        dir_arch = mArchiveFileNamePerformance.SourceDirBackup_ArchiveDirectoryPerformance ( 
                                                            pSofwareName,
                                                            pBasePath,
                                                             ) 
    
        self.__ArchiveNamingObject = mArchiveFileNamePerformance.SourceDirBackup_ArchiveFileNamePerformance( 
                                                           dir_arch,
                                                           u"GENERAL", 
                                                           pVersion,
                                                           pComputerID = socket.gethostname()
                                                           )
        self.__ArchiveNamingObject.archive_file_extention = u"zip"
        
        pFileFiltrationRules = mFiltrationRules.File_FiltrationRules()
        pDirectoryFiltrationRules = mFiltrationRules.Directory_FiltrationRules()

        self.__ZipArchiveFolder = mZipArchiveFolder.ZipArchiveFolder(
                                                                     self.__ArchiveNamingObject,
                                                                     pFileFiltrationRules,
                                                                     pDirectoryFiltrationRules
                                                                     )
    
#Объект не совпадения
        pNotEq = mEqualingObjects.NotEq_EqualingObject()
#Объект совпадения
#        pEq = mEqualingObjects.Eq_EqualingObject()
    
        #Обрабатываются только директории
        pDirProcessObject = mProcessObjects.DirectoryObject()
        #Обрабатываются только файлы
        #pFileProcessObject = mProcessObjects.FileObject()

        
        #выкидываем директории bin
        #pFiltrationRules.AddingCheckingObject(mCheckingObjects.RegEx_CheckingObject (pDirProcessObject, pNotEq, ur"bin"))#ur".+[\\/]bin[\\/]?.*"))
        
        #выкидываем директории ipch
        pDirectoryFiltrationRules.AddingCheckingObject(
            mCheckingObjects.Name_CheckingObject (pDirProcessObject, pNotEq, u"ipch"))#ur".+[\\/]ipch[\\/]?.*"))
        
        pFileFiltrationRules.AddingCheckingObject(mCheckingObjects.FileExtention_CheckingObject(pNotEq, u"sdf"))
        pFileFiltrationRules.AddingCheckingObject(mCheckingObjects.FileExtention_CheckingObject(pNotEq, u"suo"))
        pFileFiltrationRules.AddingCheckingObject(mCheckingObjects.FileExtention_CheckingObject(pNotEq, u"aps"))
        pFileFiltrationRules.AddingCheckingObject(mCheckingObjects.FileExtention_CheckingObject(pNotEq, u"opensdf"))
        
        #Архивируем GENERAL
        self.__ZipArchiveFolder.WalkThrueFileTree(u"d:\\Programming\\RusCrypto\\RusCrypto_1.2\\PROJECT\\GENERAL\\Src\\")
        self.__ZipArchiveFolder.WalkThrueFileTree(u"d:\\Programming\\RusCrypto\\RusCrypto_1.2\\PROJECT\\GENERAL\\Test\\")
            
        #Архивируем nasm
        self.__ZipArchiveFolder.AddingToArchive(u"d:\\Programming\\RusCrypto\\RusCrypto_1.2\\PROJECT\\GENERAL\\Bin\\ExtraBinaries\\nasm.exe")

        #Архивируем PLUGINS
        self.__ArchiveNamingObject.software_name = u"PLUGINS"
        self.__ZipArchiveFolder = mZipArchiveFolder.ZipArchiveFolder(
                                                                     self.__ArchiveNamingObject,
                                                                     pFileFiltrationRules,
                                                                     pDirectoryFiltrationRules
                                                                     )
        self.__ZipArchiveFolder.WalkThrueFileTree(u"d:\\Programming\\RusCrypto\\RusCrypto_1.2\\PROJECT\\PLUGINS\\Src\\")
        self.__ZipArchiveFolder.WalkThrueFileTree(u"d:\\Programming\\RusCrypto\\RusCrypto_1.2\\PROJECT\\PLUGINS\\Test\\")

        #Архивируем INSTALLATION
        self.__ArchiveNamingObject.software_name = u"INSTALLATION"
        self.__ZipArchiveFolder = mZipArchiveFolder.ZipArchiveFolder(
                                                                     self.__ArchiveNamingObject,
                                                                     pFileFiltrationRules,
                                                                     pDirectoryFiltrationRules
                                                                     )

        self.__ZipArchiveFolder = mZipArchiveFolder.ZipArchiveFolder(
                                                                     self.__ArchiveNamingObject,
                                                                     pFileFiltrationRules,
                                                                     pDirectoryFiltrationRules
                                                                     )
        pDirectoryFiltrationRules.AddingCheckingObject(
            mCheckingObjects.Name_CheckingObject (pDirProcessObject, pNotEq, u"obj"))#ur".+[\\/]ipch[\\/]?.*"))
        self.__ZipArchiveFolder.WalkThrueFileTree(u"d:\\Programming\\RusCrypto\\RusCrypto_1.2\\PROJECT\\INSTALLATION\\Src\\")
        self.__ZipArchiveFolder.WalkThrueFileTree(u"d:\\Programming\\RusCrypto\\RusCrypto_1.2\\PROJECT\\INSTALLATION\\Test\\")
        
        #Архивируем SCRIPTS
        self.__ArchiveNamingObject.software_name = u"SCRIPTS"
        self.__ZipArchiveFolder = mZipArchiveFolder.ZipArchiveFolder(
                                                                     self.__ArchiveNamingObject,
                                                                     pFileFiltrationRules,
                                                                     pDirectoryFiltrationRules
                                                                     )

        pFileFiltrationRules.AddingCheckingObject(mCheckingObjects.FileExtention_CheckingObject(pNotEq, u"pyc"))
        self.__ZipArchiveFolder.WalkThrueFileTree(u"d:\\Programming\\RusCrypto\\RusCrypto_1.2\\PROJECT\\SCRIPTS\\")

    @property
    def archive_name_object(self):
        return self.__ArchiveNamingObject
     
    @property
    def zip_archive_object(self):
        return self.__ZipArchiveFolder

class Sample_ZipAllSofwareProjectsInOneArchiveFile(object):
    """
    """
    def __init__(self, pVersion, pBasePath, pLogFilePath):
        """
        """
        pSofwareName = u"PROJECT"
        dir_arch = mArchiveFileNamePerformance.SourceDirBackup_ArchiveDirectoryPerformance ( 
                                                            pSofwareName,
                                                            os.path.join(pBasePath,u"BACKUP"),    
                                                             ) 
    
        self.__ArchiveNamingObject = mArchiveFileNamePerformance.SourceDirBackup_ArchiveFileNamePerformance( 
                                                           dir_arch,
                                                           pSofwareName, 
                                                           pVersion,
                                                           pComputerID = socket.gethostname()
                                                           )
        self.__ArchiveNamingObject.archive_file_extention = u"zip"
        
        pFileFiltrationRules = mFiltrationRules.File_FiltrationRules()
        pDirectoryFiltrationRules = mFiltrationRules.Directory_FiltrationRules()

        self.__ZipArchiveFolder = mZipArchiveFolder.ZipArchiveFolder(
                                                                     self.__ArchiveNamingObject,
                                                                     pFileFiltrationRules,
                                                                     pDirectoryFiltrationRules
                                                                     )
    
#Объект не совпадения
        pNotEq = mEqualingObjects.NotEq_EqualingObject()
#Объект совпадения
#        pEq = mEqualingObjects.Eq_EqualingObject()
    
        #Обрабатываются только директории
        pDirProcessObject = mProcessObjects.DirectoryObject()
        #Обрабатываются только файлы
        #pFileProcessObject = mProcessObjects.FileObject()

        
        #выкидываем директории bin
        #pFiltrationRules.AddingCheckingObject(mCheckingObjects.RegEx_CheckingObject (pDirProcessObject, pNotEq, ur"bin"))#ur".+[\\/]bin[\\/]?.*"))
        
        #выкидываем директории ipch
        pDirectoryFiltrationRules.AddingCheckingObject(
            mCheckingObjects.Name_CheckingObject (pDirProcessObject, pNotEq, u"ipch"))#ur".+[\\/]ipch[\\/]?.*"))
        
        pFileFiltrationRules.AddingCheckingObject(mCheckingObjects.FileExtention_CheckingObject(pNotEq, u"sdf"))
        pFileFiltrationRules.AddingCheckingObject(mCheckingObjects.FileExtention_CheckingObject(pNotEq, u"opensdf"))
        pFileFiltrationRules.AddingCheckingObject(mCheckingObjects.FileExtention_CheckingObject(pNotEq, u"suo"))
        pFileFiltrationRules.AddingCheckingObject(mCheckingObjects.FileExtention_CheckingObject(pNotEq, u"aps"))
        pFileFiltrationRules.AddingCheckingObject(mCheckingObjects.FileExtention_CheckingObject(pNotEq, u"clw"))
        
        strSrc = u"Src"
        strTest = u"Test"
       
	#Архивируем GENERAL
        strGENERAlfolder = os.path.join(pBasePath,u"GENERAL")
        try:
            self.__ZipArchiveFolder.WalkThrueFileTree( os.path.join( strGENERAlfolder,strSrc) ) #u"d:\\Programming\\RusCrypto\\RusCrypto_1.2\\PROJECT\\GENERAL\\Src\\"
            self.__ZipArchiveFolder.WalkThrueFileTree( os.path.join( strGENERAlfolder,strTest) ) #u"d:\\Programming\\RusCrypto\\RusCrypto_1.2\\PROJECT\\GENERAL\\Test\\"
        except OSError as ex :
            print ex
        
        #Архивируем nasm
        self.__ZipArchiveFolder.AddingToArchive( os.path.join( strGENERAlfolder, u"Bin\\ExtraBinaries\\nasm.exe" ) ) #u"d:\\Programming\\RusCrypto\\RusCrypto_1.2\\PROJECT\\GENERAL\\Bin\\ExtraBinaries\\nasm.exe"

        #Архивируем PLUGINS
        strPLUGINSfolder = os.path.join(pBasePath,u"PLUGINS")
        try:
            self.__ZipArchiveFolder.WalkThrueFileTree( os.path.join( strPLUGINSfolder,strSrc) ) #u"d:\\Programming\\RusCrypto\\RusCrypto_1.2\\PROJECT\\PLUGINS\\Src\\"
            self.__ZipArchiveFolder.WalkThrueFileTree( os.path.join( strPLUGINSfolder,strTest) ) #u"d:\\Programming\\RusCrypto\\RusCrypto_1.2\\PROJECT\\PLUGINS\\Test\\"
        except OSError as ex :
            print ex
        
        #Архивируем PATCHS
        strPATCHSfolder = os.path.join(pBasePath,u"PATCHS")
        try:
            self.__ZipArchiveFolder.WalkThrueFileTree( os.path.join( strPATCHSfolder,strSrc) ) #u"d:\\Programming\\RusCrypto\\RusCrypto_1.2\\PROJECT\\PATCHS\\Src\\"
            self.__ZipArchiveFolder.WalkThrueFileTree( os.path.join( strPATCHSfolder,strTest) ) #u"d:\\Programming\\RusCrypto\\RusCrypto_1.2\\PROJECT\\PATCHS\\Test\\"
        #Архивируем ExtraBinares
            self.__ZipArchiveFolder.WalkThrueFileTree( os.path.join( strPATCHSfolder,u"Bin\\ExtraBinaries") ) #u"d:\\Programming\\RusCrypto\\RusCrypto_1.2\\PROJECT\\PATCHS\\Bin\\ExtraBinaries\\"
        except OSError as ex :
            print ex

        #Архивируем DRIVERS
        strDRIVERSfolder = os.path.join(pBasePath,u"DRIVERS\\PATCHING")
        try:
            self.__ZipArchiveFolder.AddingToArchive( os.path.join( strDRIVERSfolder, u"Bin" ) )
            self.__ZipArchiveFolder.AddingToArchive( os.path.join( strDRIVERSfolder, strTest ) )

            strDRIVERSfolder = os.path.join(strDRIVERSfolder,strSrc)
        
            self.__ZipArchiveFolder.AddingToArchive( os.path.join( strDRIVERSfolder, u"PATCHING.sln" ) )
       
        
            strDRIVERSfolder = os.path.join(strDRIVERSfolder,u"inject")
            self.__ZipArchiveFolder.AddingToArchive( os.path.join( strDRIVERSfolder, u"cut.cc" ) )
            self.__ZipArchiveFolder.AddingToArchive( os.path.join( strDRIVERSfolder, u"ddkbuild.bat" ) )
            self.__ZipArchiveFolder.AddingToArchive( os.path.join( strDRIVERSfolder, u"dirs" ) )
            self.__ZipArchiveFolder.AddingToArchive( os.path.join( strDRIVERSfolder, u"inject.sln" ) )
            self.__ZipArchiveFolder.AddingToArchive( os.path.join( strDRIVERSfolder, u"readme.txt" ) )
        
        #Директорию inc
            self.__ZipArchiveFolder.WalkThrueFileTree( os.path.join( strDRIVERSfolder,u"inc") )
        
        #Проект dll
            strDLLproject = os.path.join(strDRIVERSfolder,u"dll")
            self.__ZipArchiveFolder.AddingToArchive( os.path.join( strDLLproject, u"dll.vcxproj" ) )
            self.__ZipArchiveFolder.AddingToArchive( os.path.join( strDLLproject, u"dll.vcxproj.filters" ) )
            self.__ZipArchiveFolder.AddingToArchive( os.path.join( strDLLproject, u"dll.vcxproj.user" ) )
            self.__ZipArchiveFolder.AddingToArchive( os.path.join( strDLLproject, u"inject.cpp" ) )
            self.__ZipArchiveFolder.AddingToArchive( os.path.join( strDLLproject, u"inject.def" ) )
            self.__ZipArchiveFolder.AddingToArchive( os.path.join( strDLLproject, u"MAKEFILE" ) )
            self.__ZipArchiveFolder.AddingToArchive( os.path.join( strDLLproject, u"sources" ) )
        
        #Проект drv
            strDRVproject = os.path.join(strDRIVERSfolder,u"drv")
            self.__ZipArchiveFolder.AddingToArchive( os.path.join( strDRVproject, u"drv.vcxproj" ) )
            self.__ZipArchiveFolder.AddingToArchive( os.path.join( strDRVproject, u"drv.vcxproj.filters" ) )
            self.__ZipArchiveFolder.AddingToArchive( os.path.join( strDRVproject, u"drv.vcxproj.user" ) )
            self.__ZipArchiveFolder.AddingToArchive( os.path.join( strDRVproject, u"inject.c" ) )
            self.__ZipArchiveFolder.AddingToArchive( os.path.join( strDRVproject, u"inject.h" ) )
            self.__ZipArchiveFolder.AddingToArchive( os.path.join( strDRVproject, u"inject.inf" ) )
            self.__ZipArchiveFolder.AddingToArchive( os.path.join( strDRVproject, u"loader.c" ) )
            self.__ZipArchiveFolder.AddingToArchive( os.path.join( strDRVproject, u"makefile" ) )
            self.__ZipArchiveFolder.AddingToArchive( os.path.join( strDRVproject, u"pe.c" ) )
            self.__ZipArchiveFolder.AddingToArchive( os.path.join( strDRVproject, u"sources" ) )
            self.__ZipArchiveFolder.AddingToArchive( os.path.join( strDRVproject, u"inject.reg" ) )
            self.__ZipArchiveFolder.AddingToArchive( os.path.join( strDRVproject, u"inject.install" ) )

        #Проект thunk 
            strTHUNKproject = os.path.join(strDRIVERSfolder,u"thunk")
            self.__ZipArchiveFolder.AddingToArchive( os.path.join( strTHUNKproject, u"thunk.vcxproj" ) )
            self.__ZipArchiveFolder.AddingToArchive( os.path.join( strTHUNKproject, u"thunk.vcxproj.filters" ) )
            self.__ZipArchiveFolder.AddingToArchive( os.path.join( strTHUNKproject, u"thunk.vcxproj.user" ) )
            self.__ZipArchiveFolder.AddingToArchive( os.path.join( strTHUNKproject, u"thunk.c" ) )
            self.__ZipArchiveFolder.AddingToArchive( os.path.join( strTHUNKproject, u"thunk.def" ) )
            self.__ZipArchiveFolder.AddingToArchive( os.path.join( strTHUNKproject, u"MAKEFILE" ) )
            self.__ZipArchiveFolder.AddingToArchive( os.path.join( strTHUNKproject, u"sources" ) )

        except OSError as ex :
            print ex

                
        #Архивируем INSTALLATION
        strINSTALLATIONfolder = os.path.join(pBasePath,u"INSTALLATION")
        
        pDirectoryFiltrationRules.AddingCheckingObject(
            mCheckingObjects.Name_CheckingObject (pDirProcessObject, pNotEq, u"obj"))
        try:
            self.__ZipArchiveFolder.WalkThrueFileTree( os.path.join( strINSTALLATIONfolder,strSrc) ) #u"d:\\Programming\\RusCrypto\\RusCrypto_1.2\\PROJECT\\INSTALLATION\\Src\\"
            self.__ZipArchiveFolder.WalkThrueFileTree( os.path.join( strINSTALLATIONfolder,strTest) ) #u"d:\\Programming\\RusCrypto\\RusCrypto_1.2\\PROJECT\\INSTALLATION\\Test\\"
        except OSError as ex :
            print ex

        #Архивируем SCRIPTS
        strSCRIPTSfolder = os.path.join(pBasePath,u"SCRIPTS")
        
        pFileFiltrationRules.AddingCheckingObject(mCheckingObjects.FileExtention_CheckingObject(pNotEq, u"pyc"))
        pFileFiltrationRules.AddingCheckingObject(mCheckingObjects.FileExtention_CheckingObject(pNotEq, u"log"))
        #pFileFiltrationRules.AddingCheckingObject(mCheckingObjects.FileExtention_CheckingObject(mEqualingObjects.Eq_EqualingObject(), u"py"))
        #pFileFiltrationRules.AddingCheckingObject(mCheckingObjects.FileExtention_CheckingObject(mEqualingObjects.Eq_EqualingObject(), u"bat"))
        try:
            self.__ZipArchiveFolder.WalkThrueFileTree( strSCRIPTSfolder ) #u"d:\\Programming\\RusCrypto\\RusCrypto_1.2\\PROJECT\\SCRIPTS\\")
        except OSError as ex :
            print ex

	#Архивируем TEST
        strTESTfolder = os.path.join(pBasePath,u"TEST")
        try:
            self.__ZipArchiveFolder.WalkThrueFileTree( strTESTfolder )
        except OSError as ex :
            print ex

        
    @property
    def archive_name_object(self):
        return self.__ArchiveNamingObject
     
    @property
    def zip_archive_object(self):
        return self.__ZipArchiveFolder
     
if __name__ == "__main__":
    """
    """
    strBackupFolder = os.getcwdu()
    
    strBackupFolder = os.path.join(strBackupFolder, u"../../../../..\\") #u"d:\\Programming\\RusCrypto\\RusCrypto_1.2"
    strBackupFolder = os.path.normpath(strBackupFolder)
    #print strBackupFolder
    
    #закатываем в отдельные файлы
    #pSample_ZipAllSofwareProjectsSourceFolder = Sample_ZipAllSofwareProjectsSourceFolder(
    #                                                 u"1_2", 
    #                                                 u"d:\\Programming\\RusCrypto\\RusCrypto_1.2\\PROJECT\\BACKUPING\\", 
    #                                                 u"log.log" ) 


    #закатываем в один файл
    pSample_ZipAllSofwareProjectsSourceFolder = Sample_ZipAllSofwareProjectsInOneArchiveFile(
                                                     u"1.9.5", 
                                                     strBackupFolder, #u"d:\\Programming\\RusCrypto\\RusCrypto_1.2\\PROJECT\\BACKUP\\", 
                                                     u"log.log" ) 
