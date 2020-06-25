/**
 *  @description Test Class for PriceRuleCommercialTabController class
 *
 *  2019-16-07 Anshul Garg
 */
@isTest
public class PriceRuleCommercialTabControllerTest {
    @testsetup public static void createTestData(){
        Price_Rule__c prIns = new Price_Rule__c(Name = 'Test PR');
        insert prIns;
        Unit_Sub_Category__c usc1 = new Unit_Sub_Category__c(Name  = 'TestSubCategory1');
        insert usc1;
        Unit_Sub_Category__c usc2 = new Unit_Sub_Category__c(Name  = 'TestSubCategory2');
        insert usc2;
    }
    
    public static testmethod void testSaveValuesOnPriceRule(){
        Price_Rule__c prIns = [SELECT Id FROM Price_Rule__c LIMIT 1];
        String assetNameList = 'TestAsset1;TestAsset2';
        String categoryNameList = 'TestCategory1;TestCategory2';
        String subCategoryNameList = 'TestSubCategory1;TestSubCategory2';
        String ownershipValue = 'TestOwnerValue1;TestOwnerValue2';
        Test.startTest();
        PriceRuleCommercialTabController.saveValuesOnPriceRule(prIns.Id,assetNameList,categoryNameList,subCategoryNameList,ownershipValue);
        Test.stopTest();
        Price_Rule__c actualPriceRule = [SELECT Product_Sub_Category_Value__c FROM Price_Rule__c WHERE Id = :prIns.Id];
        System.assertEquals('TestSubCategory1;TestSubCategory2', actualPriceRule.Product_Sub_Category_Value__c);
    }
    
    public static testmethod void testGetSelectedValues(){
        Price_Rule__c prIns = [SELECT Id FROM Price_Rule__c LIMIT 1];
        String assetNameList = 'TestAsset1;TestAsset2';
        String categoryNameList = 'TestCategory1;TestCategory2';
        String subCategoryNameList = 'TestSubCategory1;TestSubCategory2';
        String ownershipValue = 'TestOwnerValue1;TestOwnerValue2';
        Test.startTest();
        PriceRuleCommercialTabController.saveValuesOnPriceRule(prIns.Id,assetNameList,categoryNameList,subCategoryNameList,ownershipValue);
        PriceRuleCommercialTabController.SelectedValue instance = PriceRuleCommercialTabController.getSelectedValues(prIns.Id);
        List<PriceRuleCommercialTabController.MultiPicklistWrapper> optionList = PriceRuleCommercialTabController.getOwnerShipOptionValue();
        Test.stopTest();
        System.assertEquals(5, optionList.size());
        System.assertEquals(2, instance.unitSubCatList.size());
    }
}