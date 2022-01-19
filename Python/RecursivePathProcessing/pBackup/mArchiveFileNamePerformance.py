#!/usr/bin/env python
# -*- coding: utf-8 -*-
'''
Created on 16.04.2012

@author: Prapor
'''

import datetime
import os.path
import re

class ArchiveFileNamePerformance(object):
    '''
    classdocs
    '''

    def __init__(self):
        '''
        Constructor
        '''
    
    
    @property
    def archive_file_extention(self):
        """
            Property return string contain file extention of archive file
        """
        raise(u"The ArchiveFileNamePerformance is abstract class you cannot calling its methods")

    
            
    @property
    def archive_directory_path(self):
        """
        Property getting path to archive file 
        """
        raise(u"The ArchiveFileNamePerformance is abstract class you cannot calling its methods")
    
    @property
    def archive_file_name(self):
        """
        Property getting full file path to archive file 
        """
        raise(u"The ArchiveFileNamePerformance is abstract class you cannot calling its methods")
    
    @property
    def archive_full_file_path(self):
        """
        Property getting full file path to archive file 
        """
        raise(u"The ArchiveFileNamePerformance is abstract class you cannot calling its methods")
    
class SourceDirBackup_ArchiveDirectoryPerformance(object):
    '''
    classdocs
    '''

    def __init__(self, pSofwareName, pBasePath, pLogFilePath = None):
        '''
        Constructor
        '''
        self.__SoftwareName           = pSofwareName
        #if os.path.isdir(pBasePath):
        self.__BasePath           = os.path.normpath(pBasePath)
        #else :
        #    raise IOError(u"The param pBasePath must be folder")
        self.__LogFilePath            = pLogFilePath
        self.__CurrentTime            = datetime.datetime.now()
    
    software_name       = property( lambda self : self.__SoftwareName )
    """
        Property return string contain name of current software
    """
    base_path           = property( lambda self : self.__BasePath     )        
    """
        Property return string contain base path to archive directory
    """
            
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
            self.__FullDataString =     SourceDirBackup_ArchiveDirectoryPerformance.ConstructStringWhithFirstNullSymbols( self.__CurrentTime.date().day,     0 ) + \
                                        SourceDirBackup_ArchiveDirectoryPerformance.ConstructStringWhithFirstNullSymbols( self.__CurrentTime.date().month,   0 ) + \
                                        SourceDirBackup_ArchiveDirectoryPerformance.ConstructYearStringWhithTwoLastSymbols(self.__CurrentTime.date().year      )
            return self.__FullDataString           
    
    @property
    def full_time_string(self):
        """
        Property getting full time string
        """
        try :
            return self.__FullTimeString
        except AttributeError :
            self.__FullTimeString =     SourceDirBackup_ArchiveDirectoryPerformance.ConstructStringWhithFirstNullSymbols( self.__CurrentTime.time().hour,   0  ) + \
                                        SourceDirBackup_ArchiveDirectoryPerformance.ConstructStringWhithFirstNullSymbols( self.__CurrentTime.time().minute, 0  )
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
            self.__ArchiveDirectoryName = os.path.join( self.__ArchiveDirectoryName, SourceDirBackup_ArchiveDirectoryPerformance.ConstructStringWhithFirstNullSymbols(self.__CurrentTime.date().month, 0 ) )
            #День
            #Не будем добавлять директорию со значением текущего дня
            #self.__ArchiveDirectoryName = os.path.join( self.__ArchiveDirectoryName, NameArchive.ConstructStringWhithFirstNullSymbols(self.__CurrentTime.date().day,   0 ) )                          
            self.__ArchiveDirectoryName = os.path.join( self.__ArchiveDirectoryName, self.full_data_string )
            tDirectoryName              = self.full_data_string + "_" + self.full_time_string + "_" + self.software_name
            self.__ArchiveDirectoryName = os.path.join( self.__ArchiveDirectoryName, tDirectoryName )
            return self.__ArchiveDirectoryName           

      
