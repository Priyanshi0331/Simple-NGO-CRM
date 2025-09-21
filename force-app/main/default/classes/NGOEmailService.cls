public class NGOEmailService {
    
    public static void sendBulkEmails(List<Id> donorIds, String templateName) {
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        
        try {
            // Get email template
            EmailTemplate template = [SELECT Id, Subject, Body 
                                    FROM EmailTemplate 
                                    WHERE DeveloperName = :templateName 
                                    LIMIT 1];
            
            // Get donors with email addresses
            List<Donor__c> donors = [SELECT Id, Name, Email__c 
                                   FROM Donor__c 
                                   WHERE Id IN :donorIds 
                                   AND Email__c != null];
            
            for (Donor__c donor : donors) {
                if (String.isNotBlank(donor.Email__c)) {
                    Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                    email.setToAddresses(new List<String>{donor.Email__c});
                    email.setTemplateId(template.Id);
                    email.setTargetObjectId(donor.Id);
                    email.setSaveAsActivity(false); // Don't create activity records
                    
                    emails.add(email);
                }
            }
            
            // Send emails
            if (!emails.isEmpty()) {
                List<Messaging.SendEmailResult> results = Messaging.sendEmail(emails);
                
                // Check results
                Integer successCount = 0;
                Integer failureCount = 0;
                
                for (Messaging.SendEmailResult result : results) {
                    if (result.isSuccess()) {
                        successCount++;
                    } else {
                        failureCount++;
                        System.debug('Email send error: ' + result.getErrors()[0].getMessage());
                    }
                }
                
                System.debug('Emails sent successfully: ' + successCount);
                System.debug('Email failures: ' + failureCount);
            }
            
        } catch (QueryException e) {
            System.debug('Query error: ' + e.getMessage());
            throw new NGOEmailException('Failed to retrieve email template or donors');
        } catch (Exception e) {
            System.debug('Unexpected error: ' + e.getMessage());
            throw new NGOEmailException('Email sending failed: ' + e.getMessage());
        }
    }
    
    // Custom exception class
    public class NGOEmailException extends Exception {}
}