public with sharing class CCSelectCaseType {
	public String retUrl { get; set; }
	public String listView {get;set;}
	public String recordTypeId {get;set;}
	public Map<Id,CaseType> availableCaseTypes {get;set;}
	private String baseUrl = '/selfservice/apex/';
	
    public CCSelectCaseType() {
		retUrl = (String)Apexpages.currentPage().getParameters().get('retUrl');
		System.debug('[DEBUG-CCSelectCaseType.CCSelectCaseType()]\n=========\nretUrl: ' + retUrl);
    	listView = (String)Apexpages.currentPage().getParameters().get('listView');
		System.debug('[DEBUG-CCSelectCaseType.CCSelectCaseType()]\n=========\nlistView: ' + listView);

		// Obtain profile driven available Case Record Types
		// Convert to custom CaseType as workaround for inability to display RecordType Description.
		Map<Id,RecordType> availableRecordTypes = CCRecordType.getAvailableRecordTypeNamesForSObject(Case.SObjectType);
    	Map<String, CCRecordTypes__c> recordTypeNames = CCRecordTypes__c.getall();
		System.debug('[DEBUG-CCSelectCaseType.CCSelectCaseType()]\n=========\navailableRecordTypes: ' + availableRecordTypes);
		System.debug('[DEBUG-CCSelectCaseType.CCSelectCaseType()]\n=========\nrecordTypeNames: ' + recordTypeNames);
		availableCaseTypes = new Map<Id,CaseType>();
		for(RecordType rt : availableRecordTypes.values()) {
			CCRecordTypes__c crt = recordTypeNames.get(rt.name);
			CaseType ct = new CaseType(crt);
			availableCaseTypes.put(ct.id,ct);
		}
		System.debug('[DEBUG-CCSelectCaseType.CCSelectCaseType()]\n=========\nCASE RECORD TYPES: ' + availableCaseTypes);

		// Set default record type value
		recordTypeId = CCRecordType.getDefaultRecordTypeForSObject(Case.SObjectType);
    }
    
	//  Continue to create case
    public PageReference createCase() {
		// Obtain correct page mapping from custom settings based on record type Id to page name
    	CaseType ct = availableCaseTypes.get(recordTypeId);
    	String url = baseUrl;
    	url += ct.newPage;
        PageReference aPage = new PageReference(url);
		aPage.getParameters().put('listView',listView);
        return aPage;
    }
    
    public PageReference back() {
        PageReference aPage = new PageReference(retUrl);
		aPage.getParameters().put('listView',listView);
        return aPage;
    }

	public List<SelectOption> getRecordTypeOptions() {
		List<SelectOption> options = new List<SelectOption>();
		for(CaseType ct : availableCaseTypes.values()) {
			options.add(new SelectOption(ct.id,ct.name));
		}
		System.debug('[DEBUG-CCSelectCaseType.getRecordTypeOptions()]\n=========\nCASE RECORD TYPE OPTIONS: ' + options);
    	return options;
	}
	
	public List<CaseType> getCaseTypes() {
		return availableCaseTypes.values();
	}

	/*
	 * Communities will not display the RecordType Description
	 * So I'm implementing my own custom type
	 */
	public class CaseType {
		public String id { get; set; }
		public String name { get; set; }
		public String description { get; set; }
		public String newPage { get; set; }
		public String detailPage { get; set; }
		
		public CaseType() {
		}

		public CaseType(RecordType rt) {
			this.id = rt.id;
			this.name = rt.name;
			this.description = rt.description;
		}
		public CaseType(CCRecordTypes__c rt) {
			this.id = rt.RecordTypeId__c;
			this.name = rt.RecordTypeName__c;
			this.description = rt.RecordTypeDescription__c;
			this.newPage = rt.NewPage__c;
			this.detailPage = rt.DetailPage__c;
		}
	}

}