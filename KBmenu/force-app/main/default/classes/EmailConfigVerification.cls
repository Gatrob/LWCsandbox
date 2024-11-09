public class EmailConfigVerification {
    public static void verifyConfiguration() {
        System.debug(LoggingLevel.ERROR, '=== Email Configuration Verification ===');

        try {
            // Check OrgWideEmailAddress
            List<OrgWideEmailAddress> owea = [
                SELECT Id, Address, DisplayName, IsAllowAllProfiles 
                FROM OrgWideEmailAddress 
                WHERE Address = 'support@automai.com'
            ];
            System.debug(LoggingLevel.ERROR, 'OrgWideEmailAddress found: ' + owea.size());
            for(OrgWideEmailAddress owa : owea) {
                System.debug(LoggingLevel.ERROR, 'Details:');
                System.debug(LoggingLevel.ERROR, '- Address: ' + owa.Address);
                System.debug(LoggingLevel.ERROR, '- Display Name: ' + owa.DisplayName);
                System.debug(LoggingLevel.ERROR, '- AllowAllProfiles: ' + owa.IsAllowAllProfiles);
            }

            // Check running user context
            System.debug(LoggingLevel.ERROR, 'Current User: ' + UserInfo.getUserName());
            System.debug(LoggingLevel.ERROR, 'User Email: ' + UserInfo.getUserEmail());
            System.debug(LoggingLevel.ERROR, 'User Profile: ' + [SELECT Name FROM Profile WHERE Id = :UserInfo.getProfileId()].Name);

            // Check organization settings
            Organization org = [SELECT Id, IsSandbox, Name FROM Organization];
            System.debug(LoggingLevel.ERROR, 'Organization Settings:');
            System.debug(LoggingLevel.ERROR, '- IsSandbox: ' + org.IsSandbox);
            System.debug(LoggingLevel.ERROR, '- Organization Name: ' + org.Name);

            // Check email limits
            System.debug(LoggingLevel.ERROR, 'Email Limits:');
            System.debug(LoggingLevel.ERROR, '- Single Email Daily Limit: ' + Limits.getLimitEmailInvocations());
            System.debug(LoggingLevel.ERROR, '- Single Email Remaining: ' + (Limits.getLimitEmailInvocations() - Limits.getEmailInvocations()));

            // Check automation tools affecting Case
            checkCaseAutomation();
        } catch(Exception e) {
            System.debug(LoggingLevel.ERROR, 'Error during verification: ' + e.getMessage());
            System.debug(LoggingLevel.ERROR, 'Stack trace: ' + e.getStackTraceString());
        }
    }

    private static void checkCaseAutomation() {
        System.debug(LoggingLevel.ERROR, '=== Case Automation Check ===');
        
        try {
            // Check for Process Builder and Flows
            List<ProcessDefinition> processes = [
                SELECT Id, Name, Type, Description, TableEnumOrId
                FROM ProcessDefinition
                WHERE TableEnumOrId = 'Case'
                AND State = 'Active'
            ];
            
            System.debug(LoggingLevel.ERROR, 'Active Case Processes found: ' + processes.size());
            for(ProcessDefinition proc : processes) {
                System.debug(LoggingLevel.ERROR, 'Process Details:');
                System.debug(LoggingLevel.ERROR, '- Name: ' + proc.Name);
                System.debug(LoggingLevel.ERROR, '- Type: ' + proc.Type);
                System.debug(LoggingLevel.ERROR, '- Object: ' + proc.TableEnumOrId);
            }
            
            // Check for Email Templates used with Case
            List<EmailTemplate> templates = [
                SELECT Id, Name, DeveloperName, FolderId, Subject
                FROM EmailTemplate 
                WHERE Name LIKE '%Case%'
                OR Name LIKE '%Support%'
                ORDER BY Name
            ];
            
            System.debug(LoggingLevel.ERROR, 'Related Email Templates found: ' + templates.size());
            for(EmailTemplate template : templates) {
                System.debug(LoggingLevel.ERROR, 'Template Details:');
                System.debug(LoggingLevel.ERROR, '- Name: ' + template.Name);
                System.debug(LoggingLevel.ERROR, '- Developer Name: ' + template.DeveloperName);
                System.debug(LoggingLevel.ERROR, '- Subject: ' + template.Subject);
            }
            
        } catch(Exception e) {
            System.debug(LoggingLevel.ERROR, 'Error checking automation: ' + e.getMessage());
            System.debug(LoggingLevel.ERROR, 'Stack trace: ' + e.getStackTraceString());
        }
    }
}