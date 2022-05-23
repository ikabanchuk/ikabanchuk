@IsTest
public with sharing class OpportunityTriggerHandlerTest {

        @TestSetup
        private static void setupInitialData() {

            List <Account> accounts = new List < Account > ();
            Integer numAccounts = 3;
            Integer numOppPerAccount = 1;
            for (Integer i = 0; i < numAccounts; i++) {
                Account a = new Account(Name = 'TestAccount' + i);
                accounts.add(a);
            }
            insert accounts;

            List <Opportunity> opportunities = new List <Opportunity> ();
            for (Integer j = 0; j < numAccounts; j++) {
                Account account = accounts[j];
                for (Integer k = 0; k < numOppPerAccount; k++) {
                    opportunities.add(TestDataFactory.createOpportunityItem(account.Name + ' Opportunity ' + j,'Prospecting',1000000,'123456789' + j,System.today().addMonths(1),account.Id));
                }
            }

            insert opportunities;

            List<Invoices__c> invoices = new List<Invoices__c>();
            invoices.add(TestDataFactory.createInvoiceItem('Invoice1','New','1234567890'));
            invoices.add(TestDataFactory.createInvoiceItem('Invoice2','Paid','1234567891'));
            invoices.add(TestDataFactory.createInvoiceItem('Invoice3','New','1234567892'));
            insert invoices;
        }

        @IsTest
        private static void validateOpportunityStageUpdate_Negative() {

            Opportunity opportunity = [SELECT Id, StageName FROM Opportunity WHERE ContractId__c = '1234567892'];

            Test.startTest();
            opportunity.StageName = 'Closed Won';
            update opportunity;
            Test.stopTest();

            //validate oppty stage was not updated
            List<Opportunity> opportunitiesToVerify = [SELECT Id FROM Opportunity WHERE StageName = 'Closed Won'];
            System.assertEquals(0, opportunitiesToVerify.size());
        }

        @IsTest
        private static void validateOpportunityStageUpdate_Positive() {

            Opportunity opportunity = [SELECT Id, StageName FROM Opportunity WHERE ContractId__c = '1234567891'];

            Test.startTest();
            opportunity.StageName = 'Closed Won';
            update opportunity;
            Test.stopTest();

            //validate oppty stage was updated
            List<Opportunity> opportunitiesToVerify = [SELECT Id FROM Opportunity WHERE StageName = 'Closed Won'];
            System.assertEquals(1, opportunitiesToVerify.size());
        }
}