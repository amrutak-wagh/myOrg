@isTest
public class TestProductStructure{

    @testSetup static void dataSetup() {
        Business_Park__c bp = new Business_Park__c();
        bp.Name = 'DSC';
        bp.Business_Park_Code__c = 'bPCode';
        bp.Business_Park_Yardi__c = 'eXterNaliD';
        bp.Business_Park_Full_Name__c = 'Dubai Studio City';        
        bp.Cluster_Name__c = 'Media Cluster';
        insert bp;
        
        Plot__c plt1 = new Plot__c();
        plt1.Business_Park__c = bp.id;
        plt1.Plot_Code_YARDI__c = 'P1'; 
        plt1.Plot_Name_YARDI__c = 'Plot 1';
        plt1.Sector_Yardi_Id__c = 'SectorId1';
        plt1.Description__c = 'zxczxczxc12322343';
        plt1.Type__c = 'Plt1 Type';
        plt1.Number__c = 'plt1number';
        plt1.Status__c = 'Pre Lease';
        plt1.Active__c = true;
        plt1.Sector_Name__c = 'DummySector';
        plt1.Area_sqft__c = 12.3;
        insert plt1;
        
        Plot__c plt2 = new Plot__c();
        plt2.Business_Park__c = bp.id;
        plt2.Origin_Plot__c = plt1.id;
        plt2.Plot_Code_YARDI__c = 'P2'; 
        plt2.Plot_Name_YARDI__c = 'Plot 2';
        plt2.Sector_Yardi_Id__c = 'SectorId2';
        plt2.Description__c = 'zxczxczxc12322343';
        plt2.Type__c = 'Plt2 Type';
        plt2.Number__c = 'plt2number';
        plt2.Status__c = 'Sold';
        plt2.Active__c = true;
        plt2.Sector_Name__c = 'DummySector2';
        plt2.Area_sqft__c = 112.3;
        insert plt2;
        
        Land_Use__c landUse = new Land_Use__c();
        landUse.Name = 'Commercial';
        landUse.Plot__c = plt2.id;
        landUse.Active__c = true;
        landUse.Plot_YARDI_Id__c = plt2.Plot_Code_YARDI__c;
        landUse.YARDI_Id__c = 'LandUseYardiID';
        landUse.GFA_Sqft__c = 100;
        landUse.GFA_Sqmt__c = 9.3;
        landUse.Rate_c__c = 10;
        landUse.Level_1__c = 'LVl1';
        landUse.Level_2__c = 'LVl2';
        landUse.Level_3__c = 'LVl3';
        landUse.Split_Percent__c = 12.3;
        insert landUse;
        
        Sector__c sec = new Sector__c();
        sec.Name = 'Sector 1';
        sec.Business_Park__c = bp.id;
        sec.Number_of_Sector_Parkings__c = 3;
        sec.Paid_Parking_Available_c__c = 2;
        sec.Sector_Yardi_Id__c = 'SID';
        insert sec;
        
        Building__c bldg = new Building__c();
        bldg.Name = 'Building 01';
        bldg.Business_Park__c = bp.id;
        bldg.Active__c = true; 
        bldg.Plot__c = plt2.id;
        bldg.Property_Code_YARDI__c = 'P2B1';
        bldg.Unique_Key__c = 'DSCP2B1';
        bldg.Description__c = 'Building 1 Description';
        bldg.Development_Status__c = 'Developed';
        bldg.Property_Name__c = 'Property Name';
        bldg.Property_Type__c = 'Office';
        bldg.Ownership_Type__c = 'PMLA';
        bldg.Property__c = 'Not applicable';
        insert bldg;
        
        Asset_Class__c aClass = new Asset_Class__c();
        aClass.Name = 'Asset Class 1';
        insert aClass;
        
        Unit_Category__c uCategory = new Unit_Category__c();
        uCategory.Name = 'Category 1';
        uCategory.Asset_Class__c = aClass.id;
        uCategory.Integration_Flag__c = true;
        uCategory.Push_LeaseItems_To_DCCA__c = true;
        uCategory.Type__c = 'Commercial';
        insert uCategory;
        
        Unit_Sub_Category__c uSubCat = new Unit_Sub_Category__c();
        uSubCat.Name = 'Unit Sub Category 1';
        uSubCat.Activity__c = 'Office';
        uSubCat.Unit_Category__c = uCategory.id;
        uSubCat.SQL_Integration_Status__c = 'Success';      
        uSubCat.Push_LeaseItems_To_DCCA__c = true;
        uSubCat.Integration_Flag__c = true;
        insert uSubCat;
        
        Unit__c unit = new Unit__c();
        unit.Name = 'Unit 1';
        unit.Building__c = bldg.id;
        unit.Unit_Sub_Category__c = uSubCat.id;
        unit.Floor_Type__c = 'Floor';
        unit.Floor_Number__c = '1';
        unit.Active__c = true;
        unit.Unit_Code_YARDI__c = 'UnitCodeYD';
        unit.Floor_Type__c = 'Parking';
        unit.Floor_Number__c = 'Floor number';
        unit.Area_Validated__c = true;
        unit.Allowed_Visas__c = 11;
        unit.Is_Leasable__c = false;
        unit.No_of_Beds__c = 12;
        unit.Transactional_Unit__c = 'Sqft';
        unit.DEWA_Charge__c = false;
        unit.Cooling_Charge__c = false;
        unit.Core_NonCore__c = 'None';
        insert unit;
        
        Product2 p1 = new Product2();
        p1.Name = 'B1-101';
        p1.IsActive = true;
        p1.Building__c = bldg.id;
        p1.Unit_Sub_Category__c = uSubCat.id;
        p1.Unit__c = unit.id;
        p1.Plot__c = plt2.id;
        p1.Unique_Key__c = 'UnQKey';
        p1.Area_ft__c = 100;
        p1.GFA_Area_ft__c = 100;
        p1.Required__c = true;
        p1.Sales_Priority__c = 'NA';
        p1.Type__c = 'DDA';
        insert p1;
        
        Product2 p2 = new Product2();
        p2.Name = 'B1-102';
        p2.IsActive = true;
        p2.Building__c = bldg.id;
        p2.Unit_Sub_Category__c = uSubCat.id;
        p2.Unit__c = unit.id;
        p2.Plot__c = plt2.id;
        p2.Unique_Key__c = 'UniQKey';
        p2.Area_ft__c = 10;
        p2.GFA_Area_ft__c = 10;
        p2.Required__c = true;
        p2.Sales_Priority__c = 'NA';
        p2.Type__c = 'Parking Cards';
        insert p2;
        
        Bundle_Item__c bItem = new Bundle_Item__c();
        bItem.Service__c = p1.id;
        bItem.Service_Item__c = p2.id;
        insert bItem;
    }
    
