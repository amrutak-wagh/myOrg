/***********************************************************************************************
* Name              : CaseTrigger                                                 
* Description       : Trigger for Case object                                                                                            
* Created By        : Raza Khan (raza.khan@were4c.com)                                                                                                    
* ----------------------------------------------------------------------------------------------
**/
trigger CaseTrigger on Case (before update,after update) {
    
    if(trigger.isupdate && trigger.isafter)
    {
        AccountIntegrationUtil.updateAccountStatusYardiIntegration(trigger.new, trigger.oldmap);
        CaseTriggerHandler.afterUpdate(trigger.new);
        TerminationIntegrationUtil.sendBranSalesTerminationToYardi(trigger.new, trigger.oldmap);
        TerminationIntegrationUtil.sendKeyHandoverTerminationToYardi(trigger.new, trigger.oldmap);
    }
    if(Trigger.isUpdate && Trigger.isBefore){
        CaseTriggerHandler.beforeUpdate(trigger.oldMap,trigger.New);
    }
}