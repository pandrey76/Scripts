#!/usr/bin/env python
# -*- coding: utf-8 -*-

'''
Created on 13.05.2012

@author: Prapor
'''
import mFiltrationRules
import os.path

class RecursiveProcessFilesTree(object):
    """
    """
    
    def __init__( self, cFile_FiltrationRules, cDirectory_FiltrationRules, cPath_FiltrationRules = None):
        """
        """
        if isinstance( cFile_FiltrationRules, mFiltrationRules.File_FiltrationRules ) :
            self.__FileFiltrationRulesObject = cFile_FiltrationRules
        else :
            raise TypeError( u"Param cFile_FiltrationRules isn mFiltrationRules.File_FiltrationRules type")
        
        if isinstance( cDirectory_FiltrationRules, mFiltrationRules.Directory_FiltrationRules ) :
            self.__DirectoryFiltrationRulesObject = cDirectory_FiltrationRules
        else :
            raise TypeError( u"Param cDirectory_FiltrationRules isn mFiltrationRules.Directory_FiltrationRules type")

        if cPath_FiltrationRules != None :
            if isinstance( cPath_FiltrationRules, mFiltrationRules.Path_FiltrationRules ) :
                self.__PathFiltrationRulesObject = cPath_FiltrationRules
            else :
                raise TypeError( u"Param cPath_FiltrationRules isn mFiltrationRules.Path_FiltrationRules type")

        #self.__SearchFolder = os.path.normpath(pSearhFolder)
        #if os.path.exists(self.__SearchFolder) :
        #    pass
        #else :
        #    raise IOError(u"The path containing in string pSearhFolder daesn't exist")

        
    #search_folder = property( lambda self: self.__SearchFolder )
    """
    """
    file_filtration_rules = property( lambda self: self.__FileFiltrationRulesObject)
    """
    """  
    directory_filtration_rules = property( lambda self: self.__DirectoryFiltrationRulesObject)
    """
    """  
    path_filtration_rules = property( lambda self: self.__PathFiltrationRulesObject)
    """
    """  
    
    def WalkThrueFileTree (self, pSearhFolder):
        """
        """
        search_folder = os.path.normpath(pSearhFolder)
        if os.path.exists(search_folder) :
            pass
        else :
            raise IOError(u"The path containing in string pSearhFolder daesn't exist")

        print search_folder
        for ( path, dirs, files ) in os.walk( search_folder ) :
            #path - та точка в дереве каталогов где она находится в данный момент.
            #dirs - это список всех папок находящихся под этой точкой.
            #files - это список всех файлов находящихся под этой точкой.
            
            print path, "\n"
            #Проверяем директории
            #Если это пустая директория без файлов всё равно закатываем её в архив
            if len(dirs) == 0 and len(files) == 0:
                self.Process(path)
                
            for tDir in dirs :
                if self.directory_filtration_rules.IsProcess( tDir ) :
                    pass
                else :
                    dirs.remove(tDir)
            for tFile in files :
                if self.file_filtration_rules.IsProcess( tFile ) :
                    tPath = path
                    tPath += os.sep 
                    if tPath[-1] != os.sep :
                        tPath = tPath + os.sep  
                    tPath = tPath + tFile
                
                    #if self.filtration_rules.IsProcess( tFile ) :
                    #tPath = os.path.relpath(path, u"GENERAL\\Src")
                    print tPath
                    self.Process(tPath)


    def Process(self, path):
        """
        """
        raise TypeError(u"The Process is abstract class you cannot calling its methods")
    
    
if __name__ == '__main__':
    pass