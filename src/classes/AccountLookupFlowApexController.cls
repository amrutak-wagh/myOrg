/**
 *  @description class AccountLookupFlowApexController for AccountLookupFlow component.
 *
 *  2019-07-04  Anshul G    First version
 */
public class AccountLookupFlowApexController {
     /**
      * @method	: fetchRecords()
      * @description	: Method to fetch records for passed object, field and search value.
      * @return	: List<RecordsData>
      * @params	: objectName - Name of Object
      *           filterField - Field Name
      *           searchString - Search string
      */
	@AuraEnabled(cacheable=true)
    public static List<RecordsData> fetchRecords( String objectName, String filterField, String searchString ) {
        List<RecordsData> recordsDataList = new List<RecordsData>();
        try {
            
             String query = 'SELECT Id, ' + filterField+
                ' FROM '+objectName+
                ' WHERE '+filterField+' LIKE ' + '\'' + String.escapeSingleQuotes(searchString.trim()) + '%\'' + ' LIMIT 100';
            for(SObject s : Database.query(query)){
                RecordsData recordsData = new RecordsData();
                recordsData.value = String.valueOf(s.get('id'));
                recordsData.label = String.valueOf(s.get(filterField));
                recordsDataList.add(recordsData);
            } 
        } 
        catch (Exception err) {
            if ( String.isNotBlank( err.getMessage() ) && err.getMessage().contains( 'error:' ) ) {
                throw new AuraHandledException(err.getMessage().split('error:')[1].split(':')[0] + '.');
            } else {
                throw new AuraHandledException(err.getMessage());
            }
        }
        return recordsDataList;
    }
    
    // Wrapper class to store record name and Id as value.
    public class RecordsData {
        @AuraEnabled public String label {get;set;}
        @AuraEnabled public String value {get;set;}
    }
}