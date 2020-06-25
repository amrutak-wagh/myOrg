({
    
	createMapOfQuoteLines : function(component, event, helper) {
        console.log('I am here in Line');
        var quoteLines = {};
        var line = component.get('v.quoteLine');
		var quoteLineItemList = line.lineItemList;
        for(var i = 0; i < quoteLineItemList.length; i++) {
            quoteLines[quoteLineItemList[i].Id] = quoteLineItemList[i];
        }
        component.set('v.quoteLineMap', quoteLines);
	},
    
    populateTotalOfferPrice : function(component, event, helper) {
        var quoteLines = component.get('v.quoteLineMap');
    	var quoteLineItemId = event.getSource().get("v.class");
		var lineItemObj = quoteLines[quoteLineItemId];
        var changesMade = component.get('v.changesMade');
        var changedLineItemList = component.get('v.changedLineItemList');
		changedLineItemList.push(quoteLineItemId);
        component.set('v.changedLineItemList', changedLineItemList);
        
        
        component.set("v.lineItemObj", lineItemObj);
        var action = component.get("c.getTotalOfferedPrice");
        action.setParams({
            li : component.get("v.lineItemObj")
        });

        action.setCallback(this, function(response) {
           
           var state = response.getState();
           if(state === "SUCCESS") {

               var controllerResult = response.getReturnValue();
               var offerBestDiscountAmount = controllerResult.Total_Best_Rate__c > controllerResult.Total_Offered_Price__c ?
                   							 controllerResult.Total_Best_Rate__c - controllerResult.Total_Offered_Price__c : 0;
			   console.log('controllerResult.Additional_GP_Discount_Amount__c-----------:'+controllerResult.Additional_GP_Discount_Amount__c);
               controllerResult.DOA_Discount2__c = offerBestDiscountAmount + controllerResult.Additional_GP_Discount_Amount__c;
               console.log('controllerResult-----------:'+controllerResult);
               quoteLines[controllerResult.Id] = controllerResult;
               var lineItemArray = [];
               if(!changesMade) {
                  component.set('v.changesMade', true); 
               }
               for(var key in quoteLines){
                  lineItemArray.push(quoteLines[key]); 
               }
               var quoteLine = component.get('v.quoteLine');
               quoteLine.lineItemList = [];
               quoteLine.lineItemList = lineItemArray;
               component.set("v.quoteLine", quoteLine);
               helper.hideLoader(component);
           } 
        })
        $A.enqueueAction(action);
	},

    showLoader : function(component) {
        component.set("v.showLoader", true);
    },
    
    hideLoader: function(component){
        component.set("v.showLoader", false);
    },
    
    
})