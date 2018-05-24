public with sharing class CCNewPayerRequest extends CCCaseController {

	public CCNewPayerRequest(ApexPages.StandardController con) {
		super(con);
		recordTypeName = 'New Payer Request';

		if(!Test.isRunningTest()) {
			controller.addFields(
				new List<String> {
					'CaseNumber', 'Alternate_Email__c', 'Alternate_Email_2__c',
					'Payer_Name__c', 'Payer_ID__c', 'Address__c', 'City__c', 'State__c', 'Zip_Code__c', 
					'Payer_States__c', 'New_Payer_Transaction__c', 'Estimated_Monthly_Volume__c', 
					'Subject', 'Description', 'CID_Identifier__c', 'ContactId', 'Status', 'RecordTypeId'
				}
			);
		}
		this.cs = (Case)controller.getRecord();
		System.debug('[DEBUG-CCNewPayerRequest.CCNewPayerRequest()]\n=========\nCase: ' + this.cs);
		
		if(String.isNotBlank(controller.getId())) {
			newCase = false;
			title = 'Payer Connection Request Detail';
			// Get case contact information
			this.contact = [Select Id, Name from Contact Where Id = :cs.ContactId];
		} else {
			newCase = true;
			title = 'Payer Connection Request';
			Account account = [Select Name, Entity_Gen_Key__c from Account Where Id = :user.AccountId];
			this.cs.CID_Identifier__c = account.Entity_Gen_Key__c;
			this.cs.ContactId = contact.Id;
			this.cs.Subject = 'New Payer Request';
			// set record type
			for(RecordType rc : recordTypes.values()) {
				if('New Payer Request'.equals(rc.Name)) {
					cs.RecordTypeId = rc.Id;
				}
			}
		}
	}

	public override PageReference saveEdit() {
		if(!validate()) {
			return null;
		}
		return super.saveEdit();
    }
    
	public override PageReference Save() {
		// validate user input
		if(!validate()) {
	        System.debug('[DEBUG-CCCCNewPayerRequestCase.Save()]\n=========\nFailed Validation ');
			return null;
		}
		return super.Save();
	}
    
	public override PageReference SaveAndAddAttachment() {
		// validate user input
		if(!validate()) {
	        System.debug('[DEBUG-CCNewPayerRequest.Save()]\n=========\nFailed Validation ');
			return null;
		}
		return super.SaveAndAddAttachment();
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

        if(!editMode) {
	        if(String.isBlank(cs.Payer_Name__c)) {
	            cs.Payer_Name__c.addError('You must enter a Payer Name');
	            validInput = false;
	        }
	        if(String.isBlank(cs.Payer_ID__c)) {
	            cs.Payer_ID__c.addError('You must enter a Payer Id');
	            validInput = false;
	        }
	        if(String.isBlank(cs.New_Payer_Transaction__c)) {
	            cs.New_Payer_Transaction__c.addError('You must select one or more values');
	            validInput = false;
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

	public List<SelectOption> getNewPayerTransactions() {
		List<SelectOption> options = new List<SelectOption>();
    	Schema.DescribeFieldResult typeFieldDescription = Case.New_Payer_Transaction__c.getDescribe();
//		options.add(new SelectOption('','-Select One-'));
    	for(Schema.Picklistentry picklistEntry : typeFieldDescription.getPicklistValues()) {
    		options.add(new SelectOption(picklistEntry.getValue(),picklistEntry.getLabel()));
    		if(picklistEntry.defaultValue) {
    			cs.New_Payer_Transaction__c = picklistEntry.getValue();
    		}
    	}
    	return options;
	}
	
	public List<SelectOption> getPayerStates() {
		List<SelectOption> options = new List<SelectOption>();
    	Schema.DescribeFieldResult typeFieldDescription = Case.Payer_States__c.getDescribe();
//		options.add(new SelectOption('','-Select One-'));
    	for(Schema.Picklistentry picklistEntry : typeFieldDescription.getPicklistValues()) {
    		options.add(new SelectOption(picklistEntry.getValue(),picklistEntry.getLabel()));
    		if(picklistEntry.defaultValue) {
    			cs.Payer_States__c = picklistEntry.getValue();
    		}
    	}
    	return options;
	}
}