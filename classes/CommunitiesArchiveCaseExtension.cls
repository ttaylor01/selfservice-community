public with sharing class CommunitiesArchiveCaseExtension {

    private Case closedCase;
    private ApexPages.StandardController stdController;
    
    public CommunitiesArchiveCaseExtension(ApexPages.StandardController controller){
        this.stdController = controller;
        this.closedCase = (Case)controller.getRecord();
        System.debug('[DEBUG-CommunitiesArchiveCaseExtension.CommunitiesArchiveCaseExtension()]\n=========\nCase Id: ' + controller.getId());
    }

    public PageReference doSave() {
        this.closedCase.Status = 'Archived';
        if(stdController.save() == null) {
	        System.debug('[DEBUG-CommunitiesArchiveCaseExtension.doSave()]\n=========\nSave Failed');
            return null;
        }

        PageReference pageRef = new PageReference('/' + this.closedCase.Id);
        pageRef.setRedirect(true);
        return pageRef;
    }
}