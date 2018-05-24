public with sharing class CCCase extends CCCaseController {

	public Boolean payerVisibility {get;set;}
	public Boolean payerNameIdVisibility {get;set;}
	public Boolean payerRequestVisibility {get;set;}
	public Boolean providerVisibility {get;set;}
	public Boolean providerNameVisibility {get;set;}
	public Boolean provIdVisibility {get;set;}
	public Boolean ptanVisibility {get;set;}
	public Boolean loginVisibility {get;set;}
	public Boolean transactionVisibility {get;set;}
	public Boolean batchIdVisibility {get;set;}
	public Boolean batchIdManualEntryVisibility {get;set;}
	public Boolean patientVisibility {get;set;}
	public Boolean webIdVisibility {get;set;}
	public Boolean memberVisibility {get;set;}
	public Boolean rejectVisibility {get;set;}
	public Boolean svcDateVisibility {get;set;}
	public Boolean chargeAmtVisibility {get;set;}
	public Boolean checkVisibility {get;set;}
	public Boolean b2bVisibility {get;set;}
	public Boolean aacVisibility {get;set;}
	public String requireBriefDescription { get; set; }
	public String requireSubmissionMethod { get; set; }
	
	public CCCase(ApexPages.StandardController con) {
		super(con);
		recordTypeName = 'Community Support';

		if(!Test.isRunningTest()) {
			controller.addFields(
				new List<String> {
					'CaseNumber', 'Call_Reason__c', 'Brief_Description__c', 'Submission_Method__c',
					'Payer_Name__c', 'Payer_ID__c', 'Government_Payer__c', 'Provider_Name__c',
					'NPI_Identifier__c', 'Tax_ID__c', 'PTAN_Identifier__c', 'Atypical_Provider__c',
					'User_ID__c', 'Customer_Reference_Number__c', 'Alternate_Email__c', 'Alternate_Email_2__c',
					'New_Payer_Request_Type__c', 'EDI_Batch_ID__c', 'Patient_Name__c', 'Web_Transaction_ID__c',
					'Member_ID__c', 'EDI_Batch_Reject_Reason__c', 'Date_of_Service__c', 'Charge_Amount__c',
					'Check_Date__c', 'Check_Number__c', 'Check_Amount__c', 'B2B_Vendor_Transaction_ID__c',
					'B2B_transaction_Date__c', 'B2B_Time_of_Transaction__c', 'B2B_Vendor_Error_Code__c',
					'Address__c', 'City__c', 'State__c', 'Zip_Code__c', 'Payer_States__c', 'New_Payer_Transaction__c', 'Estimated_Monthly_Volume__c', 
					'Subject', 'Description', 'CID_Identifier__c', 'Affected_Customer_ID__c', 'ContactId', 'Status', 'RecordTypeId'
				}
			);
		}
		this.cs = (Case)controller.getRecord();
		System.debug('[DEBUG-CCCase.CCCase()]\n=========\nCase: ' + this.cs);
		
		if(String.isNotBlank(controller.getId())) {
			newCase = false;
			title = 'Case Detail';
			// Get case contact information
			this.contact = [Select Id, Name from Contact Where Id = :cs.ContactId];
		} else {
			newCase = true;
			title = 'New Case';
//			Account account = [Select Name, Entity_Gen_Key__c from Account Where Id = :user.AccountId];
			this.cs.CID_Identifier__c = this.acc.Entity_Gen_Key__c;
			this.cs.ContactId = this.contact.Id;
			// set record type
			for(RecordType rc : recordTypes.values()) {
				if('Community Support'.equals(rc.Name)) {
					cs.RecordTypeId = rc.Id;
				}
			}
		}
        
        requireBriefDescription = '';
        requireSubmissionMethod = '';

		// Handle visibility of Affected Customer ID field for AAC vendors
        Set<String> orgTypeSet = new set<String>();
		System.debug('[DEBUG-CCCase.CCCase()]\n=========\nOrganization Type(s): ' + this.acc.Organization_Type__c);
        if(this.acc.Organization_Type__c != null){
            for(String s: this.acc.Organization_Type__c.split(';')){
                orgTypeSet.add(s.trim());
            }
        }
        if( orgTypeSet.contains('Advanced Clearinghouse Non-Hubbed Vendor') ||
            orgTypeSet.contains('Advanced Clearinghouse: Non-Hubbed Vendor') ) {
            aacVisibility = true;
        } else {
            aacVisibility = false;
        }
	}

	public override PageReference saveEdit() {
		// validate user input
		if(!validate()) {
			return null;
		}
		return super.saveEdit();
    }
    
	public override PageReference Save() {
		// validate user input
		if(!validate()) {
	        System.debug('[DEBUG-CCCase.Save()]\n=========\nFailed Validation ');
			return null;
		}
		// if user selects New Payer Request, create case of record type New Payer Request
		if(cs.Call_Reason__c.equals('New Payer Request')) {
			recordTypeName = 'New Payer Request';
			cs.RecordTypeId = CCRecordTypes__c.getInstance(recordTypeName).RecordTypeId__c;
		}
		return super.Save();
	}
    
	public override PageReference SaveAndAddAttachment() {
		// validate user input
		if(!validate()) {
	        System.debug('[DEBUG-CCCase.Save()]\n=========\nFailed Validation ');
			return null;
		}
		// if user selects New Payer Request, create case of record type New Payer Request
		if(cs.Call_Reason__c.equals('New Payer Request')) {
			recordTypeName = 'New Payer Request';
			cs.RecordTypeId = CCRecordTypes__c.getInstance(recordTypeName).RecordTypeId__c;
		}
		return super.SaveAndAddAttachment();
	}
    
	public PageReference setEditVisibility() {
		system.debug('\n[DEBUG-CCCase.setEditVisibility()]\n=========\nSTARTED');
		payerVisibility = false;
		payerNameIdVisibility = false;
		payerRequestVisibility = false;
		providerVisibility = false;
		providerNameVisibility = false;
		provIdVisibility = false;
		ptanVisibility = false;
		loginVisibility = false;
		// transaction info visibility
		transactionVisibility = false;
		batchIdVisibility = false;
		batchIdManualEntryVisibility = false;
		patientVisibility = false;
		webIdVisibility = false;
		memberVisibility = false;
		rejectVisibility = false;
		svcDateVisibility = false;
		chargeAmtVisibility = false;
		// check information visibility
		checkVisibility = false;
		// b2b transaction information visibility
		b2bVisibility = false;

		system.debug('\n[DEBUG-CCCase.setEditVisibility()]\n=========\nCase.Call_Reason__c: ' + cs.Call_Reason__c);
		if(String.isNotBlank(cs.Call_Reason__c)) {

			if(cs.Call_Reason__c.equals('Auth/Referral')) {
				payerNameIdVisibility = true;
				providerNameVisibility = true;
				provIdVisibility = true;
				patientVisibility = true;
				webIdVisibility = true;
				memberVisibility = true;
				rejectVisibility = true;
				if('B2B'.equals(cs.Submission_Method__c)) b2bVisibility = true;
			} else if(cs.Call_Reason__c.equals('Claims')) {
				payerNameIdVisibility = true;

				if('Batch Reject'.equals(cs.Brief_Description__c)) {
					batchIdVisibility = true;
					if('Manual Portal Entry'.equals(cs.Submission_Method__c)) batchIdManualEntryVisibility = true;
				} else if('Claim Reject'.equals(cs.Brief_Description__c)) {
					batchIdVisibility = true;
					patientVisibility = true;
					svcDateVisibility = true;
					chargeAmtVisibility = true;
					memberVisibility = true;
					rejectVisibility = true;
					svcDateVisibility = true;
					chargeAmtVisibility = true;
					if('Manual Portal Entry'.equals(cs.Submission_Method__c)) batchIdManualEntryVisibility = true;
					if('B2B'.equals(cs.Submission_Method__c)) b2bVisibility = true;
				} else if('EOB Denial'.equals(cs.Brief_Description__c)) {
					batchIdVisibility = true;
					patientVisibility = true;
					rejectVisibility = true;
					svcDateVisibility = true;
					chargeAmtVisibility = true;
					if('B2B'.equals(cs.Submission_Method__c)) b2bVisibility = true;
				} else if('Other'.equals(cs.Brief_Description__c)) {
				} else if('Missing Response'.equals(cs.Brief_Description__c)) {
					batchIdVisibility = true;
					patientVisibility = true;
				} else {
					
				}

			} else if(cs.Call_Reason__c.equals('Claim Status')) {
				payerNameIdVisibility = true;

				if('Error Message'.equals(cs.Brief_Description__c)) {
					provIdVisibility = true;
					patientVisibility = true;
					webIdVisibility = true;
					memberVisibility = true;
					rejectVisibility = true;
					svcDateVisibility = true;
					if('B2B'.equals(cs.Submission_Method__c)) b2bVisibility = true;
				} else {
					
				}

			} else if(cs.Call_Reason__c.equals('E&B')) {
				payerNameIdVisibility = true;

				if('Error Message'.equals(cs.Brief_Description__c)) {
					provIdVisibility = true;
					patientVisibility = true;
					webIdVisibility = true;
					memberVisibility = true;
					rejectVisibility = true;
					if('B2B'.equals(cs.Submission_Method__c)) b2bVisibility = true;
				} else {
					
				}

			} else if(cs.Call_Reason__c.equals('ERA')) {
				payerNameIdVisibility = true;
				provIdVisibility = true;
				if('Data Issues'.equals(cs.Brief_Description__c)) {
					providerNameVisibility = true;
					checkVisibility = true;
				} else if('Enrollment'.equals(cs.Brief_Description__c)) {
					providerNameVisibility = true;
				} else if('ERA Restore Request'.equals(cs.Brief_Description__c)) {
					providerNameVisibility = true;
					checkVisibility = true;
				} else if('Other'.equals(cs.Brief_Description__c)) {
				} else if('Missing ERA'.equals(cs.Brief_Description__c)) {
					providerNameVisibility = true;
					checkVisibility = true;
				} else {
					
				}

			} else if(cs.Call_Reason__c.equals('Forms')) {
				providerNameVisibility = true;

				if('835 Enrollment'.equals(cs.Brief_Description__c)) {
					provIdVisibility = true;
				} else if('Billing Service Provider Access'.equals(cs.Brief_Description__c)) {
					provIdVisibility = true;
				} else if('Other'.equals(cs.Brief_Description__c)) {
					
				} else if('Org Identifier Change'.equals(cs.Brief_Description__c)) {
					provIdVisibility = true;
				} else if('Org Type Change'.equals(cs.Brief_Description__c)) {
					provIdVisibility = true;
				} else if('PAA / PCA Change'.equals(cs.Brief_Description__c)) {
					
				} else if('Service Termination Form'.equals(cs.Brief_Description__c)) {
					provIdVisibility = true;
				} else {
					
				}

			} else if(cs.Call_Reason__c.equals('FTP')) {
				payerNameIdVisibility = true;
				loginVisibility = true;
			} else if(cs.Call_Reason__c.equals('Login')) {
				loginVisibility = true;
			} else if(cs.Call_Reason__c.equals('Remittance Viewer')) {
				payerNameIdVisibility = true;

				if('Additional Payers'.equals(cs.Brief_Description__c)) {
					provIdVisibility = true;
				} else if('Billing Service'.equals(cs.Brief_Description__c)) {
					providerNameVisibility = true;
					provIdVisibility = true;
				} else if('Check Validation'.equals(cs.Brief_Description__c)) {
					providerNameVisibility = true;
					provIdVisibility = true;
					checkVisibility = true;
				} else if('Data Issues'.equals(cs.Brief_Description__c)) {
					providerNameVisibility = true;
					provIdVisibility = true;
					checkVisibility = true;
				} else if('Missing ERA'.equals(cs.Brief_Description__c)) {
					providerNameVisibility = true;
					provIdVisibility = true;
					checkVisibility = true;
				} else if('User Role Access'.equals(cs.Brief_Description__c)) {
					providerNameVisibility = true;
					loginVisibility = true;
				} else {
					
				}

			} else if(cs.Call_Reason__c.equals('New Payer Request')) {
				payerNameIdVisibility = true;
				payerRequestVisibility = true;
			} else {

			}
			
			// Handle section visibility
			if( payerNameIdVisibility || payerRequestVisibility ) {
					payerVisibility = true;
			}
			if( providerNameVisibility || provIdVisibility ) {
					providerVisibility = true;
			}
			if( batchIdVisibility || patientVisibility || webIdVisibility || memberVisibility || rejectVisibility || svcDateVisibility || chargeAmtVisibility ) {
					transactionVisibility = true;
			}

		} else {
			// clear fields
//			cs.Customer_Reference_Number__c = '';
//			cs.Alternate_Email__c = '';
//			cs.Alternate_Email_2__c = '';
			cs.Brief_Description__c = '';
			cs.Submission_Method__c = '';
			cs.Payer_Name__c = '';
			cs.Payer_ID__c = '';
//			cs.Government_Payer__c = false;
			cs.Provider_Name__c = '';
			cs.NPI_Identifier__c = '';
			cs.Tax_ID__c = '';
			cs.PTAN_Identifier__c = '';
			cs.Atypical_Provider__c = false;
			cs.User_ID__c = '';
			cs.New_Payer_Request_Type__c = '';
			// Transaction Information
			cs.EDI_Batch_ID__c = '';
			cs.Patient_Name__c = '';
			cs.Web_Transaction_ID__c = '';
			cs.Member_ID__c = '';
			cs.EDI_Batch_Reject_Reason__c = '';
			cs.Date_of_Service__c = null;
			cs.Charge_Amount__c = null;
			// Check Information
			cs.Check_Date__c = null;
			cs.Check_Number__c = '';
			cs.Check_Amount__c = null;
			// B2B Transaction Information
			cs.B2B_Vendor_Transaction_ID__c = '';
			cs.B2B_transaction_Date__c = null;
			cs.B2B_Time_of_Transaction__c = '';
			cs.B2B_Vendor_Error_Code__c = '';
			// Details
			cs.Subject = '';
			cs.Description = '';
		}

		if(cs.Government_Payer__c) {
			ptanVisibility = true;
		} else {
			cs.PTAN_Identifier__c = '';
		}

		system.debug('\n[DEBUG-CCCase.setEditVisibility()]\n=========\nEND');

		return null;
	}

	public boolean validate() {
		Boolean validInput = true;

		if(String.isNotBlank(cs.Alternate_Email__c)) {
			Pattern p = Pattern.compile( '([a-zA-Z0-9_\\-\\.]+)@(((\\[a-z]{1,3}\\.[a-z]{1,3}\\.[a-z]{1,3}\\.)|(([a-zA-Z0-9\\-]+\\.)+))([a-zA-Z]{2,4}|[0-9]{1,3}))');
			Matcher m = p.matcher(cs.Alternate_Email__c);
			if (!m.matches()) {
				cs.Alternate_Email__c.addError('Invalid email format');
				validInput = false;
			}
		}
		if(String.isNotBlank(cs.Alternate_Email_2__c)) {
			Pattern p = Pattern.compile( '([a-zA-Z0-9_\\-\\.]+)@(((\\[a-z]{1,3}\\.[a-z]{1,3}\\.[a-z]{1,3}\\.)|(([a-zA-Z0-9\\-]+\\.)+))([a-zA-Z]{2,4}|[0-9]{1,3}))');
			Matcher m = p.matcher(cs.Alternate_Email_2__c);
			if (!m.matches()) {
				cs.Alternate_Email_2__c.addError('Invalid email format');
				validInput = false;
			}
		}
		if(aacVisibility) {
            if(String.isBlank(cs.Affected_Customer_ID__c)) {
                cs.Affected_Customer_ID__c.addError('You must enter an Affected Customer ID');
                validInput = false;
            }
		}

        if(!editMode) {
            
            if(String.isBlank(cs.Call_Reason__c)) {
                cs.Call_Reason__c.addError('You must enter a Case Reason');
                validInput = false;
            }
            if(String.isNotBlank(requireBriefDescription) && String.isBlank(cs.Brief_Description__c)) {
                cs.Brief_Description__c.addError('You must enter a Brief Description');
                validInput = false;
            }
            if(String.isNotBlank(requireSubmissionMethod) && String.isBlank(cs.Submission_Method__c)) {
                cs.Submission_Method__c.addError('You must enter a Submission Method');
                validInput = false;
            }
            if(loginVisibility) {
                if(String.isBlank(cs.User_ID__c)) {
                    cs.User_ID__c.addError('You must enter a User ID');
                    validInput = false;
                }
            }
            if(ptanVisibility) {
                if(String.isBlank(cs.PTAN_Identifier__c)) {
                    cs.PTAN_Identifier__c.addError('You must enter a Provider ID/PTAN');
                    validInput = false;
                }
            }
            if(payerVisibility) {
	            if(payerNameIdVisibility) {
		            if(String.isBlank(cs.Payer_Name__c)) {
		                cs.Payer_Name__c.addError('You must enter a Payer Name');
		                validInput = false;
		            }
		            if(String.isBlank(cs.Payer_ID__c)) {
		                cs.Payer_ID__c.addError('You must enter a Payer ID');
		                validInput = false;
		            }
	            }
	            if(payerRequestVisibility) {
					if(String.isBlank(cs.New_Payer_Transaction__c)) {
						cs.New_Payer_Transaction__c.addError('You must select one or more values');
						validInput = false;
					}
                    if(String.isNotBlank(cs.Estimated_Monthly_Volume__c) && !cs.Estimated_Monthly_Volume__c.isNumeric() ) {
                        cs.Estimated_Monthly_Volume__c.addError('Estimated Monthly Volume must be a Numeric value');
                        validInput = false;
                    }
	            }
//	            if(payerRequestVisibility) {
//	                if(String.isBlank(cs.New_Payer_Request_Type__c)) {
//	                    cs.New_Payer_Request_Type__c.addError('You must select one or more values');
//	                    validInput = false;
//	                }
//	            }
            }
            if(providerVisibility) {
                if(providerNameVisibility) {
                    if(String.isBlank(cs.Provider_Name__c)) {
                        cs.Provider_Name__c.addError('You must enter a Provider Name');
                        validInput = false;
                    }
                }
                if(provIdVisibility) {
                    if(String.isBlank(cs.NPI_Identifier__c) || (!cs.NPI_Identifier__c.isNumeric() && (cs.NPI_Identifier__c.length() != 10)) ) {
                        cs.NPI_Identifier__c.addError('You must enter a 10 digit Numeric value');
                        validInput = false;
                    }
                    if((String.isBlank(cs.Tax_ID__c) || !cs.Tax_ID__c.isNumeric() || (cs.Tax_ID__c.length() != 9)) && !cs.Atypical_Provider__c ) {
                        cs.Tax_ID__c.addError('You must enter a 9 digit Numeric value');
                        validInput = false;
                    }
                }
            }
            if(transactionVisibility) {
                if(batchIdVisibility) {
                	// Is this Manual Portal Entry or batch
                	if(batchIdManualEntryVisibility) {
	                    if(String.isBlank(cs.EDI_Batch_ID__c) || (!cs.EDI_Batch_ID__c.isNumeric()) ) {
	                        cs.EDI_Batch_ID__c.addError('You must enter a valid Numeric value');
	                        validInput = false;
	                    }
                	} else {
	                    if(String.isBlank(cs.EDI_Batch_ID__c) || (!cs.EDI_Batch_ID__c.isNumeric() && (cs.EDI_Batch_ID__c.length() != 16)) ) {
	                        cs.EDI_Batch_ID__c.addError('You must enter a 16 digit Numeric value');
	                        validInput = false;
	                    }
                	}
                }
                if(patientVisibility) {
                    if(String.isBlank(cs.Patient_Name__c)) {
                        cs.Patient_Name__c.addError('You must enter a Patient Name');
                        validInput = false;
                    }
                }
                if(webIdVisibility) {
                    if(String.isBlank(cs.Web_Transaction_ID__c) || !cs.Web_Transaction_ID__c.isNumeric() ) {
                        cs.Web_Transaction_ID__c.addError('You must enter a Numeric value');
                        validInput = false;
                    }
                }
                if(memberVisibility) {
                    if(String.isBlank(cs.Member_ID__c)) {
                        cs.Member_ID__c.addError('You must enter a Member ID');
                        validInput = false;
                    }
                }
                if(rejectVisibility) {
                    if(String.isBlank(cs.EDI_Batch_Reject_Reason__c)) {
                        cs.EDI_Batch_Reject_Reason__c.addError('You must enter a Rejection/Error Message');
                        validInput = false;
                    }
                }
                if(svcDateVisibility) {
                    if(String.isBlank(String.valueOf(cs.Date_of_Service__c))) {
                        cs.Date_of_Service__c.addError('You must enter a Date of Service');
                        validInput = false;
                    }
                }
                if(chargeAmtVisibility) {
                    if(String.isBlank(String.valueOf(cs.Charge_Amount__c)) ) {
                        cs.Charge_Amount__c.addError('You must enter a valid Charge Amount');
                        validInput = false;
                    }
                }
            }
            if(checkVisibility) {
                if(String.isBlank(String.valueOf(cs.Check_Date__c))) {
                    cs.Check_Date__c.addError('You must enter a Check Date');
                    validInput = false;
                }
                if(String.isBlank(cs.Check_Number__c)) {
                    cs.Check_Number__c.addError('You must enter a Check Number');
                    validInput = false;
                }
                if(String.isBlank(String.valueOf(cs.Check_Amount__c)) ) {
                    cs.Check_Amount__c.addError('You must enter a valid Check Amount');
                    validInput = false;
                }
            }
            if(b2bVisibility) {
                if(String.isBlank(cs.B2B_Vendor_Transaction_ID__c)) {
                    cs.B2B_Vendor_Transaction_ID__c.addError('You must enter a Vendor Transaction ID');
                    validInput = false;
                }
                if(String.isBlank(String.valueOf(cs.B2B_transaction_Date__c))) {
                    cs.B2B_transaction_Date__c.addError('You must enter a Transaction Date');
                    validInput = false;
                }
                if(String.isBlank(cs.B2B_Time_of_Transaction__c)) {
                    cs.B2B_Time_of_Transaction__c.addError('You must enter a Time of Transaction');
                    validInput = false;
                }
                if(String.isBlank(cs.B2B_Vendor_Error_Code__c)) {
                    cs.B2B_Vendor_Error_Code__c.addError('You must enter a Error Code');
                    validInput = false;
                }
            }
    
            if(String.isBlank(cs.Subject)) {
                cs.Subject.addError('You must enter a Subject');
                validInput = false;
            }
            if(String.isBlank(cs.Description)) {
                cs.Description.addError('You must enter a Description');
                validInput = false;
            }

        }
		
		return validInput;
	}
}