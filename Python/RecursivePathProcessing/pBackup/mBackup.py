#!/usr/bin/env python
# -*- coding: utf-8 -*-
'''
Created on 12.05.2012

@author: Prapor
'''
import datetime
import os.path
import re

class NameArchive(object):
    '''
    classdocs
    '''

    def __init__(self, pVersion, pSofwareName, pBasePath, pComputerID, pArchiveFileExtention, pLogFilePath):
        '''
        Constructor
        '''
        self.__SoftwareName           = pSofwareName
        self.__Version                = pVersion
        self.__BasePath               = pBasePath
        self.__ComputerIdString       = pComputerID
        self.arch_file_extention      = pArchiveFileExtention
        self.__LogFilePath            = pLogFilePath
        self.__CurrentTime            = datetime.datetime.now()
    
    software_name       = property( lambda self : self.__SoftwareName )
    """
        Property return string contain name of current software
    """
    version             = property( lambda self : self.__Version      )
    """
        Property return string contain version number
    """
    base_path           = property( lambda self : self.__BasePath     )        
    """
        Property return string contain base path to archive directory
    """
    @property
    def computer_id_string(self):
        """
            Property return string contain computer name identification 
        """
        if self.__ComputerIdString == None :
            return ""
        return self.__ComputerIdString 
    
    @property
    def arch_file_extention(self):
        """
            Property return string contain file extention of archive file
        """
        return self.__ArchFileExtention

    @arch_file_extention.setter
    def arch_file_extention(self, file_ext):
        """
            Property setting string contain file extention of archive file
        """
        if type(file_ext) != unicode :
            raise TypeError( u"Param file_ext isn unicode type" )
        
        pPattern = re.compile( ur"^\.(.*)$" )
        M1 = pPattern.search( file_ext )
        if M1 :
            self.__ArchFileExtention = M1.group(1)
        else:
            self.__ArchFileExtention = file_ext

            
    log_file_path       = property( lambda self : self.__LogFilePath  )
    """
        Property return string contain full path to logging file
    """
    current_time  = property( lambda self : self.__CurrentTime  )
    """
        Property return object type "datetime" contain current time and data
    """
    
    @staticmethod
    def ConstructYearStringWhithTwoLastSymbols(param):
        pPattern = re.compile( ur"\d{2}(\d{2})" )
        M1 = pPattern.search( unicode(param) )
        if M1 :
            return M1.group(1)
        return unicode(param)

    @staticmethod
    def ConstructStringWhithFirstNullSymbols(param,num):
        if ( param < 10 ) :
            return "0" + unicode(param)
        return unicode(param)
        
    

    @property
    def full_data_string(self):
        """
        Property getting full data string
        """
        try :
            return self.__FullDataString
        except AttributeError :
            self.__FullDataString =     NameArchive.ConstructStringWhithFirstNullSymbols( self.__CurrentTime.date().day,     0 ) + \
                                        NameArchive.ConstructStringWhithFirstNullSymbols( self.__CurrentTime.date().month,   0 ) + \
                                        NameArchive.ConstructYearStringWhithTwoLastSymbols(self.__CurrentTime.date().year      )
            return self.__FullDataString           
    
    @property
    def full_time_string(self):
        """
        Property getting full time string
        """
        try :
            return self.__FullTimeString
        except AttributeError :
            self.__FullTimeString =     NameArchive.ConstructStringWhithFirstNullSymbols( self.__CurrentTime.time().hour,   0  ) + \
                                        NameArchive.ConstructStringWhithFirstNullSymbols( self.__CurrentTime.time().minute, 0  )
            return self.__FullTimeString           
            
    @property
    def archive_directory(self):
        """
        Property getting path to archive file 
        """
        try :
            return self.__ArchiveDirectoryName
        except AttributeError:
            self.__ArchiveDirectoryName = os.path.normpath(self.__BasePath)
            #Год
            self.__ArchiveDirectoryName = os.path.join( self.__ArchiveDirectoryName, unicode(self.__CurrentTime.date().year) )
            #Месяц
            self.__ArchiveDirectoryName = os.path.join( self.__ArchiveDirectoryName, NameArchive.ConstructStringWhithFirstNullSymbols(self.__CurrentTime.date().month, 0 ) )
            #День
            #Не будем добавлять директорию со значением текущего дня
            #self.__ArchiveDirectoryName = os.path.join( self.__ArchiveDirectoryName, NameArchive.ConstructStringWhithFirstNullSymbols(self.__CurrentTime.date().day,   0 ) )                          
            self.__ArchiveDirectoryName = os.path.join( self.__ArchiveDirectoryName, self.full_data_string )
            tDirectoryName              = self.full_data_string + "_" + self.full_time_string + "_" + self.software_name
            self.__ArchiveDirectoryName = os.path.join( self.__ArchiveDirectoryName, tDirectoryName )
            return self.__ArchiveDirectoryName           

    @property
    def archive_file_name(self):
        """
        Property getting full file path to archive file 
        """
        try :
            return self.__ArchiveFileName
        except AttributeError :
            self.__ArchiveFileName =        "V"                       + \
                                            self.version              + \
                                            "__"                      + \
                                            self.software_name        + \
                                            "__"                      + \
                                            self.computer_id_string   + \
                                            "__"                      + \
                                            self.full_data_string     + \
                                            "_"                       + \
                                            self.full_time_string
                                            
            return self.__ArchiveFileName

    @property
    def full_archive_file_path(self):
        """
        Property getting full file path to archive file 
        """
        try :
            return self.__ArchiveFullFilePath
        except AttributeError :
            self.__ArchiveFullFilePath =    os.path.join( self.archive_directory, self.archive_file_name)
            self.__ArchiveFullFilePath = self.__ArchiveFullFilePath + "." + self.arch_file_extention
            return self.__ArchiveFullFilePath
    
                                           
        
if __name__ == "__main__" :
    name_arch = NameArchive (u"1_0", "Installation",
                                        u"d:\\Programming\\RusCrypto\\RusCrypto_1.2\\PROJECT\\BACKUP\\",
                                        None,
                                        u".zip",
                                        u"log.log" )
    print name_arch.archive_directory
    print name_arch.full_archive_file_path