/***********************************************************************************************
* Name              : UnitTrigger                                                 
* Description       : Trigger for Unit object                                           
* Created Date      : 19/05/2019                                                    
* Created By        : Prachi Sinha (prachi.sinha@were4c.com)                                                                                                    
* ----------------------------------------------------------------------------------------------
**/

trigger UnitTrigger on Unit__c (before insert, before update) {

    if(trigger.IsBefore){
        if(trigger.IsInsert){
            if(UnitTriggerHelper.IsInsert == true){
                UnitTriggerHelper.isInsert = false;
                UnitTriggerHelper.populateUnitSubCategory(Trigger.new);
            }
        }
    
        //before update
        if(trigger.IsUpdate){    
            if(UnitTriggerHelper.isUpdate == true){
                UnitTriggerHelper.isUpdate = false;
                UnitTriggerHelper.populateUnitSubCategoryUpdate(Trigger.new, Trigger.oldMap);
            }
        }
    }    
}