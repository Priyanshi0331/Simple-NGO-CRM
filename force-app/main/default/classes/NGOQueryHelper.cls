public class NGOQueryHelper {
    
    // Get top donors by donation amount
    public static List<Donor__c> getTopDonors(Integer limitCount) {
        return [SELECT Id, Name, Email__c, Total_Donated__c, Last_Donation_Date__c
                FROM Donor__c 
                WHERE Total_Donated__c > 0
                ORDER BY Total_Donated__c DESC 
                LIMIT :limitCount];
    }
    
    // Get volunteers by skill
    public static List<Volunteer__c> getVolunteersBySkill(String skill) {
        String searchSkill = '%' + skill + '%';
        return [SELECT Id, Name, Email__c, Phone__c, Skills__c
                FROM Volunteer__c 
                WHERE Skills__c LIKE :searchSkill];
    }
    
    // Get donation summary by fund
    public static Map<String, Decimal> getDonationSummaryByFund() {
        Map<String, Decimal> fundSummary = new Map<String, Decimal>();
        
        for (AggregateResult ar : [SELECT Fund__c fund, SUM(Amount__c) total
                                  FROM Donation__c 
                                  GROUP BY Fund__c]) {
            String fund = (String) ar.get('fund');
            Decimal total = (Decimal) ar.get('total');
            fundSummary.put(fund, total);
        }
        
        return fundSummary;
    }
    
    // Search across multiple objects using SOSL
    public static List<List<sObject>> searchNGORecords(String searchTerm) {
        String searchQuery = 'FIND \'' + searchTerm + '\' IN ALL FIELDS ' +
                           'RETURNING Donor__c(Name, Email__c), ' +
                           'Volunteer__c(Name, Email__c, Skills__c)';
        
        return Search.query(searchQuery);
    }
}