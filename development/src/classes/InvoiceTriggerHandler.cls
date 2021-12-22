public with sharing class InvoiceTriggerHandler extends TriggerHandler {

    private List<Invoices__c> triggerNew;
    private Map<Id, Invoices__c> triggerMapNew;

    public InvoiceTriggerHandler() {
        this.triggerNew = (List<Invoices__c>) Trigger.new;
        this.triggerMapNew = (Map<Id, Invoices__c>) Trigger.newMap;
    }

    public override void beforeInsert() {

        Set<String> contractIds = new Set<String>();
        Set<String> contractIdToCreateOpportunity = new Set<String>();
        Map<String, Opportunity> opportunityPerContractId = new Map<String, Opportunity>();
        Map<String, Invoices__c> invoicePerContractId = new Map<String, Invoices__c>();

        for (Invoices__c invoice : this.triggerNew) {
            if (String.isNotBlank(invoice.ContractId__c)) contractIds.add(invoice.ContractId__c);
            invoicePerContractId.put(invoice.ContractId__c, invoice);
        }

        List<Opportunity> oppToAssignInvoice = [SELECT Id, ContractId__c FROM Opportunity WHERE ContractId__c IN: contractIds];
        for (Opportunity opportunity : oppToAssignInvoice) {
            if (String.isNotBlank(opportunity.ContractId__c)) opportunityPerContractId.put(opportunity.ContractId__c, opportunity);
        }

        for (String invoiceContractId : invoicePerContractId.keySet()) {
            if (opportunityPerContractId.get(invoiceContractId) != null) {
                invoicePerContractId.get(invoiceContractId).Opportunity__c = opportunityPerContractId.get(invoiceContractId).Id;
            } else {
                contractIdToCreateOpportunity.add(invoiceContractId);
            }
        }

        if (contractIdToCreateOpportunity.size() > 0) {
            List<Opportunity> opportunitiesToCreate = new List<Opportunity>();
            opportunitiesToCreate = createOpportunityFromContract(contractIdToCreateOpportunity);
            for (Opportunity opportunity : opportunitiesToCreate) {
                invoicePerContractId.get(opportunity.ContractId__c).Opportunity__c = opportunity.Id;
            }
        }
    }

    private static List<Opportunity> createOpportunityFromContract(Set<String> contractIdToCreateOpportunity){

        List<Opportunity> opportunitiesToCreate = new List<Opportunity>();
        for (String contractId : contractIdToCreateOpportunity) {
            opportunitiesToCreate.add(new Opportunity(
                    Name = contractId + Date.today(),
                    StageName = 'Prospecting',
                    CloseDate = System.today().addMonths(1),
                    ContractId__c = contractId
            ));
        }
        insert opportunitiesToCreate;
        return opportunitiesToCreate;
    }
}