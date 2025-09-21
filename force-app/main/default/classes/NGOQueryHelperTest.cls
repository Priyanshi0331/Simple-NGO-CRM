@isTest
private class NGOQueryHelperTest {
    @TestSetup
static void setupTestData() {
    // Create test donors with different donation amounts
    List<Donor__c> donors = new List<Donor__c>{
        new Donor__c(Name = 'Top Donor', Email__c = 'top@test.com'),
        new Donor__c(Name = 'Medium Donor', Email__c = 'medium@test.com'),
        new Donor__c(Name = 'Small Donor', Email__c = 'small@test.com')
    };
    insert donors;
    
    // Create donations
    List<Donation__c> donations = new List<Donation__c>{
        new Donation__c(Donor__c = donors[0].Id, Amount__c = 10000, Fund__c = 'General'),
        new Donation__c(Donor__c = donors[1].Id, Amount__c = 5000, Fund__c = 'Education'),
        new Donation__c(Donor__c = donors[2].Id, Amount__c = 1000, Fund__c = 'Health')
    };
    insert donations;
    
    // Update donor totals (since Total_Donated__c is not auto-populated in test context)
    donors[0].Total_Donated__c = 10000;
    donors[1].Total_Donated__c = 5000;
    donors[2].Total_Donated__c = 1000;
    update donors;
    
    // Create test volunteer
    Volunteer__c volunteer = new Volunteer__c(
        Name = 'Test Volunteer',
        Skills__c = 'Teaching'
    );
    insert volunteer;
}

@isTest 
static void testGetTopDonors() {
    Test.startTest();
    List<Donor__c> topDonors = NGOQueryHelper.getTopDonors(2);
    Test.stopTest();
    
    System.assertEquals(2, topDonors.size());
    System.assertEquals('Top Donor', topDonors[0].Name);
}

@isTest 
static void testGetVolunteersBySkill() {
    Test.startTest();
    List<Volunteer__c> volunteers = NGOQueryHelper.getVolunteersBySkill('Teaching');
    Test.stopTest();
    
    System.assertEquals(1, volunteers.size());
    System.assertEquals('Test Volunteer', volunteers[0].Name);
}

@isTest 
static void testGetDonationSummaryByFund() {
    Test.startTest();
    Map<String, Decimal> summary = NGOQueryHelper.getDonationSummaryByFund();
    Test.stopTest();
    
    System.assertEquals(10000, summary.get('General'));
    System.assertEquals(5000, summary.get('Education'));
    System.assertEquals(1000, summary.get('Health'));
}
}