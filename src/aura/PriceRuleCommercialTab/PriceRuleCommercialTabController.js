({	
    init : function(component,event,helper){
        debugger;
        var action = component.get("c.getOwnerShipOptionValue");
        debugger;
        action.setCallback(this,function(response){
          var state = response.getState();
            if(state === "SUCCESS"){
                var controllerResponse = response.getReturnValue();
                debugger;
                component.set("v.options",controllerResponse);
                var newAction = component.get("c.getSelectedValues");
                newAction.setParams({
                    prId : component.get("v.recordId")
                });
                
                newAction.setCallback(this, function(response) {
                    
                    var state = response.getState();
                    if(state === "SUCCESS"){
                        debugger;
                        var controllerResponse = response.getReturnValue();
                        debugger;
                        component.set("v.selectedAssets",controllerResponse.assetClassList);
                        component.set("v.selectedCategory",controllerResponse.unitCategoryList);
                        component.set("v.selectedSubCategory",controllerResponse.unitSubCatList);
                        component.set("v.values",controllerResponse.selectedOwnership);
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
            }else if (state === "INCOMPLETE") {
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
    handleChange : function(component,event,helper){
        var selectedOwnerShipValue = event.getParam("value");
        component.set("v.selectedOwnerShipValue",selectedOwnerShipValue);
    },
    handleClick : function(component,event,helper){
        debugger;
        var recordId = component.get("v.recordId");
        var assetNameList;
        var categoryNameList ;
        var subCategoryNameList ;
        var loopOutput = '';
        var selectedAssets = component.get("v.selectedAssets");
        var selectedCategory = component.get("v.selectedCategory");
        var selectedSubCategory = component.get("v.selectedSubCategory");
        selectedAssets.forEach(myFunction);
        assetNameList = loopOutput;
        assetNameList = assetNameList.substring(0,assetNameList.length - 1);
        loopOutput = '';
        selectedCategory.forEach(myFunction);
        categoryNameList = loopOutput;
        categoryNameList = categoryNameList.substring(0,categoryNameList.length - 1);
        loopOutput = '';
        selectedSubCategory.forEach(myFunction);
        subCategoryNameList = loopOutput;
        subCategoryNameList = subCategoryNameList.substring(0,subCategoryNameList.length - 1);
        loopOutput = '';
        function myFunction(item) {
            loopOutput = loopOutput + item.Name + ';'
        }
        var selectedOwnerShipValue = component.get("v.selectedOwnerShipValue");
        selectedOwnerShipValue = selectedOwnerShipValue.toString()
        if((assetNameList == undefined || assetNameList == '') 
           && ( categoryNameList == undefined || categoryNameList == '')
           && (subCategoryNameList == undefined || subCategoryNameList == '')
           && (selectedOwnerShipValue == undefined || selectedOwnerShipValue == '')  ){
            var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    type: 'error',
                    mode: 'pester',
                    message: 'Please Select Values'
                });
                toastEvent.fire();
            return true;
        }
        var action = component.get("c.saveValuesOnPriceRule");
        action.setParams({
            recId : recordId,
            assetNameList : assetNameList,
            categoryNameList : categoryNameList,
            subCategoryNameList : subCategoryNameList,
            ownershipValue : selectedOwnerShipValue
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
                    message: 'All changes have been updated!'
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
})