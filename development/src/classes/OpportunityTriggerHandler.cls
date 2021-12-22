public with sharing class OpportunityTriggerHandler extends TriggerHandler {

    private List<Opportunity> triggerNew;
    private List<Opportunity> triggerOld;
    private Map<Id, Opportunity> triggerMapNew;
    private Map<Id, Opportunity> triggerMapOld;

    public OpportunityTriggerHandler() {
        this.triggerNew = (List<Opportunity>) Trigger.new;
        this.triggerOld = (List<Opportunity>) Trigger.old;
        this.triggerMapNew = (Map<Id, Opportunity>) Trigger.newMap;
        this.triggerMapOld = (Map<Id, Opportunity>) Trigger.oldMap;
    }

    public override void beforeUpdate() {

        Set<Id> opportunityIdsToSkipStageUpdate = new Set<Id>();
        Set<Id> opportunityIdsWIthUpdatedStage = new Set<Id>();
        //get oppty with updated stage
        for (Opportunity opportunity : this.triggerNew) {
            if (this.triggerMapNew.get(opportunity.Id).StageName != this.triggerMapOld.get(opportunity.Id).StageName) {
                opportunityIdsWIthUpdatedStage.add(opportunity.Id);
            }
        }
        //get not paid invoices
        List<Invoices__c> notPaidInvoices = [SELECT Id, Status__c, Opportunity__c
                                            FROM Invoices__c
                                            WHERE Opportunity__c IN: opportunityIdsWIthUpdatedStage AND Status__c <> 'Paid'];

        if (notPaidInvoices.size() > 0) {
           for (Invoices__c invoice : notPaidInvoices) {
               if (this.triggerMapNew.get(invoice.Opportunity__c).StageName == 'Closed Won') {
                   opportunityIdsToSkipStageUpdate.add(invoice.Opportunity__c);
               }
           }
            revertOpportunityStageUpdate(opportunityIdsToSkipStageUpdate);
        }
    }

    private void revertOpportunityStageUpdate(Set<Id> opportunityIdsToSkipStageUpdate){

        for (Opportunity opportunity : this.triggerMapNew.values()) {
           if (opportunityIdsToSkipStageUpdate.contains(opportunity.Id)) {
               this.triggerMapNew.get(opportunity.Id).StageName = this.triggerMapOld.get(opportunity.Id).StageName;
           }
        }
    }
}