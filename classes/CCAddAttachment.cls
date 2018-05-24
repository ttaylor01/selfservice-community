public class CCAddAttachment {
    
    public String fileName {get;set;}
    public Blob fileBody {get;set;}
	public String retUrl { get; set; }
	public String caseId {get;set;}
	public String caseNumber {get;set;}
	public String listView {get;set;}

    public CCAddAttachment() {
    	caseId = (String)Apexpages.currentPage().getParameters().get('id');
    	caseNumber = (String)Apexpages.currentPage().getParameters().get('parentname');
		System.debug('[DEBUG-CCAddAttachment.CCAddAttachment()]\n=========\nCase Id and Number: ' + caseId + ' - ' + caseNumber);
		retUrl = (String)Apexpages.currentPage().getParameters().get('retUrl');
		System.debug('[DEBUG-CCAddAttachment.CCAddAttachment()]\n=========\nretUrl: ' + retUrl);
    	listView = (String)Apexpages.currentPage().getParameters().get('listView');
		System.debug('[DEBUG-CCAddAttachment.CCAddAttachment()]\n=========\nlistView: ' + listView);
    }
    
    // create an actual Attachment record with the Contact_Attachment__c as parent
    private Database.SaveResult saveStandardAttachment() {
        Database.SaveResult result;
        
        Attachment attachment = new Attachment();
        attachment.body = this.fileBody;
        attachment.name = this.fileName;
        attachment.parentId = this.caseId;
        // inser the attahcment
        result = Database.insert(attachment);
        // reset the file for the view state
        fileBody = Blob.valueOf(' ');
        return result;
    }
    
    /**
    * Upload process is:
    *  1. Insert new Attachment with the Case record as parent
    **/
    public PageReference processUpload() {
        try {
            Database.SaveResult attachmentResult = saveStandardAttachment();
        
            if (attachmentResult == null || !attachmentResult.isSuccess()) {
                ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 
                  'Could not save attachment.'));
                return null;
            }
        
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