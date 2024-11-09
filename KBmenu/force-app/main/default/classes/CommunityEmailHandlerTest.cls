@IsTest
private class CommunityEmailHandlerTest {
    @TestSetup
    static void setup() {
        Contact testContact = new Contact(
            FirstName = 'Test',
            LastName = 'User',
            Email = 'test@example.com'
        );
        insert testContact;
        
        Case testCase = new Case(
            Subject = 'Test Case',
            ContactId = testContact.Id,
            Status = 'New'
        );
        insert testCase;
    }
    
    @IsTest
    static void testSendCaseEmail() {
        Contact testContact = [SELECT Id, Email FROM Contact LIMIT 1];
        Case testCase = [SELECT Id FROM Case LIMIT 1];
        
        CommunityEmailHandler.CaseEmailRequest request = new CommunityEmailHandler.CaseEmailRequest();
        request.toEmail = testContact.Email;
        request.subject = 'Test Subject';
        request.contactId = testContact.Id;
        request.caseId = testCase.Id;
        
        Test.startTest();
        CommunityEmailHandler.sendCaseEmail(new List<CommunityEmailHandler.CaseEmailRequest>{ request });
        Test.stopTest();
        
        System.assertEquals(0, Limits.getEmailInvocations(), 
            'No emails should be sent in test context');
    }
    
    @IsTest
    static void testSendCaseEmailNullInputs() {
        Test.startTest();
        CommunityEmailHandler.sendCaseEmail(null);
        CommunityEmailHandler.sendCaseEmail(new List<CommunityEmailHandler.CaseEmailRequest>());
        Test.stopTest();
        
        System.assertEquals(0, Limits.getEmailInvocations(), 
            'No emails should be sent with null inputs');
    }
}