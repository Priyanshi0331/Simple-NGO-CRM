trigger DonationTrigger on Donation__c (after insert, after update) {
    if (Trigger.isAfter && (Trigger.isInsert || Trigger.isUpdate)) {
        DonationTriggerHandler.handleAfterInsertOrUpdate(Trigger.new);
    }
}