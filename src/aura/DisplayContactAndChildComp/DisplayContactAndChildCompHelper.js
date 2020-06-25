({
    //Method show the case details and related WorkOrder details
	initCaseDetails : function(component, event, helper) {
        
		var action = component.get("c.getCaseRecord"); /* Method from the controller is called which accepts case record id 
														  and name of case and Work Order field set as parameters & returns Wrapper
														  with all the required details*/
        
        action.setParams({
            recordId : component.get("v.recordId"),
        });
        
        action.setCallback(this, function(response) {
            
           var state = response.getState();
           if(state === "SUCCESS"){
               
               var controllerResponse = JSON.parse(response.getReturnValue());
               if(controllerResponse.caseInstance.Status == 'New'){
                   component.set("v.progressBarValue","1");
               }else if(controllerResponse.caseInstance.Status == 'In_Progress'){
                   debugger;
                   component.set("v.progressBarValue","2");
               }else if(controllerResponse.caseInstance.Status == 'Closed - Approved'){
                   component.set("v.progressBarValue","3");
               }else if(controllerResponse.caseInstance.Status == 'Closed - Rejected'){
                   component.set("v.progressBarValue","4");
               }
               component.set("v.wrapperInfo",controllerResponse);
               component.set("v.caseFields",controllerResponse.listFsmCase); // List of fields of case which are displayed on UI
               component.set("v.caseRecord",controllerResponse.caseInstance); // Case record which is to be displayed on UI
               component.set("v.mapIdRecordTypeId",controllerResponse.mapIdRecordTypeId);
               //component.set("v.progressBarValue",controllerResponse.caseInstance.Status);
               
               //Preparing the JSON structure for the fields which are displayed in tree grid
               var gridColumnString= JSON.stringify(controllerResponse.listFsmWorkOrder);
			   gridColumnString = gridColumnString.replace(/\"name\":/g, "\"fieldName\":");
			   var gridColumnJson = JSON.parse(gridColumnString);
               
               gridColumnJson.push({type: 'button',
                                    fieldName: 'test1',
                                    label: 'Action',
                                    typeAttributes: {
                                        iconName: '',
                                        name: 'Resubmit', 
                                        title: 'Resubmit',
                                        label:'Resubmit',
                                        alternativeText:'Return',
                                        variant: 'brand', 
                                        class: {fieldName: 'isbutton'},
                                        
                                    }});
               debugger;
      		   component.set('v.loaded', !component.get('v.loaded'));
               component.set('v.gridColumns',gridColumnJson);
               component.set('v.gridData', controllerResponse.listmapWrapper);
               
           } else if (state === "INCOMPLETE") {
               // do something

           }
           else if (state === "ERROR") {
               var errors = response.getError();
               if (errors) {
                   if (errors[0] && errors[0].message) {
                       console.log("Error message: " + 
                                   errors[0].message);
                       //helper.showToast(errors[0].message, 'dismissible', 'error');
                   }
               } else {
                   console.log("Unknown error");
                   //helper.showToast('Unknown error', 'dismissible', 'error');
               }
           }
            
        })
        $A.enqueueAction(action);
	},
    
    // This method displays the window to create the new WorkOrder
    createWorkOrderRecordHelper : function(component, event, helper) {
        
        var windowRedirect = window.location.href;
        var parentWorkOrderId = event.getParam('row').id;
        var actionName = event.getParam('action').name;
        var mapIdRecordType = component.get('v.mapIdRecordTypeId');
        
        if ( actionName == 'Resubmit' ) {
            debugger;
            var createRecordEvent = $A.get("e.force:createRecord");
            
            console.log('===',mapIdRecordType[parentWorkOrderId]);
            createRecordEvent.setParams({
                "entityApiName": "WorkOrder",
                "defaultFieldValues": {
                    'CaseId':component.get('v.recordId'),
                    'ParentWorkOrderId' : parentWorkOrderId,
                    'RecordTypeId' : mapIdRecordType[parentWorkOrderId]
                },
                "panelOnDestroyCallback": function(event) {
                    
                    var url='';
                    var vars = {};
                    var parts = windowRedirect.replace(/[?&]+([^=&]+)=([^&]*)/gi, function(m,key,value) {
                        vars[key] = value;
                    });
                    
                    url= windowRedirect;
                    var recIdParam = vars['recordId'];
                    var isloggedin = vars['isloggedIn'];
                    if(isloggedin == null || isloggedin==undefined) {
                        url = url + '&isloggedIn=true';
                        console.log('------1-------');
                    }
                    if(recIdParam == null || recIdParam==undefined){
                        url = url + '&recordId='+component.get('v.recordId');
                        console.log('------2-------');
                    }
                    window.location.href = url; // Return to the the main security page if no new WorkOrder is created
                    
               }
            });
            createRecordEvent.fire();
        } 
    }
})