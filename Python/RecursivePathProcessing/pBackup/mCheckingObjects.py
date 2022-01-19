#!/usr/bin/env python
# -*- coding: utf-8 -*-
'''
Created on 13.04.2012

@author: Prapor
'''
import mProcessObjects
import mEqualingObjects
import re
#import os.path

class CheckingObject(object):
    '''
    classdocs
    '''

    def __init__(self, cProcObject, cEquObject ):
        '''
        Constructor
        '''
        if isinstance(cProcObject, mProcessObjects.ProcessObject) :
            self.__ProcObject = cProcObject
        else :
            raise TypeError( u"Param cProcObject isn mProcessObjects.ProcessObject type")
        
        if isinstance(cEquObject, mEqualingObjects.EqualingObject) :
            self.__EquObject = cEquObject
        else :
            raise TypeError( u"Param cEquObject isn mEqualingObjects.EqualingObject type")
       
         
        
    process_object = property ( lambda self : self.__ProcObject )
    '''
        Property getting ProcessObject 
    '''
    equ_object     = property ( lambda self : self.__EquObject )
    '''
        Property getting EqualingObject
    '''
    
    def Process(self, param):
        """
            This method checking processing of object
        """
        raise TypeError(u"The CheckingObject is abstract class you cannot calling its methods")
        
        
class RegEx_CheckingObject(CheckingObject):
    '''
    classdocs
    '''

    def __init__(self, cProcObject, cEquObject, param ):
        '''
        Constructor
        '''
        super(RegEx_CheckingObject, self).__init__(cProcObject, cEquObject )
        
        tParam = ur"123" 
        if type(tParam) == type(param) :
            self.__Patern = param
        else :
            raise TypeError( u"Param pattern isn unicode type")
        
        
        
    pattern = property ( lambda self : self.__Patern )
        
    def Process(self, param):
        """
            This method checking processing of object
        """
       
        pPattern = re.compile( self.pattern )
        M1 = pPattern.search( param )
        if M1 :
            return self.equ_object.IsEqualing(True)
        else:
            return self.equ_object.IsEqualing(False)
        

class Name_CheckingObject(CheckingObject):
    '''
    classdocs
    '''

    def __init__(self, cProcObject, cEquObject, tParam ):
        '''
        Constructor
        '''
        super(Name_CheckingObject, self).__init__(cProcObject, cEquObject )
        
        if type(tParam) == unicode :
            self.__Patern = tParam
        else :
            raise TypeError( u"Param pattern isn unicode type")
        
        
        
    pattern = property ( lambda self : self.__Patern )
        
    def Process(self, param):
        """
            This method checking processing of object
        """
       
        if param == self.__Patern :
            return self.equ_object.IsEqualing(True)
        else:
            return self.equ_object.IsEqualing(False)

class FileExtention_CheckingObject(CheckingObject):
    '''
    classdocs
    '''

    def __init__(self, cEquObject, pFileExtention ):
        '''
        Constructor
        '''
        cProcObject = mProcessObjects.FileObject()
        super(FileExtention_CheckingObject, self).__init__(cProcObject, cEquObject )
        
        self.__FileExtention = pFileExtention
        
    file_extention = property ( lambda self : self.__FileExtention )
    """
        Property returning extention of file
    """
        
    def Process(self, param):
        """
            This method checking processing of object
        """
       
        pPattern = re.compile( ur"^.+\.(.+)$" )
        M1 = pPattern.search( param )
        if M1 :
            if M1.group(1) == self.file_extention :
                return self.equ_object.IsEqualing(True)
            else:
                return self.equ_object.IsEqualing(False) 
        else :
            return self.equ_object.IsEqualing(False)
        
        
if __name__ == "__main__" :
    
    #Объект не совпадения
    pNotEq = mEqualingObjects.NotEq_EqualingObject()
    #Объект совпадения
    pEq = mEqualingObjects.Eq_EqualingObject()
    
    #Обрабатываются только директории
    pDirProcessObject = mProcessObjects.DirectoryObject()
    #Обрабатываются только файлы
    pFileProcessObject = mProcessObjects.FileObject()
    
    pRegEx_CheckingObject_1 = RegEx_CheckingObject (pDirProcessObject, pNotEq, ur".+Debug.*")
    pRegEx_CheckingObject_2 = RegEx_CheckingObject (pFileProcessObject, pNotEq, ur".+\.exe")
    pRegEx_CheckingObject_3 = RegEx_CheckingObject (pFileProcessObject, pEq, ur".+\.txt")
    pRegEx_CheckingObject_4 = RegEx_CheckingObject (pDirProcessObject, pEq, ur".+[\\/]Debug[\\/].*")
    
    
    pFileExtention_CheckingObject_1 = FileExtention_CheckingObject(pEq, u"txt")
    pFileExtention_CheckingObject_2 = FileExtention_CheckingObject(pNotEq, u"exe")
    
    #Test
    #-------------------------------------------------------------#
    print u"Test 1.1\n"
    param_1_1 = u"d:\\Distr\\All Distibutives\\Mobile\\"
    #Директория не содержащая ".+Debug.*"
    if pRegEx_CheckingObject_1.Process(param_1_1) :
        print u"Ok"
    else:
        print u"Error"
    

    param_1_2 = u"d:\\Programming\\PROJECT\\AtlasCard 1.0.0.1\\VS2008\\CyberNet\AtlasCard\\AtlasCard\\bin\\Debug\\"
    print u"Test 1.2\n"
    #Директория не содержащая ".+Debug.*"
    if pRegEx_CheckingObject_1.Process(param_1_2) :
        print u"Error"
    else:
        print u"Ok"

    print u"Test 1.3\n"
    param_1_1 = u"d:\\Distr\\All Distibutives\\Mobile\\qippda2140.cab"
    #Директория не содержащая ".+Debug.*"
    if pRegEx_CheckingObject_1.Process(param_1_1) :
        print u"Error"
    else:
        print u"Ok"
    

    #-------------------------------------------------------------#
    #Test 2
    #Путь к файлу ".exe"
    param_2_1 = u"d:\\Distr\\All Distibutives\\Mobile\\qippda2140.cab"
    print u"Test 2.1\n"
    if pRegEx_CheckingObject_2.Process(param_2_1) :
        print u"Ok"
    else:
        print u"Error"
    
    
    param_2_2 = u"d:\\Distr\\ACDSee Photo Editor v4.0.195\\setup.exe"
    print u"Test 2.2\n"
    if pRegEx_CheckingObject_2.Process(param_2_2) :
        print u"Error"
    else:
        print u"Ok"

    param_2_3 = u"d:\\Distr\\ACDSee Photo Editor v4.0.195\\"
    print u"Test 2.3\n"
    if pRegEx_CheckingObject_2.Process(param_2_3) :
        print u"Error"
    else:
        print u"Ok"
    