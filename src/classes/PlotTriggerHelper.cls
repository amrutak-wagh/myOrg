/***********************************************************************************************
* Name              : PlotTriggerHelper                                                 
* Description       : PlotTriggerHelper class is a helper class for PlotTrigger.
* Created Date      : 19/05/2019                                                    
* Created By        : Prachi Sinha (prachi.sinha@were4c.com)                                                                                                    
* ----------------------------------------------------------------------------------------------
* VERSION   Developer   Date        Description     Ticket/Reference                                                                    
* 1.0       Prachi      19/05/2019   Created                              
************************************************************************************************/
public with sharing class PlotTriggerHelper{

    /************************************************************************************
    Method  :         populateSector 
    Description :     populate sector lookup field based on the sector name field - before insert
    Version :         1.0
    ************************************************************************************/
    public static void populateSector(List<Plot__c> plotList){
    
        List<Sector__c> sectorList = [select id, Name from sector__c];
        Map<String,Id> sectorNameMap = new Map<String,Id>();
        
        //sector names will never be duplicate
        for(Sector__c secRec : sectorList){
            sectorNameMap.put(secRec.name,secRec.Id);
        }
        
        for(Plot__c plotRec: plotList){
            if(plotRec.Sector_Name__c <> null){
                if(sectorNameMap.containsKey(plotRec.Sector_Name__c)){
                    plotRec.Sector__c = sectorNameMap.get(plotRec.Sector_Name__c);
                }
            }
        }
    }
    
    /************************************************************************************
    Method  :         populateSectorUpdate 
    Description :     populate sector lookup field based on the sector name field - before update
    Version :         1.0
    ************************************************************************************/
    public static void populateSectorUpdate(List<Plot__c> plotNewList, Map<Id,Plot__c> plotOldMap){
    
        List<Plot__c> plotList = new List<Plot__c>();
        for(Plot__c plotRecord : plotNewList){
            if(plotOldMap.get(plotRecord.Id).Sector_Name__c != plotRecord.Sector_Name__c){
                plotList.add(plotRecord);
            }
        }
        
        if(plotList.size() > 0){
            populateSector(plotList);
        }                
    }
    
    
    /************************************************************************************
    Method  :         populateBusinessPark
    Description :     populate business park lookup field based on the business park short name field - before insert
    Version :         1.0
    ************************************************************************************/
    public static void populateBusinessPark(List<Plot__c> plotList){
    
        List<Business_Park__c> businessParkList = [select id, Name from Business_Park__c];
        Map<String,Id> bpNameMap = new Map<String,Id>();
        
        //business park names will never be duplicate
        for(Business_Park__c bpRec : businessParkList){
            bpNameMap.put(bpRec.name,bpRec.Id);
        }
        
        for(Plot__c plotRec: plotList){
            if(plotRec.Business_Park_Yardi__c <> null){
                if(bpNameMap.containsKey(plotRec.Business_Park_Yardi__c)){
                    plotRec.Business_Park__c = bpNameMap.get(plotRec.Business_Park_Yardi__c);
                }
            }
        }
    }
    
    /************************************************************************************
    Method  :         populateBusinessParkUpdate 
    Description :     populate business park lookup field based on the business park short name field - before update
    Version :         1.0
    ************************************************************************************/
    public static void populateBusinessParkUpdate(List<Plot__c> plotNewList, Map<Id,Plot__c> plotOldMap){
    
        List<Plot__c> plotList = new List<Plot__c>();
        for(Plot__c plotRecord : plotNewList){
            if(plotOldMap.get(plotRecord.Id).Business_Park_Yardi__c != plotRecord.Business_Park_Yardi__c){
                plotList.add(plotRecord);
            }
        }
        
        if(plotList.size() > 0){
            populateBusinessPark(plotList);
        }                
    }
    
}