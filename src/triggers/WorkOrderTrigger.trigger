trigger WorkOrderTrigger on WorkOrder (before insert, before update) {
    if(Trigger.isBefore && Trigger.isUpdate)
	WorkOrderTriggerHandler.handleBeforeUpdate(Trigger.new);
}