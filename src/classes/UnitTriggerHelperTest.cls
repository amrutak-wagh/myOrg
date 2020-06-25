/**
 *  @description Test class for UnitTriggerHelper
 *
 *  2019-08-19  Shraddha N    First version
 *  
 */

@isTest
public class UnitTriggerHelperTest {
    // Method to create test setup data.
	@isTest
    public static void test1(){
        String errorMessage = '';
        List<Unit__c> unitList = new List<Unit__c>();
        
        Business_Park__c businessParkObject = new Business_Park__c(
                Name = 'D3', Business_Park_Code__c = 'D3'
        );
        insert businessParkObject;
        
        Plot__c plotObject = new Plot__c(Name = 'testPlot',Plot_Code_YARDI__c = 'pricingEngineTestPlot',Area_sqft__c = 100.0,
            					   Business_Park__c = businessParkObject.Id,Plot_Name_YARDI__c = 'pricingEngineTestPlotName',
            					   Type__c = 'type',Status__c = 'Available - Sale',Sector_Name__c = 'sectorName');
        insert plotObject;
        
        Building__c buildingObejct = new Building__c(Plot__c = plotObject.Id,Name = 'Test Build 1' , Business_Park__c = businessParkObject.Id,
                                             Ownership_Type__c = 'TECOM Owned', Development_Status__c = 'Under Development',
                                             Property_Code_YARDI__c ='d3_cb',Property__c ='Parking', Building_Code__c = 'B-P1-1');
        insert buildingObejct;
        
        Asset_Class__c assetClassObject = new Asset_Class__c(Name = 'Commercial');
        insert assetClassObject;
        
        Unit_Category__c unitCategoryObject = new Unit_Category__c(Name = 'Office',
                                                                   Asset_Class__c = assetClassObject.Id);
        insert unitCategoryObject;

        Unit_Sub_Category__c unitSubCategoryObject = new Unit_Sub_Category__c(Name = 'Standard Office',
                                                                              Unit_Category__c = unitCategoryObject.Id
                                                                             );
        insert unitSubCategoryObject;
        
        Unit__c unitObject1 = new Unit__c(Name  ='Test Unit',Area_ft__c = 910,Building__c = buildingObejct.Id, Unit_Sub_Category__c = unitSubCategoryObject.Id,
                                 		  Unit_Code_YARDI__c = 'B106',Transactional_Unit__c ='Sqft', Floor_Number__c = 'Fifth Floor', Floor_Type__c = '05',
                                          Category_Combination__c = 'Commercial-Office-Standard Office');
       
        Test.startTest();
       
        insert unitObject1;
        unitObject1.Category_Combination__c = 'Test' ;
            
        try{
        	update unitObject1;
        } catch(Exception e){
            errorMessage = e.getMessage();
        }
        Test.stopTest();
        
        System.assertEquals(errorMessage.contains('Unable to find the unit sub category for the given combination.'), true);
    }
   
}