trigger InvoiceTrigger on Invoices__c (before insert) {

    new InvoiceTriggerHandler().run();
}