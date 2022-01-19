#!/usr/bin/env python
# -*- coding: utf-8 -*-

import mRecursiveProcessFilesTree
#import mBackup

import os
import zipfile
import mArchiveFileNamePerformance

class ZipArchiveFolder(mRecursiveProcessFilesTree.RecursiveProcessFilesTree):
    """
    """
    
    def __init__( self, cNameArchive, cFile_FiltrationRules, cDirectory_FiltrationRules, cPath_FiltrationRules = None):
        """
        """
        super(ZipArchiveFolder, self).__init__( cFile_FiltrationRules, cDirectory_FiltrationRules, cPath_FiltrationRules )
        
        if isinstance(cNameArchive, mArchiveFileNamePerformance.ArchiveFileNamePerformance) :
            self.__NameArchive = cNameArchive
            self.__NameArchive.archive_file_extention = u"zip"
            try :
                os.makedirs(self.__NameArchive.archive_directory_path)
            except OSError:
                pass
            self.__ZipObject = zipfile.ZipFile(self.__NameArchive.archive_full_file_path, 'w', zipfile.ZIP_DEFLATED)
            #os.chdir(pSearhFolder)
        else :
            raise TypeError( u"Param cNameArchive isn mBackup.NameArchive type")
        
        
        
    name_archive = property( lambda self: self.__NameArchive )
    """
    """
    zip_object = property(lambda self: self.__ZipObject)
    """
    """
    
    def Process(self, pPath):
        """
        """
        self.zip_object.write(pPath)
        
    def AddingToArchive(self,pPath):
        """
        """
        if os.path.exists(pPath) :
            self.zip_object.write(pPath)
        else :
            raise IOError(u"The path containing in string pPath daesn't exist")
        

    def __del__(self):
        """
        """
        self.zip_object.close()
    
if __name__ == '__main__':
    pass