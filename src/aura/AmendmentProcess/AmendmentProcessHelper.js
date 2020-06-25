({	qliIdArray : [],
  	checkboxesChecked : [],
  
  	 retrieveOpportunityPageLayout : function(component, helper) {
        component.set("v.displayOpp",true);
       	component.set("v.displayChildOpp",false);
        component.set("v.displayQuoteLine",false);
        component.set("v.displayQuote",false);
        component.set("v.displayRemovedQuoteLine",false);
         
        var action = component.get("c.getPageLayoutMetadata");
       // var pageLayoutName = component.get("v.PageLayoutName");
        var pageLayoutName = 'Opportunity-Opportunity Layout';
 
        console.log("pageLayoutName: " + pageLayoutName);

        var actionParams = {
            "pageLayoutName" : pageLayoutName
        };

        action.setParams(actionParams);
        action.setCallback(this, function(response){
            var state = response.getState();
            console.log("callback state: " + state);

            if (component.isValid() && state === "SUCCESS") {
                var pageLayout = response.getReturnValue();
                component.set("v.PageLayout", pageLayout.Sections);
                helper.createChildOppHelper(component);
            }
        });
        
        $A.enqueueAction(action);
    },
  
	createChildOppHelper:function(component){
       var recordId =  component.get("v.recordId");
		var action = component.get("c.createChildOpportunity");
        action.setParams({
            opportunityId : component.get("v.recordId")
        });
            
        action.setCallback(this, function(res){
            if(res.getState() === "SUCCESS"){
                console.log('res.getReturnValue()---------',res.getReturnValue());
                component.set("v.opportunity", res.getReturnValue());
                component.set("v.opportunityId", res.getReturnValue().Id);
            }
        });
        
        $A.enqueueAction(action);
    },
  
  	retrieveChildOpportunityPageLayout : function(component, helper) {
        component.set("v.displayOpp",true);
       	component.set("v.displayChildOpp",false);
        component.set("v.displayQuoteLine",false);
        component.set("v.displayQuote",false);
        component.set("v.displayRemovedQuoteLine",false);
         
        var action = component.get("c.getPageLayoutMetadata");
       // var pageLayoutName = component.get("v.PageLayoutName");
        var pageLayoutName = 'Opportunity-Opportunity Layout';
 
        console.log("pageLayoutName: " + pageLayoutName);

        var actionParams = {
            "pageLayoutName" : pageLayoutName
        };

        action.setParams(actionParams);
        action.setCallback(this, function(response){
            var state = response.getState();
            console.log("callback state: " + state);

            if (component.isValid() && state === "SUCCESS") {
                var pageLayout = response.getReturnValue();
                console.log("pageLayout: " ,pageLayout);
                //console.log("pageLayout: " ,component.get("v.recordId"));
                component.set("v.PageLayout", pageLayout.Sections);
                helper.getChildOppHelper(component);
            }
        });
        
        $A.enqueueAction(action);
    },
  
  	getChildOppHelper:function(component){
        var opportunityId = component.get("v.opportunityId");
        
		var action = component.get("c.getChildOpportunityRecord");
        action.setParams({
            opportunityId : opportunityId
        });
            
        action.setCallback(this, function(res){
            if(res.getState() === "SUCCESS"){
                component.set("v.opportunity", res.getReturnValue());
            }
        });
        $A.enqueueAction(action);
    },
  
  	retrieveQuotePageLayout : function(component, helper) {
        
        var action = component.get("c.getPageLayoutMetadata");
       // var pageLayoutName = component.get("v.PageLayoutName");
        var pageLayoutName = 'Quote-Quote Layout';
 
        console.log("pageLayoutName: " + pageLayoutName);

        var actionParams = {
            "pageLayoutName" : pageLayoutName
        };

        action.setParams(actionParams);
        action.setCallback(this, function(response){
            var state = response.getState();
            console.log("callback state: " + state);

            if (component.isValid() && state === "SUCCESS") {
                var pageLayout = response.getReturnValue();
                console.log("pageLayout: " ,pageLayout);

                //console.log("pageLayout: " ,component.get("v.recordId"));
                component.set("v.PageLayout", pageLayout.Sections);
                helper.getQuoteHelper(component);
            }
        });
        
        $A.enqueueAction(action);
    },
    getQuoteHelper:function(component){
     	var action = component.get("c.getQuoteRecord");
        action.setParams({
            opportunityId : component.get("v.opportunityId")
        });
            
        action.setCallback(this, function(res){
            if(res.getState() === "SUCCESS"){
                var quoteObj = res.getReturnValue();
                component.set("v.quote", quoteObj);
                component.set("v.quoteId", quoteObj.Id);
                console.log('quoteId-- ', quoteObj.Id);
            }
        });
		$A.enqueueAction(action);
    },
  	  	
  	updateQuoteHelper:function(component){
    	var updatedQuote = component.get("v.date");
        console.log('updatedQuote-------------', updatedQuote);
        var updateQuote = component.get("c.updateQuoteRecord");
        updateQuote.setParams({
            opportunityId : component.get("v.opportunityId"),
            terminationDate : updatedQuote
        });
        updateQuote.setCallback(this, function(res){
            if(res.getState() === "SUCCESS"){
                component.set("v.quote", res.getReturnValue());
            }
        });
        
		$A.enqueueAction(updateQuote);
    },
    
    getQuoteLineHelper:function(component){
        var action = component.get("c.getQuoteLineItemRecord");
        action.setParams({
            "quoteId" : component.get("v.quote.Id")
        });
            
        action.setCallback(this, function(res){
            if(res.getState() === "SUCCESS"){
                var result = res.getReturnValue();
				var data = [];
                for(var i=0; i<result.length;i++){
                    var obj = {};
                    obj.id = result[i].Id;
                    obj.Name = result[i].Product2.Name;
                    data.push(obj);
                }
                component.set("v.quoteLineItems", data);
            }
        });
		$A.enqueueAction(action); 
    },
  	
  	getSelectedQLIHelper:function(component,event){
        console.log('getSelectedQLIHelper called.....');
        if(event.getSource().get("v.checked") == true){
             this.checkboxesChecked.push(event.getSource().get('v.value'));
        }
       
        component.set("v.selectedCheckboxes",this.checkboxesChecked);
    },
    
    getRemovedQuoteLineItemHelper:function(component,event){
        var selectedCheckBoxes = component.get("v.selectedCheckboxes");
        var qli = component.get('v.quoteLineItems');

        for (var i = 0; i < qli.length; i++) {   
            if(selectedCheckBoxes.includes(qli[i].Id)){
                qli.splice(i,1);
                i--;
            } 
        }
    	component.set('v.quoteLineItems',qli);            
    },
    
  	getRemovedQuoteLineHelper:function(component, event){
        var qliIdList = component.get("v.selectedCheckboxes");
        if(qliIdList.length == 0){
            component.set("v.noCheckboxSelected", true);
        } else{
            component.set("v.noCheckboxSelected", false);
        }
        
        var action = component.get("c.getRemovedQuoteLineItemList");
        
        action.setParams({
            qLIId : qliIdList
        });   
        
        action.setCallback(this, function(res){
            if(res.getState() === "SUCCESS"){
                this.qliIdArray = this.qliIdArray.concat(res.getReturnValue());
                component.set("v.removedQuoteLineItems", this.qliIdArray);
            }
        });
		$A.enqueueAction(action);
    },
  
  	getRemoveableQuoteLineItems:function(component){
      var removeableQuoteLineItems = [];
      var selectedQuoteLineItems = component.find("quoteLineItems").getSelectedRows();
      var termindationDate = component.get("v.date");
        for(var i=0; i<selectedQuoteLineItems.length; i++){
            var item = {};
            item.id = selectedQuoteLineItems[i].id;
            item.productName = selectedQuoteLineItems[i].Name;
            item.terminationDate = termindationDate;
            removeableQuoteLineItems.push(item);
        }
      component.set("v.removedQuoteLineItems", removeableQuoteLineItems);
  	},
  
  	showPageMessage: function(component, title, message, type){
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title: title,
            message: message,
            type: type
        });
        toastEvent.fire();
    }
})