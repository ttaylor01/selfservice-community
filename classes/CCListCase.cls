public with sharing class CCListCase {

	private Contact contact { get; set; }
	private User user { get; set; }
	private Profile profile { get; set; }
	public String listView { get; set; }
	public String title { get; set; }
	public String searchStr { get; set; }
	public Integer size { get; set; }
	public Integer noOfRecords { get; set; }
	public List<SelectOption> paginationSizeOptions { get; set; }
	private Set<Id> recordTypeIds { get; set; }
	private Map<Id,CaseType> availableCaseTypes {get;set;}
	public String recordTypeId {get;set;}
	public String selectedId {get;set;}
	private String baseUrl = '/selfservice/apex/';

	public String sortFieldSave;

	public CCListCase() {
		system.debug('\n[DEBUG-CCListCase.CCListCase()]\n=========\nCurrent Profile: ' + UserInfo.getProfileId());
		this.user = [Select Id, AccountId, ContactId, Billing_Authorization__c from User Where Id = :UserInfo.getUserId()];
		this.contact = [Select Id, Name from Contact Where Id = :user.ContactId];
		this.profile = [Select Id, Name from Profile Where Id = :UserInfo.getProfileId()];
		System.debug('[DEBUG-CCListCase.CCListCase()]\n=========\nUSER: ' + this.user);
		System.debug('[DEBUG-CCListCase.CCListCase()]\n=========\nCONTACT: ' + this.contact);

		size=10;
		paginationSizeOptions = new List<SelectOption>();
		paginationSizeOptions.add(new SelectOption('5','5'));
		paginationSizeOptions.add(new SelectOption('10','10'));
		paginationSizeOptions.add(new SelectOption('25','25'));
		paginationSizeOptions.add(new SelectOption('50','50'));
		paginationSizeOptions.add(new SelectOption('100','100'));

		// Obtain profile driven available Case Record Types
		// Convert to custom CaseType as workaround for inability to display RecordType Description.
		Map<Id,RecordType> availableRecordTypes = CCRecordType.getAvailableRecordTypeNamesForSObject(Case.SObjectType);
    	Map<String, CCRecordTypes__c> recordTypeNames = CCRecordTypes__c.getall();
		System.debug('[DEBUG-CCSelectCaseType.CCListCase()]\n=========\navailableRecordTypes: ' + availableRecordTypes);
		System.debug('[DEBUG-CCSelectCaseType.CCListCase()]\n=========\nrecordTypeNames: ' + recordTypeNames);
		availableCaseTypes = new Map<Id,CaseType>();
		for(RecordType rt : availableRecordTypes.values()) {
			CCRecordTypes__c crt = recordTypeNames.get(rt.name);
			CaseType ct = new CaseType(crt);
			availableCaseTypes.put(ct.id,ct);
		}
		System.debug('[DEBUG-CCSelectCaseType.CCListCase()]\n=========\nCASE RECORD TYPES: ' + availableCaseTypes);
        recordTypeIds = availableCaseTypes.keySet();

		listView = (String)Apexpages.currentPage().getParameters().get('listView');
		if(String.isBlank(listView)) listView = 'Open';
		title = 'My ' + listView + ' Cases';
		
		sortFieldSave = sortField;
	}

	public ApexPages.StandardSetController setCon {
		get {
			if(setCon == null) {
	            String whereClause = '';
	            whereClause += 'WHERE AccountId = \'' + this.user.AccountId + '\' AND RecordTypeId IN :recordTypeIds ';
	            System.debug('[DEBUG-CCListCase.getSetCon()]\n=========\nCases to View? ' + listView);
	            if(listView == 'Open' || String.isBlank(listView)) {
	                whereClause += 'AND isClosed = false ';
	            } else {
	                whereClause += 'AND Status = \'' + listView + '\' ';
	            }
	            String q = '';
	            if(String.isBlank(searchStr)) {
	                q += 'SELECT ' + join(caseFields, ',') + ' ';
	                q += 'FROM Case ';
	                q += whereClause;
	                q += ' ORDER BY ' + String.escapeSingleQuotes(SortField) + ' ' + String.escapeSingleQuotes(SortDirection) + ' LIMIT 10000';
					System.debug('[DEBUG-CCListCase.getSetCon()]\n=========\nSOQL: ' + q);
					setCon = new ApexPages.StandardSetController(Database.getQueryLocator(q));
	            } else {
	                String escapedQ = String.escapeSingleQuotes(searchStr);
	                String orQuery = buildOrQuery(escapedQ);
	                
	                q += 'FIND \'' + orQuery + '\' IN ALL FIELDS RETURNING ';
	                q += 'Case(' + join(caseFields, ',') + ' ';
	                q += whereClause;
	                q += ' ORDER BY ' + String.escapeSingleQuotes(SortField) + ' ' + String.escapeSingleQuotes(SortDirection) + ' LIMIT 2000';
	                q += ') ';
		            System.debug('[DEBUG-CCListCase.getCases()]\n=========\nSOSL : ' + q);
	                List<List<sObject>> searchList = Search.query(q);
					setCon = new ApexPages.StandardSetController((List<Case>)searchList[0]);
	            }

				setCon.setPageSize(size);
				noOfRecords = setCon.getResultSize();
			}
			return setCon;
		}
		set;
	}
	
	// SortDirection - return sort direction. Default ascending(asc)
	public String SortDirection {
		get { if (SortDirection == null) {  SortDirection = 'desc NULLS LAST'; } return SortDirection;  }
		set;
	}
	
	// SortField - return sort by field. Default to Name
	public String SortField {
		get { if (SortField == null) {SortField = 'LastModifiedDate'; } return SortField;  }
		set; 
	}

	// SortToggle - toggles the sorting of query from asc<-->desc
	public PageReference SortToggle() {
		SortDirection = SortDirection.equals('asc') ? 'desc NULLS LAST' : 'asc';
		// reset alpha filter and sort sequence when sorted field is changed
		if (SortFieldSave != SortField) {
			SortDirection = 'asc';
			SortFieldSave = SortField;
		}
		// run the query again
		return refreshList();
	}

	//Changes the size of pagination
	public PageReference refreshPageSize() {
		setCon.setPageSize(size);
		return null;
	}

	public PageReference refreshList() {
		if(String.isNotBlank(this.searchStr) && this.searchStr.length() < 3) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, 'Your search term must have 3 or more characters.'));
			return null;
		}
		setCon = null;
		title = 'My ' + listView + ' Cases';
		return null;
	}

	public pageReference reset() {
		this.searchStr = '';
		return refreshList();
	}
      	
	public List<Case> getCases() {
		System.debug('[DEBUG-CCListCase.getCases()]\n=========\ncases: ' + setCon.getRecords());
		// deep clone so that I can modify the list to prettify the record type name
		List<Case> listofcases = setCon.getRecords().deepclone(true,true,true);
		for(Case c : listofcases) {
			CaseType ct = availableCaseTypes.get(c.RecordTypeId);
			c.Other_Case_Number__c = ct.name;
		}
		return listofcases;
	}
    
	public List<SelectOption> getViews() {
		List<SelectOption> options = new List<SelectOption>();
   		options.add(new SelectOption('Open','My Open Cases'));
   		options.add(new SelectOption('Closed','My Closed Cases'));
   		options.add(new SelectOption('Archived','My Archived Cases'));
    	return options;
	}
	
	public PageReference createNewCase() {
		PageReference pr;

		// Kind of kludgy, but use setting to override basic case record type selection process to force user to create single case type.
		String createPage = CC_App_Settings__c.getInstance(UserInfo.getProfileId()).CaseCreatePage__c;
		if(String.isNotBlank(createPage)) {
			pr = new PageReference(baseUrl + createPage);
		} else {
			if(availableCaseTypes.size() > 1) {
				pr = Page.CCSelectCaseType;
			} else {
				pr = new PageReference(baseUrl + availableCaseTypes.values()[0].newPage);
			}
		}
		
		pr.getParameters().put('listView',listView);
		pr.getParameters().put('retURL', baseUrl+'CCListCase?listView='+listView);
		pr.setRedirect(true);
		return pr;
	}

	public PageReference gotoCaseDetail() {
    	CaseType ct = availableCaseTypes.get(recordTypeId);
    	String url = baseUrl;
    	url += ct.detailPage;
        PageReference pr = new PageReference(url);
        pr.getParameters().put('id',selectedId);
		pr.getParameters().put('listView',listView);
		pr.getParameters().put('retURL', baseUrl+'CCListCase?listView='+listView);
		pr.setRedirect(true);
		return pr;
	}

    /* Takes entered search string,
     *  breaks into separate words separated by space,
     *  adds wildcard * character
     *  concatenates each with OR operator.
     *  Ex:  foo bar --> foo* OR bar*
     */
    public static String buildOrQuery(String keywords) {
        system.debug('[DEBUG-CCListCase.buildOrQuery()] keywords: '+keywords);
        if (String.isBlank(keywords)) return null;

        String temp;
        //keywords = keywords.replaceAll('"' ,'\\"');
        List<String> tokens = String.escapeSingleQuotes(keywords).replaceAll('[!.,?<>;:{}@#$%^&*()]', '').split(' ');
        List<String> newTokens = new List<String>();
        
        for (String s : tokens) {
            temp = s.trim();
            newTokens.add(temp + '*');
        }
        tokens = newTokens;

        if (tokens.isEmpty()) {
            system.debug('[DEBUG-CCListCase.buildOrQuery()]  returned EMPTY KEYWORDS ');
            return null;
        } else if (tokens.size() == 1) {
            system.debug('[DEBUG-CCListCase.buildOrQuery()]  returned KEYWORD TOKENS \n===='+tokens[0]+'=====\n');
            return tokens[0];
        } else {
            String returnStr = join(tokens, ' OR ');
            system.debug('[DEBUG-CCListCase.buildOrQuery()]  returned KEYWORD TOKENS \n===='+returnStr+'=====\n');
            return returnStr;
        }
    }

    // joins elements in the passed list of strings by the passed string c
    // c can be a single character or a longer string -- useful for joinging segments of a dynamic sosl or soql query
    public static String join(List<String> strings, String c) {
        if (strings == null || strings.isEmpty()) return null;

        String sep = (String.isBlank(c) ? ',' : c);
        Integer i, size;
        String s = strings[0];

        size = strings.size();
        for (i = 1; i < size; i++) {
            s += (sep + strings[i]);
        }
        return s;
    }
    // version of join method that takes a set of strings
    public static String join(Set<String> strings, String c) {
        return join(new List<String>(strings), c);
    }
    

    // these fields must be queried for the Case collection object, so this set is
    // used in the sosl and soql queries to ensure that all queries get the right fields
    public static Set<String> caseFields {
        get {
            if (caseFields == null) {
                caseFields = new Set<String>{
                    'Id',
                    'CaseNumber',
                    'CreatedDate',
                    'ClosedDate',
                    'LastModifiedDate',
                    'Status',
                    'Subject',
                    'CreatedBy.Alias',
                    'Customer_Reference_Number__c',
                    'CID_Identifier__c',
                    'RecordTypeId','Other_Case_Number__c'
                };
            }
            return caseFields;
        }
        private set;
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