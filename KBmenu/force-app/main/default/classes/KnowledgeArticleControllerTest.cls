@IsTest
private class KnowledgeArticleControllerTest {
    private static final String TEST_ARTICLE_TITLE = 'Test Article';
    
    @TestSetup
    static void setupTestData() {
        Knowledge__kav testArticle = new Knowledge__kav(
            Title = TEST_ARTICLE_TITLE,
            UrlName = 'test-article',
            Summary = 'Test Summary',
            Content__c = 'Test Content',
            Language = 'en_US',
            PublishStatus = 'Online'
        );
        
        User adminUser = new User(
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id,
            LastName = 'Admin',
            Email = 'admin@testorg.com',
            Username = 'admin' + System.currentTimeMillis() + '@testorg.com',
            CompanyName = 'TEST',
            Title = 'Title',
            Alias = 'admin',
            TimeZoneSidKey = 'America/Los_Angeles',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US'
        );
        insert adminUser;
        
        System.runAs(adminUser) {
            insert testArticle;
        }
    }
    
    @IsTest
    static void testGetArticleByTitle_Success() {
        Test.startTest();
        Knowledge__kav result = KnowledgeArticleController.getArticleByTitle(TEST_ARTICLE_TITLE);
        Test.stopTest();
        
        System.assertNotEquals(null, result, 'Article should be found');
        System.assertEquals(TEST_ARTICLE_TITLE, result.Title, 'Article title should match');
        System.assertEquals('Test Content', result.Content__c, 'Article content should match');
    }
    
    @IsTest
    static void testGetArticleByTitle_NotFound() {
        Boolean exceptionThrown = false;
        String nonExistentTitle = 'Non-Existent Article';
        
        Test.startTest();
        try {
            KnowledgeArticleController.getArticleByTitle(nonExistentTitle);
            System.assert(false, 'Expected an exception for non-existent article');
        } catch (Exception e) {
            exceptionThrown = true;
        }
        Test.stopTest();
        
        System.assert(exceptionThrown, 'An exception should have been thrown');
    }
    
    @IsTest
    static void testGetArticleByTitle_NullTitle() {
        Boolean exceptionThrown = false;
        
        Test.startTest();
        try {
            KnowledgeArticleController.getArticleByTitle(null);
            System.assert(false, 'Expected an exception for null title');
        } catch (Exception e) {
            exceptionThrown = true;
        }
        Test.stopTest();
        
        System.assert(exceptionThrown, 'An exception should have been thrown');
    }
}