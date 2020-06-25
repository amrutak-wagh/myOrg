({
    quoteLines : {},
    selectedBuildingArray : [],
    selectedUnits : [],
    changedOfferedRatequoteLines : {},
	createCategoryFilter : function(component, event, helper) {
		var action = component.get("c.getCategoryFilter"); /* Method from the controller is called which accepts case record id 
														  and name of case and Work Order field set as parameters & returns Wrapper
														  with all the required details*/
        
        action.setParams({
            recordId : component.get("v.recordId"),
        });
        
        action.setCallback(this, function(response) {
           component.set("v.isWaiting",false); 
           var state = response.getState();
           if(state === "SUCCESS"){
               var controllerResult = response.getReturnValue();
               console.log('controllerResult--'+controllerResult);
               component.set("v.categoryList",controllerResult);
               component.set("v.options",controllerResult.subCategory);
               debugger;
               component.set("v.selectedUnitSet",controllerResult[0].unitIdSet);
               this.selectedBuildingArray = controllerResult[0].buildingIdsList;
               if(this.selectedBuildingArray.length > 0){
                   component.set("v.disableBuildingPicklist",true);
                   component.set("v.selectedBuilding",this.selectedBuildingArray[0]);
               }
               debugger;
               //21/09/2019 - Adeel, do not empty the list 
               //component.set("v.lineItemList",[]);
               this.quoteLines = {};
               //component.set("v.options",controllerResult.subCategory);
           } else if (state === "INCOMPLETE") {
               // do something
           }
           else if (state === "ERROR") {
               
           }
        })
        $A.enqueueAction(action);
	},
    getSubCategoryValues : function(component, event, helper){
        var checkboxes = component.find("categoryCheckBox");
        console.log('Checkboxes : ', checkboxes);
        var checkboxesChecked = [];
        component.set('v.unitList', []);
        component.set('v.floorList', []);
        //Don't reset buildings for expansion 
        if(!component.get("v.isExpansion")){
          component.set('v.buildingList',[]);          
          component.set('v.selectedBuilding', "");
        }

        if(this.selectedBuildingArray.length > 0){
            helper.getFloorForBuilding(component, event, helper);
        }
        for (var i=0; i<checkboxes.length; i++) {
            // And stick the checked ones onto an array...
            console.log(checkboxes[i].get("v.value"))
            if (checkboxes[i].get("v.checked")) {
                checkboxesChecked.push(checkboxes[i].get("v.value"));
            }
        }
        console.log('checkboxesChecked:::',checkboxesChecked);
        component.set('v.checkboxesCheckedList',checkboxesChecked);
        
        var action = component.get("c.getBuildingList"); /* Method from the controller is called which accepts case record id 
														  and name of case and Work Order field set as parameters & returns Wrapper
														  with all the required details*/
        action.setParams({
            subCategoryIdList : checkboxesChecked
        });
        
        action.setCallback(this, function(response) {
           component.set("v.isWaiting",false);
            var state = response.getState();
           component.set("v.isWaiting",false);
            if(state === "SUCCESS"){
               var controllerResult = response.getReturnValue();
               // as building is already selected with predefined from opportunity.
               if(!component.get("v.isExpansion")){
                 component.set("v.buildingList",controllerResult);
               }
           } else if (state === "INCOMPLETE") {
               // do something
           }
           else if (state === "ERROR") {
               
           }
        })
        $A.enqueueAction(action);
    },
    getFloorForBuilding : function(component, event, helper){
        var selectedBuilding = (component.find('select').get('v.value') != undefined && component.find('select').get('v.value') != "") ? component.find('select').get('v.value') : this.selectedBuildingArray.length == 0 ? "" :this.selectedBuildingArray[0];
        var buildingExist  = this.selectedBuildingArray.length == 0 ? true : this.selectedBuildingArray.includes(selectedBuilding);
        debugger;
        if(buildingExist == false){
            debugger;
            component.set("v.floorList",[]);
            component.set("v.isWaiting",false);
            var errorMsg = 'You can not select different building as Line Items for other building already exists';
            helper.showErrorToast(component, event, helper,errorMsg);
            return true;
        }
        debugger;
        component.set('v.unitList', []);
        component.set('v.floorList', []);
        component.set('v.selectedFloor', '');
        component.set("v.selectedBuilding",selectedBuilding);
        var action = component.get("c.getFloorList"); /* Method from the controller is called which accepts case record id 
														  and name of case and Work Order field set as parameters & returns Wrapper
														  with all the required details*/
        action.setParams({
            bId : selectedBuilding
        });
        
        action.setCallback(this, function(response) {
           var state = response.getState();
           component.set("v.isWaiting",false);
           if(state === "SUCCESS"){
               var controllerResult = response.getReturnValue();
               debugger;
               component.set("v.floorList",controllerResult);
           } else if (state === "INCOMPLETE") {
               // do something
           }
           else if (state === "ERROR") {
               
           }
        })
        $A.enqueueAction(action);
    },
    floorValue : function(component, event, helper) {
        debugger;
        var selectedFloor = component.find('select1').get('v.value');
        component.set("v.selectedFloor",selectedFloor);
    },
    findUnits : function(component, event, helper){
        var selectedFloor = component.find('select1').get('v.value');
        component.set("v.selectedFloor",selectedFloor);
        //var floorNumber = component.get("v.selectedFloor");
        var bId = '';
        var floorNumber = selectedFloor;
        var fromArea = component.get("v.fromArea");
        fromArea = fromArea == "" ? undefined : fromArea;
        var toArea = component.get("v.toArea");
        toArea = toArea == "" ? undefined : toArea;
        var selectedSubCategories = component.get("v.checkboxesCheckedList")
        debugger;
        if(bId == undefined || bId == null || bId == ''){
            //helper.getFloorForBuilding(component, event, helper);
            var selectedBuilding = component.find('select').get('v.value');
        	component.set("v.selectedBuilding",selectedBuilding);
            component.set("v.selectedFloor",selectedFloor);
        }
        bId = component.get("v.selectedBuilding");
        debugger;
        if(selectedSubCategories.length == 0){
            component.set("v.isWaiting",false);
            var errorMsg = 'Please Enter all the values';
            helper.showErrorToast(component, event, helper,errorMsg);
            return;
        }
        debugger;
        
        var buildingExist  = this.selectedBuildingArray.length == 0 ? true : this.selectedBuildingArray.includes(selectedBuilding);
        debugger;
        if(buildingExist == false && selectedBuilding != ""){
            component.set("v.isWaiting",false);
            var errorMsg = 'You can not perform search on this building';
            helper.showErrorToast(component, event, helper,errorMsg);
            return;
        }
        var action = component.get("c.getUnits");
        debugger;
        action.setParams({
            bId : bId,
            fromArea : fromArea,
            toArea : toArea,
            floorNumber : floorNumber,
            selectedSubCat : selectedSubCategories,
            buildingOnExistingQLI : this.selectedBuildingArray,
            existingUnitIdList : component.get("v.selectedUnitSet"),
            excludedUnits : component.get("v.excludedUnits")
        });
        action.setCallback(this, function(response) {
           component.set("v.isWaiting",false);
            component.set("v.selectedFloor",floorNumber);
           var state = response.getState();
           if(state === "SUCCESS"){
               var controllerResult = response.getReturnValue();
               debugger;
               if(controllerResult.length <= 50){
                  console.log(JSON.stringify(controllerResult));
                   component.set("v.unitList",controllerResult);
               }else{
                   var errorMsg = 'Please Filter the results using building and floor';
            	   helper.showErrorToast(component, event, helper,errorMsg);
                   return;
               }
               
           } else if (state === "INCOMPLETE") {
               // do something
           }
           else if (state === "ERROR") {
               
           }
        })
        $A.enqueueAction(action);
    },
    searchLineItems : function(component, event, helper){
        debugger;
        var unitName = event.currentTarget.dataset.id;
        var build = event.currentTarget.dataset.building;
        var uName = event.currentTarget.dataset.name;
        component.set("v.build",build);
        if(!this.selectedBuildingArray.includes(build) && this.selectedBuildingArray.length != 0){
            component.set("v.isWaiting",false);
            helper.showErrorToast(component, event, helper,'You can not add units from different buildings');
            return;
        }
        console.log('this.quoteLines----', this.quoteLines);
        console.log('this.unitName----', unitName);
        if(!this.quoteLines[unitName]) {
             var action = component.get("c.fetchLineItems");
            action.setParams({
                quoteId : component.get("v.recordId"),
                unitId : unitName,
                lineItemList : component.get("v.lineItemList")
            });
            
            
            action.setCallback(this, function(response) {
               component.set("v.isWaiting",false);
               var state = response.getState();
               if(state === "SUCCESS"){
                   var controllerResult = response.getReturnValue();
                   console.log('I ma resout ---:', controllerResult);
                   for(var i = 0; i < controllerResult.length; i++) {
                       //if(this.changedOfferedRatequoteLines[controllerResult[i].unitId]) {
                        	//controllerResult[i].quoteLineItem.Offer_Price__c = this.changedOfferedRatequoteLines[controllerResult[i].unitId];
                       //}
                      this.quoteLines[controllerResult[i].unitId] = controllerResult[i];
                   }
                   var lineItemArray = [];
                   for(var key in this.quoteLines){
                      lineItemArray.push(this.quoteLines[key]); 
                   }
                   if(component.get("v.selectedBuilding") != undefined && component.get("v.selectedBuilding") != ""){
                       this.selectedBuildingArray.push(component.get("v.selectedBuilding"));
                   }else{
                       this.selectedBuildingArray.push(component.get("v.build"));
                   }
                   component.set("v.lineItemList",lineItemArray);
                   component.set("v.newlyItems", lineItemArray);
               } else if (state === "INCOMPLETE") {
                   // do something
               }
               else if (state === "ERROR") {
                   var errors = response.getError();
                    console.log(errors);
                    var errorMsg = 'Unknown error';
                    if (errors && Array.isArray(errors) && errors.length > 0) {
                        errorMsg = errors[0].message;
                    }
                   helper.showErrorToast(component, event, helper,errorMsg);
               }
            })
            $A.enqueueAction(action);
        }
        else {
            component.set("v.isWaiting",false);
        }
       
    },
    removeQuoteLines : function(component, event, helper,errorMsg){
        var unitName = event.currentTarget.dataset.id;
        var build = event.currentTarget.dataset.building;
        component.set("v.removeBuild",build);
        //this.selectedUnits.pop(unitName);
        delete this.quoteLines[unitName];
        debugger;
        
        console.log('this.quoteLines-----', this.quoteLines);
        //this.selectedBuildingArray.pop(component.get("v.selectedBuilding"));
        var lineItemArray = [];
        for(var key in this.quoteLines){
            lineItemArray.push(this.quoteLines[key]); 
        }
        component.set("v.lineItemList", lineItemArray);
        component.set("v.newlyItems", lineItemArray);

        var action = component.get("c.removeAndUpdateSelectedProductsBestRate");
        
        action.setParams({
            quoteId : component.get("v.recordId"),
            lineItemList : component.get("v.lineItemList")
        });
        action.setCallback(this, function(response) {

          var state = response.getState();
          if(state === "SUCCESS"){

                 var controllerResult = response.getReturnValue();
                 for(var i = 0; i < controllerResult.length; i++) {
                    //if(this.changedOfferedRatequoteLines[controllerResult[i].unitId]) {
                        //controllerResult[i].quoteLineItem.Offer_Price__c = this.changedOfferedRatequoteLines[controllerResult[i].unitId];
                   //}
                    this.quoteLines[controllerResult[i].unitId] = controllerResult[i];
                 }
                 lineItemArray = [];
                 for(var key in this.quoteLines){
                    lineItemArray.push(this.quoteLines[key]); 
                 }
                 component.set("v.lineItemList", lineItemArray);
                 component.set("v.newlyItems", lineItemArray);
              	 debugger;
                  if(component.get("v.selectedBuilding") != undefined && component.get("v.selectedBuilding") != ""){
                      this.selectedBuildingArray.pop(component.get("v.selectedBuilding"));
                  }else{
                      this.selectedBuildingArray.pop(component.get("v.removeBuild"));
                  }
                 component.set("v.isWaiting",false);
             } else if (state === "INCOMPLETE") {

             }
             else if (state === "ERROR") {
                 var errors = response.getError();
                  console.log(errors);
                  var errorMsg = 'Unknown error';
                  if (errors && Array.isArray(errors) && errors.length > 0) {
                      errorMsg = errors[0].message;
                  }
                 helper.showErrorToast(component, event, helper,errorMsg);
             }
        })
        $A.enqueueAction(action);
        
        //component.set("v.lineItemList",lineItemArray);
    },
    onSave : function(component, event, helper) {
        var action = component.get("c.save");
        
        action.setParams({
           "lineItemList" : component.get('v.lineItemList')
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            var controllerResult = response.getReturnValue();
            //component.set("v.isWaiting",false);
            if (state === "SUCCESS") {
                /*var toastEvent = $A.get("e.force:showToast");
                if(controllerResult) {
                  toastEvent.setParams({
                        mode: 'sticky',
                        message: controllerResult
                  });
                }
                else {
                   
                   toastEvent.setParams({
                        mode: 'sticky',
                        message: 'Quote line added!'
                    });
                    
                }
                toastEvent.fire(); */
                var toastEvent = $A.get("e.force:showToast");
                console.log('I am herer---', controllerResult);
                debugger;
                if(controllerResult) {
                     console.log('I am If---', controllerResult);
                 	helper.updateExistingQLIs(component, event, helper, controllerResult);
                }
                else {
                   console.log('I am esle---', controllerResult);
                   component.set("v.isWaiting",false);
                   toastEvent.setParams({
                        mode: 'sticky',
                        message: 'Quote line added!'
                    });
                    toastEvent.fire();
                    $A.get('e.force:refreshView').fire();
                    var navEvt = $A.get("e.force:navigateToSObject");
                    navEvt.setParams({
                        "recordId": component.get("v.recordId"),
                        "slideDevName": "detail"
                    });
                    navEvt.fire();
                    helper.createCategoryFilter(component, event, helper);
                    
                }
                
                
            } else if (state === 'ERROR') {
                var errors = response.getError();
                console.log(errors);
                 component.set("v.isWaiting",false);
                var message = 'Unknown error';
                if (errors && Array.isArray(errors) && errors.length > 0) {
                    message = errors[0].message;
                }

                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    mode: 'sticky',
                    message: message
                });
                toastEvent.fire();
                
            }
       });
       $A.enqueueAction(action);
    },
    
    updateExistingQLIs : function(component, event, helper,controllerResult) {
        
        var action = component.get("c.updateExistingQLIsApx");
        console.log('I am here 2---', controllerResult);
        action.setParams({
           "quoteLineItemList" : controllerResult
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            var controllerResult = response.getReturnValue();
            console.log('I am here 2 controllerResult---', controllerResult);
            component.set("v.isWaiting",false);
            if (state === "SUCCESS") {
                var toastEvent = $A.get("e.force:showToast");
                if(controllerResult) {
                  toastEvent.setParams({
                        mode: 'sticky',
                        message: controllerResult
                  });
                }
                else {
                   
                   toastEvent.setParams({
                        mode: 'sticky',
                        message: 'Quote line added!'
                    });
                    $A.get('e.force:refreshView').fire();
                    var navEvt = $A.get("e.force:navigateToSObject");
                    navEvt.setParams({
                        "recordId": component.get("v.recordId"),
                        "slideDevName": "detail"
                    });
                    navEvt.fire();
                }
                toastEvent.fire(); 
                helper.createCategoryFilter(component, event, helper);
            } else if (state === 'ERROR') {
                var errors = response.getError();
                console.log(errors);
                var message = 'Unknown error';
                if (errors && Array.isArray(errors) && errors.length > 0) {
                    message = errors[0].message;
                }

                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    mode: 'sticky',
                    message: message
                });
                toastEvent.fire();
            }
       });
       $A.enqueueAction(action);
        
    },
    
    
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
    },

    populateQuoteLinesForExpansion: function(component, event, helper){

    },
    
    populateTotalOfferPrice : function(component, event, helper) {
        console.log('@@'+JSON.stringify(this.quoteLines));
        debugger;
      	var unitName = event.getSource().get("v.class");
  	   	var lineItemObj = this.quoteLines[unitName];

        //this.changedOfferedRatequoteLines[unitName] = event.getSource().get("v.value");
        component.set("v.lineItemObj",lineItemObj);
        var action = component.get("c.getTotalOfferedPrice");
        action.setParams({
            //quoteId : component.get("v.recordId"),
            li : component.get("v.lineItemObj")
        });
        debugger;
        action.setCallback(this, function(response) {
           component.set("v.isWaiting",false);
           var state = response.getState();
           if(state === "SUCCESS"){
               debugger;
               var controllerResult = response.getReturnValue();
               debugger;
               
               controllerResult.changedOfferedRate = event.getSource().get("v.value");
               this.quoteLines[controllerResult.unitId] = controllerResult;
               var lineItemArray = [];
			   debugger;
               for(var key in this.quoteLines){
                  lineItemArray.push(this.quoteLines[key]); 
               }
               debugger;
               component.set("v.lineItemList",lineItemArray);
           } 
        })
        $A.enqueueAction(action);
	}
})