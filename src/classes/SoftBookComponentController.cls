/***********************************************************************************************
* Name              : SoftBookComponentController                                                 
* Description       : Controller class for lightning component 'SoftBook'
* Created Date      : 31/07/2019                                                    
* Created By        : Adeel Ahmad (adeel.ahmad@were4c.com)                                                                                                    
* ---------------------------------------------------------------------------------------------- */
public class SoftBookComponentController {
    
    /*
     * 31/07/2019 - Adeel Ahmad
     * Lightning method to do soft booking.
     * Returns list of products2 if already soft booked.
    */
	@AuraEnabled
    public static SoftBookWrapper doSoftBooking(String quoteId){
        SoftBookWrapper wrp = new SoftBookWrapper();
		wrp.isSuccessfull = true;
        Quote quote = [SELECT Id, Soft_Book__c,Opportunity.Id, Opportunity.Probability,Soft_Booking_Date_Time__c FROM Quote WHERE Id=:quoteId];
        LIST<QuoteLineItem> qItems = [SELECT Id,Product2.Id,Product2.Name,Product2.Status__c,Product2.Unit__c,Product2.Unit__r.Status__c FROM QuoteLineItem WHERE QuoteId =:quoteId];
        if(quote.Opportunity.Probability < 50){
            wrp.isSuccessfull = false;
            wrp.validationMessage = 'The Opportunity probability is less than 50%. You can not soft book the products or Unit on this Quote.';
        }else if(quote.Soft_Book__c == true){
            wrp.isSuccessfull = false;
            wrp.validationMessage = 'The Quote has already been soft-booked.';            
        }else{
            if(qItems.size() == 0){
                wrp.isSuccessfull = false;
                wrp.validationMessage = 'Please add Products to be able to Soft-Book the Quote';                            
            }else{
                try{
                    SET<String> alreadyBookedProducts = new SET<String>();
                    for(QuoteLineItem qli : qItems){
                        if(qli.Product2.Status__c == 'Soft Booked'){
                            alreadyBookedProducts.add(qli.Product2.Name);
                        }
                        if(qli.Product2.Unit__r.Status__c == 'Soft Booked'){
                            alreadyBookedProducts.add(qli.Product2.Name);
                        }
                    }
                    if(alreadyBookedProducts.size() > 0){
                        wrp.isSuccessfull = false;
                        wrp.validationMessage = 'Unable to perform action.';     
                        wrp.softBookedItems = new LIST<String>();
                        wrp.softBookedItems.addAll(alreadyBookedProducts);
                    }else{
                        quote.Soft_Book__c = true;
                        quote.Soft_Booking_Date_Time__c = DateTime.now();
                        update quote;                    
                        wrp.isSuccessfull = true;
                        wrp.successMessage = 'Congratulations! The Quote has been Soft-Booked.';                        
                    }
                }catch(Exception e){
                    wrp.isSuccessfull = false;
                	wrp.validationMessage = e.getMessage();
                }
            }
        }
		return wrp;
    }
    
    public class SoftBookWrapper{
        @AuraEnabled public Boolean isSuccessfull {get; set;}
        @AuraEnabled public String validationMessage {get; set;}
        @AuraEnabled public String successMessage {get; set;}
        @AuraEnabled public LIST<String> softBookedItems {get; set;}
    }
}