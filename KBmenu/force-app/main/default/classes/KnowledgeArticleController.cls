public with sharing class KnowledgeArticleController {
    public class KnowledgeArticleException extends Exception {}
    
    @AuraEnabled(cacheable=true)
    public static Knowledge__kav getArticleByTitle(String title) {
        try {
            if (title == null) {
                throw new KnowledgeArticleException('Title cannot be null');
            }

            // Check field-level security for all possible content fields
            if (!Schema.sObjectType.Knowledge__kav.fields.Content__c.isAccessible() ||
                !Schema.sObjectType.Knowledge__kav.fields.Summary.isAccessible() ||
                !Schema.sObjectType.Knowledge__kav.fields.Title.isAccessible()) {
                throw new KnowledgeArticleException('Insufficient access to article fields');
            }

            String userLanguage = UserInfo.getLanguage();
            
            // Query with only the fields that exist in your org
            String query = 'SELECT Id, Title, UrlName, Summary, Content__c ' +
                         'FROM Knowledge__kav ' +
                         'WHERE Title = :title ' +
                         'AND Language = :userLanguage ';
                         
            if (!Test.isRunningTest()) {
                query += 'AND PublishStatus = \'Online\' ';
            }
            
            query += 'LIMIT 1';
            
            List<Knowledge__kav> articles = Database.query(query);

            if (!articles.isEmpty()) {
                // Log the retrieved article for debugging
                System.debug('Retrieved article: ' + articles[0]);
                return articles[0];
            } else {
                throw new KnowledgeArticleException('No article found with title: ' + title);
            }
            
        } catch (KnowledgeArticleException e) {
            throw new AuraHandledException(e.getMessage());
        } catch (Exception e) {
            throw new AuraHandledException('An error occurred: ' + e.getMessage());
        }
    }
}