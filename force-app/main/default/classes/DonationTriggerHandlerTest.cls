@isTest
private class DonationTriggerHandlerTest {
    @testSetup
    static void setupData() {
        Donor__c d = new Donor__c(Name = 'Test Donor', Email__c = 'test@example.com');
        insert d;
    }

    static testMethod void testCategoryUpdateAfterDonations() {
        Donor__c donor = [SELECT Id FROM Donor__c WHERE Email__c = 'test@example.com' LIMIT 1];

        Donation__c a = new Donation__c(Donor__c = donor.Id, Amount__c = 5000, Donation_Date__c = Date.today());
        Donation__c b = new Donation__c(Donor__c = donor.Id, Amount__c = 6000, Donation_Date__c = Date.today());
        Test.startTest();
            insert new List<Donation__c>{ a, b };
        Test.stopTest();

        donor = [SELECT Id, Category__c FROM Donor__c WHERE Id = :donor.Id LIMIT 1];
        System.assertEquals('Regular Donor', donor.Category__c, 'Total 11,000 should make donor a Regular Donor');
    }
}