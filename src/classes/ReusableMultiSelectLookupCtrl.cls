/************************************************************************************
* Name          : ReusableMultiSelectLookupCtrl                                                 
* Description   : Controller of ReusableMultiSelectLookup.cmp
* Created Date  : 12/07/2019                                                    
* Created By    : 4C - Anshul Garg (anshul.garg@weare4c.com)
* Jira/Req By   :                                                                                                                                           
* -----------------------------------------------------------------------------------------------------------------------
* VERSION   Developer   Date        Description     Ticket/Reference    

************************************************************************************/
public class ReusableMultiSelectLookupCtrl {
	
    /**
     *  @description Searches the record of ObjectName type in the org and exclude the selected results
     *  @param  searchKeyWord Search Keyword on which the serach is performed
     * 			ObjectName  Object on which search is performed
     * 			excludeitemsList
     *  @return List of Searched Sobjects
     */
    @AuraEnabled
    public static List < sObject > fetchLookUpValues(String searchKeyWord, String ObjectName, List<sObject> excludeitemsList) {
        String searchKey = '%' + searchKeyWord + '%';
        List < SObject > returnList = new List < SObject > ();
 
        List<String> lstExcludeitems = new List<String>();
        for(SObject item : excludeitemsList ){
            lstExcludeitems.add(item.id);
        }
        
        // Create a Dynamic SOQL Query For Fetch Record List with LIMIT 5 and exclude already selected records  
        String sQuery =  'select id, Name from ' +ObjectName + ' where Name LIKE: searchKey AND Id NOT IN : lstExcludeitems order by createdDate DESC LIMIT 10';
        List < SObject > searchedRecordsList = Database.query(sQuery);
        
        for (SObject obj: searchedRecordsList) {
            returnList.add(obj);
        }
        return returnList;
    }
}