    static testMethod void TestData1() {
        Business_Park__c b = [Select Id, Name, Business_Park_Yardi__c, Business_Park_Code__c, Business_Park_Full_Name__c, Cluster_Name__c from Business_Park__c LIMIT 1];
        Plot__c pl1 = [Select Id, Business_Park__c, Name, Plot_Code_YARDI__c, Plot_Name_YARDI__c, Description__c, Type__c, Number__c, Status__c, Active__c, Sector_Name__c, Area_sqft__c  from Plot__c where Plot_Code_YARDI__c = 'P1' LIMIT 1];
        Plot__c pl2 = [Select Id, Business_Park__c, Name, Plot_Code_YARDI__c, Plot_Name_YARDI__c, Description__c, Type__c, Number__c, Status__c, Active__c, Sector_Name__c, Area_sqft__c  from Plot__c where Plot_Code_YARDI__c = 'P2' LIMIT 1];
        Land_Use__c lUse = [Select Id, Name,Plot__c,Plot_YARDI_Id__c,Rate_c__c, Level_1__c, Level_2__c, Level_3__c, GFA_Sqft__c, GFA_Sqmt__c, Split_Percent__c, Active__c from Land_Use__c where Name = 'Commercial' LIMIT 1];
        Sector__c sc = [Select Id, Name, Business_Park__c, Sector_Yardi_Id__c from Sector__c where Name = 'Sector 1' LIMIT 1];
        Building__c bg = [Select Id, Name, Business_Park__c, Plot__c, Property_Code_YARDI__c, Unique_Key__c, Description__c, Development_Status__c, Property_Name__c, Property_Type__c, Ownership_Type__c from Building__c where Name = 'Building 01' LIMIT 1];
        Asset_Class__c ac = [Select Id, Name from Asset_Class__c where Name = 'Asset Class 1' LIMIT 1];
        Unit_Category__c uCat = [Select Id, Name, Asset_Class__c, Type__c from Unit_Category__c where Name = 'Category 1' LIMIT 1];
        Unit_Sub_Category__c uSCat = [Select Id, Name, Activity__c, Unit_Category__c from Unit_Sub_Category__c where Name = 'Unit Sub Category 1' LIMIT 1];
        Unit__c u = [Select Id, Name, Building__c, Unit_Sub_Category__c, Floor_Type__c, Floor_Number__c, Area_Validated__c, Allowed_Visas__c, Is_Leasable__c, No_of_Beds__c, Transactional_Unit__c, DEWA_Charge__c, Cooling_Charge__c, Core_NonCore__c from Unit__c where Name = 'Unit 1' LIMIT 1];
        Product2 pr1 = [Select Id, Name, Building__c, Unit_Sub_Category__c, Unit__c, Plot__c, Unique_Key__c, Type__c from Product2 where Name = 'B1-101' LIMIT 1];
        Product2 pr2 = [Select Id, Name, Building__c, Unit_Sub_Category__c, Unit__c, Plot__c, Unique_Key__c, Type__c from Product2 where Name = 'B1-102' LIMIT 1];
        Bundle_Item__c bIt = [Select Id, Name, Service_Item__c, Service__c from Bundle_Item__c LIMIT 1]; 
        
        
        
        //Plot Validations
        //Plot Name yardi validation
        pl1.Plot_Name_YARDI__c = pl2.Plot_Name_YARDI__c;
        //Type and Number
        pl1.Type__c ='Any text Value';
        pl1.Number__c = 'Any text Value';
        //Sector name and Sector Yardi ID without any Sector
        pl1.Sector__c = null;
        pl1.Sector_Name__c = 'SecName';
        pl1.Sector_Yardi_Id__c = 'SecYardiIdew';
        try{
            update pl1;
        }
        catch(DmlException e){
            System.assert(e.getMessage().contains('failed'), e.getMessage()); 
        }
        
        //Land use with no values
        lUse.YARDI_Id__c = null;
        lUse.Level_1__c = null;
        lUse.Level_2__c = null;
        lUse.Level_3__c = null;
        lUse.GFA_Sqft__c = null;
        lUse.GFA_Sqmt__c = null;
        lUse.Split_Percent__c = null;
        try{
            update lUse;
        }
        catch(DmlException e){
            System.assert(e.getMessage().contains('failed'), e.getMessage()); 
        }
        
        
        
        //Type in Unit Category and Actvity in Unit Sub Category
        uCat.Type__c = 'Residential';
        uSCat.Activity__c = 'Industrial'; // Purpose of activity Field
        try{
            update uCat;
            update uSCat;
        }
        catch(DmlException e){
            System.assert(e.getMessage().contains('failed'), e.getMessage()); 
        }
        
        //Entering a new Business Park with name same as of existing BP.
        Business_Park__c bPark = new Business_Park__c();
        bPark.Name = 'DSC';
        bPark.Business_Park_Code__c = 'bPCode1';
        bPark.Business_Park_Yardi__c = 'eXterNaliD1';
        bPark.Business_Park_Full_Name__c = 'Dubai Studio City';        
        bPark.Cluster_Name__c = 'Media Cluster';
        try{
            insert bPark;
        }
        catch(DmlException e){
            System.assert(e.getMessage().contains('failed'), e.getMessage()); 
        }
        
        //Building with blank values and a different BP and a Plot with different BP
        Building__c bldn = new Building__c();
        bldn.Property_Code_YARDI__c = null;
        bldn.Description__c = null;
        bldn.Development_Status__c = null;
        bldn.Property__c = 'Office';
        bldn.Ownership_Type__c = null;
        bldn.Unique_Key__c = null;
        bldn.Plot__c = pl1.id;
        bldn.Business_Park__c = bPark.id;
        try{
            insert bldn;
        }
        catch(DmlException e){
            System.assert(e.getMessage().contains('failed'), e.getMessage()); 
        }
        
        Unit_Category__c uCategory2 = new Unit_Category__c();
        uCategory2.Name = 'Category 2';
        uCategory2.Asset_Class__c = ac.id;
        uCategory2.Integration_Flag__c = true;
        uCategory2.Push_LeaseItems_To_DCCA__c = true;
        uCategory2.Type__c = 'Commercial';
        insert uCategory2;
        
        Unit_Sub_Category__c uSubCat2 = new Unit_Sub_Category__c();
        uSubCat2.Name = 'Unit Sub Category 2';
        uSubCat2.Activity__c = 'Office';
        uSubCat2.Unit_Category__c = uCategory2.id;
        uSubCat2.SQL_Integration_Status__c = 'Success';      
        uSubCat2.Push_LeaseItems_To_DCCA__c = true;
        uSubCat2.Integration_Flag__c = true;
        insert uSubCat2;
        
        //Product with different Building, Plot, Unit Category and Unit Sub Category
        pr1.Building__c = bldn.id;
        pr1.Plot__c = pl2.id;
        pr1.Unit__c = u.id;
        pr1.Unit_Sub_Category__c = uSubCat2.id ;       
        try{
            update pr1;
        }
        catch(DmlException e){
            System.assert(e.getMessage().contains('failed'), e.getMessage()); 
        }
    }
    
