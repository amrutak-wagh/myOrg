/**
 *  @description Extension for QLIOverrideDeletePage - which overrides QLI delete button.
 *
 *  2019-08-27  Amruta K   Restrict to delete if the Opportunity type is Renewal and Sub-type is Expansion.
 */
public class QLIOverrideDeleteExtension {
	public final QuoteLineItem qliRecord {get; set;}
    private ApexPages.StandardController stdCtrl;
    public Boolean displayError {get; set;}
    public Boolean displaySuccess {get; set;}
    public QLIOverrideDeleteExtension(ApexPages.StandardController stdController) {
        this.qliRecord = (QuoteLineItem)stdController.getRecord();
        stdCtrl = stdController;
        stdCtrl.getRecord();
        displayError = false;
        displaySuccess = false;
    }
    
    // Method to delete QLI from detail page of QLI and display proper success/Error message.
    public PageReference checkOpportunity() {
        List<QuoteLineItem> qliLst = [SELECT 
                                      	Id, 
                                      	QuoteId, 
                                      	Quote.Opportunity.Type,
                                      	Quote.Opportunity.Sub_Type__c 
                                      FROM QuoteLineItem
                                      WHERE Id =:qliRecord.Id ];
        
        if(qliLst[0].Quote.Opportunity.Type == 'Renewal' && qliLst[0].Quote.Opportunity.Sub_Type__c == 'Expansion') {
			
            displayError = true;
            displaySuccess = false;
            return null;
        }
        else {
            try{
                delete qliLst[0];
                displaySuccess = true;
                displayError = false;
            }
            catch(Exception e) {
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.WARNING,e.getMessage());
            	ApexPages.addMessage(myMsg);
            }
            
            return null;
        }
    }
}