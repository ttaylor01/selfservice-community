public with sharing class CCBillingAccountSelect {
	public boolean hasBillingAccountAccess { get; set; }
	public boolean hasBillingAccount { get; set; }
	public String selectedId {get;set;}
	public List<Zuora__CustomerAccount__c> accounts { get;set; }
	private User user { get; set; }
	private Account account { get; set; }
	private String baseUrl = '/selfservice/apex/';

	public CCBillingAccountSelect() {
		// Set intial page component visibility
		accounts = new List<Zuora__CustomerAccount__c>();
		hasBillingAccountAccess = true;
		hasBillingAccount = true;
		this.user = [Select Id, AccountId, ContactId, Billing_Authorization__c from User Where Id = :UserInfo.getUserId()];
		this.account = [Select Name, Entity_Gen_Key__c from Account Where Id = :user.AccountId];
		System.debug('[DEBUG-CCBillingAccountSelect.] CONSTRUCTOR\nUSER: ' + this.user);
		System.debug('[DEBUG-CCBillingAccountSelect.] CONSTRUCTOR\nACCOUNT: ' + this.account);

		try {
            system.debug('\n[DEBUG-CCBillingAccountSelect] CONSTRUCTOR\n=========\ntry block');
			// Does user have access to view and manage billing information?
			if(!Test.isRunningTest() && !this.user.Billing_Authorization__c) {
				hasBillingAccountAccess = false;
	            appendMessage(ApexPages.Severity.INFO, 'You do not have authorization to view Billing Account information.');
	            return;
			}

			Zuora__CustomerAccount__c billingAccount;
			if(App_Settings__c.getInstance(UserInfo.getProfileId()).isHeWUser__c) {
				accounts = [SELECT Zuora__Account__c, Zuora__Balance__c, Name, Id, Zuora__Zuora_Id__c,
					Zuora__BillToId__c, Zuora__SoldToId__c, AvailityLineOfBusiness__c, Zuora__Parent__c, Zuora__AccountNumber__c, Zuora__BillToName__c,
					Zuora__Status__c, Zuora__LastInvoiceDate__c
					FROM Zuora__CustomerAccount__c
					WHERE
						Zuora__Account__c = :user.AccountId 
						AND AvailityLineOfBusiness__c != '' AND AvailityLineOfBusiness__c = 'HeW' 
						AND	Zuora__Status__c = 'Active' 
						AND Zuora__LastInvoiceDate__c != NULL
					];
			} else {
				accounts = [SELECT Zuora__Account__c, Zuora__Balance__c, Name, Id, Zuora__Zuora_Id__c,
					Zuora__BillToId__c, Zuora__SoldToId__c, AvailityLineOfBusiness__c, Zuora__Parent__c, Zuora__AccountNumber__c, Zuora__BillToName__c,
					Zuora__Status__c, Zuora__LastInvoiceDate__c
					FROM Zuora__CustomerAccount__c
					WHERE
						Zuora__Account__c = :user.AccountId 
						AND AvailityLineOfBusiness__c != 'AAC' AND AvailityLineOfBusiness__c != 'HeW' 
						AND	Zuora__Status__c = 'Active' 
						AND Zuora__LastInvoiceDate__c != NULL
					];
			}
			// Has billing information for this account been established?
			if(accounts.size() < 1) {
				hasBillingAccount = false;
	            appendMessage(ApexPages.Severity.INFO, 'Billing Account has not been established.');
	            return;
			}

            system.debug('\n[DEBUG-CCBillingAccountSelect] CONSTRUCTOR\n=========\nBilling Accounts: ' + accounts);
		} catch (Exception ex) {
			// instantiate class variables so that page can render error
			hasBillingAccountAccess = false;
			hasBillingAccount = false;
            
			appendMessage(ApexPages.Severity.ERROR, 'We are currently having difficulties obtaining billing information.  Please try again later.');
			system.debug('\n[DEBUG-CCBillingAccountSelect] CONSTRUCTOR\n=========\nException catch block: '+ex.getMessage());
		}
	}

	private static void appendMessage(ApexPages.Severity messageType, String message) {
		ApexPages.addMessage(new ApexPages.Message(messageType, message));
	}
	
	public PageReference validateAndRedirect() {
		system.debug('\n[DEBUG-CCBillingAccountSelect.validateAndRedirect]\n=========\nBilling Accounts: ' + accounts);
		if(accounts != null && accounts.size() == 1) {
			// FORWARD TO CCBillingAccount.page
			selectedId = accounts[0].Zuora__Zuora_Id__c;
			return gotoBillingAccount();
		} else {
			return null;
		}
	}

	public PageReference gotoBillingAccount() {
		system.debug('\n[DEBUG-CCBillingAccountSelect.gotoBillingAccount]\n=========\nselectedId: ' + selectedId);
    	String url = baseUrl;
    	url += 'CCBillingAccount';
        PageReference pr = new PageReference(url);
        pr.getParameters().put('id',selectedId);
		pr.getParameters().put('retURL', baseUrl+'CCBillingAccountSelect');
		pr.setRedirect(true);
		return pr;
	}

}