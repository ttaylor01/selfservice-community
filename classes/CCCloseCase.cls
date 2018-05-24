public with sharing class CCCloseCase {
    public String body {get;set;}
	public String retUrl { get; set; }
	public String caseId {get;set;}
	public String listView {get;set;}
	public Case cs {get;set;}

    public CCCloseCase() {
    	caseId = (String)Apexpages.currentPage().getParameters().get('id');
		System.debug('[DEBUG-CCCloseCase.CCCloseCase()]\n=========\nCase Id: ' + caseId);
		retUrl = (String)Apexpages.currentPage().getParameters().get('retUrl');
		System.debug('[DEBUG-CCCloseCase.CCCloseCase()]\n=========\nretUrl: ' + retUrl);
    	listView = (String)Apexpages.currentPage().getParameters().get('listView');
		System.debug('[DEBUG-CCCloseCase.CCCloseCase()]\n=========\nlistView: ' + listView);
		cs = [SELECT Id, CaseNumber, Subject, Status FROM Case WHERE Id = :caseId LIMIT 1];
		cs.Status = 'Closed';
		System.debug('[DEBUG-CCCloseCase.CCCloseCase()]\n=========\ncase: ' + cs);
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
                ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 
                  'You must first enter a comment value.'));
                return null;
        	}
            Database.SaveResult commentResult = saveComment();
        
            if (commentResult == null || !commentResult.isSuccess()) {
                ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 
                  'Could not save comment.'));
                return null;
            }

			cs.Status = 'Closed';
			Database.SaveResult closeResult = Database.update(cs);
			        
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