@isTest
private class DonationTriggerHandlerTest {
    
    @TestSetup
    static void setupTestData() {
        // Create test donor
        Donor__c testDonor = new Donor__c(
            Name = 'Test Donor',
            Email__c = 'test@example.com',
            Phone__c = '9876543210'
        );
        insert testDonor;
    }
    
    @isTest 
    static void testDonationInsert() {
        // Get test donor
        Donor__c donor = [SELECT Id FROM Donor__c LIMIT 1];
        
        // Create test donation
        Donation__c testDonation = new Donation__c(
            Donor__c = donor.Id,
            Amount__c = 1000,
            Donation_Date__c = Date.today(),
            Fund__c = 'General',
            Payment_Method__c = 'Cash'
        );
        
        Test.startTest();
        insert testDonation;
        Test.stopTest();
        
        // Verify donation was inserted
        Donation__c insertedDonation = [SELECT Id, Amount__c, Notes__c 
                                       FROM Donation__c 
                                       WHERE Id = :testDonation.Id];
        
        System.assertEquals(1000, insertedDonation.Amount__c);
    }
    
    @isTest 
    static void testWeekendDonation() {
        Donor__c donor = [SELECT Id FROM Donor__c LIMIT 1];
        
        // Create donation on Saturday (adjust date as needed)
        Date saturday = Date.newInstance(2024, 1, 6); // A Saturday
        
        Donation__c weekendDonation = new Donation__c(
            Donor__c = donor.Id,
            Amount__c = 2000,
            Donation_Date__c = saturday,
            Fund__c = 'Education',
            Payment_Method__c = 'Online'
        );
        
        Test.startTest();
        insert weekendDonation;
        Test.stopTest();
        
        // Verify weekend note was added
        Donation__c insertedDonation = [SELECT Notes__c FROM Donation__c WHERE Id = :weekendDonation.Id];
        System.assert(insertedDonation.Notes__c.contains('Weekend donation'));
    }
    
   @isTest 
static void testFirstTimeDonorTask() {
    Donor__c donor = [SELECT Id, Name FROM Donor__c LIMIT 1];
    
    Donation__c firstDonation = new Donation__c(
        Donor__c = donor.Id,
        Amount__c = 5000,
        Donation_Date__c = Date.today(),
        Fund__c = 'Health',
        Payment_Method__c = 'Bank Transfer'
    );
    
    Test.startTest();
    insert firstDonation;
    Test.stopTest();
    
    // Since we removed task creation, just verify donation was created
    List<Donation__c> donations = [SELECT Id FROM Donation__c WHERE Donor__c = :donor.Id];
    System.assertEquals(1, donations.size());
    
    // Test that category was updated instead
    Donor__c updatedDonor = [SELECT Category__c FROM Donor__c WHERE Id = :donor.Id];
    System.assertNotEquals(null, updatedDonor.Category__c);
}
}