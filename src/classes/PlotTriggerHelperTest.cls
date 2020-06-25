/**
 *  @description Test class for PlotTriggerHelper
 *
 *  2019-08-19  Shraddha N    First version
 *  
 */

@isTest
public class PlotTriggerHelperTest {
	 //Common test data to be used in test class
    @isTest
    public static void insertUpdateTest(){
        String errorMessage = '';
        Sector__c sectorObject = new Sector__c(Name = 'Sector 1');
        insert sectorObject;
        
        Business_Park__c businessParkObject = new Business_Park__c(Name = 'D3', Business_Park_Code__c = 'D3');
        
        Test.startTest();
        insert businessParkObject;
        
        Plot__c plotObject = new Plot__c(Name = 'Test Plot 1',Plot_Code_YARDI__c = 'pricingEngineTestPlot 1',Area_sqft__c = 100.0,
            					   		  Business_Park__c = businessParkObject.Id,Plot_Name_YARDI__c = 'pricingEngineTestPlotName 1' ,
            					   		  Type__c = 'Type 1',Status__c = 'Available - Sale',Sector_Name__c = sectorObject.Name, 
                                          Business_Park_Yardi__c = businessParkObject.Name);

        insert plotObject;
        
        plotObject.Sector_Name__c = 'Test Sector';
        plotObject.Business_Park_Yardi__c = 'Test Business Park Yardi';
        
        try{
            update plotObject;
        } catch(Exception e){
            errorMessage = e.getMessage();
        }
        
        Test.stopTest();
        
        System.assertEquals(errorMessage, '');
    }
    
}