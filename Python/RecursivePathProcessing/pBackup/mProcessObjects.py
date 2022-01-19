'''
Created on 13.04.2012

@author: Prapor
'''

import os.path

class ProcessObject(object):
    '''
    classdocs
    '''
    def __init__(self):
        '''
        Constructor
        '''
        pass
    
    def IsContinue(self, param):
        """
            This method checking continue processing of object
        """
        raise TypeError(u"The ProcessObject is abstract class you cannot calling its methods")
    

class PathObject(ProcessObject):
    """
        Class checking the directory parametr 
    """
    
    def __init__(self):
        '''
        Constructor
        '''
        pass
    
    def IsContinue(self, param):
        """
            This method checking that second param is directory
        """
        return False

class DirectoryObject(ProcessObject):
    """
        Class checking the directory parametr 
    """
    
    def __init__(self):
        '''
        Constructor
        '''
        pass
    
    def IsContinue(self, param):
        """
            This method checking that second param is directory
        """
        return os.path.isdir(param)
    
class FileObject(ProcessObject):
    """
        Class checking the file input parametr 
    """
    
    def __init__(self):
        '''
        Constructor
        '''
        pass
    
    def IsContinue(self, param):
        """
            This method checking that second param is directory
        """
        return os.path.isfile(param)
    