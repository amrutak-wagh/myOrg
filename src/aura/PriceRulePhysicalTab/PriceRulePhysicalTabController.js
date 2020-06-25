({ // eslint-disable-line
    
    init: function (component,event,helper) {
        var columns = [
            {
                type: 'text',
                fieldName: 'name',
                label: 'Business Park',
                initialWidth: 500
            }
        ];
		var selectedRows = ["a06Q0000009seP0IAI"];
        component.set("v.gridColumns", columns);
		debugger;
        // data
        var action = component.get("c.getBusinessParkList");
        action.setCallback(this, function(response) {
            
           var state = response.getState();
           if(state === "SUCCESS"){
               debugger;
               var controllerResponse = JSON.parse(response.getReturnValue());
               component.set("v.gridData", controllerResponse);
               var newAction = component.get("c.getSelectedRowsId");
               newAction.setParams({
                   prId : component.get("v.recordId")
               });
               
               newAction.setCallback(this, function(response) {
                   
                   var state = response.getState();
                   if(state === "SUCCESS"){
                       debugger;
                       var controllerResponse = response.getReturnValue();
                       debugger;
                       component.set("v.selectedRows", controllerResponse);
                       component.set("v.isWaiting",false);
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
               $A.enqueueAction(newAction);
               //component.set("v.isWaiting",false);
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

    handleRowToggle: function(component, event, helper) {
        // retrieve the unique identifier of the row being expanded
       
        //var rowName = event.getParam('id');
		
        // the new expanded state for this row
        var isExpanded = event.getParam('isExpanded');

        // does the component have children content for this row already?
        var hasChildrenContent = event.getParam('hasChildrenContent');

        // the complete row data
        var rowName = event.getParam('row').id;

        // the row names that are currently expanded
        var expandedRows = component.find('treegrid_async').getCurrentExpandedRows();
		var selectedRows = component.get("v.selectedRows");
        // if hasChildrenContent is false then we need to react and add children
        if (hasChildrenContent === false) {
            component.set('v.isWaiting', true);
			var action = component.get("c.getBuildings");
            action.setParams({
                bpId : rowName
            });
            
           action.setCallback(this, function(response) {
            
           var state = response.getState();
           if(state === "SUCCESS"){
               
               var controllerResponse = JSON.parse(response.getReturnValue());
               helper.retrieveUpdatedData(component.get("v.gridData"),rowName,controllerResponse).then(function (newData) {
                   component.set('v.gridData', newData);
                   component.set("v.selectedRows",selectedRows);
                   component.set('v.isWaiting', false);
               });
               //component.set('v.gridData', controllerResponse);
               
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
            // call a method to retrieve the updated data tree that includes the missing children
            
        }
    },
    handleRowSelect : function(component,event,helper){
        helper.helperHandleRowSelect(component,event,helper);
    },
    handleClick : function(component,event,helper){
        debugger;
        helper.helperHandleRowSelect(component,event,helper);
        var recordId = component.get("v.recordId");
        var selectedBusinessPark = component.get("v.selectedBusinessPark");
        var selectedBuilding = component.get("v.selectedBuilding");
        if((selectedBusinessPark == undefined || selectedBusinessPark == '') && ( selectedBuilding == undefined || selectedBuilding == '')){
            var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    type: 'error',
                    mode: 'pester',
                    message: 'Please Select Any Business Park and Building'
                });
                toastEvent.fire();
            return true;
        }
        var action = component.get("c.saveValuesOnPriceRule");
        action.setParams({
            recId : recordId,
            selectedBusinessPark : selectedBusinessPark,
            selectedBuilding : selectedBuilding
        });
        action.setCallback(this, function(response) {
           debugger;
           var state = response.getState();
           if(state === "SUCCESS"){
               debugger;
               var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    type: 'success',
                    mode: 'pester',
                    message: 'Values Added !!'
                });
                toastEvent.fire();
               $A.get('e.force:refreshView').fire();
               var navEvt = $A.get("e.force:navigateToSObject");
               navEvt.setParams({
                   "recordId": component.get("v.recordId"),
                   "slideDevName": "detail"
               });
               navEvt.fire();
               
               
               
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
    }
}) // eslint-disable-line