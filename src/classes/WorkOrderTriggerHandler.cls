public class WorkOrderTriggerHandler {
    public static void handleBeforeUpdate(List<WorkOrder> workOrderList){
        WorkOrderUtils.checkWorkOrderSequence(workOrderList);
    }
}