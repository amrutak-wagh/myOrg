/***********************************************************************************************
* Name              : PlotTrigger                                                 
* Description       : Trigger for Plot object                                           
* Created Date      : 19/05/2019                                                    
* Created By        : Prachi Sinha (prachi.sinha@were4c.com)                                                                                                    
* ----------------------------------------------------------------------------------------------
**/

trigger PlotTrigger on Plot__c (before insert, before update) {
    
    if(trigger.IsBefore){
        //before insert
        if(trigger.IsInsert){
            PlotTriggerHelper.populateSector(Trigger.new);
            PlotTriggerHelper.populateBusinessPark(Trigger.new);
        }
        
        //before update
        if(trigger.IsUpdate){    
            PlotTriggerHelper.populateSectorUpdate(Trigger.new, Trigger.oldMap);
            PlotTriggerHelper.populateBusinessParkUpdate(Trigger.new, Trigger.oldMap);
        }
    }   
}