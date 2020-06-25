/**
 *  @description Test Class for ReusableMultiSelectLookupCtrl class
 *
 *  2019-16-07 Anshul Garg
*/
@isTest
public class ReusableMultiSelectLookupCtrlTest {
    public static testmethod void testFetchLookUpValues(){
        List<Asset_Class__c> assetClassList = new List<Asset_Class__c>();
        for(Integer i = 1;i <= 10 ; i++){
            Asset_Class__c assetIns = new Asset_Class__c(Name = 'Test' + i);
            assetClassList.add(assetIns);
        }
        insert assetClassList;
        List<Asset_Class__c> excludedAssetClassList = [SELECT Id FROM Asset_Class__c LIMIT 5];
        List<sObject> excludeitemsList = excludedAssetClassList;
        Test.startTest();
        List < sObject > returnList = ReusableMultiSelectLookupCtrl.fetchLookUpValues('Test','Asset_Class__c',excludeitemsList);
        Test.stopTest();
        System.assertEquals(5, returnList.size());
    }
}