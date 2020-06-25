({
	sendVerificationCode: function(component, event, helper){
		helper.showLoader(component);
        var url = window.location.href;
        var contactId = url.split('&')[0].split('=')[1];
        var action = component.get('c.sendVerificationCode');
        action.setParams({
            contactId: contactId
        }); 
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result= response.getReturnValue();
                if(result == true){
                	helper.showPageMessage(component, 'Success!', 'Verification code successfully sent to your email address.', 'success');                	
                	component.set('v.contactId', contactId);
                	component.set('v.currentStep', 0);
                }else{
                	helper.showPageMessage(component, 'Error!', 'Unable to send verification code.', 'error');
                }
            } else if (state === "ERROR") {
                alert('error');
            }
            helper.stopLoading(component);
        });
        $A.enqueueAction(action);
	},

    saveBusinessForm: function(component, event, helper,isDraft){
        var infoWrapper = component.get('v.contactInfo');
        var currentStep = component.get('v.currentStep');
		
        if(isDraft == false){
            var isValid = helper.validateBusinessForm(component, event, helper);
            if(!isValid){
                return;
            }
        }
        

        helper.showLoader(component);
        var action = component.get('c.saveBusinessFormInfo');

        action.setParams({
            contactId: component.get('v.contactId'), 
            accountId: component.get('v.accountId'),
            wrapperJSON: JSON.stringify(infoWrapper)
        }); 
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result= response.getReturnValue();
                component.set('v.contactInfo', result);
                helper.stopLoading(component);
                if(isDraft == false){
                    if(infoWrapper.proposedLegalFormOfBusiness.indexOf('FZ-LLC') > -1){
                        component.set('v.currentStep', component.get('v.currentStep')+2);
                    }else{
                        component.set('v.currentStep', component.get('v.currentStep')+1);
                    }
                }else{
                    helper.showPageMessage(component, 'Success!', 'You have successfully saved the form', 'success');
                }
                
            } else if (state === "ERROR") {
                helper.showPageMessage(component, 'Error!', 'Error processing your request.', 'error');
                helper.stopLoading(component);
            }
        });
        $A.enqueueAction(action);
    },

    saveCompanyInfo: function(component, event, helper,isDraft){
        //Validate fields.
        if(isDraft == false){
            if(!helper.validateCompanyInformation(component, event, helper)){
                return;
            }
        }
        

        var infoWrapper = component.get('v.contactInfo');

        helper.showLoader(component);
        var action = component.get('c.saveCompanyInfo');

        action.setParams({
            contactId: component.get('v.contactId'), 
            accountId: component.get('v.accountId'),
            wrapperJSON: JSON.stringify(infoWrapper)
        }); 
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result= response.getReturnValue();
                component.set('v.contactInfo', result);
                helper.stopLoading(component);
                if(isDraft == false){
                    component.set('v.currentStep', component.get('v.currentStep')+1);
                }else{
                    helper.showPageMessage(component, 'Success!', 'You have successfully saved the form', 'success');
                }
                
            } else if (state === "ERROR") {
                helper.showPageMessage(component, 'Error!', 'Error processing your request.', 'error');
                helper.stopLoading(component);
            }
        });
        $A.enqueueAction(action);
    },

    saveActivities: function(component, event, helper,isDraft){
        var selectedActivities = component.get('v.selectedActivity');
        var currentStep = component.get("v.currentStep");
        //if(selectedActivities.length > 0){
            helper.showLoader(component);
            var action = component.get('c.saveActivities');

            action.setParams({
                contactId: component.get('v.contactId'), 
                accountId: component.get('v.accountId'),
                activitiesJSON: JSON.stringify(selectedActivities)
            }); 
            action.setCallback(this, function (response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    var result= response.getReturnValue();
                    var activeMemberSections = [];
                    for(var i=0; i<result.members.length; i++){
                        activeMemberSections.push('member_section_'+i);
                    }
                    component.set('v.activeMemberSections', activeMemberSections);
                    component.set('v.contactInfo', result);
                    component.set('v.selectedActivity', result.activities);
                    helper.stopLoading(component);
                    if(isDraft == false && selectedActivities.length > 0){
                        component.set('v.currentStep', component.get('v.currentStep')+1);
                    }else if(isDraft == true){
                        helper.showPageMessage(component, 'Success!', 'You have successfully saved the form', 'success');
                    }else if(isDraft == false && selectedActivities.length == 0){
                        helper.showPageMessage(component, '', 'Please choose atleast 1 activity.', 'error');
                    }
                    
                } else if (state === "ERROR") {
                    helper.showPageMessage(component, 'Error!', 'Error processing your request.', 'error');
                    helper.stopLoading(component);
                }
            });
            $A.enqueueAction(action);
        //}else{
            //helper.showPageMessage(component, '', 'Please choose atleast 1 activity.', 'error');      
        //}
    },

    saveMembers: function(component, event, helper,isDraft){

        //Validate member fields.
        if(isDraft == false){
            if(!helper.validateMembers(component, event, helper)){
                return;
            }
        }
        

        var selectedMembers = component.get('v.contactInfo').members;
        var currentStep = component.get("v.currentStep");

        helper.showLoader(component);
        var action = component.get('c.saveMembersInfo');

        action.setParams({
            contactId: component.get('v.contactId'), 
            accountId: component.get('v.accountId'),
            membersJSON: JSON.stringify(selectedMembers)
        }); 
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result= response.getReturnValue();
                if(isDraft == false){
                    debugger;
                    component.set('v.currentStep', currentStep+1);
                	component.set('v.contactInfo', result);
                }else{
                    debugger;
                    helper.showPageMessage(component, 'Success!', 'You have successfully saved the form', 'success'); 
                }
                
                helper.stopLoading(component);
            } else if (state === "ERROR") {
                helper.showPageMessage(component, 'Error!', 'Error processing your request.', 'error');
                helper.stopLoading(component);
            }
        });
        $A.enqueueAction(action);
    },

    saveAdditionalDocuments: function(component, event, helper,isDraft){
        console.log('---isDraft',isDraft);
        if(isDraft == false){
            if(!helper.validateMandatoryDocuments(component, event, helper)){
                return;
            }
        }
        helper.showLoader(component);
        var action = component.get('c.saveDocuments');
        action.setParams({
            contactId: component.get('v.contactId'), 
            accountId: component.get('v.accountId')
        }); 
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result= response.getReturnValue();
                helper.stopLoading(component);
                if(isDraft == false){
                    component.set('v.currentStep', component.get('v.currentStep')+1);
                }else{
                    helper.showPageMessage(component, 'Success!', 'You have successfully saved the form', 'success');                	
                }
                
            } else if (state === "ERROR") {
                helper.showPageMessage(component, 'Error!', 'Error processing your request.', 'error');
                helper.stopLoading(component);
            }
        });
        $A.enqueueAction(action);
    },

    submitApplication: function(component, event, helper){
        helper.showLoader(component);
        var action = component.get('c.submitApplication');
        action.setParams({
            contactId: component.get('v.contactId'), 
            accountId: component.get('v.accountId')
        }); 
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result= response.getReturnValue();
                helper.stopLoading(component);
                if(isDraft == false){
                    component.set('v.currentStep', component.get('v.currentStep')+1);
                }else{
                    helper.showPageMessage(component, 'Success!', 'You have successfully saved the form', 'success');                	
                }
                
            } else if (state === "ERROR") {
                helper.showPageMessage(component, 'Error!', 'Error processing your request.', 'error');
                helper.stopLoading(component);
            }
        });
        $A.enqueueAction(action);
    },


    updateMembersIndex: function(component){
        var info = component.get('v.contactInfo');
        var members = info.members;
        for (var j = 0; j < members.length; j++){
            members[j].index = j;
        }
        info.members = members;
        component.set('v.contactInfo', info);
    },

    //Validation helper functions
    validateBusinessForm: function(component, event, helper){
        var info = component.get('v.contactInfo');
        var isValid = true;
        var erroMessage = 'Please provide the missing fields. \n';
        var validationObj = {};

        if(info.selectedLicenseType == '' || info.selectedLicenseType == undefined){
            isValid = false;
            erroMessage += 'Please select license type.\n';
            validationObj.licenseType = 'Please select license type.';
        }

        if(info.selectedLicenseType == 'DDA'){
            if(info.proposedLegalFormOfBusiness == '' || info.proposedLegalFormOfBusiness == undefined){
                isValid = false;
                erroMessage += 'Please select Proposed Legal Form of Business. \n';
            }

            if(info.ProposedNameofBusiness1stchoice == '' || info.ProposedNameofBusiness1stchoice == undefined){
                isValid = false;
                erroMessage += 'Please provide Proposed Name of Business (first choice).\n';
            }

            if(info.ProposedNameofBusiness2ndchoice == '' || info.ProposedNameofBusiness2ndchoice == undefined){
                isValid = false;
                erroMessage += 'Please provide Proposed Name of Business (second choice).\n';
            }

            if(info.ProposedNameofBusiness3rdchoice == '' || info.ProposedNameofBusiness3rdchoice == undefined){
                isValid = false;
                erroMessage += 'Please provide Proposed Name of Business (third choice).\n';
            }
        }

        if(!isValid){
            helper.showPageMessage(component, '', erroMessage , 'error');            
        }
        component.set('v.validationObject',validationObj);
        return isValid;
    },

    //Validate company information section
    validateCompanyInformation: function(component, event, helper){
        var info = component.get('v.contactInfo');
        var isValid = true;
        var erroMessage = 'Please provide the missing fields. \n';
        var validationObj = {};

        if(info.parentCompanyName == '' || info.parentCompanyName == undefined){
            isValid = false;
            erroMessage += 'Please provide parent company name.\n';
            validationObj.licenseType = 'Please provide parent company Name.';
        }

        if(info.registrationNo == '' || info.registrationNo == undefined){
            isValid = false;
            erroMessage += 'Please provide parent company license number.\n';
            validationObj.licenseType = 'Please provide parent company License Number.';
        }

        if(info.dateOfIncorporation == '' || info.dateOfIncorporation == undefined){
            isValid = false;
            erroMessage += 'Please provide parent company Date of Incorporation.\n';
            validationObj.licenseType = 'Please provide parent company Date of Incorporation.';
        }

        if(info.selectedtatutorySeat == '' || info.selectedtatutorySeat == undefined){
            isValid = false;
            erroMessage += 'Please provide Statutory Seat(Place of Registration).\n';
            validationObj.licenseType = 'Please provide Statutory Seat(Place of Registration).';
        }

        if(!isValid){
            helper.showPageMessage(component, '', erroMessage , 'error');            
        }
        component.set('v.validationObject',validationObj);
        return isValid;
    },

    validateMembers: function(component, event, helper){
        var validationObj = [];
        var members = component.get('v.contactInfo').members;
        var isValid = true;
        var allSelectedRoles = [];
        var allUserRoles = [];
		var roleCountObj = {};
        if(members.length > 0 ){
            for(var i =0; i<members.length; i++){
                var member = members[i];
                var contactRoles = member.contactRole;
                var selectedRoles = [];
                var obj = new Object();

                if(member.firstName == ''){
                    obj.missingFirstName = true;   
                    isValid = false;
                }

                if(member.lastName == ''){
                    obj.missingLastName = true;   
                    isValid = false;
                }

                if(member.passportNo == '' || member.passportNo == undefined){
                    obj.missingPassportNo = true;   
                    isValid = false;
                }

                if(member.selectedCountry == ''){
                    obj.missingNationality = true;   
                    isValid = false;
                }

                for(var j=0; j<contactRoles.length; j++){
                    if(contactRoles[j].isSelected){
                        selectedRoles.push(contactRoles[j].roleName);
                        allSelectedRoles.push(contactRoles[j].roleName);
                    }
                    if(i == 0){
                        allUserRoles.push(contactRoles[j].roleName);
                    }
                }

                if(selectedRoles.length == 0){
                    obj.missingRole = true;   
                    isValid = false;
                }
                
                members[i].validator = obj;
                for(var k = 0;k < contactRoles.length;k++){
                    var currentRole = contactRoles[k];
                    if(currentRole.isSelected == true){
                        if(roleCountObj[currentRole.roleName] != undefined && roleCountObj[currentRole.roleName] != null){
                            roleCountObj[currentRole.roleName] = roleCountObj[currentRole.roleName] + 1 ;
                        }else{
                            roleCountObj[currentRole.roleName] = 1;
                        }
                    } 
                }
                
            }
			
            if(!isValid){
                helper.showPageMessage(component, '', 'Please provide all the required fields.', 'error');                
            }else{ //Look for atleast 1 role selected
                for(var k=0; k<allUserRoles.length;k++){
                    if(!allSelectedRoles.includes(allUserRoles[k])){
                        isValid = false;
                    }
                }

                if(!isValid){
                    helper.showPageMessage(component, '', 'Please ensure there is atleast one member for each Role.', 'error');
                }
            }
        }else{
            isValid = false;
            helper.showPageMessage(component, '', 'Please add atleast 1 member.', 'error');
        }
        
        if(roleCountObj['Member'] > 7){
            isValid = false;
            helper.showPageMessage(component, '', 'You can not add more than 7 Member', 'error');
        }else if(roleCountObj['General Manager'] > 1){
            isValid = false;
            helper.showPageMessage(component, '', 'You can not add more than 1 General Manager', 'error');
        }else if (roleCountObj['Board of Directors'] > 6){
            isValid = false;
            helper.showPageMessage(component, '', 'Please add less than 6 Board of Directors', 'error');
        }
        component.set('v.contactInfo.members',members);
        return isValid;
    },
	
    validateMandatoryDocuments : function(component, title, helper){
        var isValid = true;
        var mandatoryDocs = document.getElementsByClassName("document-label mandatory").length;
        var uploadedDocs = document.getElementsByClassName("documentMandatory").length;
        console.log('mandatoryDocs---',mandatoryDocs);
        console.log('uploadedDocs---',uploadedDocs);
        debugger;
        if(mandatoryDocs == uploadedDocs){
            isValid = true;
        }else{
            isValid = false;
            helper.showPageMessage(component, '', 'Please Upload all the mandatory documents', 'error');
        }
        return isValid;
    },
    
	showPageMessage: function(component, title, message, type){
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title: title,
            message: message,
            type: type
        });
        toastEvent.fire();
    },

	showLoader : function(component) {
        $A.util.removeClass(component.find("loader"), "slds-hide");        
	},
    
    stopLoading: function(component){
        $A.util.addClass(component.find("loader"), "slds-hide");
    }

})