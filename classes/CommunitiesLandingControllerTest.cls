/**
 * An apex page controller that takes the user to the right start page based on credentials or lack thereof
 */
@IsTest public with sharing class CommunitiesLandingControllerTest {
    @IsTest(SeeAllData=true) public static void testCommunitiesLandingController() {
        // Instantiate a new controller with all parameters in the page
        User guestUser = [Select Id From User Where UserType = 'Guest' LIMIT 1];
        System.runAs(guestUser) {
	        CommunitiesLandingController controller = new CommunitiesLandingController();
			PageReference pageRef = Page.CommunitiesLanding;
			pageRef.getParameters().put('startUrl', '50011000004ObEg');
			Test.setCurrentPage(pageRef);
			controller.forwardToStartPage();
        }
      }
}