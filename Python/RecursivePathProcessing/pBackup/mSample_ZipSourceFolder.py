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


class Sample_ZipSourceFolder(object):
    """
    """
    def __init__(self, pVersion, pSofwareName, pBasePath, pLogFilePath):
        """
        """
        dir_arch = mArchiveFileNamePerformance.SourceDirBackup_ArchiveDirectoryPerformance ( 
                                                            pSofwareName,
                                                            pBasePath,
                                                             ) 
    
        self.__ArchiveNamingObject = mArchiveFileNamePerformance.SourceDirBackup_ArchiveFileNamePerformance( 
                                                           dir_arch,
                                                           dir_arch.software_name, 
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

    
    @property
    def archive_name_object(self):
        return self.__ArchiveNamingObject
     
    @property
    def zip_archive_object(self):
        return self.__ZipArchiveFolder
     
if __name__ == "__main__":
    """
    """
    pSample_ZipSourceFolder = Sample_ZipSourceFolder(
                                                     u"1_0", 
                                                     u"GENERAL",
                                                     u"d:\\Programming\\RusCrypto\\RusCrypto_1.2\\PROJECT\\BACKUPING\\", 
                                                     u"log.log" )
    #pSample_ZipSourceFolder._Sample_ZipSourceFolder__ZipArchiveFolder.WalkThrueFileTree()
    pSample_ZipSourceFolder.zip_archive_object.WalkThrueFileTree(u"d:\\Programming\\RusCrypto\\RusCrypto_1.2\\PROJECT\\GENERAL\\Src\\")
    
    #Архивируем nasm
    
    #pSample_ZipSourceFolder.zip_archive_object.search_folder = os.path.join(pSample_ZipSourceFolder.zip_archive_object.search_folder,u"") 
    pSample_ZipSourceFolder.zip_archive_object.AddingToArchive(u"d:\\Programming\\RusCrypto\\RusCrypto_1.2\\PROJECT\\GENERAL\\Bin\\ExtraBinaries\\nasm.exe")
    
    
