@isTest
public class CommunityEmailHandlerTest {
    @TestSetup
    static void setupTestData() {
        // Create test account
        Account testAccount = new Account(
            Name = 'Test Account'
        );
        insert testAccount;
        
        // Create test contact
        Contact testContact = new Contact(
            FirstName = 'Test',
            LastName = 'User',
            Email = 'test@automai.com',
            AccountId = testAccount.Id
        );
        insert testContact;
        
        // Create test case
        Case testCase = new Case(
            ContactId = testContact.Id,
            Subject = 'Test Case',
            Status = 'New',
            Origin = 'Web'
        );
        insert testCase;
    }
    
    @isTest
    static void testSendCaseNotification() {
        Case testCase = [SELECT Id FROM Case LIMIT 1];
        
        Test.startTest();
        CommunityEmailHandler.sendCaseNotification(
            new List<String>{ testCase.Id }
        );
        Test.stopTest();
    }
}