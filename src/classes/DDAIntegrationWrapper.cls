public class DDAIntegrationWrapper {
    public class NameApprovalRequest{
        public String businessPark;
        public String legalStructure;
        public String name1;
        public String name2;
        public String name3;
        public String NARNo;
        public String requestorEmail;
        public String requestorName;
        public String workOrderId;
    }
    
    public class NARResponse{
        public String DDAID;
        public String errorMessage;
        public Boolean isSuccess;
        public String NARNo;
        public String status;
        public String workOrderId;
    }
    
    public class ServiceRequest{
        public String requestId;
        public Boolean skipLeaseValidation;
        public Boolean convertToTrustAccount;
        public Boolean isMovetonextStep;
        public String workorderName;
        public String workorderId;
        public String narno;
        public String serviceName;
        public String approvedName;
        public String approvedArabicName;
        public String oraclePartyId;
        public String oraclePartyNo;
        public String businessUnit;
        public String legalFramework;
        public String accountType;
        public String bpMobileNo;
        public String salesPerson;
        public String companyLeaseType;
        public String DEDInitialApprovalName;
        public String contactEmail;
        public String DEDTradeLicenseNo;
        public String contactPerson;
        public Date securityClearanceDate;
        public Date securityClearanceExpiryDate;
        public Boolean isSercurityApproved;
        public String securityClearanceStatus;
        public String managerInchargeEmail;
        public Date businessPlanApprovalDate;
        public String businessPlanApprovalStatus;
        public List<RequestedActivity> requestActivities;
        public List<RequestRelation> requestRelations;
    }
    
    public class RequestRelation{
        public Date birthDate;
        public Date dateOfIncorporation;
        public String email;
        public String externalCRMID;
        public String firstName;
        public String gender;
        public String lastName;
        public String legalName;
        public String name;
        public String nationality;
        public Date passportExpiryDate;
        public Date passportIssueDate;
        public String passportNo;
        public String position;
        public String registrationNo;
        public String salutation;
        public String StatutorySeat;
    }
    
    public class RequestedActivity{
        public String DDAActivityID;
        public String externalCRMID;
    }
    
    public class ServiceRequestDocument{
        public String DDAattachmentID;
        public String docName;
        public Boolean isMandatory;
    }
    
    public class ServiceRequestResponse{
        public String errormessage;
        public Boolean isSuccess;
        public String oraclePartyId;
        public String requestId;
        public String requestName;
        public String workOrderId;
        public List<ServiceRequestDocument> docs;
    }
    
    public class ProcessAttachment{
        public String body;
        public String errorMessage;
        public String fileName;
        public Boolean isSuccess;
        public String parentId;
        public String description;
    }
    
    public class Lease{
        public String licenseNo;
        public String oraclePartyId;
        public String serviceRequestId;
        public String opportunityStage;
        public Date leaseStartDate;
        public Date leaseEndDate;
        public Date leaseTerminationDate;
        public String contractStatus;
        public String contractStatusReason;
        public String agreementNo;
        public String businessPark;
        public String oppType;
        public String leasetype;
        public String originalAggrement;
        public List<LeaseItem> leaseItems;
    }
    
    public class LeaseItem{
        public String externalOLIID;
        public Decimal area;
        public String plot;
        public String subCategory;
        public String category;
        public String unitNoEnglish;
        public String unitNoArabic;
        public String floorEnglish;
        public String floorArabic;
        public String propertyEnglish;
        public String propertyArabic;
        public String propertyUnitId;
        public String propertyId;
        public Boolean isRegisteredAddress;
    }

    public class LeaseItemResponse{
        public String errorMessage;
        public String externalOLIID;
        public Boolean isSuccess;
        public String oraclePartyId;
        public String serviceRequestId;
    }
}