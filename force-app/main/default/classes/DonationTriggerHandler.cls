public class DonationTriggerHandler {
    
    // Validate donation data before insert
    public static void validateDonationData(List<Donation__c> newDonations) {
        
        for (Donation__c donation : newDonations) {
            // Additional validation beyond validation rules
            
            // Check for weekend donations (might need special processing)
            Datetime donationDateTime = DateTime.newInstance(
                donation.Donation_Date__c, Time.newInstance(12, 0, 0, 0));
            String dayOfWeek = donationDateTime.format('EEEE');
            
            if (dayOfWeek == 'Saturday' || dayOfWeek == 'Sunday') {
                // Add note for weekend donations
                if (String.isBlank(donation.Notes__c)) {
                    donation.Notes__c = 'Weekend donation - verify processing';
                } else {
                    donation.Notes__c += '\nWeekend donation - verify processing';
                }
            }
        }
    }
    
    // Handle post-donation processing
    public static void handleDonationProcessing(List<Donation__c> newDonations, 
                                              Map<Id, Donation__c> oldDonationMap) {
        
        List<Task> tasksToCreate = new List<Task>();
        Set<Id> donorIds = new Set<Id>();
        
        for (Donation__c donation : newDonations) {
            donorIds.add(donation.Donor__c);
            
            // Create special task for first-time donors
            if (Trigger.isInsert) {
                // Check if this is their first donation
                Integer donationCount = [SELECT COUNT() 
                                       FROM Donation__c 
                                       WHERE Donor__c = :donation.Donor__c];
                
                if (donationCount == 1) {
                    Task welcomeTask = new Task();
                    welcomeTask.Subject = 'Welcome new donor: ' + donation.Donor__r.Name;
                    welcomeTask.Description = 'First donation of ₹' + donation.Amount__c + 
                                            '. Send welcome packet and build relationship.';
                    welcomeTask.Priority = 'High';
                    welcomeTask.Status = 'Not Started';
                    welcomeTask.ActivityDate = Date.today().addDays(3);
                    
                    
                    tasksToCreate.add(welcomeTask);
                }
            }
        }
        
        // Insert tasks if any were created
        if (!tasksToCreate.isEmpty()) {
            insert tasksToCreate;
        }
        
        // Update donor categories based on total donations
        updateDonorCategories(donorIds);
    }
    
    // Helper method to categorize donors
    private static void updateDonorCategories(Set<Id> donorIds) {
        List<Donor__c> donorsToUpdate = new List<Donor__c>();
        
        for (Donor__c donor : [SELECT Id, Total_Donated__c FROM Donor__c WHERE Id IN :donorIds]) {
            String newCategory;
            
            if (donor.Total_Donated__c >= 50000) {
                newCategory = 'Major Donor';
            } else if (donor.Total_Donated__c >= 10000) {
                newCategory = 'Regular Donor';
            } else {
                newCategory = 'Supporter';
            }
            
            // Only update if category changed (add Category__c field to Donor first)
            donor.put('Category__c', newCategory);
            donorsToUpdate.add(donor);
        }
        
        if (!donorsToUpdate.isEmpty()) {
            update donorsToUpdate;
        }
    }
}