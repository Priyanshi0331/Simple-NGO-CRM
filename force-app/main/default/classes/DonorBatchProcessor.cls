public class DonorBatchProcessor {
    
    // Process donors in batches for better performance
    public static void processDonorUpdates() {
        
        // List to store donors needing updates
        List<Donor__c> donorsToUpdate = new List<Donor__c>();
        
        // Set to avoid duplicate processing
        Set<Id> processedDonorIds = new Set<Id>();
        
        // Map to store donation counts per donor
        Map<Id, Integer> donorDonationCount = new Map<Id, Integer>();
        
        // Get all donations and count by donor
        for (Donation__c donation : [SELECT Donor__c FROM Donation__c]) {
            if (donorDonationCount.containsKey(donation.Donor__c)) {
                donorDonationCount.put(donation.Donor__c, 
                                     donorDonationCount.get(donation.Donor__c) + 1);
            } else {
                donorDonationCount.put(donation.Donor__c, 1);
            }
        }
        
        // Process donors based on donation count
        for (Donor__c donor : [SELECT Id, Name, Total_Donated__c FROM Donor__c]) {
            
            if (!processedDonorIds.contains(donor.Id)) {
                
                Integer donationCount = donorDonationCount.get(donor.Id);
                if (donationCount == null) donationCount = 0;
                
                // Determine donor status
                String status;
                if (donationCount == 0) {
                    status = 'Prospect';
                } else if (donationCount == 1) {
                    status = 'New Donor';
                } else if (donationCount <= 5) {
                    status = 'Regular Donor';
                } else {
                    status = 'Loyal Donor';
                }
                
                // Add Status__c field to Donor object (Picklist)
                donor.put('Status__c', status);
                donorsToUpdate.add(donor);
                processedDonorIds.add(donor.Id);
            }
        }
        
        // Update donors in batches
        if (!donorsToUpdate.isEmpty()) {
            try {
                update donorsToUpdate;
                System.debug('Successfully updated ' + donorsToUpdate.size() + ' donors');
            } catch (Exception e) {
                System.debug('Error updating donors: ' + e.getMessage());
            }
        }
    }
}