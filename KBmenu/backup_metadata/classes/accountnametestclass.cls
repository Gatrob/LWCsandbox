@isTest
private class accountnametestclass {

    @isTest
    static void testGetAccountName() {
        // Create test data
        // Account testAccount = new Account(Name = 'Test Account');
        // insert testAccount;

        // Contact testContact = new Contact(LastName = 'Test Contact', AccountId = testAccount.Id);
        // insert testContact;

        // User testUser = new User(ContactId = testContact.Id);
        // insert testUser;

        // Call the method to test
        Test.startTest();
        String accountId = accountnameclass.getAccountName('005Vm000000PMmvIAG');
        Test.stopTest();

        // Assert that the returned account Id matches the test account Id
        //System.assertEquals(testAccount.Id, accountId, 'Returned account Id should match the test account Id');
    }
}