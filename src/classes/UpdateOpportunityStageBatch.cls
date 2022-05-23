/**
 * Update Stage of the Opportunity where Invoices were paid
 * */
public class UpdateOpportunityStageBatch implements Database.Batchable<sObject>, Database.Stateful {

        public Database.QueryLocator start(Database.BatchableContext bc) {
            return Database.getQueryLocator(
                    'SELECT ID, StageName, (SELECT ID, Status__c FROM Invoices__r WHERE Status__c = \'Paid\'' + ')' +
                            'FROM Opportunity ' +
                            'Where StageName <> \'Closed Won\''
            );
        }

        public void execute(Database.BatchableContext bc, List<Opportunity> scope){
            List<Opportunity> opportunitiesToUpdateStage = new List<Opportunity>();
            for (Opportunity opportunity : scope) {
                for (Invoices__c invoice : opportunity.Invoices__r) {
                    opportunity.StageName = 'Closed Won';
                    opportunitiesToUpdateStage.add(opportunity);
                    break;
                }
            }
            update opportunitiesToUpdateStage;
        }

        public void finish(Database.BatchableContext bc){
            //
        }
    }