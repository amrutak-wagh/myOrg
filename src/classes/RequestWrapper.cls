/***********************************************************************************************
* Name              : RequestWrapper                                              
* Description       : wrappers for request body
* Created Date      : 17/06/2019                                                    
* Created By        : Prachi Sinha (prachi.sinha@were4c.com)                                                                                                    
* ----------------------------------------------------------------------------------------------
* VERSION   Developer   Date        Description                                                                        
* 1.0       Prachi      17/06/2019   Created      
* 2.0       Prachi      20/06/2019   Added the request/response for Lease    
* 3.0        Raza       04/07/2019   Added the TOR request     
* 4.0       Raza        06/08/2019   Add Termination request & Response
* 5.0 .     Raza        03/09/2019 . Add notice date to the termination request
* 6.0 .     Raza        08/09/2019 . Add assigment request details
************************************************************************************************/

public class RequestWrapper{
    
    //class for json structure for account - to be pushed to Oracle ERP
    public class AccountWrapper{
        public String P_SALESFORCE_ID;
        public String P_PARTY_NAME;
        public String P_PARENT_COMPANY_NAME;
        public String P_LICENSE_NUMBER;
        public String P_CUSTOMER_CLASSIFICATION;
        public String P_RELATED_PARTY_TYPE;
        public String P_BUSINESS_PARK;
        public String P_TRN_NUMBER;
        public String P_ADDRESS1;
        public String P_CITY;
        public String P_STATE;
        public String P_COUNTRY;
        public String P_POSTAL_CODE;
        public String P_PRIMARY_PHONE_NUMBER;
        public String P_EMAIL_ADDRESS;
        public String X_PARTY_NUMBER;
        public String X_CUSTOMER_ID;
        public String X_CUSTOMER_NUMBER;
        public String X_PARTY_ID;
    } 
    
    //class for json request structure for Lease
    public class LeaseRequestWrapper{
        public String opportunityId;
        public String quoteId;
        public Integer parentAmendmentId;
        public String opportunityType;
        public String opportunitySubType;
        public String opportunityTCode;
        public String yardiBrandCode;
        public String quoteStatus;
        public String opportunityName;
        public String opportunityLeaseType;
        public Date quoteStartDate;
        public Date quoteEndDate;
        public String opportunitySalesCategory;
        public String yardiCustomerCode;
        public String accountLegalName;
        public Date quoteCCLSignDate;
        public String quoteDescription;
        public String opportunityAGNumber;
        public String quoteCurrencyCode;
        public Boolean quoteLegalTermChanged;
        public String yardiContactId;
        public String ExpAmendmentTerm;
        public List<qliWrapper> quoteLineItems;     
        public List<turnOverRent>   tors;
    }  
    
    //class for qliWrapper
    public class qliWrapper{
        public String qliProductCode;
        public Date qliStartDate;
        public Date qliEndDate;
        public String qliChargeCode;
        public Decimal qliOfferPrice;
        public String qliTransactionalUnit;
        public Integer qliNoofBeds;
        public String qliCurrencyCode; 
        public String qliProrationMethod;
        public String qliUnitId;
        public String quotePaymentTerm;
    }
    
    //class for Lease Response Wrapper
    public class LeaseResponseWrapper{
        public String yardiIntegrationStatus;
        public String yardiIntegrationErrorMessage;
        public String opportunityTCode;
        public Integer opportunityAmendmentId;
        public List<PaymentScheduleWrapper> paymentSchedule;
    }
    
    //class for payment schedule wrapper
    public class PaymentScheduleWrapper{
        public String propertyCode;
        public String tenantCode;
        public String description;
        public String chargeCode;
        public Decimal billedAmount;
        public Date chargeFrom;
        public Date chargeTo;
        public String quoteId; 
        Public Decimal taxAmount;
    }
    
    //class for lease status change to CCL Signed
    public class LeaseCCLSigned{
        public String opportunityTCode;
        public String quoteStatus;
        public Date quoteCCLSignDate;
        public String quoteId;
    }
    
    //class for Lease CCL Sign Status change Response and HSE Status Response
    public class IntegrationResponse{
        public String yardiIntegrationStatus;
        public String yardiIntegrationErrorMessage;
    }
    
    //class for lease status change to CCL Signed
    public class HSEStatus{
        public String HSENotes;
        public String HSEStatus;
        public Date HSEClearanceDate;
        public String OpportunityAGNumber;
    }
    // class for TOR request for lease
    Public class turnOverRent{
        public Date retailstartDate;
        public Date retailendDate;
        public String salesreportfrequency;
        public String retailbillingfrequency;
        public String breakpointfrequency;
        public String salesendofyear;
        public String salestype;
        public Date overagefromDate;
        public Date overagetoDate;
        public String naturalbreakpoint;
        public Double naturalbreakpointpercent;
        public String overageoffsettype;
        public String overageoffsetaccountchargecode1;
        public String overageoffsetaccountchargecode2;
        public String overageoffsetaccountchargecode3;
        public String overageoffsetaccountchargecode4;
        public String overageoffsetaccountchargecode5;
        
        
    }
    // class for the Termination Request
    public class TerminationRequestWrapper{
        public string propertyCode;
        public string opportunityAGNumber;
        public string brandCode;
        public Date fodDate;
        public string description;
        public Date moveOutDate;
        public Date keyHandOverDate;
        public string terminationType;
        public string reason;
        public boolean isCancelled;
        public string opportunityId;
        Public Date NoticeDate;
        
    }
    public class TerminationResponse{
        public string YardiIntegrationStatus;
        public string YardiIntegrationErrorMessage;
        public string OpportunityTCode;
        public string OpportunityAmendmentId;
        public List<OutstandingPayment> outstandingPayments;
    }
    
    public class OutstandingPayment{
        public string description;
        public string chargeCode;
        public decimal billedAmount;
        public decimal vatAmount;
        public Date chargeFrom;
        public Date chargeTo;
        public string opportunityId;
    }
    
    //class for Assigment Request
    public class Assignment {
        public String extRefLeaseId;
        public boolean legalTermChanged;
        public String amendmentType;
        public String amendmentSubType;
        public String propertyCode;
        public String yardiLeaseCode;
        public String yardibrandCode;
        public String status;
        public String leaseName;
        public String companyName;
        public String leaseType;
        public Date assignmentDate;
        public String salesCategory;
        public String customerCode;
        public String description;
        public String yardiContactCode;
        public string opportunityAGNumber;
        
    }
    
}