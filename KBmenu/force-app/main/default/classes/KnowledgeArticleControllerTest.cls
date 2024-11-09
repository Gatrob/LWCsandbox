@IsTest
private class KnowledgeArticleControllerTest {
    private static final String TEST_ARTICLE_TITLE = 'Test Article';
    
    @TestSetup
    static void setupTestData() {
        Profile adminProfile = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        User testUser = new User(
            ProfileId = adminProfile.Id,
            LastName = 'Test User',
            Email = 'testuser@test.com',
            Username = 'testuser@test.com' + System.currentTimeMillis(),
            CompanyName = 'TEST',
            Title = 'Title',
            Alias = 'alias',
            TimeZoneSidKey = 'America/Los_Angeles',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US'
        );
        insert testUser;
        
        System.runAs(testUser) {
            Knowledge__kav testArticle = new Knowledge__kav(
                Title = TEST_ARTICLE_TITLE,
                UrlName = 'test-article',
                Summary = 'Test Summary',
                Content__c = 'Test Content',
                Language = 'en_US'
            );
            insert testArticle;
        }
    }
    
    @IsTest
    static void testGetArticleByTitle_Success() {
        User testUser = [SELECT Id FROM User WHERE Email = 'testuser@test.com' LIMIT 1];
        
        System.runAs(testUser) {
            Test.startTest();
            Knowledge__kav result = KnowledgeArticleController.getArticleByTitle(TEST_ARTICLE_TITLE);
            Test.stopTest();
            
            System.assertNotEquals(null, result, 'Article should be found');
            System.assertEquals(TEST_ARTICLE_TITLE, result.Title, 'Article title should match');
        }
    }
    
    @IsTest
    static void testGetArticleByTitle_NotFound() {
        User testUser = [SELECT Id FROM User WHERE Email = 'testuser@test.com' LIMIT 1];
        
        System.runAs(testUser) {
            Test.startTest();
            Boolean exceptionThrown = false;
            try {
                KnowledgeArticleController.getArticleByTitle('Non-Existent Article');
            } catch (AuraHandledException e) {
                exceptionThrown = true;
            }
            Test.stopTest();
            
            System.assert(exceptionThrown, 'Expected an exception for non-existent article');
        }
    }
    
    @IsTest
    static void testGetArticleByTitle_NoAccess() {
        Profile restrictedProfile = [SELECT Id FROM Profile WHERE Name = 'Minimum Access - Salesforce' LIMIT 1];
        User restrictedUser = new User(
            ProfileId = restrictedProfile.Id,
            LastName = 'Restricted User',
            Email = 'restricted@test.com',
            Username = 'restricted@test.com' + System.currentTimeMillis(),
            CompanyName = 'TEST',
            Title = 'Title',
            Alias = 'alias',
            TimeZoneSidKey = 'America/Los_Angeles',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US'
        );
        insert restrictedUser;
        
        System.runAs(restrictedUser) {
            Test.startTest();
            Boolean exceptionThrown = false;
            try {
                KnowledgeArticleController.getArticleByTitle(TEST_ARTICLE_TITLE);
            } catch (AuraHandledException e) {
                exceptionThrown = true;
            }
            Test.stopTest();
            
            System.assert(exceptionThrown, 'Expected an exception for insufficient access');
        }
    }
    
    @IsTest
    static void testGetArticleByTitle_NullTitle() {
        Test.startTest();
        Boolean exceptionThrown = false;
        try {
            KnowledgeArticleController.getArticleByTitle(null);
        } catch (AuraHandledException e) {
            exceptionThrown = true;
        }
        Test.stopTest();
        
        System.assert(exceptionThrown, 'Expected an exception for null title');
    }
    
    @IsTest
    static void testGetArticleByTitle_DifferentLanguage() {
        User spanishUser = new User(
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id,
            LastName = 'Spanish User',
            Email = 'spanish@test.com',
            Username = 'spanish@test.com' + System.currentTimeMillis(),
            CompanyName = 'TEST',
            Title = 'Title',
            Alias = 'alias',
            TimeZoneSidKey = 'America/Los_Angeles',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'es',
            LocaleSidKey = 'es'
        );
        insert spanishUser;
        
        System.runAs(spanishUser) {
            Test.startTest();
            Boolean exceptionThrown = false;
            try {
                KnowledgeArticleController.getArticleByTitle(TEST_ARTICLE_TITLE);
            } catch (AuraHandledException e) {
                exceptionThrown = true;
            }
            Test.stopTest();
            
            System.assert(exceptionThrown, 'Expected an exception for different language');
        }
    }
}