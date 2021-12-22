@isTest
private class UpdateOpportunityStageBatchTest {

    @TestSetup
    private static void setUpInitialData() {

        List <Account> accounts = new List < Account > ();
        Integer numAccounts = 2;
        Integer numOppPerAccount = 1;
        for (Integer i = 0; i < numAccounts; i++) {
            Account a = new Account(Name = 'TestAccount' + i);
            accounts.add(a);
        }
        insert accounts;

        List <Opportunity> opportunities = new List <Opportunity>();
        for (Integer j = 0; j < numAccounts; j++) {
            Account account = accounts[j];
            for (Integer k = 0; k < numOppPerAccount; k++) {
                opportunities.add(TestDataFactory.createOpportunityItem(account.Name + ' Opportunity ' + j,'Prospecting',1000000,'123456789' + j,System.today().addMonths(1),account.Id));
            }
        }
        insert opportunities;

        List<Invoices__c> invoices = new List<Invoices__c>();
        invoices.add(TestDataFactory.createInvoiceItem('Invoice1','Paid','1234567890'));
        invoices.add(TestDataFactory.createInvoiceItem('Invoice2','Paid','1234567890'));
        invoices.add(TestDataFactory.createInvoiceItem('Invoice3','Paid','1234567891'));
        invoices.add(TestDataFactory.createInvoiceItem('Invoice4','Paid','1234567891'));
        insert invoices;
    }

    @IsTest
    private static void testOpportunityStageUpdate_Positive() {

        Test.startTest();
        UpdateOpportunityStageBatch b = new UpdateOpportunityStageBatch();
        Id batchId = Database.executeBatch(b);
        Test.stopTest();

        //validate stage of opportunities
        System.assertEquals(2, [SELECT count() FROM Opportunity WHERE StageName = 'Closed Won']);
    }

    @IsTest
    private static void testOpportunityStageUpdateNoConditionData() {

        List<Invoices__c> invoices = [SELECT ID, Status__c FROM Invoices__c];
        for (Invoices__c invoice : invoices) {
            invoice.Status__c = 'New';
        }
        update invoices;
        Test.startTest();
        UpdateOpportunityStageBatch b = new UpdateOpportunityStageBatch();
        Id batchId = Database.executeBatch(b);
        Test.stopTest();

        //validate stage of opportunities
        System.assertEquals(0, [SELECT count() FROM Opportunity WHERE StageName = 'Closed Won'],
                'Opportunity Stage was updated without conditional data');
    }
}