global without sharing class CommunityEmailHandler {
    @InvocableMethod(label='Send Case Email')
    global static void sendCaseEmail(List<CaseEmailRequest> requests) {
        if(requests != null && !requests.isEmpty()) {
            System.enqueueJob(new EmailQueueable(requests));
        }
    }
    
    // Make EmailQueueable public so test class can access it
    public class EmailQueueable implements System.Queueable {
        private List<CaseEmailRequest> requests;
        
        public EmailQueueable(List<CaseEmailRequest> reqs) {
            this.requests = reqs;
        }
        
        public void execute(System.QueueableContext context) {
            List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
            
            for(CaseEmailRequest req : requests) {
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                email.setToAddresses(new String[]{ req.toEmail });
                email.setSubject(req.subject);
                email.setHtmlBody('Thank you for submitting your case. Our team will review and respond shortly.');
                email.setSenderDisplayName('Automai Support');
                
                if(req.contactId != null) {
                    email.setTargetObjectId(req.contactId);
                }
                if(req.caseId != null) {
                    email.setWhatId(req.caseId);
                }
                
                emails.add(email);
            }
            
            if(!emails.isEmpty() && !Test.isRunningTest()) {
                Messaging.sendEmail(emails, false);
            }
        }
    }
    
    global class CaseEmailRequest {
        @InvocableVariable(required=true)
        public String toEmail;
        
        @InvocableVariable(required=true)
        public String subject;
        
        @InvocableVariable(required=true)
        public Id contactId;
        
        @InvocableVariable(required=true)
        public Id caseId;
    }
}