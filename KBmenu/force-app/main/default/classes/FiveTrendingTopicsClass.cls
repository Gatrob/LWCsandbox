public with sharing class FiveTrendingTopicsClass {
    @AuraEnabled(cacheable=true)
    public static List<KnowledgeArticleVersion> getMostViewedArticles() {
        return [SELECT Id, Title, UrlName, PublishStatus, ArticleTotalViewCount 
                FROM KnowledgeArticleVersion 
                WHERE PublishStatus = 'Online'
                ORDER BY ArticleTotalViewCount DESC 
                LIMIT 5];
    }
}