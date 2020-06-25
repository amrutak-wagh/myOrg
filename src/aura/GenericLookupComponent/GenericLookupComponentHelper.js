({
    showDefaultUser : function(component, event, helper) {
          console.log('call showDefaultUser is ');
        var action = component.get('c.fetchCurrentUserRecord');
        action.setCallback(this,function(response){
            if(response.getState() === 'SUCCESS') {
                var result = response.getReturnValue(); 
               console.log('Result is ',result)
              // document.getElementsByClassName('slds-button').style.display = block;
               // $A.util.removeClass(component.find("slds-button"), "slds-button");
                //$A.util.addClass(component.find("slds-button"), "newblock");
                if(result.length > 0)
                {
                    
                    
                //  $A.util.addClass(component.find("slds-button"), "newblock");
                    component.set('v.selectedRecord',result[0]);
                    if(component.get('v.selectDefualt')  != ''){
                    component.set('v.selectedRecord',component.get('v.selectDefualt'));
                    }
                     console.log('selected Defualt is ', component.get('v.selectDefualt'));
                    console.log('selected Record is ', component.get('v.selectedRecord'));
                }
            }
        });
        $A.enqueueAction(action);
    }, 
	searchRecordsHelper : function(component, event, helper, value) {
		$A.util.removeClass(component.find("Spinner"), "slds-hide");
        component.set('v.message','');
        component.set('v.recordsList',null);
		// Calling Apex Method
    	var action = component.get('c.fetchRecords');
        action.setStorable();
        //alert(JSON.stringify(component.get('v.fieldName')));
        action.setParams({
            'objectName' : component.get('v.objectName'),
            'filterField' : component.get('v.fieldName'),
            'searchString' : component.get('v.searchString')
        });
        action.setCallback(this,function(response){
        	var result = response.getReturnValue();
        	if(response.getState() === 'SUCCESS') {
                // To check if any records are found for searched keyword
    			if(result.length > 0) {
    				// To check if value attribute is prepopulated or not
					if( $A.util.isEmpty(value) ) {
                        component.set('v.recordsList',result);        
					} else {
						var index = result.findIndex(x => x.value === value)
                        if(index != -1) {
                            var selectedRecord = result[index];
                        }
                        component.set('v.selectedRecord',selectedRecord);
					}
    			} else {
    				component.set('v.message','No Records Found');
    			}
        	} else if(response.getState() === 'INCOMPLETE') {
                component.set('v.message','No Server Response or client is offline');
            } else if(response.getState() === 'ERROR') {
                // If server throws any error
                var errors = response.getError();
                if (errors && errors[0] && errors[0].message) {
                    component.set('v.message', errors[0].message);
                }
            }
            // To open the drop down list of records
            if( $A.util.isEmpty(value) )
                $A.util.addClass(component.find('resultsDiv'),'slds-is-open');
        	$A.util.addClass(component.find("Spinner"), "slds-hide");
        });
        $A.enqueueAction(action);
	}
})