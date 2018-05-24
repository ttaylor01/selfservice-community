public with sharing class CCBillingAccount {

	public Account account { get; set; }
	public Map<String,Zuora__PaymentMethod__c> paymentMethods;
	private User user { get; set; }
	public boolean editContactMode { get; set; }
	public boolean editAccountMode { get; set; }
	public boolean hasBillingAccount { get; set; }
	public boolean hasBillingAccountAccess { get; set; }
	public Map<String,String> communicationProfileMap { get; set; }
	public boolean applyAutoPayEdit { get; set; }
	
	public String paramValue { get; set; }
	public String retUrl { get; set; }
	public String selectedId { get; set; }
	public boolean isHeWUser { get; set; }

	public CCBillingAccount() {
		this.retUrl = (String)Apexpages.currentPage().getParameters().get('retUrl');
		this.selectedId = (String)Apexpages.currentPage().getParameters().get('id');
		System.debug('[DEBUG-CCBillingAccount.] CONSTRUCTOR\nretUrl: ' + this.retUrl);
		System.debug('[DEBUG-CCBillingAccount.] CONSTRUCTOR\nselectedId: ' + this.selectedId);

		// Set intial page component visibility
		editContactMode = false;
		editAccountMode = false;
		hasBillingAccount = true;
		hasBillingAccountAccess = true;
		this.user = [Select Id, AccountId, ContactId, Billing_Authorization__c from User Where Id = :UserInfo.getUserId()];
		this.account = [Select Name, Entity_Gen_Key__c from Account Where Id = :user.AccountId];
		System.debug('[DEBUG-CCBillingAccount.] CONSTRUCTOR\nUSER: ' + this.user);
		System.debug('[DEBUG-CCBillingAccount.] CONSTRUCTOR\nACCOUNT: ' + this.account);

		try {
			// Does user have access to view and manage billing information?
			if(!Test.isRunningTest() && !this.user.Billing_Authorization__c) {
				hasBillingAccountAccess = false;
	            appendMessage(ApexPages.Severity.INFO, 'You do not have authorization to view Billing Account information.');
	            return;
			}

			// initialize communication profiles to set based on autopay indicator
			communicationProfileMap = new Map<String,String>();
			List<zqu__CommunicationProfile__c> cpList = [SELECT Name, zqu__ZuoraId__c FROM zqu__CommunicationProfile__c];
			for(zqu__CommunicationProfile__c cp : cpList) {
				communicationProfileMap.put(cp.Name,cp.zqu__ZuoraId__c);
			}
			System.debug('[DEBUG-CCBillingAccount.] CONSTRUCTOR\ncommunicationProfile: ' + communicationProfileMap);

			/*
			 * DON'T REALLY NEED ALL THIS TO GET THE zBillingAccount object set
			 * JUST READ THE zuora account.
			 */
			Zuora__CustomerAccount__c billingAccount;
			if(String.isBlank(this.selectedId)) {
				List<Zuora__CustomerAccount__c> billingAccountList = [SELECT Zuora__Account__c, Zuora__Balance__c, Name, Id, Zuora__Zuora_Id__c,
					Zuora__BillToId__c, Zuora__SoldToId__c, AvailityLineOfBusiness__c, Zuora__Parent__c
					FROM Zuora__CustomerAccount__c
					WHERE Zuora__Account__c = :user.AccountId];
				// Has billing information for this account been established?
				if(billingAccountList.size() < 1) {
					hasBillingAccount = false;
		            appendMessage(ApexPages.Severity.INFO, 'Billing Account has not been established.');
		            return;
				}
				// Select the appropriate Billing Account if there are more than 1.
				// If HeW LOB, Billing should be managed through the parent account.
				billingAccount = billingAccountList[0];
				for(Zuora__CustomerAccount__c za : billingAccountList) {
					if(String.isNotBlank(za.AvailityLineOfBusiness__c) && za.AvailityLineOfBusiness__c.equals('HeW')) {
						if(String.isBlank(za.Zuora__Parent__c)) {
							billingAccount = za;
							break;
						}
					}
				}
				this.selectedId = billingAccount.Zuora__Zuora_Id__c;
				
			} else {
				billingAccount = [SELECT Zuora__Account__c, Zuora__Balance__c, Name, Id, Zuora__Zuora_Id__c,
					Zuora__BillToId__c, Zuora__SoldToId__c, AvailityLineOfBusiness__c, Zuora__Parent__c
					FROM Zuora__CustomerAccount__c
					WHERE Zuora__Zuora_Id__c = :this.selectedId];
			}
			/*
			 * DON'T REALLY NEED ALL THIS TO GET THE zBillingAccount object set
			 */

			Zuora.zApi zApiInstance = CCZUtility.zlogin();

			String queryStr = 'SELECT Id, AccountNumber, AutoPay, Balance, BillToId, ' +
				'DefaultPaymentMethodId, Name, PaymentGateway, SoldToId, TotalInvoiceBalance ' + 
				'FROM Account WHERE Id = \'' + billingAccount.Zuora__Zuora_Id__c + '\'';
			
			List<Zuora.zObject> accounts = CCZUtility.zquery(zApiInstance, queryStr, 'Account');
            system.debug('\n[DEBUG-CCBillingAccount.] CONSTRUCTOR\n=========\nAccounts: ' + accounts);
            zBillingAccount = new BillingAccountUI();
			for(Zuora.zObject a : accounts) {
				zBillingAccount.id = (String)a.getValue('Id');
				zBillingAccount.accountNumber  = (String)a.getValue('AccountNumber');
				zBillingAccount.autoPay  = (Boolean)a.getValue('AutoPay');
				zBillingAccount.balance  = (decimal)a.getValue('Balance');
				zBillingAccount.billToId  = (String)a.getValue('BillToId');
				zBillingAccount.soldToId  = (String)a.getValue('SoldToId');
				zBillingAccount.defaultPaymentMethodId = (String)a.getValue('DefaultPaymentMethodId');
				zBillingAccount.name  = (String)a.getValue('Name');
				zBillingAccount.paymentGateway  = (String)a.getValue('PaymentGateway');
				zBillingAccount.totalInvoiceBalance  = (decimal)a.getValue('TotalInvoiceBalance');
			}

			queryStr = 'SELECT Id, Address1, Address2, City, PostalCode, State, FirstName, LastName, ' +
				'WorkEmail, WorkPhone ' + 
				'FROM Contact WHERE Id = \'' + zBillingAccount.billToId + '\' OR Id = \'' + zBillingAccount.soldToId + '\'';
            system.debug('\n[DEBUG-CCBillingAccount] CONSTRUCTOR\n=========\nBilling Contact QUERY: ' + queryStr);
			List<Zuora.zObject> contacts = CCZUtility.zquery(zApiInstance, queryStr, 'Contact');
            system.debug('\n[DEBUG-CCBillingAccount] CONSTRUCTOR\n=========\nContacts: ' + contacts);
            billToContact = new ContactUI();
            soldToContact = new ContactUI();
            for(Zuora.zObject c : contacts) {
            	String zId = (String)c.getValue('Id');
            	if(String.isNotBlank(zId)) {
            		// could be both bill to and sold to
            		if(zId.equals(zBillingAccount.billToId)) {
            			billToContact.id = zId;
            			billToContact.address1  = (String)c.getValue('Address1');
            			billToContact.address2  = (String)c.getValue('Address2');
            			billToContact.city  = (String)c.getValue('City');
            			billToContact.state  = (String)c.getValue('State');
            			billToContact.postalCode  = (String)c.getValue('PostalCode');
            			billToContact.firstName  = (String)c.getValue('FirstName');
            			billToContact.lastName  = (String)c.getValue('LastName');
            			billToContact.email  = (String)c.getValue('WorkEmail');
            			billToContact.phone  = (String)c.getValue('WorkPhone');
            		}
            		if(zId.equals(zBillingAccount.soldToId)) {
            			soldToContact.id = zId;
            			soldToContact.address1  = (String)c.getValue('Address1');
            			soldToContact.address2  = (String)c.getValue('Address2');
            			soldToContact.city  = (String)c.getValue('City');
            			soldToContact.state  = (String)c.getValue('State');
            			soldToContact.postalCode  = (String)c.getValue('PostalCode');
            			soldToContact.firstName  = (String)c.getValue('FirstName');
            			soldToContact.lastName  = (String)c.getValue('LastName');
            			soldToContact.email  = (String)c.getValue('WorkEmail');
            			soldToContact.phone  = (String)c.getValue('WorkPhone');
            		}
            	}
            }

			queryStr = 'SELECT Id, CreditCardMaskNumber, CreditCardType, CreditCardHolderName, PaymentMethodStatus, ' +
				'AchAbaCode, AchAccountName, AchAccountNumberMask, AchAccountType, AchBankName, Type, ' +
				'CreditCardAddress1, CreditCardAddress2, CreditCardCity, CreditCardCountry, CreditCardExpirationMonth, ' +
				'CreditCardExpirationYear, CreditCardPostalCode, CreditCardState ' + 
				'FROM PaymentMethod WHERE AccountId = \'' + zBillingAccount.id + '\'';
			List<Zuora.zObject> pms = CCZUtility.zquery(zApiInstance, queryStr, 'PaymentMethod');
            system.debug('\n[DEBUG-CCBillingAccount] CONSTRUCTOR\n=========\nPayment Methods: ' + pms);
            paymentMethods = new Map<String, Zuora__PaymentMethod__c>();
            // Place Credit Card methods first
			for(Zuora.zObject pm : pms) {
				if(('CreditCard').equals((String)pm.getValue('Type'))) {
					Zuora__PaymentMethod__c paymentMethod = new Zuora__PaymentMethod__c();
					paymentMethod.Zuora__Type__c = (String)pm.getValue('Type');
					paymentMethod.Zuora__CreditCardMaskNumber__c = (String)pm.getValue('CreditCardMaskNumber');
					paymentMethod.Zuora__CreditCardHolderName__c = (String)pm.getValue('CreditCardHolderName');
					paymentMethod.Zuora__CreditCardType__c = (String)pm.getValue('CreditCardType');
					paymentMethod.Zuora__CreditCardAddress1__c = (String)pm.getValue('CreditCardAddress1');
					paymentMethod.Zuora__CreditCardAddress2__c = (String)pm.getValue('CreditCardAddress2');
					paymentMethod.Zuora__CreditCardCity__c = (String)pm.getValue('CreditCardCity');
					paymentMethod.Zuora__CreditCardCountry__c = (String)pm.getValue('CreditCardCountry');
					paymentMethod.Zuora__CreditCardExpirationMonth__c = String.valueOf(pm.getValue('CreditCardExpirationMonth'));
					paymentMethod.Zuora__CreditCardExpirationYear__c = String.valueOf(pm.getValue('CreditCardExpirationYear'));
					paymentMethod.Zuora__CreditCardPostalCode__c = (String)pm.getValue('CreditCardPostalCode');
					paymentMethod.Zuora__CreditCardState__c = (String)pm.getValue('CreditCardState');
					paymentMethod.Zuora__External_Id__c = (String)pm.getValue('Id');
	                paymentMethods.put(paymentMethod.Zuora__External_Id__c,paymentMethod);
				}
			}
			// Then place ACH methods
			for(Zuora.zObject pm : pms) {
				if(('ACH').equals((String)pm.getValue('Type'))) {
					Zuora__PaymentMethod__c paymentMethod = new Zuora__PaymentMethod__c();
					paymentMethod.Zuora__Type__c = (String)pm.getValue('Type');
					paymentMethod.Zuora__AchAbaCode__c = (String)pm.getValue('AchAbaCode');
					paymentMethod.Zuora__AchAccountName__c = (String)pm.getValue('AchAccountName');
					paymentMethod.Zuora__AchAccountNumberMask__c = (String)pm.getValue('AchAccountNumberMask');
					paymentMethod.Zuora__AchAccountType__c = (String)pm.getValue('AchAccountType');
					paymentMethod.Zuora__AchBankName__c = (String)pm.getValue('AchBankName');
					paymentMethod.Zuora__External_Id__c = (String)pm.getValue('Id');
	                paymentMethods.put(paymentMethod.Zuora__External_Id__c,paymentMethod);
				}
			}

			if(String.isNotBlank(zBillingAccount.defaultPaymentMethodId)) {
				zBillingAccount.defaultPaymentMethod = paymentMethods.get(zBillingAccount.defaultPaymentMethodId);
			}

			// initially if this is a HeW Community user
            isHeWUser = App_Settings__c.getInstance(UserInfo.getProfileId()).isHeWUser__c;
			/*
			 *	Obtain latest Invoice to drive validation rule on auto pay edit
			 */
            applyAutoPayEdit = false;
            if(!App_Settings__c.getInstance(UserInfo.getProfileId()).isHeWUser__c) {
	            List<InvoiceWrapper> invoiceList = new List<InvoiceWrapper>();
	            queryStr = 'SELECT Id, AccountId, Amount, InvoiceDate, Status, PostedDate ' +
	                'FROM Invoice WHERE AccountId = \'' + zBillingAccount.id + '\' AND Status = \'Posted\'';
	            List<Zuora.zObject> invoices = CCZUtility.zquery(zApiInstance, queryStr, 'Invoice');
	            system.debug('\n[DEBUG-CCBillingAccount] CONSTRUCTOR\n=========\nInvoices: ' + invoices);
	            if(invoices.size() > 0) {
		            for(Zuora.zObject obj : invoices) {
		                Zuora__ZInvoice__c i = new Zuora__ZInvoice__c();
		                i.Zuora__Zuora_Id__c = (String)obj.getValue('Id');
		                i.Zuora__TotalAmount__c  = (decimal)obj.getValue('Amount');
		                i.Zuora__InvoiceDate__c = (Date)obj.getValue('InvoiceDate');
		                i.Zuora__Posted_Date__c = Date.valueOf((DateTime)obj.getValue('PostedDate'));
		                invoiceList.add(new InvoiceWrapper(i));
		            }
		            invoiceList.sort();
		            Zuora__ZInvoice__c i = invoiceList.get(0).invoice;
		            if(i.Zuora__TotalAmount__c < 1000.00) {
		                applyAutoPayEdit = true;
		            }
	            } else {
	                applyAutoPayEdit = true;
	            }
            }

            system.debug('\n[DEBUG-CCBillingAccount] CONSTRUCTOR\n=========\nBilling Account: ' + zBillingAccount);
/*
		} catch( Zuora.zForceException ex) {
            appendMessage(ApexPages.Severity.ERROR, 'zForceException: ---- ' + ex.getMessage());
			system.debug('\n[DEBUG-CCBillingAccount] CONSTRUCTOR\n=========\nzForceException catch block: '+ex.getMessage());
		} catch( Zuora.zAPIException ex) {
            appendMessage(ApexPages.Severity.ERROR, 'zAPIException: ---- ' + ex.getMessage());
			system.debug('\n[DEBUG-CCBillingAccount] CONSTRUCTOR\n=========\nzAPIException catch block: '+ex.getMessage());
		} catch( Zuora.zRemoteException ex) {
            appendMessage(ApexPages.Severity.ERROR, 'zRemoteException: ---- ' + ex.getMessage());
			system.debug('\n[DEBUG-CCBillingAccount] CONSTRUCTOR\n=========\nzRemoteException catch block: '+ex.getMessage());
*/
		} catch (Exception ex) {
			// instantiate class variables so that page can render error
            zBillingAccount = new BillingAccountUI();
            billToContact = new ContactUI();
            soldToContact = new ContactUI();
            paymentMethods = new Map<String, Zuora__PaymentMethod__c>();
            
            // set page visibility settings
			hasBillingAccount = false;
			hasBillingAccountAccess = false;
            
			appendMessage(ApexPages.Severity.ERROR, 'We are currently having difficulties obtaining billing information.  Please try again later.');
			system.debug('\n[DEBUG-CCBillingAccount] CONSTRUCTOR\n=========\nException catch block: '+ex.getMessage());
		}
	}

	// utility method to display input for payment method options
	public boolean hasPaymentMethod {
		get {
			if(paymentMethods.size()>=1) { return true; } else { return false; }
		}
		set;
	}
	public List<SelectOption> getMethods() {
		List<SelectOption> options = new List<SelectOption>();
        // If we have defined payment methods and a selected defaul method, display ability to remove.
		if(hasPaymentMethod && zBillingAccount.defaultPayment) {
			options.add(new SelectOption('','Remove Default Method'));
		}
		for(Zuora__PaymentMethod__c pm : paymentMethods.values()) {
			if(('CreditCard').equals(pm.Zuora__Type__c)) {
				String label = '<img src="'+CCZUtility.getResourceURL('CC' + pm.Zuora__CreditCardType__c + 'Logo')+'" align="middle">  ';
	    		label += pm.Zuora__CreditCardMaskNumber__c;
	    		label += '&nbsp;&nbsp;<strong> Expires: </strong>' + pm.Zuora__CreditCardExpirationMonth__c + '/' + pm.Zuora__CreditCardExpirationYear__c;
	    		SelectOption so = new SelectOption(pm.Zuora__External_Id__c,label);
	    		so.setEscapeItem(false);
	    		options.add(so);
			} else {
				String label = 'ACH ' + pm.Zuora__AchBankName__c + ' ' + pm.Zuora__AchAccountNumberMask__c;
	    		SelectOption so = new SelectOption(pm.Zuora__External_Id__c,label);
	    		so.setEscapeItem(false);
	    		options.add(so);
			}
		}
		return options;
	}

	private static void appendMessage(ApexPages.Severity messageType, String message) {
		ApexPages.addMessage(new ApexPages.Message(messageType, message));
	}

	public PageReference toggleEditContactMode() {
		if(!editContactMode) {
			paramValue = ApexPages.currentPage().getParameters().get('contactType');
			if('BillTo'.equals(paramValue)) {
				inputContact = new ContactUI(billToContact);
			} else {
				inputContact = new ContactUI(soldToContact);
			}
		} else {
			inputContact = new ContactUI();
		}
		editContactMode = !editContactMode;
		return null;
	}
	
	public PageReference toggleEditAccountMode() {
		editAccountMode = !editAccountMode;
		return null;
	}
	public PageReference cancelEditAccountMode() {
		editAccountMode = !editAccountMode;
		zBillingAccount.defaultPaymentMethodId = zBillingAccount.defaultPaymentMethod.Zuora__External_Id__c;
		return null;
	}
	
	public PageReference editBillingContact() {
		boolean validInput = true;
		system.debug('\n[DEBUG-CCBillingAccount] editBillingContact\n=========\nUserInput to update: ' + inputContact);
		if(String.isBlank(inputContact.email) ||
			String.isBlank(inputContact.phone) ||
			String.isBlank(inputContact.firstName) ||
			String.isBlank(inputContact.lastName) ) {
            appendMessage(ApexPages.Severity.ERROR, 'Please enter all required fields before saving changes');
            validInput = false;
		}
		// ensure correct phone format
		if(!PhoneFormatter.isValidPhone(inputContact.phone)) {
            appendMessage(ApexPages.Severity.ERROR, 'Please enter a valid phone number - (xxx) xxx-xxxx');
            validInput = false;
		}
		Pattern p = Pattern.compile( '([a-zA-Z0-9_\\-\\.]+)@(((\\[a-z]{1,3}\\.[a-z]{1,3}\\.[a-z]{1,3}\\.)|(([a-zA-Z0-9\\-]+\\.)+))([a-zA-Z]{2,4}|[0-9]{1,3}))');
		Matcher m = p.matcher(inputContact.email);
		if (!m.matches()) {
            appendMessage(ApexPages.Severity.ERROR, 'Please enter a valid email address');
            validInput = false;
		}
		if(!validInput) {
			return null;
		}
		inputContact.phone = PhoneFormatter.formatPhone(inputContact.phone);

		try {
			Zuora.zApi zApiInstance = CCZUtility.zlogin();

			Zuora.zObject obj = new Zuora.zObject('Contact');
			obj.setValue('Id', inputContact.Id);
			obj.setValue('Address1', inputContact.address1);
			obj.setValue('Address2', inputContact.address2);
			obj.setValue('City', inputContact.city);
			obj.setValue('State', inputContact.state);
			obj.setValue('PostalCode', inputContact.postalCode);
			obj.setValue('FirstName', inputContact.firstName);
			obj.setValue('LastName', inputContact.lastName);
			obj.setValue('WorkEmail', inputContact.email);
			obj.setValue('WorkPhone', inputContact.phone);

			system.debug('\n[DEBUG-CCBillingAccount] editBillingContact\n=========\nZuora.zObject to update: ' + obj);
			List<Zuora.zObject> objs = new List<Zuora.zObject> {obj};
			List<Zuora.zApi.SaveResult> results = CCZUtility.zupdate(zApiInstance,objs);
			for (Zuora.zApi.SaveResult result : results) {
				if (result.Success) {
					if(inputContact.id.equals(zBillingAccount.billToId)) {
						billToContact = new ContactUI(inputContact);
					}
					if(inputContact.id.equals(zBillingAccount.soldToId)) {
						soldToContact = new ContactUI(inputContact);
					}
					CCZUtility.zsync(zApiInstance,zBillingAccount.id);
					toggleEditContactMode();
				} else {
					Zuora.zObject[] errors = result.errors;
					ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Error saving Contact:\n' + errors));
				}
			}
/*
		} catch( Zuora.zForceException ex) {
            appendMessage(ApexPages.Severity.ERROR, 'zForceException: ---- ' + ex.getMessage());
			system.debug('\n[DEBUG-CCBillingAccount] editBillingContact\n=========\nzForceException catch block: '+ex.getMessage());
		} catch( Zuora.zAPIException ex) {
            appendMessage(ApexPages.Severity.ERROR, 'zAPIException: ---- ' + ex.getMessage());
			system.debug('\n[DEBUG-CCBillingAccount] editBillingContact\n=========\nzAPIException catch block: '+ex.getMessage());
		} catch( Zuora.zRemoteException ex) {
            appendMessage(ApexPages.Severity.ERROR, 'zRemoteException: ---- ' + ex.getMessage());
			system.debug('\n[DEBUG-CCBillingAccount] editBillingContact\n=========\nzRemoteException catch block: '+ex.getMessage());
*/
		} catch (Exception ex) {
            appendMessage(ApexPages.Severity.ERROR, 'Exception: ---- ' + ex.getMessage());
            system.debug('\n[DEBUG-CCBillingAccount] editBillingContact\n=========\n catch block exception message:  '+ex.getMessage());
		}

		return null;
	}

	public PageReference editBillingAccount() {
		boolean validInput = true;
		system.debug('\n[DEBUG-CCBillingAccount] editBillingAccount\n=========\ndefaultPaymentMethodId: ' + zBillingAccount.defaultPaymentMethodId);
		if(zBillingAccount.autoPay && String.isBlank(zBillingAccount.defaultPaymentMethodId)) {
            appendMessage(ApexPages.Severity.ERROR, 'Because this customer account is designated as Auto-Pay, you must specify an Electronic Payment Method as the default.');
            validInput = false;
		}

		// Prevents customers from disabling auto-pay and/or removing all payment methods if their last invoice was less than $1000.
		if(applyAutoPayEdit && (!zBillingAccount.autoPay || String.isBlank(zBillingAccount.defaultPaymentMethodId))) {
            appendMessage(ApexPages.Severity.ERROR, 'Because the latest Invoice Amount is less than $1000, you cannot disable Auto-Pay or remove default payment method.');
            validInput = false;
		}

		if(!validInput) {
			return null;
		}

		try {
			Zuora.zApi zApiInstance = CCZUtility.zlogin();

			/*
			 * If trying to UNset DefaultPaymentMethod, you must either
			 * 1. Set to common, global method such as 'Check'
			 * 2. Use actual, underlying SOAP call and set the fieldsToNull on the desired field.
					<ns1:update> 
					<ns1:zObjects xsi:type="ns2:Account"> 
					**<ns2:fieldsToNull>DefaultPaymentMethodId</ns2:fieldsToNull>*
					<ns2:Id>2c92c0f9483f301e01485af0ab760717</ns2:Id> 
					</ns1:zObjects> 
					</ns1:update>
			 */
            if(String.isBlank(zBillingAccount.defaultPaymentMethodId)) {
                String queryStr = 'SELECT Id, Name, AccountId, Type ' + 
                    'FROM PaymentMethod WHERE Name = \'Check\'';
                List<Zuora.zObject> pms = CCZUtility.zquery(zApiInstance, queryStr, 'PaymentMethod');
				system.debug('\n[DEBUG-CCBillingAccount] editBillingAccount\n=========\nPaymentMethods: ' + pms);
                // Place Credit Card methods first
                zBillingAccount.defaultPaymentMethodId = (String)pms[0].getValue('Id');
                for(Zuora.zObject pm : pms) {
					system.debug('\n[DEBUG-CCBillingAccount] editBillingAccount\n=========\nPaymentMethod Id: ' + (String)pm.getValue('Id'));
					system.debug('\n[DEBUG-CCBillingAccount] editBillingAccount\n=========\nPaymentMethod Type: ' + (String)pm.getValue('Type'));
					system.debug('\n[DEBUG-CCBillingAccount] editBillingAccount\n=========\nPaymentMethod Name: ' + (String)pm.getValue('Name'));
					system.debug('\n[DEBUG-CCBillingAccount] editBillingAccount\n=========\nPaymentMethod AccountId: ' + (String)pm.getValue('AccountId'));
                }
                
            }

			Zuora.zObject obj = new Zuora.zObject('Account');
			obj.setValue('Id', zBillingAccount.Id);
			obj.setValue('AutoPay', zBillingAccount.autoPay);
			obj.setValue('CommunicationProfileId', (zBillingAccount.autoPay)?communicationProfileMap.get('Credit Card Customer'):communicationProfileMap.get('Default Profile'));
			obj.setValue('PaymentTerm', (zBillingAccount.autoPay)?'Due Upon Receipt':'Net 30');
			obj.setValue('DefaultPaymentMethodId', String.isBlank(zBillingAccount.defaultPaymentMethodId)?null:zBillingAccount.defaultPaymentMethodId);

			system.debug('\n[DEBUG-CCBillingAccount] editBillingAccount\n=========\nZuora.zObject to update: ' + obj);
			List<Zuora.zObject> objs = new List<Zuora.zObject> {obj};
			List<Zuora.zApi.SaveResult> results = CCZUtility.zupdate(zApiInstance,objs);
			for (Zuora.zApi.SaveResult result : results) {
				if (result.Success) {
					if(String.isNotBlank(zBillingAccount.defaultPaymentMethodId)) {
						zBillingAccount.defaultPaymentMethod = paymentMethods.get(zBillingAccount.defaultPaymentMethodId);
					}
					toggleEditAccountMode();
					CCZUtility.zsync(zApiInstance,zBillingAccount.id);
				} else {
					Zuora.zObject[] errors = result.errors;
					ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Error saving Account Payment Options:\n' + errors));
				}
			}
/*
		} catch( Zuora.zForceException ex) {
            appendMessage(ApexPages.Severity.ERROR, 'zForceException: ---- ' + ex.getMessage());
			system.debug('\n[DEBUG-CCBillingAccount] editBillingAccount\n=========\nzForceException catch block: '+ex.getMessage());
		} catch( Zuora.zAPIException ex) {
            appendMessage(ApexPages.Severity.ERROR, 'zAPIException: ---- ' + ex.getMessage());
			system.debug('\n[DEBUG-CCBillingAccount] editBillingAccount\n=========\nzAPIException catch block: '+ex.getMessage());
		} catch( Zuora.zRemoteException ex) {
            appendMessage(ApexPages.Severity.ERROR, 'zRemoteException: ---- ' + ex.getMessage());
			system.debug('\n[DEBUG-CCBillingAccount] editBillingAccount\n=========\nzRemoteException catch block: '+ex.getMessage());
*/
		} catch (Exception ex) {
            appendMessage(ApexPages.Severity.ERROR, 'Exception: ---- ' + ex.getMessage());
            system.debug('\n[DEBUG-CCBillingAccount] editBillingAccount\n=========\n catch block exception message:  '+ex.getMessage());
		}

		return null;
	}

	/**
	 * Utility class to represent billing account
	 */
	public BillingAccountUI zBillingAccount { get; set; }
	public class BillingAccountUI {
		public String id { get; set; }
		public String accountNumber { get; set; }
		public Boolean autoPay { get; set; }
		public decimal balance { get; set; }
		public decimal totalInvoiceBalance { get; set; }
		public String billToId { get; set; }
		public String soldToId { get; set; }
		public String defaultPaymentMethodId { get; set; }
		public String name { get; set; }
		public String paymentGateway { get; set; }
		public Zuora__PaymentMethod__c defaultPaymentMethod { get; set; }
		public boolean defaultPayment {
			get {
				if(defaultPaymentMethod != null && (String.isNotBlank(defaultPaymentMethod.Zuora__CreditCardMaskNumber__c) || String.isNotBlank(defaultPaymentMethod.Zuora__AchAccountNumberMask__c))) {
					return true;
				} else {
					return false;
				}
			}
			set;
		}
		public boolean defaultCreditCard {
			get {
				if(String.isNotBlank(defaultPaymentMethodId) && defaultPaymentMethod != null && defaultPaymentMethod.Zuora__Type__c.equals('CreditCard')) {
					return true;
				} else {
					return false;
				}
			}
			set;
		}
		public String paymentMethodString {
			get {
				String strValue = '';
				if(defaultCreditCard) {
					strValue = '<img src="'+CCZUtility.getResourceURL('CC' + defaultPaymentMethod.Zuora__CreditCardType__c + 'Logo')+'" align="middle">  ';
	        		strValue += defaultPaymentMethod.Zuora__CreditCardMaskNumber__c;
	        		strValue += '&nbsp;&nbsp;<strong> Expires: </strong>' + defaultPaymentMethod.Zuora__CreditCardExpirationMonth__c + '/' + defaultPaymentMethod.Zuora__CreditCardExpirationYear__c;
				} else {
					strValue = 'ACH ' + defaultPaymentMethod.Zuora__AchBankName__c + ' ' + defaultPaymentMethod.Zuora__AchAccountNumberMask__c;
				}
        		return strValue;
			}
			set;
		}

		public BillingAccountUI() {
			defaultPayment = false;
			defaultCreditCard = false;
		}
	}

	/**
	 * Utility class to represent billing contact input
	 */
	public ContactUI billToContact { get; set; }
	public ContactUI soldToContact { get; set; }
	public ContactUI inputContact { get; set; }
	public class ContactUI {
	    public List<SelectOption> stateOptions { get; set; }
		public String id { get; set; }
		public String address1 { get; set; }
		public String address2 { get; set; }
		public String city { get; set; }
		public String state { get; set; }
		public String postalCode { get; set; }
		public String firstName { get; set; }
		public String lastName { get; set; }
		public String email { get; set; }
		public String phone { get; set; }
		
		public ContactUI() {
			init();
		}

		public ContactUI(ContactUI contact) {
			init();
			this.id = contact.id;
			this.address1 = contact.address1;
			this.address2 = contact.address2;
			this.city = contact.city;
			this.state = contact.state;
			this.postalCode = contact.postalCode;
			this.firstName = contact.firstName;
			this.lastName = contact.lastName;
			this.email = contact.email;
			this.phone = contact.phone;
		}
		
		private void init() {
        	stateOptions = new List<SelectOption>();
			stateOptions.add(new SelectOption('','-Select One-'));
	    	List<States__c> states = States__c.getall().values();
	    	states.sort();
	    	for(States__c s : states) {
	    		stateOptions.add(new SelectOption(s.State_Name__c,s.State_Name__c));
	    	}
		}
	}

	public List<SelectOption> getStates() {
		List<SelectOption> options = new List<SelectOption>();
		options.add(new SelectOption('','-Select One-'));
    	List<States__c> states = States__c.getall().values();
    	states.sort();
    	for(States__c s : states) {
    		options.add(new SelectOption(s.State_Name__c,s.State_Name__c));
    	}
    	return options;
	}

    public with sharing class InvoiceWrapper implements Comparable {
        public Zuora__ZInvoice__c invoice { get; set; }

        //This is the contructor method. When we create a new cContact object we pass a Contact that is set to the con property. We also set the selected value to false
        public InvoiceWrapper(Zuora__ZInvoice__c inv) {
            invoice = inv;
        }
        
        public Integer compareTo(Object compareTo) {
            // The return value of 0 indicates that both are equal
            Integer returnValue = 0;
            try {
                // cast object to Zuora__ZInvoice__c
                InvoiceWrapper compareTozInv = (InvoiceWrapper)compareTo;
                if(invoice.Zuora__Posted_Date__c < compareTozInv.invoice.Zuora__Posted_Date__c) {
                    returnValue = 1;
                } else if(invoice.Zuora__Posted_Date__c > compareTozInv.invoice.Zuora__Posted_Date__c) {
                    returnValue = -1;
                }
            } catch (Exception ex) {
                appendMessage(ApexPages.Severity.ERROR, 'Unable to Sort List: ---- ' + ex.getMessage());
                system.debug('\n[DEBUG-CCBillingAccount.InvoiceWrapper.compareTo()]\n=========\n catch block exception message:  '+ex.getMessage());
            }
            return returnValue;
        }
    }
}