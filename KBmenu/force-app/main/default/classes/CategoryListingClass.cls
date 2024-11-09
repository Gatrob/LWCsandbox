public with sharing class CategoryListingClass {

    @AuraEnabled(cacheable=true)
    public static Map<String, Object> getKnowledgeDataCategories(String categoryName, String categoryGroupName, Integer pageNumber) {
        Map<String, Object> result = new Map<String, Object>();

        // Query to get articles for the selected category
        String articleQuery = 'SELECT Id, Title, Summary, RecordTypeId, UrlName FROM Knowledge__kav WHERE PublishStatus = \'Online\' WITH DATA CATEGORY ' + categoryGroupName + '__c AT ' + categoryName + '__c LIMIT 10 OFFSET ' + (pageNumber - 1) * 10;
        //String articleQuery = 'SELECT Id, Title, Summary, RecordTypeId, UrlName FROM Knowledge__kav WHERE PublishStatus = \'Online\' WITH DATA CATEGORY ' + categoryGroupName + '__c AT ' + categoryName + '__c';
        List<Knowledge__kav> articles = Database.query(articleQuery);

        List<Map<String, String>> articleData = new List<Map<String, String>>();
        for (Knowledge__kav article : articles) {
            // Fetch ArticleType from associated KnowledgeArticle
            //RecordType articleInfo = [SELECT Name FROM RecordType WHERE Id = :article.RecordTypeId LIMIT 1];

            Map<String, String> articleMap = new Map<String, String>();
            articleMap.put('Id', article.Id);
            articleMap.put('Title', article.Title);
            articleMap.put('Summary', article.Summary);
            // articleMap.put('Content', article.Content__c);
            // articleMap.put('Description', article.Description__c);
            // articleMap.put('Answer', article.Answer__c);
            // Use Name from the associated RecordType
            //articleMap.put('Type', articleInfo != null ? articleInfo.Name : '');
            articleMap.put('UrlName', article.UrlName);
            articleData.add(articleMap);
        }

        result.put('articleList', articleData);

        // Query to get total number of articles for the selected category
        // String totalArticlesQuery = 'SELECT COUNT() FROM Knowledge__kav WHERE PublishStatus = \'Online\' WITH DATA CATEGORY ' + categoryGroupName + '__c AT ' + categoryName + '__c';
        // Integer totalArticles = Database.query(totalArticlesQuery).size();
        
        // result.put('totalArticles', totalArticles);

        return result;
    }

    private static final Integer ARTICLES_PER_PAGE = 10;
}