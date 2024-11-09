global class CommunityEmailHandler {
    @InvocableMethod(label='Send Community Case Notification' description='Sends a case notification email from support@automai.com')
    global static void sendCaseNotification(List<String> caseIds) {
        if(caseIds == null || caseIds.isEmpty()) return;
        
        // Query case and related contact - Added Contact.FirstName to the query
        Case caseRecord = [
            SELECT Id, ContactId, Subject, CaseNumber, 
                   Contact.Email, Contact.FirstName, Category__c
            FROM Case 
            WHERE Id = :caseIds[0]
        ];
        
        // Query specific org-wide email address
        OrgWideEmailAddress[] owea = [
            SELECT Id, Address, DisplayName
            FROM OrgWideEmailAddress 
            WHERE Address = 'support@automai.com'
            LIMIT 1
        ];
        
        if(!owea.isEmpty() && caseRecord.ContactId != null) {
            // Create email message with enforced sender
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            email.setOrgWideEmailAddressId(owea[0].Id);
            email.setTargetObjectId(caseRecord.ContactId);
            email.setWhatId(caseRecord.Id);
            email.setTreatTargetObjectAsRecipient(true);
            email.setSaveAsActivity(true);
            
            // Set template or specific email content
            String subject = 'Case Created: ' + caseRecord.CaseNumber + ' - ' + caseRecord.Subject;
            String body = 'Dear ' + (caseRecord.Contact.FirstName != null ? caseRecord.Contact.FirstName : 'Customer') + ',\n\n';
            body += 'Thank you for submitting your case. Your case number is ' + caseRecord.CaseNumber + '.\n\n';
            body += 'We will review your case and get back to you shortly.\n\n';
            body += 'Best regards,\nAutomai Support Team';
            
            email.setSubject(subject);
            email.setPlainTextBody(body);
            
            try {
                if(!Test.isRunningTest()) {
                    Messaging.sendEmail(new Messaging.SingleEmailMessage[]{ email }, false);
                }
            } catch(Exception e) {
                System.debug('Error sending email: ' + e.getMessage());
            }
        }
    }
}