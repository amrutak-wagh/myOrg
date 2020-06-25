public class LeaseMergerBatchScheduler implements Schedulable {
	public void execute(SchedulableContext sc){
        LeaseMergerBatch batchIns = new LeaseMergerBatch(); //ur batch class
        Database.executebatch(batchIns);
    }
}