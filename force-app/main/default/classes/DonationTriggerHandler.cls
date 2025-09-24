public with sharing class DonationTriggerHandler {
    public static void handleAfterInsertOrUpdate(List<Donation__c> donations) {
        if (donations == null || donations.isEmpty()) return;
        Set<Id> donorIds = new Set<Id>();
        for (Donation__c d : donations) {
            if (d.Donor__c != null) donorIds.add(d.Donor__c);
        }
        if (donorIds.isEmpty()) return;

        // Aggregate total and last date per donor (one SOQL)
        List<AggregateResult> agg = [
            SELECT Donor__c donorId, SUM(Amount__c) totalAmount, MAX(Donation_Date__c) lastDate
            FROM Donation__c
            WHERE Donor__c IN :donorIds
            GROUP BY Donor__c
        ];

        Map<Id, Decimal> totals = new Map<Id, Decimal>();
        Map<Id, Date> lastDates = new Map<Id, Date>();
        for (AggregateResult ar : agg) {
            Id did = (Id) ar.get('donorId');
            Decimal total = (Decimal) ar.get('totalAmount');
            Date lastDate = (Date) ar.get('lastDate');
            totals.put(did, total);
            lastDates.put(did, lastDate);
        }

        List<Donor__c> donorsToUpdate = new List<Donor__c>();
        for (Id did : donorIds) {
            Decimal total = totals.containsKey(did) ? totals.get(did) : 0;
            String category = 'Supporter';
            if (total >= 50000) category = 'Major Donor';
            else if (total >= 10000) category = 'Regular Donor';

            Donor__c dUp = new Donor__c(Id = did);
            dUp.Category__c = category;
            if (lastDates.containsKey(did)) dUp.Last_Donation_Date__c = lastDates.get(did);
            donorsToUpdate.add(dUp);
        }

        if (!donorsToUpdate.isEmpty()) {
            try {
                update donorsToUpdate;
            } catch (DmlException e) {
                // keep trigger resilient: log the error
                System.debug('DonationTriggerHandler update error: ' + e.getMessage());
            }
        }
    }
}