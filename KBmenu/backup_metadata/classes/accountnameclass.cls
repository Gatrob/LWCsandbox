public with sharing class accountnameclass {
    @AuraEnabled(cacheable=true)
    public static String getAccountName(Id userId) {
        String accountName = '';
        List<User> userRecords = [SELECT ContactId FROM User WHERE Id = :userId LIMIT 1];
        if(!userRecords.isEmpty()) {
            User userRecord = userRecords[0];
            List<Contact> contactRecords = [SELECT Account.Name FROM Contact WHERE Id = :userRecord.ContactId LIMIT 1];
            if(!contactRecords.isEmpty()) {
                Contact contactRecord = contactRecords[0];
                if(contactRecord.Account != null) {
                    accountName = contactRecord.Account.Name;
                }
            }
        }
        return accountName;
    }
}