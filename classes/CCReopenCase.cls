public with sharing class CCReopenCase {
    public String body {get;set;}
	public String retUrl { get; set; }
	public String caseId {get;set;}
	public String listView {get;set;}
	public Case cs {get;set;}
	public Boolean canReopen { get; set; }

    public CCReopenCase() {
    	caseId = (String)Apexpages.currentPage().getParameters().get('id');
		System.debug('[DEBUG-CCReopenCase.CCReopenCase()]\n=========\nCase Id: ' + caseId);
		retUrl = (String)Apexpages.currentPage().getParameters().get('retUrl');
		System.debug('[DEBUG-CCReopenCase.CCReopenCase()]\n=========\nretUrl: ' + retUrl);
    	listView = (String)Apexpages.currentPage().getParameters().get('listView');
		System.debug('[DEBUG-CCReopenCase.CCReopenCase()]\n=========\nlistView: ' + listView);
		cs = [SELECT Id, CaseNumber, Subject, Status, ClosedDate FROM Case WHERE Id = :caseId LIMIT 1];
		System.debug('[DEBUG-CCReopenCase.CCReopenCase()]\n=========\ncase: ' + cs);
		cs.Status = 'Re-opened';

		Long dtClosed = cs.ClosedDate.getTime();
		Long dtCurrent = DateTime.now().getTime();
		Long milliseconds = dtCurrent - dtClosed;
		Long seconds = milliseconds / 1000;
		Long minutes = seconds / 60;
		Long hours = minutes / 60;
		Long days = hours / 24;
		system.debug('\n[DEBUG-CCReopenCase.CCReopenCase]\n=========\n seconds:minutes:hours:days: '+seconds+':'+minutes+':'+hours+':'+days);
		if(days >= 14) {
			canReopen = false;
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Cases cannot be re-opened beyond 14 days of case closure. Please open a new case.'));
		} else {
			canReopen = true;
		}
    }
    
    // create an actual Attachment record with the Contact_Attachment__c as parent
    private Database.SaveResult saveComment() {
        Database.SaveResult result;
	
		CaseComment comment = new CaseComment(ParentId=this.caseId,CommentBody=body);
        // inser the comment
        result = Database.insert(comment);
        // reset the input for the view state
        body = '';
        return result;
    }
    
    /**
    * Upload process is:
    *  1. Insert new Comment with the Case record as parent
    **/
    public PageReference save() {
        try {
        	if(String.isBlank(body)) {
                ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'You must first enter a comment value.'));
                return null;
        	}
			cs.Status = 'Re-opened';
			Database.SaveResult closeResult = Database.update(cs);
            if (closeResult == null || !closeResult.isSuccess()) {
                ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Case could not be reopened.'));
                return null;
            }
		        
            Database.SaveResult commentResult = saveComment();
        
        } catch (Exception e) {
            ApexPages.AddMessages(e);
            return null;
        }
        PageReference aPage = new PageReference(retUrl);
		aPage.getParameters().put('listView',listView);
        return aPage;
    }
    
    public PageReference back() {
        PageReference aPage = new PageReference(retUrl);
		aPage.getParameters().put('listView',listView);
        return aPage;
    }     
    
}