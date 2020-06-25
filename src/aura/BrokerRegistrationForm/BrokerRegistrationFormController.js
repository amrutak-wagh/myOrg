({
    doInit : function(component, event, helper) {
        helper.sendVerificationCode(component, event, helper);
	},

    resentVerificationCode: function(component, event, helper){
        helper.sendVerificationCode(component, event, helper);
    },

    cVerificationCode: function(component, event, helper){
        var action = component.get('c.confirmVerificationCode');
        var confirmationCode = component.find('confirmationCode').get('v.value');//'51625733';//component.find('confirmationCode').get('v.value');
        var contactId = component.get('v.contactId');//'003Q000001Jt1sDIAR';//component.get('v.contactId');

        if(confirmationCode != '' && confirmationCode != undefined){
            helper.showLoader(component);
            action.setParams({
                contactId:contactId,
                confirmationCode: confirmationCode
            }); 
            action.setCallback(this, function (response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    var result= response.getReturnValue();
                    //Incase of correct confirmation code 
                    if(result.isValid == true){
                        component.set('v.currentStep', result.currentPage);
                        component.set('v.contactInfo', result);
                        component.set('v.contactId', result.contactId);
                        component.set('v.accountId', result.accountId);
                        component.set('v.selectedActivity', result.activities);
                    }else{
                        helper.showPageMessage(component, 'Error!', 'Wrong verification code entered.', 'error');
                    }
                } else if (state === "ERROR") {
                    alert('error');
                }
                helper.stopLoading(component);
            });
            $A.enqueueAction(action);            
        }else{
            helper.showPageMessage(component, 'Error!', 'Please enter verification code.', 'error');
        }
    },

    addNewMember: function(component, event, helper){
        helper.showLoader(component);
        var action = component.get('c.getNewMember');

        action.setParams({
            proposedLegalFormOfBusiness:component.get('v.contactInfo').proposedLegalFormOfBusiness
        }); 
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result= response.getReturnValue();
                var info = component.get('v.contactInfo');
                info.members.push(result);
                var totalMembers = info.members.length-1;
                //var activeSection = [];
                //activeSection.push('member_section_'+totalMembers);
                //component.set('v.activeMemberSections', activeSection);

                component.set('v.contactInfo', info);
                helper.updateMembersIndex(component);
                helper.stopLoading(component);                
            } else if (state === "ERROR") {
                helper.showPageMessage(component, 'Error!', 'Error processing your request.', 'error');
                helper.stopLoading(component);
            }
        });
        $A.enqueueAction(action);
    },

    deleteMember: function(component, event, helper){
        helper.showLoader(component);
        setTimeout(function(){

            var deleteableIndex = event.getSource().get("v.value");
            var info = component.get('v.contactInfo');
            var deletedMemberId = info.members[deleteableIndex].contactId;
            info.members.splice(deleteableIndex,1);
            if(deletedMemberId != undefined){
                info.deletedMembers += deletedMemberId + ',';
            }
            component.set('v.contactInfo', info);
            helper.updateMembersIndex(component);
            helper.stopLoading(component);
        },2000);
    },

    updateLicenseType: function(component, event, helper){
        var contactInfo = component.get('v.contactInfo');
        var licenseType = event.getSource().get("v.label");
        contactInfo.selectedLicenseType = licenseType;
        component.set('v.contactInfo', contactInfo);
    },

    updateBusinessLegalForm: function(component, event, helper){
        var contactInfo = component.get('v.contactInfo');
        var legalForm = event.getSource().get("v.label");
        contactInfo.proposedLegalFormOfBusiness = legalForm;
        component.set('v.contactInfo', contactInfo);
    },

	goBack: function(component, event, helper){
		var currentStep = component.get("v.currentStep") - 1;
        var proposedLegalFormOfBusiness = component.get('v.contactInfo').proposedLegalFormOfBusiness;
        if(currentStep == 2 && proposedLegalFormOfBusiness.indexOf('FZ-LLC') > -1){
            currentStep = currentStep - 1;
        }
		component.set("v.currentStep", currentStep);
	},

	goNext: function(component, event, helper){
		var currentStep = component.get("v.currentStep");
        if(currentStep == 3){
            var isDraft = false;
            helper.saveActivities(component, event, helper,isDraft);
        }else if(currentStep == 4){
            var isDraft = false;
            helper.saveMembers(component, event, helper,isDraft);
        }else if(currentStep == 1){
            var isDraft = false;
            helper.saveBusinessForm(component, event, helper,isDraft);
        }else if(currentStep == 2){
            var isDraft = false;
            helper.saveCompanyInfo(component, event, helper,isDraft);            
        }else if(currentStep == 5){
            var isDraft = false;
            helper.saveAdditionalDocuments(component, event, helper,isDraft);
        }else if(currentStep == 6){
            var isDraft = false;
            helper.submitApplication(component, event, helper,isDraft);            
        }else{
            component.set('v.currentStep', currentStep+1);            
        }
	},

    updateMailingStates: function(component, event, helper){
        var selectedCountry = event.getSource().get('v.value');
        var selectedIndex = event.getSource().get('v.name');
        var info = component.get('v.contactInfo');
        var stateMap = info.members[selectedIndex].countryToStateMap;
        var stateCodeToState = info.members[selectedIndex].stateCodeToStateMap;
        var statesInCountry = stateMap[selectedCountry];
        var stateOptions = [];
        stateOptions.push({'label': '--None--', 'value': ''});
        if(statesInCountry != ''){
            for(var i =0; i<statesInCountry.length; i++){
                var label = stateCodeToState[statesInCountry[i]];
                stateOptions.push({'label': label, 'value': statesInCountry[i]});
            }
            info.members[selectedIndex].mailingAddress.isStateDisabled = false;
        }else{
            info.members[selectedIndex].mailingAddress.isStateDisabled = true;
        }
        info.members[selectedIndex].stateOptions = stateOptions;
        component.set('v.contactInfo', info);
    },

    handleMemberFileUpload: function(component, event, helper){
        var uploadedFiles = event.getParam("files");
        var documentId = uploadedFiles[0].documentId;
        var fileId = event.getSource().get('v.name');    
        var members = component.get('v.contactInfo').members;
        for (var i = 0; i < members.length; i++){
            var additionalDocuments = members[i].additionalDocuments;
            for(var j=0; j<additionalDocuments.length; j++){
                if(additionalDocuments[j].documentId == fileId){
                    additionalDocuments[j].uploadedFileId = documentId;
                }
            }
        }
        component.set('v.contactInfo.members', members);
    },

    handleFileUpload: function(component, event, helper){
        var uploadedFiles = event.getParam("files");
        var documentId = uploadedFiles[0].documentId;
        var fileId = event.getSource().get('v.name');    
        var additionalDocuments = component.get('v.contactInfo').additionalDocuments;
        for (var i = 0; i < additionalDocuments.length; i++){
            if(additionalDocuments[i].documentId == fileId){
                additionalDocuments[i].uploadedFileId = documentId;
            }
        }
        component.set('v.contactInfo.additionalDocuments', additionalDocuments);
    },

    previewDocument: function(component, event, helper){
        var documentId = event.getSource().get("v.value");
        $A.get('e.lightning:openFiles').fire({
            recordIds: [documentId]
        });
    },

    handleFilesChange: function(component, event, helper){
        var files = event.getSource().get("v.files");
        alert(files);
    },

	doSubmit: function(component, event, helper){
        component.set('v.currentStep', 7);
	},

    searchSegments : function(component, event, helper) {
        const serverSearchAction = component.get('c.search');
        component.find('Segment__c').search(serverSearchAction);
    },

    searchActivities : function(component, event, helper) {
        const serverSearchAction = component.get('c.search');
        component.find('Segment_Activity__c').search(serverSearchAction);
    },

    addressChange: function(component, event, helper){
        alert('changed...');
    },

    showSelectedSegment: function(component, event, helper){
        console.log(JSON.stringify(component.get("v.selectedSegment")));

    },

    showPageMessage: function(component, event, helper){
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                title: 'Error!',
                message: 'testing error message here',
                type: 'error'
            });
            toastEvent.fire();
    },
    
    saveDraft: function(component, event, helper){
		var currentStep = component.get("v.currentStep");
        if(currentStep == 3){
            var isDraft = true;
            helper.saveActivities(component, event, helper,isDraft);
        }else if(currentStep == 4){
            var isDraft = true;
            helper.saveMembers(component, event, helper,isDraft);//validation -- done
        }else if(currentStep == 1){
            var isDraft = true;
            helper.saveBusinessForm(component, event, helper,isDraft);//validation -- done
        }else if(currentStep == 2){
            var isDraft = true;
            helper.saveCompanyInfo(component, event, helper,isDraft);//validation   -- done         
        }else if(currentStep == 5){
            var isDraft = true;
            helper.saveAdditionalDocuments(component, event, helper,isDraft); // added
        }else if(currentStep == 6){
            var isDraft = true;
            helper.submitApplication(component, event, helper,isDraft);     // added       
        }else{
            component.set('v.currentStep', currentStep+1);            
        }
	}
})