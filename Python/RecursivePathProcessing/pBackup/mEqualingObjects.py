#!/usr/bin/env python
# -*- coding: utf-8 -*-
'''
Created on 13.04.2012

@author: Prapor
'''

class EqualingObject (object):
    """
    """
    
    def IsEqualing(self, bool_param):
        """
            Abstract method calling error
        """
        raise TypeError
    
    
class  NotEq_EqualingObject(EqualingObject):
    """
        Class changing the result of bool operation     
    """
    
    def __init__(self):
        """
        """
        
    def IsEqualing(self, bool_param):
        """
            Comparing Method, if bool_param True method returning False
            If bool_param False method returning True 
        """
        if bool_param is not True and bool_param is not False :
            raise TypeError(u"The second param bool_param must be True or False")
        
        if bool_param is True:
            return False
        if bool_param is False :
            return True

class  Eq_EqualingObject(EqualingObject):
    """
        Class not changing the result of bool operation     
    """
    
    def __init__(self):
        """
        """
        
    def IsEqualing(self, bool_param):
        """
            Comparing Method, if bool_param True method returning True
            If bool_param False method returning False 
        """
        if bool_param is not True and bool_param is not False :
            raise TypeError(u"The second param bool_param must be True or False")
        return bool_param
    
        