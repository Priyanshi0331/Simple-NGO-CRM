public with sharing class DonorStatsHelper {
    // find donors who haven't donated in X months
    public static List<Donor__c> findLapsedDonors(Integer monthsThreshold) {
        Date cutoff = Date.today().addMonths(-monthsThreshold);
        return [
            SELECT Id, Name, Email__c, Last_Donation_Date__c, Total_Donated__c
            FROM Donor__c
            WHERE Last_Donation_Date__c < :cutoff
              AND Total_Donated__c > 0
            ORDER BY Last_Donation_Date__c ASC
            LIMIT 200
        ];
    }

    // basic donor summary stats
    public static Map<String, Object> getDonorSummaryStats() {
        Map<String, Object> stats = new Map<String, Object>();
        AggregateResult[] ar = [
            SELECT COUNT(Id) totalDonors,
                   SUM(Total_Donated__c) totalDonated,
                   AVG(Total_Donated__c) averageDonation,
                   MAX(Total_Donated__c) largestDonation
            FROM Donor__c
            WHERE Total_Donated__c > 0
        ];
        if (!ar.isEmpty()) {
            AggregateResult r = ar[0];
            Decimal totalDonors = (Decimal) r.get('totalDonors');
            stats.put('totalDonors', totalDonors == null ? 0 : totalDonors.intValue());
            stats.put('totalDonated', (Decimal) r.get('totalDonated'));
            stats.put('averageDonation', (Decimal) r.get('averageDonation'));
            stats.put('largestDonation', (Decimal) r.get('largestDonation'));
        }
        return stats;
    }
}