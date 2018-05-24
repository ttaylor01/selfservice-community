public with sharing class CCManageBilling {

    public Zuora__CustomerAccount__c billingAccount { get; set; }
    public String paymentMethodId { get; set; }
    private PageReference goBack;
    public List<InvoiceWrapper> invoiceList { get; set; }
    public List<InvoiceWrapper> invoicePayments { get; set; }
    public List<Zuora__Payment__c> paymentList { get; set; }
    public Map<String,Zuora__PaymentMethod__c> paymentMethods;
    public String retUrl { get; set; }
    public Zuora__ZInvoice__c total {
        get {
            if(total == null) {
                total = new Zuora__ZInvoice__c(Zuora__Balance2__c = 0, Zuora__TotalAmount__c = 0, Zuora__TaxAmount__c = 0);
            }
            system.debug('\n[DEBUG-CCManageBilling] getTotal\n=========\nTotal Invoice: '+ total);
            system.debug('\n[DEBUG-CCManageBilling] getTotal\n=========\ninvoiceList: '+ invoiceList);
            if(invoiceList == null) invoiceList = new List<InvoiceWrapper>();
            for(InvoiceWrapper i : invoiceList) {
                system.debug('\n[DEBUG-CCManageBilling] getTotal\n=========\nInvoice: '+ i);
                total.Zuora__Balance2__c += i.invoice.Zuora__Balance2__c;
                total.Zuora__TotalAmount__c += i.invoice.Zuora__TotalAmount__c;
                total.Zuora__TaxAmount__c += i.invoice.Zuora__TaxAmount__c==null ? 0 : i.invoice.Zuora__TaxAmount__c;
            }
            system.debug('\n[DEBUG-CCManageBilling] getTotal\n=========\nTotal Invoice: '+ total);
            return total;
        }
        set;
    }
    public boolean makePaymentMode { get; set; }
    private String paymentSortOrder = 'DESC';
    
    public CCManageBilling() {
        try {
            String billingAccountId = (String)Apexpages.currentPage().getParameters().get('id');
            retUrl = (String)Apexpages.currentPage().getParameters().get('retUrl');
            system.debug('\n[DEBUG-CCManageBilling] CONSTRUCTOR\n=========\nretUrl: ' + retUrl);
            system.debug('\n[DEBUG-CCManageBilling] CONSTRUCTOR\n=========\nBilling Account ID: ' + billingAccountId);
            goBack = new PageReference(retUrl);
            makePaymentMode = false;

            billingAccount = [SELECT Zuora__Account__c, Zuora__Balance__c, Name, Id, Zuora__Zuora_Id__c,
                Zuora__BillToId__c, Zuora__SoldToId__c, Zuora__DefaultPaymentMethod__c
                FROM Zuora__CustomerAccount__c
                WHERE Zuora__Zuora_Id__c = :billingAccountId];

            Zuora.zApi zApiInstance = CCZUtility.zlogin();

            // Need to obtain the default payment method and will store in SFDC billing account object
            String queryStr = 'SELECT Id, DefaultPaymentMethodId, PaymentGateway ' +
                'FROM Account WHERE Id = \'' + billingAccount.Zuora__Zuora_Id__c + '\'';
            List<Zuora.zObject> accounts = CCZUtility.zquery(zApiInstance, queryStr, 'Account');
            system.debug('\n[DEBUG-CCBillingAccount.] CONSTRUCTOR\n=========\nAccounts: ' + accounts);
            for(Zuora.zObject a : accounts) {
                paymentMethodId = (String)a.getValue('DefaultPaymentMethodId');
            }

            queryStr = 'SELECT Id, CreditCardMaskNumber, CreditCardType, CreditCardHolderName, PaymentMethodStatus, ' +
                'AchAbaCode, AchAccountName, AchAccountNumberMask, AchAccountType, AchBankName, Type, ' +
                'CreditCardAddress1, CreditCardAddress2, CreditCardCity, CreditCardCountry, CreditCardExpirationMonth, ' +
                'CreditCardExpirationYear, CreditCardPostalCode, CreditCardState ' + 
                'FROM PaymentMethod WHERE AccountId = \'' + billingAccount.Zuora__Zuora_Id__c + '\'';
            List<Zuora.zObject> pms = CCZUtility.zquery(zApiInstance, queryStr, 'PaymentMethod');
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
/*
        } catch( Zuora.zForceException ex) {
            appendMessage(ApexPages.Severity.ERROR, 'zForceException: ---- ' + ex.getMessage());
            system.debug('\n[DEBUG-CCManageBilling] CONSTRUCTOR\n=========\nzForceException catch block: '+ex.getMessage());
        } catch( Zuora.zAPIException ex) {
            appendMessage(ApexPages.Severity.ERROR, 'zAPIException: ---- ' + ex.getMessage());
            system.debug('\n[DEBUG-CCManageBilling] CONSTRUCTOR\n=========\nzAPIException catch block: '+ex.getMessage());
        } catch( Zuora.zRemoteException ex) {
            appendMessage(ApexPages.Severity.ERROR, 'zRemoteException: ---- ' + ex.getMessage());
            system.debug('\n[DEBUG-CCManageBilling] CONSTRUCTOR\n=========\nzRemoteException catch block: '+ex.getMessage());
*/
        } catch (Exception ex) {
            appendMessage(ApexPages.Severity.ERROR, ex.getMessage());
            system.debug('\n[DEBUG-CCManageBilling] CONSTRUCTOR\n=========\nException catch block: '+ex.getMessage());
        }
    }

    private static void appendMessage(ApexPages.Severity messageType, String message) {
        ApexPages.addMessage(new ApexPages.Message(messageType, message));
    }

    public PageReference goBack() {
        goBack.setRedirect(true);
        return goBack;
    }
    public PageReference toggleMakePaymentMode() {
        if(!hasPaymentMethod) {
            appendMessage(ApexPages.Severity.INFO, 'You must define a Payment Method to apply a payment.');
            return null;
        }
        system.debug('\n[DEBUG-CCManageBilling.toggleMakePaymentMode()]\n=========\nmakePaymentMode: ' + makePaymentMode);
        invoicePayments = new List<InvoiceWrapper>();
        boolean hasSelected = false;
        if(!makePaymentMode) {
            for(InvoiceWrapper i : getInvoices()) {
                if(i.selected) {
                    hasSelected = true;
                    invoicePayments.add(i);
                }
            }
            if(!hasSelected) {
                appendMessage(ApexPages.Severity.INFO, 'You must select one or more Invoices to apply a payment.');
                total = null;
                return null;
            }
        } else {
            for(InvoiceWrapper i : getInvoices()) {
                if(i.selected) {
                    i.selected = false;
                }
            }
            total = null;
        }
        makePaymentMode = !makePaymentMode;
        system.debug('\n[DEBUG-CCManageBilling.toggleMakePaymentMode()]\n=========\ninvoicePayments: ' + invoicePayments);
        system.debug('\n[DEBUG-CCManageBilling.toggleMakePaymentMode()]\n=========\nmakePaymentMode: ' + makePaymentMode);
        return null;
    }
    
    public PageReference sendPayment() {
        try {
            boolean validInput = true;
            decimal totalAmount = 0.0;
            for(InvoiceWrapper i : invoicePayments) {
                if(i.internalPaymentAmount != null && i.internalPaymentAmount != 0 ) {
                    if(i.internalPaymentAmount > i.invoice.Zuora__Balance2__c) {
                        appendMessage(ApexPages.Severity.ERROR, 'Amount of payment for Invoice, '+i.invoice.Name+', cannot exceed remaining invoice balance.');
                        validInput = false;
                    }
                    totalAmount += i.internalPaymentAmount;
                }
            }
            system.debug('\n[DEBUG-CCManageBilling.sendPayment()]\n=========\ntotalAmount: ' + totalAmount);
            if(String.isBlank(paymentMethodId) || totalAmount == 0 ) {
                appendMessage(ApexPages.Severity.ERROR, 'You must enter an Amount and select a Payment Option to apply a payment');
                validInput = false;
            }
            if(!validInput) return null;

            Zuora.zApi zApiInstance = CCZUtility.zlogin();
            List<Zuora.zObject> objs = new List<Zuora.zObject>();
            DateTime dt = Date.today();
            String zuoraDate = dt.format('yyyy-MM-dd','EDT');
            for(InvoiceWrapper i : invoicePayments) {
                Zuora.zObject payment = new Zuora.zObject('Payment');
                payment.setValue('AccountId', billingAccount.Zuora__Zuora_Id__c);
                payment.setValue('InvoiceId', i.invoice.Zuora__Zuora_Id__c);
                payment.setValue('AppliedInvoiceAmount', i.internalPaymentAmount);      // The amount of the payment to apply to an invoice.
                payment.setValue('Amount', i.internalPaymentAmount);                    // Amount of payment
                /*
                payment.setValue('EffectiveDate', Zuora.zUtil.getZuoraDateOnly(Date.today()));  // yyyy-MM-dd format only
                 * Zuora.zUtil.getZuoraDateOnly(Date.today()) is not visible for compilation.
                 * I've had this issue before with zuora methods.
                 * Must manipulate manually to get correct format.
                 */
                payment.setValue('EffectiveDate', zuoraDate);   // yyyy-MM-dd format only
                payment.setValue('PaymentMethodId', paymentMethodId);
                payment.setValue('Status', 'Processed');
                payment.setValue('Gateway', getPaymentGateway(paymentMethods.get(paymentMethodId).Zuora__Type__c));
                payment.setValue('Type', 'Electronic');
                objs.add(payment);
                system.debug('\n[DEBUG-CCManageBilling.sendPayment()]\n=========\nZuora.zObject to create: ' + payment);
            }

            List<Zuora.zApi.SaveResult> results = CCZUtility.zcreate(zApiInstance,objs);
            boolean successful = false;
            for (Zuora.zApi.SaveResult result : results) {
                if (result.Success) {
                    successful = true;
                } else {
                    Zuora.zObject[] errors = result.errors;
                    appendMessage(ApexPages.Severity.ERROR, 'Error applying one or more payments');
                    for (Zuora.zObject error : errors) {
                        String errorCode = (String)error.getValue('Code');
                        String message = (String)error.getValue('Message');
                        appendMessage(ApexPages.Severity.ERROR, errorCode + ': ' + message);
                    }
                }
            }
            if(successful) {
                // reset page rendering triggers
                invoiceList = null;
                invoicePayments = null;
                paymentList = null;
                total = null;
                makePaymentMode = !makePaymentMode;
                appendMessage(ApexPages.Severity.INFO, 'Payment Submitted');
                CCZUtility.zsync(zApiInstance,billingAccount.Zuora__Zuora_Id__c);
            }
/*
        } catch( Zuora.zForceException ex) {
            appendMessage(ApexPages.Severity.ERROR, 'zForceException: ---- ' + ex.getMessage());
            system.debug('\n[DEBUG-CCManageBilling.sendPayment()]\n=========\nzForceException catch block: '+ex.getMessage());
        } catch( Zuora.zAPIException ex) {
            appendMessage(ApexPages.Severity.ERROR, 'zAPIException: ---- ' + ex.getMessage());
            system.debug('\n[DEBUG-CCManageBilling.sendPayment()]\n=========\nzAPIException catch block: '+ex.getMessage());
        } catch( Zuora.zRemoteException ex) {
            appendMessage(ApexPages.Severity.ERROR, 'zRemoteException: ---- ' + ex.getMessage());
            system.debug('\n[DEBUG-CCManageBilling.sendPayment()]\n=========\nzRemoteException catch block: '+ex.getMessage());
*/
        } catch (Exception ex) {
            appendMessage(ApexPages.Severity.ERROR, 'Exception: ---- ' + ex.getMessage());
            system.debug('\n[DEBUG-CCManageBilling.sendPayment()]\n=========\n catch block exception message:  '+ex.getMessage());
        }

        return null;
    }
    
    public List<InvoiceWrapper> getInvoices() {
        if(invoiceList == null) {
            invoiceList = new List<InvoiceWrapper>();
/*
            for(Zuora__ZInvoice__c i : [SELECT Zuora__Account__c, Zuora__Balance2__c, Name, Zuora__ZuoraId__c, Zuora__InvoiceDate__c, Zuora__DueDate__c,
                Zuora__Status__c, Id, Zuora__PaymentAmount__c, Zuora__TaxAmount__c, Zuora__TotalAmount__c
                FROM Zuora__ZInvoice__c
                WHERE Zuora__BillingAccount__c = :billingAccount.Id]) {
                invoiceList.add(new InvoiceWrapper(i));
            }
*/

            Zuora.zApi zApiInstance = CCZUtility.zlogin();
            String zuoraDateTime = Zuora.zUtil.getZuoraDate(System.now());
            system.debug('\n[DEBUG-CCManageBilling.getInvoices()]\n=========\nCurrent zuoraDateTime: ' + zuoraDateTime);
            String queryStr = 'SELECT Id, AccountId, Amount, Balance, DueDate, InvoiceDate, InvoiceNumber, PaymentAmount, ' +
                'Status, TaxAmount, LastEmailSentDate ' +
                'FROM Invoice WHERE AccountId = \'' + billingAccount.Zuora__Zuora_Id__c + '\' AND Status = \'Posted\'';
//              'FROM Invoice WHERE AccountId = \'' + billingAccount.Zuora__Zuora_Id__c + '\' AND Status = \'Posted\' ' +
//              'AND LastEmailSentDate != null AND LastEmailSentDate < \'' + zuoraDateTime + '\'';
            List<Zuora.zObject> objs = CCZUtility.zquery(zApiInstance, queryStr, 'Invoice');
            system.debug('\n[DEBUG-CCManageBilling.getInvoices()]\n=========\nInvoices: ' + objs);
            for(Zuora.zObject obj : objs) {
                Zuora__ZInvoice__c i = new Zuora__ZInvoice__c();
                i.Zuora__Zuora_Id__c = (String)obj.getValue('Id');
                i.Zuora__BillingAccount__c = billingAccount.Id;
                i.Zuora__Balance2__c  = (decimal)obj.getValue('Balance');
                i.Zuora__PaymentAmount__c  = (decimal)obj.getValue('PaymentAmount');
                i.Zuora__TotalAmount__c  = (decimal)obj.getValue('Amount');
                i.Zuora__TaxAmount__c  = (decimal)obj.getValue('TaxAmount');
                i.Name = (String)obj.getValue('InvoiceNumber');
                i.Zuora__Status__c = (String)obj.getValue('Status');
                i.Zuora__InvoiceDate__c = (Date)obj.getValue('InvoiceDate');
                i.Zuora__DueDate__c = (Date)obj.getValue('DueDate');
//              i.Zuora__DueDate__c = Date.valueOf((DateTime)obj.getValue('DueDate'));
                invoiceList.add(new InvoiceWrapper(i));
                system.debug('\n[DEBUG-CCManageBilling.getInvoices()]\n=========\nLastEmailSentDate: ' + i.Name + ' : ' + Date.valueOf((DateTime)obj.getValue('LastEmailSentDate')));
            }

        }
        invoiceList.sort();
        return invoiceList;
    }
    
    public List<Zuora__Payment__c> getPayments() {
        if(paymentList == null) {
            paymentList = new List<Zuora__Payment__c>();
            for(Zuora__Payment__c p : Database.query(
                'SELECT Id, Zuora__Account__c, Zuora__Amount__c, Zuora__InvoiceNumber__c, Name, Zuora__EffectiveDate__c, Zuora__Status__c, Zuora__PaymentMethod__c ' +
                'FROM Zuora__Payment__c ' +
                'WHERE Zuora__BillingAccount__c = \'' + billingAccount.Id + '\' ' +
                'ORDER BY Zuora__EffectiveDate__c ' + paymentSortOrder
            )) {
                paymentList.add(p);
            }
        }
        return paymentList;
    }
    
    public void sortByPaymentDate() {
        if('DESC'.equals(paymentSortOrder)) {
            paymentSortOrder = 'ASC';
        } else {
            paymentSortOrder = 'DESC';
        }
        paymentList = null;
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

    private String getPaymentGateway(String paymentMethodType) {
        String gateway = '';
        if(paymentMethodType.equals('CreditCard')) {
        	gateway = App_Settings__c.getInstance(UserInfo.getProfileId()).CreditCardGateway__c;
        } else {
        	gateway = App_Settings__c.getInstance(UserInfo.getProfileId()).ACHGateway__c;
        }
        return gateway;
    }

    /*
     * This is our wrapper/container class.
     * Contains both the Invoice object and a Boolean value to denote the selected Invoice from the UI
     */
    public String invSortOrder = 'DESC';
    public void sortByInvoiceDate() {
        if('DESC'.equals(invSortOrder)) {
            invSortOrder = 'ASC';
        } else {
            invSortOrder = 'DESC';
        }
    }
    public with sharing class InvoiceWrapper implements Comparable {
        public Zuora__ZInvoice__c invoice { get; set; }
        public Boolean selected { get; set; }
        private decimal internalPaymentAmount;
        public decimal inputPaymentAmount {
            get;
            set {
                inputPaymentAmount = value;
                if(value != null) {
                    // set Scale to match currency
                    internalPaymentAmount = value.setScale(2, System.RoundingMode.HALF_UP);
                } else {
                    internalPaymentAmount = value;
                }
            }
        }

        //This is the contructor method. When we create a new cContact object we pass a Contact that is set to the con property. We also set the selected value to false
        public InvoiceWrapper(Zuora__ZInvoice__c inv) {
            invoice = inv;
            inputPaymentAmount = invoice.Zuora__Balance2__c;
            selected = false;
        }
        
        public Integer compareTo(Object compareTo) {
            // The return value of 0 indicates that both are equal
            Integer returnValue = 0;
            try {
                // cast object to Zuora__ZInvoice__c
                InvoiceWrapper compareTozInv = (InvoiceWrapper)compareTo;
                if(invoice.Zuora__InvoiceDate__c < compareTozInv.invoice.Zuora__InvoiceDate__c) {
                    returnValue = 1;
                } else if(invoice.Zuora__InvoiceDate__c > compareTozInv.invoice.Zuora__InvoiceDate__c) {
                    returnValue = -1;
                }
            } catch (Exception ex) {
                appendMessage(ApexPages.Severity.ERROR, 'Unable to Sort List: ---- ' + ex.getMessage());
                system.debug('\n[DEBUG-CCManageBilling.InvoiceWrapper.compareTo()]\n=========\n catch block exception message:  '+ex.getMessage());
            }
            return returnValue;
        }
    }
}