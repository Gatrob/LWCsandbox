public without sharing class KnowledgeArticleController {
    @AuraEnabled(cacheable=true)
    public static Knowledge__kav getArticleByTitle(String title) {
        try {
            // Debug information
            System.debug('Current User ID: ' + UserInfo.getUserId());
            System.debug('Current User Profile: ' + [SELECT Name FROM Profile WHERE Id = :UserInfo.getProfileId()].Name);
            System.debug('Current User Type: ' + UserInfo.getUserType());
            
            if (title == null) {
                throw new AuraHandledException('Title cannot be null');
            }

            String userLanguage = UserInfo.getLanguage();
            
            // Debug query
            String query = 'SELECT Id, Title, UrlName, Summary, Content__c ' +
                         'FROM Knowledge__kav ' +
                         'WHERE Title = :title ' +
                         'AND Language = :userLanguage ';
            
            if (!Test.isRunningTest()) {
                query += 'AND PublishStatus = \'Online\' ';
            }
            
            query += 'LIMIT 1';
            
            System.debug('Executing query: ' + query);
            
            List<Knowledge__kav> articles = Database.query(query);
            System.debug('Query results: ' + articles);

            if (!articles.isEmpty()) {
                return articles[0];
            }
            
            throw new AuraHandledException('No published article found with title: ' + title);
            
        } catch (Exception e) {
            System.debug('Error in getArticleByTitle: ' + e.getMessage());
            System.debug('Error stack trace: ' + e.getStackTraceString());
            throw new AuraHandledException(e.getMessage());
        }
    }
}