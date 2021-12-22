@IsTest
private class InvoiceTriggerHandlerTest {

    @TestSetup
    private static void setupInitialData() {

        List < Account > accounts = new List < Account > ();
        Integer numAccounts = 3;
        Integer numOppPerAccount = 1;
        for (Integer i = 0; i < numAccounts; i++) {
            Account a = new Account(Name = 'TestAccount' + i);
            accounts.add(a);
        }
        insert accounts;

        List < Opportunity > opportunities = new List < Opportunity > ();
        List < String > isoCodes = new List < String > {
                'GBP',
                'EUR',
                'RUB'
        };
        for (Integer j = 0; j < numAccounts; j++) {
            Account account = accounts[j];
            for (Integer k = 0; k < numOppPerAccount; k++) {
                opportunities.add(TestDataFactory.createOpportunityItem(account.Name + ' Opportunity ' + j,'Prospecting',1000000,'123456789' + j,System.today().addMonths(1),account.Id));
            }
        }

        insert opportunities;
    }

    @IsTest
    private static void createInvoiceOpportunityExists() {

        List<Invoices__c> invoices = new List<Invoices__c>();
        List<Opportunity> opportunities = [SELECT ID, ContractId__c FROM Opportunity
                                           WHERE ContractId__c <> null];
        Test.startTest();
        for (Integer i = 0; i < opportunities.size(); i++) {
             invoices.add(TestDataFactory.createInvoiceItem('Invoice' + i,'New','123456789' + i));
        }
        insert invoices;
        Test.stopTest();

        List<Invoices__c> invoicesToVerify = new List<Invoices__c>();
        for (Invoices__c invoice : invoicesToVerify) {
             System.assertNotEquals(invoice.Opportunity__c, null);
        }
        //validate no new oppty were created
        List<Opportunity> opportunitiesToVerify = [SELECT Id FROM Opportunity];
        System.assertEquals(3, opportunitiesToVerify.size());
    }
}