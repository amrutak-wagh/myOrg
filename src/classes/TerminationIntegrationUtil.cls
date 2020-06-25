/***********************************************************************************************
* Name              : TerminationIntegrationUtil                                               
* Description       : Supportintg utility class Real-time integration for termination details to be sent to OIC, which will push the details to Yardi
* Created Date      : 06/08/2019                                                    
* Created By        : Raza khan (raza.khan@were4c.com)                                                                                                    
* ----------------------------------------------------------------------------------------------
* VERSION   Developer   Date        Description     Ticket/Reference                                                                    
* 1.0       Raza      20/06/2019   Created 
************************************************************************************************/
public with sharing class TerminationIntegrationUtil {
    
    private static Id terRecTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Lease Termination').getRecordTypeId();
   
    public static void sendBranSalesTerminationToYardi(List<Case> cases, Map<Id, Case> oldMap)
    {
        List<Id> terminationCases = new List<Id>();
        for(Case c: cases)
        {
            if((c.status == 'Brand Sales Approved' || (c.Status == 'Cancelled' && c.Is_Cancelled__c)) &&
               c.status != oldmap.get(c.id).status && c.recordtypeId == terRecTypeId  )
            {
                terminationCases.add(c.id);
            }
        }
        if(!terminationCases.isEmpty())
        {
            sendTerminationToYardi(terminationCases);
        }
    }
    
    public static void sendKeyHandoverTerminationToYardi(List<Case> cases, Map<Id, Case> oldMap)
    {
        List<Id> terminationCases = new List<Id>();
        for(Case c: cases)
        {
            if( c.Key_Handover_Date__c  != oldmap.get(c.id).Key_Handover_Date__c  && c.status == 'Finance Approved' &&
               c.recordtypeId == terRecTypeId )
            {
                terminationCases.add(c.id);
            }
        }
        if(!terminationCases.isEmpty())
        {
            sendTerminationToYardi(terminationCases);
        }
    }
    
    @future(callout = true )
    public static void sendTerminationToYardi(List<Id> caseIds)
    {
         TerminationIntegration.sentTerminationToOIC(caseIds);
    }

}