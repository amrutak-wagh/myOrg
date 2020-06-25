/**
 *  @description Test Class for PriceRulePhyicalTabController class
 *
 *  2019-16-07 Anshul Garg
*/
@isTest
public class PriceRulePhysicalTabControllerTest {
    @testsetup public static void createTestData(){
        Price_Rule__c prIns = new Price_Rule__c(Name = 'Test PR');
        insert prIns;
        Business_Park__c bsp = new Business_Park__c(Name = 'TestBP1',Business_Park_Yardi__c = 'Test',Business_Park_Code__c ='TestBP1');
        insert bsp;
        Business_Park__c bsp2 = new Business_Park__c(Name = 'TestBP2',Business_Park_Yardi__c = 'Test2',Business_Park_Code__c ='TestBP2');
        insert bsp2;
        Business_Park__c bsp3 = new Business_Park__c(Name = 'TestBP3',Business_Park_Yardi__c = 'Test3',Business_Park_Code__c ='TestBP3');
        insert bsp3;
        Plot__c plot = new Plot__c(Name = 'testPlot',Plot_Code_YARDI__c = 'pricingEngineTestPlot',Area_sqft__c = 100.0,
            					   Business_Park__c = bsp2.Id,Plot_Name_YARDI__c = 'pricingEngineTestPlotName',
            					   Type__c = 'type',Status__c = 'Available - Sale',Sector_Name__c = 'sectorName');
        insert plot;
        Building__c build1 = new Building__c(Plot__c = plot.Id,Name = 'TestBuilding1' ,Ownership_Type__c = 'TECOM Owned',Building_Code__c ='TestBuilding1',
                                           Development_Status__c = 'Under Development',Property_Code_YARDI__c ='d3_cb',Property__c ='Parking');
        insert build1;
        Building__c build2 = new Building__c(Name = 'TestBuilding2' ,Ownership_Type__c = 'TECOM Owned',Business_Park__c = bsp3.Id,Building_Code__c ='TestBuilding2',
                                           Development_Status__c = 'Under Development',Property_Code_YARDI__c ='d3_cb1',Property__c ='Parking');
        insert build2;
    }
    
    public static testmethod void testGetBusinessParkList(){
        Test.startTest();
        String str = PriceRulePhysicalTabController.getBusinessParkList();
        Test.stopTest();
        System.assert(!String.isBlank(str));
    }
    
    public static testmethod void testGetBuildings(){
        List<Business_Park__c> bpList = [SELECT Id FROM Business_Park__c LIMIT 3];
        Test.startTest();
        String str1 = PriceRulePhysicalTabController.getBuildings(bpList[0].Id);
        String str2 = PriceRulePhysicalTabController.getBuildings(bpList[1].Id);
        String str3 = PriceRulePhysicalTabController.getBuildings(bpList[2].Id);
        Test.stopTest();
        System.assert(!String.isBlank(str1));
    }
    
    public static testmethod void testsaveValuesOnPriceRule(){
        Price_Rule__c prIns = [SELECT Id FROM Price_Rule__c LIMIT 1];
        String selectedBusinessPark = 'TestBP1;TestBP2';
        String selectedBuilding = 'TestBuilding1;TestBuilding2';
        Test.startTest();
        PriceRulePhysicalTabController.saveValuesOnPriceRule(prIns.Id, selectedBusinessPark, selectedBuilding);
        Test.stopTest();
        Price_Rule__c actualPR = [SELECT Id,Business_Park_Value__c FROM Price_Rule__c WHERE Id = :prIns.Id];
        System.assertEquals(selectedBusinessPark+';TestBP3', actualPR.Business_Park_Value__c);
    }
    
    public static testmethod void testgetSelectedRowsId(){
        Price_Rule__c prIns = [SELECT Id FROM Price_Rule__c LIMIT 1];
        String selectedBusinessPark = 'TestBP1;TestBP2';
        String selectedBuilding = 'TestBuilding1;TestBuilding2';
        Test.startTest();
        PriceRulePhysicalTabController.saveValuesOnPriceRule(prIns.Id, selectedBusinessPark, selectedBuilding);
        List<String> selectedValueList = PriceRulePhysicalTabController.getSelectedRowsId(prIns.Id);
        Test.stopTest();
        System.assertEquals(5, selectedValueList.size());
    }
}