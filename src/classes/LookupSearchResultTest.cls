/************************************************************************************
* Name          : LookupSearchResultTest                                                 
* Description   : Test class for 'LookupSearchResult'
************************************************************************************/

@isTest
public class LookupSearchResultTest {  
    
    //Created a test data for LookupSearchResult
    Static Id id;
    Static String  sObjectType = 'Account';
    Static String objIcon ='Test Icon';
    Static String  title  = 'Test';
    Static String subtitle = 'subtest';
     
    //Returned an a Test data of Account record to insert   
    @isTest    
    public static Account accountObj (){
        Account accountObj = new Account(Name = 'My Company');    
        return accountObj;          
    }    
    
    //Method to test the Id of inserted object   
    @isTest
    public static void LookupSearchResultGetId(){
        Account acc = accountObj();
        insert acc;
        id =acc.Id; 
        LookupSearchResult lookupObje = New LookupSearchResult(id, sObjectType, objIcon, title, subtitle);
        Test.startTest();
        lookupObje.getId();
        Test.stopTest();
        system.assertNotEquals(lookupObje.getId(), Null);
    }
    
    //Method to test the sObjectType of given test data    
    @isTest
    public static void LookupSearchResultGetSObjectType(){
        Account acc = accountObj();
        insert acc;
        LookupSearchResult lookupObje = New LookupSearchResult(id, sObjectType, objIcon, title, subtitle);
        Test.startTest();
        lookupObje.getSObjectType();
        Test.stopTest();
        system.assertEquals(lookupObje.getSObjectType(), 'Account');
    }
    
    //Method to test the Icon of given in test data Icon     
    @isTest
    public static void LookupSearchResultGetIcon(){
        Account acc = accountObj();
        insert acc;
        LookupSearchResult lookupObje = New LookupSearchResult(id, sObjectType, objIcon, title, subtitle);
        Test.startTest();
        lookupObje.getIcon();
        Test.stopTest();
        system.assertEquals(lookupObje.getIcon(), 'Test Icon');  
    }
    
    //Method to test the Title of given in test data       
    @isTest
    public static void LookupSearchResultGetTitle(){
        Account acc = accountObj();
        insert acc;
        LookupSearchResult lookupObje = New LookupSearchResult(id, sObjectType, objIcon, title, subtitle);
        Test.startTest();
        lookupObje.getTitle();
        Test.stopTest();
        system.assertEquals(lookupObje.getTitle(), 'Test');
    }
    
    //Method to test the Subtitle of given in test data      
    @isTest
    public static void LookupSearchResultGetSubtitle(){
        Account acc = accountObj();
        insert acc;
        LookupSearchResult lookupObje = New LookupSearchResult(id, sObjectType, objIcon, title, subtitle);
        Test.startTest();
        lookupObje.getSubtitle();
        Test.stopTest();
        system.assertEquals(lookupObje.getSubtitle(), 'subtest');
    }
}