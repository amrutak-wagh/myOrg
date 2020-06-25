({
	doInit : function(component, event, helper) {
		var quoteId = component.get("v.recordId");
        var action = component.get("c.doSoftBooking");
        action.setParams({
            quoteId : quoteId
        });
        action.setCallback(this, function(response) {
            if (response.getState() == "SUCCESS") {
                var result = response.getReturnValue();
                //Added timeout here as loading gets disappear after a second which is not looking good, 
                //it adds a delay to screen
                setTimeout(function(){
                    if(result.isSuccessfull){
                        $A.get("e.force:closeQuickAction").fire();
                        helper.showPageMessage(component, '', result.validationMessage, 'error');                        
                        $A.get('e.force:refreshView').fire();
                    }else{
                        var errorMessage = result.validationMessage;
                        if(result.softBookedItems != undefined && result.softBookedItems.length > 0){
                            var softBookedItems = '\n Following products are already soft booked:';
                            for(var i=0; i<result.softBookedItems.length; i++){
                                softBookedItems += '\n ' + result.softBookedItems[i];
                            }
                            errorMessage += softBookedItems;
                        }
                        helper.showPageMessage(component, '', errorMessage, 'error');                        
                        $A.get("e.force:closeQuickAction").fire();

                    }
                    component.set('v.isLoading', false);                    
                },1000);
            }else{
                alert('Error performing your request.');
            }
        });
        $A.enqueueAction(action);
	}
})