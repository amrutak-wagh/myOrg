({  massDeleteQli : function(component, event, helper) {
    console.log("in mass Delete Qli");
    console.log("quoteId:" + component.get("v.recordId"));
    var action = component.get("c.massQuoteLineItemsDelete");
    action.setParams({
        "quoteId" : component.get("v.recordId")
    });
    action.setCallback(this, function(response) {
        var state = response.getState();
        console.log("in the call back function");
        if (state === "SUCCESS") {  
            console.log(" success quoteId:" + component.get("v.recordId"));
            var result = response.getReturnValue();
            console.log("result:" + result);
            if(result === "deleted"){
                console.log("result:" + result);
                //$A.get("e.force:closeQuickAction").fire(); 
                $A.get("e.force:closeQuickAction").fire();
                $A.get('e.force:refreshView').fire();
                helper.showPageMessage(component, '', "Records has been deleted successfully.", 'success');                                            
            }else{
                if(result === "not deleted"){
                    $A.get("e.force:closeQuickAction").fire(); 
                    $A.get('e.force:refreshView').fire();
                    helper.showPageMessage(component, '', "Records can only be deleted unless quote is is not soft booked.", 'error');                                            
                }else 
                {
                    $A.get("e.force:closeQuickAction").fire(); 
					$A.get('e.force:refreshView').fire();
                    helper.showPageMessage(component, '', result, 'error');               
                }
            }
        }else if (state === "ERROR") {
                console.log("in error:"+ state);
                console.log("respose:" + response.getState());
            	$A.get("e.force:closeQuickAction").fire(); 
                    helper.showPageMessage(component, '', result, 'error'); 
            	$A.get('e.force:refreshView').fire();
                
            }
        
        }); 
        $A.enqueueAction(action);    
    }
                       
                       
                       })