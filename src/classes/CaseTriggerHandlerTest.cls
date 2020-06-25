@isTest
public class CaseTriggerHandlerTest {
    public static testmethod void testMethod1(){
        Account a = new Account(Name = 'Test Account');
        insert a;
        Contact con = new Contact(AccountId = a.Id,LastName = 'Test Contact');
        insert con;
        Case c = new Case(Status = 'New',Type ='Termination',ContactId = con.Id,AccountId = a.Id);
        insert c;
        WorkOrder w= new WorkOrder(CaseId = c.Id,Status= 'New');
        insert w;
        try{
            c.Status = 'Closed - Approved';
            update c;
        }catch(Exception e){
            
        }
    }
    public static testmethod void testMethod2(){
        Account a = new Account(Name = 'Test Account');
        insert a;
        Contact con = new Contact(AccountId = a.Id,LastName = 'Test Contact');
        insert con;
        Case c = new Case(Status = 'New',Type ='Termination',ContactId = con.Id,AccountId = a.Id);
        insert c;
        WorkOrder w= new WorkOrder(CaseId = c.Id,Status= 'New');
        insert w;
        try{
            c.Status = 'Closed - Rejected';
            update c;
        }catch(Exception e){
            
        }
    }
}