public class DonorStatsHelper {
    
    // Method to calculate donor retention rate
    public static Decimal calculateRetentionRate() {
        // Get total donors who donated this year
        Integer thisYearDonors = [SELECT COUNT() 
                                 FROM Donor__c 
                                 WHERE Last_Donation_Date__c = THIS_YEAR];
        
        // Get total donors who donated last year
        Integer lastYearDonors = [SELECT COUNT() 
                                 FROM Donor__c 
                                 WHERE Last_Donation_Date__c = LAST_YEAR];
        
        // Calculate retention rate
        if (lastYearDonors > 0) {
            Decimal retentionRate = (Decimal.valueOf(thisYearDonors) / 
                                   Decimal.valueOf(lastYearDonors)) * 100;
            return retentionRate.setScale(2);
        }
        return 0;
    }
    
    // Method to find lapsed donors (no donation in 6 months)
    public static List<Donor__c> findLapsedDonors() {
        Date sixMonthsAgo = Date.today().addMonths(-6);
        
        List<Donor__c> lapsedDonors = [SELECT Id, Name, Email__c, 
                                      Last_Donation_Date__c, Total_Donated__c
                                      FROM Donor__c 
                                      WHERE Last_Donation_Date__c < :sixMonthsAgo
                                      ORDER BY Last_Donation_Date__c];
        
        return lapsedDonors;
    }
}