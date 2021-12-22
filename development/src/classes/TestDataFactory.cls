/**
 * Common test utility class contains reusable code for test data creation
 */
@IsTest
public class TestDataFactory {

    public static Invoices__c createInvoiceItem(String invoiceName, String invoiceStatus, String invoiceContractId) {
        return new Invoices__c(
                Name = invoiceName,
                Status__c = invoiceStatus,
                ContractId__c = invoiceContractId
        );
    }

    public static Opportunity createOpportunityItem(String opportunityName,
                                                    String opportunityStage,
                                                    Decimal opportunityAmount,
                                                    String opportunityContractId,
                                                    Date opportunityCloseDate,
                                                    Id accountId) {

        return new Opportunity(Name = opportunityName,
                StageName = opportunityStage,
                Amount = opportunityAmount,
                ContractId__c = opportunityContractId,
                CloseDate = opportunityCloseDate,
                AccountId = accountId);
    }
}