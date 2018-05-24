/**
 * An apex page controller that exposes the site login functionality
 */
//    @IsTest(SeeAllData=true) 
@IsTest
private class CommunitiesLoginControllerTest {
    static testMethod void testCommunitiesLoginController () {
        User testUser = [SELECT Id FROM User WHERE UserName = 'community.test@availity.com' LIMIT 1];
        System.runAs(testUser) {
            Test.startTest();

	     	CommunitiesLoginController controller = new CommunitiesLoginController();
	     	System.assertEquals(null, controller.forwardToAuthPage());
//	     	PageReference page = controller.forwardToCustomAuthPage();

			controller.username = 'username';
			controller.password = 'pwd';
			PageReference page = controller.login();
			
            Test.stopTest();
        }
    }

    @testSetup static void setup() {
        System.runAs( new User(Id = UserInfo.getUserId()) ) {
        	CCTestDataFactory.createTestRecords();
       }
    }    
}