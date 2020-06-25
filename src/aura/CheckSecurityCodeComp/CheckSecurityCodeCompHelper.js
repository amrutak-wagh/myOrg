({
	helperMethod : function(component, event, helper) {
		
	},
    //This method gets the value from URL and make a callout to Apex controller.
    //After making callout attributes on the comp are assigned values accordingly
    checkCodeFromURLHelper : function(component,event,helper){
        
        var vars = {};
        var parts = window.location.href.replace(/[?&]+([^=&]+)=([^&]*)/gi, function(m,key,value) {
            vars[key] = value;
        });
        
        var encodedURLCode = vars["id"] != undefined && vars["id"] != null &&  vars["id"] != '' ? vars["id"] : '';
        var userEnteredCode = component.get("v.userEnteredCode");
    	var action = component.get("c.verifyContact");
        
        action.setParams({
            encodedURLCode : encodedURLCode
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
           	if(state === "SUCCESS"){
               var controllerResponse = response.getReturnValue();
               
               console.log('Assignment Result : ', controllerResponse);
               if(controllerResponse != undefined && controllerResponse!="" && controllerResponse != null){
                   console.log('Here========');
                   if(controllerResponse.Code__c == userEnteredCode){
                       component.set("v.recordId",controllerResponse);
                       var evt = $A.get("e.c:compEvent");
                       if(controllerResponse.Cases != undefined && controllerResponse.Cases != null){
                           evt.setParams({ "recordID": controllerResponse.Cases[0].Id});
                       	   evt.fire();
                       }else{
                           var errorMsg = 'No Case Related To Contact is Found. Please try again';
                           helper.showErrorToast(component, event, helper,errorMsg);
                       }
                   }else{
                       var errorMsg = 'Please enter correct verification code';
                       helper.showErrorToast(component, event, helper,errorMsg);
                   }
                   
               }else{
                   var errorMsg = 'Please try again';
                   helper.showErrorToast(component, event, helper,errorMsg);
               }
			   
           } else if (state === "INCOMPLETE") {
               // do something

           }
           else if (state === "ERROR") {
               var errors = response.getError();
               if (errors) {
                   if (errors[0] && errors[0].message) {
                       console.log("Error message: " + 
                                   errors[0].message);
                       
                   }
               } else {
                   console.log("Unknown error");
                   //helper.showToast('Unknown error', 'dismissible', 'error');
               }
           }
            
        })
        $A.enqueueAction(action);
	},
    
    // This method shows toast message when response from controller is null,'',undefined
    
    showErrorToast : function(component, event, helper,errorMsg) {
        
        var toastEvent = $A.get("e.force:showToast");
        var errorMsg = errorMsg;
        console.log('msg....',errorMsg);
        console.log('toastEvent=======',toastEvent);
        toastEvent.setParams({
            title : 'Error Message',
            message: errorMsg,
            messageTemplate: 'Mode is pester ,duration is 5sec and Message is overrriden',
            duration:' 5000',
            key: 'info_alt',
            type: 'error',
            mode: 'pester'
        });
        toastEvent.fire();
    }
	
})