/**
 *  @description Test class for AccountLookupFlowApexController
 *
 *  2019-08-06  Amruta K    First version
 */
@isTest
public class AccountLookupFlowControllerTest {

    // create new list of accounts
    public static List <Account> getAccounts(){
        List<Account> childAccountList = new List<Account>();
        for(Integer i=0; i < 10; i++){
            Account account = new Account(
                	Name = 'Test Company'
        	);
            childAccountList.add(account);
        }
        return childAccountList;
    }    
    
    // Test method to test fetchRecords method to verify if it returns correct number of records.
    Public Static testMethod void fetchRecordsTestCase1(){
        
        List <Account> childAccs = getAccounts();
        insert childAccs;
        
        Test.startTest();
        	List<AccountLookupFlowApexController.RecordsData> recordsList = 
                AccountLookupFlowApexController.fetchRecords('Account', 'Name', 'Test');
        Test.stopTest();
        
        System.assertEquals(10, recordsList.size());
      
    } 
    // Test method to test fetchRecords method to verify if it thorw an exception.
    Public Static testMethod void fetchRecordsTestCase2(){
         try{
             Test.startTest();
                List<AccountLookupFlowApexController.RecordsData> recordsList = 
                    AccountLookupFlowApexController.fetchRecords('', 'Name', 'Test');
            Test.stopTest();
         }
         catch(Exception e){
             System.assertEquals('Script-thrown exception', e.getMessage());
         }
     }
     // Test method to test fetchRecords method to verify if it returns correct no records.
     Public Static testMethod void fetchRecordsTestCase3(){
        
        List <Account> childAccs = getAccounts();
        insert childAccs;
        
        Test.startTest();
        	List<AccountLookupFlowApexController.RecordsData> recordsList = 
                AccountLookupFlowApexController.fetchRecords('Account', 'Name', 'ABC');
        Test.stopTest();
        
        System.assertEquals(0, recordsList.size());
      
    } 
}