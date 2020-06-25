/***********************************************************************************************
* Name              : NewRenewLeaseIntegration                                               
* Description       : Real-time integration for lease details to be sent to OIC, which will push the details to Yardi
* Created Date      : 20/06/2019                                                    
* Created By        : Prachi Sinha (prachi.sinha@were4c.com)                                                                                                    
* ----------------------------------------------------------------------------------------------
* VERSION   Developer   Date        Description     Ticket/Reference                                                                    
* 1.0       Prachi      20/06/2019   Created 
* 2.0       Raza                     Updated         send TOR information with same lease integration call
* 2.1       Raza        16/07/2019   Updated         update the records for new lease response & HSE response received from OIC
* 2.2 .     Raza .      05/09/2019 . Updated .       Update the controller to handle the amendments related changes
************************************************************************************************/

public without sharing class NewRenewLeaseIntegration{
    private static Map<String,String> leasestatus = new Map<String,String>{'New'=>'Original Lease', 'Amendment'=>'Modification'};

    /************************************************************************************
    Method  :         sendLeaseToOIC 
    Description :     POST lease details to OIC endpoint
    Version :         1.0
					  2.0 - send TOR information with same lease integration call
					  3.0 - update the quote & opportunity and insert paymentschedule response received  from OIC
					  4.0 - update the quote status Accepted to 'CCL Acceptance' to send the lease for ccl accepted
					  5.0 - update to handle the amendments quote fields 
    ************************************************************************************/
    public static void sendLeaseToOIC(List<Id> quoteIdList){
    
        List<Quote> quoteList = [SELECT Id,Opportunity.Id,Opportunity.Parent_Amendment_Id__c,Opportunity.Type,Opportunity.Sub_Type__c,Account__c,
                            Opportunity.T_Code__c,Yardi_Brand_Code__c,Status,Opportunity.Name,Opportunity.Lease_Type__c,Proposed_Start_Date__c,
                            Proposed_End_Date__c,Opportunity.Retail_Sales_Category__c,Yardi_Customer_Code__c,contact.account.Legal_Name__c,opportunity.account.Yardi_Account_Id__c,
                            CCL_Sign_Date__c,Description,Opportunity.AG_Number__c,CurrencyISOCode,Legal_Terms_Changed__c,Contact.Yardi_Contact_Id__c,opportunity.Contact__r.Yardi_Contact_Id__c,
                            Payment_Terms__r.Yardi_Code__c,opportunity.account.Legal_name__c,Expansion_Separate_Amendment_Terms__c , (select Transaction_Unit__c	,Best_Rate__c, Yardi_Unit_ID__c ,Product_Code__c,                                                                                                       
                            Start_Date__c,End_Date__c,Charge_Code__c,Offer_Price__c,Transactional_Unit__c,No_of_Beds__c,CurrencyISOCode,Proration_Method__c, Yardi_Charge_Code__c, Payment_Term_Yardi_Code__c,  
                          	Type__c,Product2.Unique_Key__c from quoteLineItems) 
                            from quote where id in: quoteIdList];

        map<Id,List<Turn_Over_Rent__c>> turnOverRents = new Map<Id,List<Turn_Over_Rent__c>>();
        for(Turn_Over_Rent__c tor: [SELECT BreakPoint_Frequency__c,CreatedById,CreatedDate,CurrencyIsoCode,Id,IsDeleted,LastModifiedById,
                            LastReferencedDate,LastViewedDate,Name,Natural_Breakpoint_Percentage__c,Natural_Breakpoint__c,Overage_From_Date__c,Overage_Offset_Account_Charge_Code_1__c,
                            Overage_Offset_Account_Charge_Code_2__c,Overage_Offset_Account_Charge_Code_3__c,Overage_Offset_Account_Charge_Code_4__c,Overage_Offset_Account_Charge_Code_5__c,
                            Overage_Offset_Type__c,Overage_To_Date__c,OwnerId,Quote__c,Retail_Billing_Frequency__c,Retail_End_Date__c,Retail_Start_Date__c,Sales_End_Of_Year__c,Sales_Report_Frequency__c,Sales_Type__c
                            FROM Turn_Over_Rent__c where Quote__c in:quoteIdList ])
                            {
                                List<Turn_Over_Rent__c> tors = turnOverRents.get(tor.Quote__c);
                                if(tors == null)
                                {
                                    tors = new List<Turn_Over_Rent__c>();
                                    turnOverRents.put(tor.Quote__c, tors);
                                }
                                tors.add(tor);
                            }
                            
        List<Quote> quoteListToUpdate = new List<Quote>();
        List<Opportunity> opportunityListToUpdate = new List<Opportunity>();
        List<Payment_Schedule__c> paymenySchedulesToInsert = new List<Payment_Schedule__c>();
        
        //RealTimeIntegrationFramework
        for(Quote quoteRecord : quoteList){
            
            RequestWrapper.LeaseRequestWrapper requestWrap = new RequestWrapper.LeaseRequestWrapper();
            requestWrap.opportunityId = quoteRecord.Opportunity.Id;
            requestWrap.quoteId = quoteRecord.id;
            requestWrap.parentAmendmentId = (quoteRecord.Opportunity.Parent_Amendment_Id__c != null)? Integer.valueOf(quoteRecord.Opportunity.Parent_Amendment_Id__c) : 0;
            requestWrap.opportunityType =  quoteRecord.Opportunity.Type != 'Renewal'? leasestatus.get(quoteRecord.Opportunity.Type) : quoteRecord.Opportunity.Type;
            requestWrap.opportunitySubType = (quoteRecord.Opportunity.Sub_Type__c != null) ? quoteRecord.Opportunity.Sub_Type__c: '';
            requestWrap.opportunityTCode = (quoteRecord.Opportunity.T_Code__c!= null)? quoteRecord.Opportunity.T_Code__c: '';
            requestWrap.yardiBrandCode = (quoteRecord.Yardi_Brand_Code__c != null) ?quoteRecord.Yardi_Brand_Code__c : '' ;
            requestWrap.quoteStatus = (quoteRecord.Status == 'Accepted')? 'CCL Acceptance': quoteRecord.Status ;
            requestWrap.opportunityLeaseType = quoteRecord.Opportunity.Lease_Type__c;
            requestWrap.quoteStartDate = quoteRecord.Proposed_Start_Date__c;
            requestWrap.quoteEndDate = quoteRecord.Proposed_End_Date__c;
            requestWrap.opportunitySalesCategory = (quoteRecord.Opportunity.Retail_Sales_Category__c != null)? quoteRecord.Opportunity.Retail_Sales_Category__c: '';
            requestWrap.yardiCustomerCode = quoteRecord.Yardi_Brand_Code__c;
            requestWrap.accountLegalName = quoteRecord.opportunity.account.Legal_name__c;
            if(quoteRecord.CCL_Sign_Date__c != null)
            {   requestWrap.quoteCCLSignDate = quoteRecord.CCL_Sign_Date__c;}
            else{
                requestWrap.quoteCCLSignDate = System.today().addYears(-20);
            }
            if(quoteRecord.Description != null)
            { requestWrap.quoteDescription = quoteRecord.Description; }
            else
            {
                requestWrap.quoteDescription = '';
            }
            requestWrap.opportunityAGNumber = quoteRecord.Opportunity.AG_Number__c;
            requestWrap.quoteCurrencyCode = quoteRecord.CurrencyISOCode;
            requestWrap.quoteLegalTermChanged = quoteRecord.Legal_Terms_Changed__c;
            requestWrap.yardiContactId = quoteRecord.opportunity.Contact__r.Yardi_Contact_Id__c;
           // requestWrap.quotePaymentTerm = quoteRecord.Payment_Terms__r.Yardi_Code__c;
            requestWrap.opportunityName =  quoteRecord.Account__c;
             requestWrap.ExpAmendmentTerm = quoteRecord.Expansion_Separate_Amendment_Terms__c != null ? quoteRecord.Expansion_Separate_Amendment_Terms__c : '';
            List<RequestWrapper.qliWrapper> qliList = new List<RequestWrapper.qliWrapper>();
            for(quoteLineItem qli : quoteRecord.quoteLineItems){
                RequestWrapper.qliWrapper qliWrap = new RequestWrapper.qliWrapper();
                qliWrap.qliProductCode = qli.Product_Code__c;
                qliWrap.qliStartDate = qli.Start_Date__c;
                qliWrap.qliEndDate = qli.End_Date__c;
                qliWrap.qliChargeCode = qli.Yardi_Charge_Code__c; //qli.Charge_Code__c;
                qliWrap.qliOfferPrice = ( qli.Best_Rate__c > qli.Offer_Price__c)? qli.Best_Rate__c: qli.Offer_Price__c ;
                qliWrap.qliTransactionalUnit =(qli.Transaction_Unit__c	 != null)? (qli.Transaction_Unit__c	 == 'Sqft'? 'Amount Per Area': 'Flat Amount'): '';
                qliWrap.qliNoofBeds = (qli.No_of_Beds__c != null)? Integer.valueOf(qli.No_of_Beds__c): 0;
                qliWrap.qliCurrencyCode = qli.CurrencyISOCode;
                qliWrap.qliProrationMethod = qli.Proration_Method__c;
                qliWrap.qliUnitId = qli.Yardi_Unit_ID__c;
                qliwrap.quotePaymentTerm = qli.Payment_Term_Yardi_Code__c;
                
                qliList.add(qliWrap);
                if(qli.Type__c == 'Normal' && (qli.Best_Rate__c - qli.Offer_Price__c) >0 ){
                    RequestWrapper.qliWrapper qliWrap1 = new RequestWrapper.qliWrapper();
                    qliWrap1.qliProductCode = qli.Product_Code__c;
                    qliWrap1.qliStartDate = qli.Start_Date__c;
                    qliWrap1.qliEndDate = qli.End_Date__c;
                    qliWrap1.qliChargeCode = 'rntdis';//qli.Yardi_Charge_Code__c; // qli.Charge_Code__c;
                    qliWrap1.qliOfferPrice = qli.Offer_Price__c - qli.Best_Rate__c;
                    qliWrap1.qliTransactionalUnit =(qli.Transaction_Unit__c	 != null)? (qli.Transaction_Unit__c == 'Sqft'? 'Amount Per Area': 'Flat Amount'): '';
                    qliWrap1.qliNoofBeds = (qli.No_of_Beds__c != null)? Integer.valueOf(qli.No_of_Beds__c): 0;
                    qliWrap1.qliCurrencyCode = qli.CurrencyISOCode;
                    qliWrap1.qliProrationMethod = qli.Proration_Method__c;
                    qliWrap1.qliUnitId = qli.Yardi_Unit_ID__c ;
                    qliwrap1.quotePaymentTerm = 'Annual';// qli.Payment_Term_Yardi_Code__c;
                   // qliWrap1.yardiDiscount = qli.Offer_Price__c - qli.Best_Rate__c;
                    qliList.add(qliWrap1);
                }
            }
            List<RequestWrapper.turnOverRent> turnOverRentWrappers = new List<RequestWrapper.turnOverRent>();
            if(turnOverRents.get(quoteRecord.id) != null){
                for(Turn_Over_Rent__c tr:turnOverRents.get(quoteRecord.id))
                {
                    RequestWrapper.turnOverRent wtor = new RequestWrapper.turnOverRent();
                    wtor.retailstartdate = tr.Retail_Start_Date__c;
                    wtor.retailenddate = tr.Retail_End_Date__c;
                    wtor.salesreportfrequency = tr.Sales_Report_Frequency__c;
                    wtor.retailbillingfrequency = tr.Retail_Billing_Frequency__c;
                    wtor.breakpointfrequency = tr.BreakPoint_Frequency__c;
                    wtor.salesendofyear = tr.Sales_End_Of_Year__c;
                    wtor.salestype = tr.Sales_Type__c;
                    wtor.overagefromdate = tr.Overage_From_Date__c;
                    wtor.overagetodate = tr.Overage_To_Date__c;
                    wtor.naturalbreakpoint = tr.Natural_Breakpoint__c;
                    wtor.naturalbreakpointpercent = tr.Natural_Breakpoint_Percentage__c;
                    wtor.overageoffsettype = tr.Overage_Offset_Type__c; 
                    wtor.overageoffsetaccountchargecode1 = tr.Overage_Offset_Account_Charge_Code_1__c;
                    wtor.overageoffsetaccountchargecode2= tr.Overage_Offset_Account_Charge_Code_2__c;
                    wtor.overageoffsetaccountchargecode3= tr.Overage_Offset_Account_Charge_Code_3__c;
                    wtor.overageoffsetaccountchargecode4= tr.Overage_Offset_Account_Charge_Code_4__c;
                    wtor.overageoffsetaccountchargecode5= tr.Overage_Offset_Account_Charge_Code_5__c;
                    turnOverRentWrappers.add(wtor);
                }
            }
            requestWrap.tors = turnOverRentWrappers;
            requestWrap.quoteLineItems = qliList;  
            httpResponse response = new httpResponse();
            
            try{  String request =    JSON.serialize(requestWrap);   
                System.debug('request:'+ request);
                response =  RealTimeIntegrationFramework.realTimeCall(request,System.Label.OIC_Lease_Endpoint);  
                																							
                system.debug('response:'+ response);                                             
                RequestWrapper.LeaseResponseWrapper responseData =(RequestWrapper.LeaseResponseWrapper)JSON.deserialize(response.getBody(), RequestWrapper.LeaseResponseWrapper.class);
                if(responseData <> null){
                    if( responseData.opportunityTCode != null && !string.isBlank(responseData.opportunityTCode)  ){
                        Opportunity oppUpdate = new Opportunity();
                        oppUpdate.Id = quoteRecord.OpportunityId;
                        oppUpdate.T_Code__c = responseData.opportunityTCode;
                        oppUpdate.Amendment_Id__c = responseData.opportunityAmendmentId;
                        opportunityListToUpdate.add(oppUpdate);
                    }
                    quoteRecord.Yardi_Integration_Status__c  = responseData.yardiIntegrationStatus;
                	quoteRecord.Yardi_Integration_Error_Message__c  = responseData.yardiIntegrationErrorMessage;
                    
                    if(responseData.paymentSchedule != null){
                        
                        for(RequestWrapper.PaymentScheduleWrapper wpayment: responseData.paymentSchedule)
                        {
                            Payment_Schedule__c payment = new Payment_Schedule__c();
                            payment.Property_Code__c  = wpayment.propertyCode;
                            payment.Tenant_Code__c  = wpayment.tenantCode;
                            payment.Description__c  = wpayment.description;
                            payment.Charge_Code__c = wpayment.chargeCode;
                            payment.BilledAmount__c  = wpayment.billedAmount;
                            payment.Charge_From__c  = wpayment.chargeFrom;
                            payment.Charge_To__c = wpayment.chargeTo;
                            payment.Quote__c = quoteRecord.id;
                            payment.VAT_Amount__c = wpayment.taxAmount;
                                                    
                                                    

                            paymenySchedulesToInsert.add(payment);
                            
                        }
                    }
                    
                    
                } 
            }
            catch(Exception e){
                System.debug('Callout error: '+ e);
                //System.debug(response.toString());
                quoteRecord.Yardi_Integration_Error_Message__c = e.getMessage();
            }     
            
            quoteListToUpdate.add(quoteRecord);         
        }  
        
        if(quoteListToUpdate.size() > 0){
            update quoteListToUpdate;
        }
        if(opportunityListToUpdate.size() >0)
            update opportunityListToUpdate;
        if(paymenySchedulesToInsert.size() >0)
            insert paymenySchedulesToInsert;
    }
    
    /************************************************************************************
    Method  :         cclSignLeaseStatus 
    Description :     post CCL Acceptance status to OIC endpoint
    Version :         1.0
                      1.5 - set the fields on the opportunity received from the OIC response
    ************************************************************************************/
    public static void cclSignLeaseStatus(List<Id> quoteIdList){
        List<Quote> quoteList = [SELECT Id, CCL_Sign_Date__c, Status, Opportunity.T_Code__c, Yardi_Integration_Status__c,
                          Yardi_Integration_Error_Message__c 
                                 from quote where id in: quoteIdList];
                            
        List<Quote> quoteListToUpdate = new List<Quote>();
                            
        for(Quote quoteRecord : quoteList){
            RequestWrapper.LeaseCCLSigned requestWrap = new RequestWrapper.LeaseCCLSigned();
            requestWrap.opportunityTCode = quoteRecord.Opportunity.T_Code__c;
            requestwrap.quoteStatus = quoteRecord.Status;
            requestWrap.quoteCCLSignDate = quoteRecord.CCL_Sign_Date__c;
            requestWrap.quoteId = quoteRecord.Id;
            
            httpResponse response = new httpResponse();
            
            try{                
                response = RealTimeIntegrationFramework.realTimeCall(JSON.serialize(requestWrap), System.Label.RequestBinEndpoint); 
                RequestWrapper.IntegrationResponse responseData = (RequestWrapper.IntegrationResponse)JSON.deserialize(response.getBody(), RequestWrapper.IntegrationResponse.class);
               	quoteRecord.Yardi_Integration_Status__c = responseData.yardiIntegrationStatus;
                quoteRecord.Yardi_Integration_Error_Message__c = responseData.yardiIntegrationErrorMessage;
            }
            catch(Exception e){
                System.debug('Callout error: '+ e);
                System.debug(response.toString());
                quoteRecord.Yardi_Integration_Error_Message__c = e.getMessage();
            }
            
            quoteListToUpdate.add(quoteRecord);           
        } 
        
        if(quoteListToUpdate.size() > 0){
            update quoteListToUpdate;
        }       
    }
    
    /************************************************************************************
    Method  :         hseOpportunityStatus
    Description :     post HSE  status to OIC endpoint
    Version :         1.0
    ************************************************************************************/
    public static void hseOpportunityStatus(List<Id> opportunityIdList){
        List<Opportunity> opportunityList = [SELECT Id, HSE_Clearance_Date__c, HSE_Status__c, HSE_Notes__c,
                                            AG_Number__c from opportunity where id in: opportunityIdList];
                                            
        List<Opportunity> oppListToUpdate = new List<Opportunity>();
                            
        for(Opportunity opportunityRecord : opportunityList){
            RequestWrapper.HSEStatus requestWrap = new RequestWrapper.HSEStatus();
            requestWrap.hseClearanceDate =  opportunityRecord.HSE_Clearance_Date__c;
            requestwrap.hseStatus = opportunityRecord.HSE_Status__c;
            requestWrap.hseNotes = (opportunityRecord.HSE_Notes__c != null)?opportunityRecord.HSE_Notes__c :'';
            requestWrap.opportunityAGNumber = opportunityRecord.AG_Number__c;
            
            httpResponse response = new httpResponse();
            
            try{                
                
                response = RealTimeIntegrationFramework.realTimeCall(JSON.serialize(requestWrap), System.Label.OIC_HSEStatus_Endpoint); 
                RequestWrapper.IntegrationResponse responseData = (RequestWrapper.IntegrationResponse)JSON.deserialize(response.getBody(), RequestWrapper.IntegrationResponse.class);
                opportunityRecord.Yardi_Integration_Status__c = responseData.yardiIntegrationStatus; 
                opportunityRecord.Yardi_Integration_Error_Message__c = responseData.yardiIntegrationErrorMessage;

            }
            catch(Exception e){
                System.debug('Callout error: '+ e);
                System.debug(response.toString());
                opportunityRecord.Yardi_Integration_Error_Message__c = e.getMessage();
            }  
            
            oppListToUpdate.add(opportunityRecord);         
        } 
        
        if(oppListToUpdate.size() > 0){
            update oppListToUpdate;
        }       
    }
    
}