    static testMethod void TestData2() {
        Plot__c plt1 = [Select Id, Business_Park__c, Name, Plot_Code_YARDI__c, Plot_Name_YARDI__c, Description__c, Type__c, Number__c, Status__c, Active__c, Sector_Name__c, Area_sqft__c  from Plot__c where Plot_Code_YARDI__c = 'P1' LIMIT 1];
        Plot__c plt2 = [Select Id, Business_Park__c, Name, Plot_Code_YARDI__c, Plot_Name_YARDI__c, Description__c, Type__c, Number__c, Status__c, Active__c, Sector_Name__c, Area_sqft__c  from Plot__c where Plot_Code_YARDI__c = 'P2' LIMIT 1];
        Sector__c sct = [Select Id, Name, Business_Park__c, Sector_Yardi_Id__c from Sector__c where Name = 'Sector 1' LIMIT 1];
        
        //Entering a new Business Park with name same as of existing BP.
        Business_Park__c bPark = new Business_Park__c();
        bPark.Name = 'DSC';
        bPark.Business_Park_Code__c = 'bPCode1';
        bPark.Business_Park_Yardi__c = 'eXterNaliD1';
        bPark.Business_Park_Full_Name__c = 'Dubai Studio City';        
        bPark.Cluster_Name__c = 'Media Cluster';
        try{
            insert bPark;
        }
        catch(DmlException e){
            System.assert(e.getMessage().contains('failed'), e.getMessage()); 
        }
        
        // One More Sector with Different BP and no Yardi Id
        Sector__c sec2 = new Sector__c();
        sec2.Name = 'Sector 1';
        sec2.Business_Park__c = bPark.id;
        sec2.Number_of_Sector_Parkings__c = 32;
        sec2.Paid_Parking_Available_c__c = 22;
        sec2.Sector_Yardi_Id__c = 'secId';
        try{
            insert sec2;
        }
        catch(DmlException e){
            System.assert(e.getMessage().contains('failed'), e.getMessage()); 
        }
        
        //Sector added without sector details
        plt2.Sector__c = sec2.id;
        plt2.Sector_Name__c = null;
        plt2.Sector_Yardi_Id__c = null; 
        try{
            update plt2;
        }
        catch(DmlException e){
            System.assert(e.getMessage().contains('failed'), e.getMessage()); 
        }
        //Origin Plot with different Sectors (with different BP) and Origin Plots for each other
        //pl2 already has pl1 as its origin plot
        plt1.Origin_Plot__c = plt2.id;
        plt1.Sector__c = sct.id;
        try{
            update plt1;
        }
        catch(DmlException e){
            System.assert(e.getMessage().contains('failed'), e.getMessage()); 
        }
        
    }
}