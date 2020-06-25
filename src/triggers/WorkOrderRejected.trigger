trigger WorkOrderRejected on WorkOrder (after update) {
    if(Trigger.isAfter && Trigger.isUpdate){
        List<WorkOrder> objListWorkOrder = new List<WorkOrder>();
         for(WorkOrder objworks : Trigger.new){
             if(objworks.Status != Trigger.oldMap.get(objworks.id).Status && objworks.Status == 'Rejected'){
                 objListWorkOrder.add(objworks);
             }
         }
         if(objListWorkOrder.size() > 0){
             WorkOrderRejectedCTRL.SendMailRejected(objListWorkOrder);
         }
    }
}