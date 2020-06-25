trigger GracePeriodTrigger on Grace_Period__c (after insert,after update,before delete) {
    if(Trigger.isBefore){
        if(Trigger.isDelete){
            GracePeriodTriggerHandler.handleGracePeriodDelete(Trigger.oldMap);
        }
    }else if(Trigger.isAfter){
        if(Trigger.isInsert){
            GracePeriodTriggerHandler.handleGracePeriodInsert(Trigger.newMap);
        }else if(Trigger.isUpdate){
            GracePeriodTriggerHandler.handleGracePeriodUpdate(Trigger.newMap,Trigger.oldMap);
        }
    }
}