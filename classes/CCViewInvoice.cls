public with sharing class CCViewInvoice {

    public Zuora__ZInvoice__c invoice { get; set; }
    public List<InvoiceItems> invoiceItems { get; set; }
    public String totalAmount {
    	get {
		    String s = '$' + (invoice.Zuora__TotalAmount__c==null||invoice.Zuora__TotalAmount__c==0?'0.00':String.valueOf(((invoice.Zuora__TotalAmount__c).setScale(2) + 0.001).format()));
		    return s.substring(0,s.length()-1);
    	}
    }
    public String taxAmount {
    	get {
		    String s = '$' + (invoice.Zuora__TaxAmount__c==null||invoice.Zuora__TaxAmount__c==0?'0.001':String.valueOf(((invoice.Zuora__TaxAmount__c).setScale(2) + 0.001).format()));
		    return s.substring(0,s.length()-1);
    	}
    }
    public String subTotalAmount {
    	get {
		    String s = '$' + (invoice.Zuora__AmountWithoutTax__c==null||invoice.Zuora__AmountWithoutTax__c==0?'0.00':String.valueOf(((invoice.Zuora__AmountWithoutTax__c).setScale(2) + 0.001).format()));
		    return s.substring(0,s.length()-1);
    	}
    }

	public CCViewInvoice() {
		try {
	        String invoiceId = (String)Apexpages.currentPage().getParameters().get('invId');
	        system.debug('\n[DEBUG-CCViewInvoice] CONSTRUCTOR\n=========\nINVOICE ID: ' + invoiceId);
	        invoice = [SELECT Id, Zuora__Account__c, Zuora__Balance2__c, Name, Zuora__ZuoraId__c, Zuora__InvoiceDate__c,
	            Zuora__DueDate__c, Zuora__Status__c, Zuora__PaymentAmount__c, Zuora__TaxAmount__c, Zuora__TotalAmount__c, Zuora__Zuora_Id__c, Zuora__PaymentTerm__c,
	            Zuora__BillingAccount__r.Name, Zuora__BillingAccount__r.Zuora__BillToCity__c, Zuora__BillingAccount__r.Zuora__BillToCountry__c,
				Zuora__BillingAccount__r.Zuora__BillToAddress1__c, Zuora__BillingAccount__r.Zuora__BillToAddress2__c, Zuora__BillingAccount__r.Zuora__DefaultPaymentMethod__c,
				Zuora__BillingAccount__r.Zuora__BillToState__c, Zuora__BillingAccount__r.Zuora__BillToPostalCode__c, Zuora__BillingAccount__r.Zuora__BillToName__c,
				Zuora__BillingAccount__r.Zuora__AccountNumber__c, Zuora__AmountWithoutTax__c
	            FROM Zuora__ZInvoice__c
	            WHERE Zuora__Zuora_Id__c = :invoiceId
	            LIMIT 1];

			Zuora.zApi zApiInstance = CCZUtility.zlogin();

			String query = 'SELECT Id, ChargeAmount, RatePlanChargeId, ' +
				'Quantity, ServiceEndDate, ServiceStartDate, UnitPrice, TaxAmount ' +
				'FROM InvoiceItem WHERE InvoiceId = \'' + invoice.Zuora__Zuora_Id__c + '\' AND ChargeAmount > 0';
			List<Zuora.zObject> items = CCZUtility.zquery(zApiInstance, query, 'InvoiceItem');
	        system.debug('\n[DEBUG-CCViewInvoice] CONSTRUCTOR\n=========\nINVOICE ITEMS: ' + items);

	        String whereClause = '';
			for(Zuora.zObject item : items) {
				if(String.isBlank(whereClause)) {
					whereClause += 'Id = \'' + (String)item.getValue('RatePlanChargeId') + '\'';
				} else {
					whereClause += ' OR Id = \'' + (String)item.getValue('RatePlanChargeId') + '\'';
				}
			}
			query = 'SELECT Id, Name ' +
				'FROM RatePlanCharge WHERE ' + whereClause;
	        system.debug('\n[DEBUG-CCViewInvoice] CONSTRUCTOR\n=========\nquery: ' + query);
			List<Zuora.zObject> objs = CCZUtility.zquery(zApiInstance, query, 'RatePlanCharge');
	        system.debug('\n[DEBUG-CCViewInvoice] CONSTRUCTOR\n=========\nobjs: ' + objs);
	        Map<String,String> ratePlans = new Map<String,String>(); 
			for(Zuora.zObject obj : objs) {
				ratePlans.put((String)obj.getValue('Id'),(String)obj.getValue('Name'));
			}
			invoiceItems = new List<InvoiceItems>();
			for(Zuora.zObject item : items) {
				InvoiceItems invoiceItem = new InvoiceItems();
				invoiceItem.chargeAmount = String.valueOf(item.getValue('ChargeAmount'));
				invoiceItem.quantity = String.valueOf(item.getValue('Quantity'));
				invoiceItem.serviceEndDate = String.valueOf(item.getValue('ServiceEndDate'));
				invoiceItem.serviceStartDate = String.valueOf(item.getValue('ServiceStartDate'));
				invoiceItem.unitPrice = String.valueOf(item.getValue('UnitPrice'));
				invoiceItem.taxAmount = String.valueOf(item.getValue('TaxAmount'));
				invoiceItem.productName = ratePlans.get(String.valueOf(item.getValue('RatePlanChargeId')));
				invoiceItems.add(invoiceItem);
			}
	        system.debug('\n[DEBUG-CCViewInvoice] CONSTRUCTOR\n=========\nInvoiceItems: ' + invoiceItems);
		} catch (Exception ex) {
			system.debug('\n[DEBUG-CCViewInvoice] CONSTRUCTOR\n=========\nException catch block: '+ex.getMessage());
		}
	}

	/**
	 * Utility class to represent ach input
	 */
	public class InvoiceItems {
		public String productName { get; set; }
		public String chargeAmount { 
			get{
				return currency(chargeAmount);
			}
			set;
		}
		public String quantity { get; set; }
		public String serviceEndDate { 
			get {
				return Date.valueOf(serviceEndDate).format();
			}
			set;
		}
		public String serviceStartDate {
			get {
				return Date.valueOf(serviceStartDate).format();
			}
			set;
		}
		public String unitPrice { 
			get {
				return '$'+(unitPrice.contains('.')?unitPrice:(unitPrice+'.00'));
			}	 
			set;
		}
		public String taxAmount { 
			get{
				return currency(taxAmount);
			}
			set;
		}
		
		private String currency(String i) {
		    String s = '$' + ( Decimal.valueOf(i==null||i.trim()==''?'0':i).setScale(2) + 0.001 ).format();
		    return s.substring(0,s.length()-1);
		}
	}
}