class SourceDirBackup_ArchiveFileNamePerformance(ArchiveFileNamePerformance):
    '''
    classdocs
    '''

    def __init__(self, pSourceDirBackup_ArchiveDirectoryPerformance, pSoftware, pVersion = None, pComputerID = None, pArchiveFileExtention = u"zip", pLogFilePath = None):
        '''
        Constructor
        '''
        if isinstance( pSourceDirBackup_ArchiveDirectoryPerformance, SourceDirBackup_ArchiveDirectoryPerformance ) :
            self.__DirectoryNameObject = pSourceDirBackup_ArchiveDirectoryPerformance
        else :
            raise TypeError( u"Param pSourceDirBackup_ArchiveDirectoryPerformance isn SourceDirBackup_ArchiveDirectoryPerformance type")

        self.__Software               = pSoftware
        self.__Version                = pVersion
        self.__ComputerIdString       = pComputerID
        self.archive_file_extention   = pArchiveFileExtention
        self.__LogFilePath            = pLogFilePath

    
    archive_directory_object          = property( lambda self : self.__DirectoryNameObject      )
    """
        Property return object contain archive directory methods performance 
    """
   
    version             = property( lambda self : self.__Version      )
    """
        Property return string contain version number
    """
    
    log_file_path       = property( lambda self : self.__LogFilePath  )
    """
        Property return string contain full path to logging file
    """
    
    @property
    def software_name(self):
        """
            Property return string contain software_name number
        """
        try :
            return self.__Software
        except AttributeError :
            self.__Software = self.__TempSoftware

        

    @software_name.setter
    def software_name(self, soft_name):
        """
            Property setting string contain version number
        """
        if type(soft_name) != unicode :
            raise TypeError( u"Param soft_name isn unicode type" )
        self.__Software = soft_name  
        del self.__ArchiveFileName
        del self.__ArchiveFullFilePath
        

    @property
    def computer_id_string(self):
        """
            Property return string contain computer name identification 
        """
        #rint unicode(self.__ComputerIdString)
        if self.__ComputerIdString == None :# or self.__ComputerIdString == u"":
            return None
        try :
            unicode(self.__ComputerIdString)
        except UnicodeError :
            pPattern = re.compile( ur"([A-Za-z]*).*" )
            M1 = pPattern.search(self.__ComputerIdString)
            if M1 :
                return M1.group(1)
            else :
                return None
        if self.__ComputerIdString == u"" :
            return None
        return self.__ComputerIdString
    
    @computer_id_string.setter
    def computer_id_string(self, pComputerID):
        """
            Property setting string contain computer name identification 
        """
        if type(pComputerID) == unicode or pComputerID == None :
            self.__ComputerIdString = pComputerID
        else :
            raise TypeError(u"Parametr pComputerID must be unicode or None")
    
    
    @property
    def archive_file_extention(self):
        """
            Property return string contain file extention of archive file
        """
        return self.__ArchFileExtention

    @archive_file_extention.setter
    def archive_file_extention(self, file_ext):
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

            
    @property
    def archive_file_name(self):
        """
        Property getting full file path to archive file 
        """
        try :
            return self.__ArchiveFileName
        except AttributeError :
            self.__ArchiveFileName = u""
            if self.version != None :
                self.__ArchiveFileName =  "V" + self.version              
            if self.__ArchiveFileName != u"" :
                self.__ArchiveFileName += "__"
            self.__ArchiveFileName += self.software_name
            if self.computer_id_string != None :
                self.__ArchiveFileName += "__" + self.computer_id_string
            self.__ArchiveFileName +=  "__"                        + \
                    self.archive_directory_object.full_data_string + \
                                       "_"                         + \
                    self.archive_directory_object.full_time_string
                                            
            return self.__ArchiveFileName

    @property
    def archive_directory_path(self):
        """
        Property getting path to archive file 
        """
        return self.archive_directory_object.archive_directory
    
    @property
    def archive_full_file_path(self):
        """
        Property getting full file path to archive file 
        """
        try :
            return self.__ArchiveFullFilePath
        except AttributeError :
            self.__ArchiveFullFilePath = os.path.join( self.archive_directory_object.archive_directory, self.archive_file_name)
            self.__ArchiveFullFilePath = self.__ArchiveFullFilePath + "." + self.archive_file_extention
            return self.__ArchiveFullFilePath

if __name__ == "__main__" :
    dir_arch = SourceDirBackup_ArchiveDirectoryPerformance ( 
                                                            u"Installation",
                                                            u"d:\\Programming\\RusCrypto\\RusCrypto_1.2\\PROJECT\\BACKUP\\",
                                                             ) 
    import socket
    name_arch = SourceDirBackup_ArchiveFileNamePerformance( 
                                                           dir_arch, 
                                                           #u"1_0",
                                                           pComputerID = socket.gethostname()
                                                           )
                                                           
    print name_arch.archive_directory_path
    print name_arch.archive_full_file_path
            