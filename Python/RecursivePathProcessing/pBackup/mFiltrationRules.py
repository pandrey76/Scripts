#!usr/bin/env python
# -*- coding: utf-8 -*-

'''
Created on 13.05.2012

@author: Prapor
'''
import mCheckingObjects
import mProcessObjects

class FiltrationRules(object):
    '''
    classdocs
    '''
    def __init__ (self):
        """
        """
        self.__CheckObjectList = []
    
    check_object_list = property ( lambda self : self.__CheckObjectList )
    """
        Property return list of checking objects
    """ 
    def AddingCheckingObject(self, cCheckingObject):
        """
        """
        if isinstance(cCheckingObject, mCheckingObjects.CheckingObject) :
            self.check_object_list.append(cCheckingObject)
        else :
            raise TypeError( u"Param cCheckingObject isn mCheckingObjects.CheckingObject type")

        
    def IsProcess (self, param):
        """
            Method for processing filters objects
        """
        for obj in self.__CheckObjectList :
            if obj.Process(param) is False :
                return False
        return True

class Path_FiltrationRules(FiltrationRules):
    '''
    classdocs
    '''
    def __init__ (self):
        """
        """
        super(Path_FiltrationRules, self).__init__()
        
    def AddingCheckingObject(self, cCheckingObject):
        """
        """
        if isinstance(cCheckingObject.process_object, mProcessObjects.PathObject):
            super(Path_FiltrationRules, self).AddingCheckingObject(cCheckingObject)
        else :
            raise TypeError( u"Param cCheckingObject isn mProcessObjects.PathObject type")


class Directory_FiltrationRules(FiltrationRules):
    '''
    classdocs
    '''
    def __init__ (self):
        """
        """
        super(Directory_FiltrationRules, self).__init__()
        
        
    def AddingCheckingObject(self, cCheckingObject):
        """
        """
        if isinstance(cCheckingObject.process_object, mProcessObjects.DirectoryObject):
            super(Directory_FiltrationRules, self).AddingCheckingObject(cCheckingObject)
            #FiltrationRules.AddingCheckingObject(self, cCheckingObject)
        else :
            raise TypeError( u"Param cCheckingObject isn mProcessObjects.DirectoryObject type")

class File_FiltrationRules(FiltrationRules):
    '''
    classdocs
    '''
    def __init__ (self):
        """
        """
        super(File_FiltrationRules, self).__init__()
        
    def AddingCheckingObject(self, cCheckingObject):
        """
        """
        if isinstance(cCheckingObject.process_object, mProcessObjects.FileObject):
            super(File_FiltrationRules, self).AddingCheckingObject(cCheckingObject)
        else :
            raise TypeError( u"Param cCheckingObject isn mProcessObjects.FileObject type")
        
#    def IsProcess (self, param):
#        """
#            Method for processing filters objects
#        """
#        for obj in self.__CheckObjectList :
#            if obj.Process(param) is False :
#                return False
#            return True
