global class DemoManagerUpdateClass implements Database.Batchable<sObject> {
   global Database.Querylocator start(Database.BatchableContext BC) {
      //Return all open cases owned by a user
      return Database.getQueryLocator([SELECT Id, Case_Owner_Manager__c, OwnerId FROM Case WHERE Status != 'Closed' AND Owner.Type = 'User']);
   }

   global void execute(Database.BatchableContext BC, List<Case> scope) {
      //Iterate through the cases and build a set of owner ids that we can use to query the user object
      Set<Id> userIds = new Set<Id>();
      for (Case c : scope) {
         userIds.add(c.OwnerId);
      }

      //Query the user records for each of these case owners
      Map<Id, User> caseowners = new Map<Id, User>([SELECT Id, ManagerId FROM User WHERE Id IN :userIds]);

      //Create a list that will hold cases that need to be updated
      List<Case> casesforupdate = new List<Case>();

      //Iterate through the cases and check to see if a manager update is needed
      for (Case c : scope) {
         if (c.Case_Owner_Manager__c != caseowners.get(c.OwnerId).ManagerId) {
            c.Case_Owner_Manager__c = caseowners.get(c.OwnerId).ManagerId;
            casesforupdate.add(c);
         }
      }

      //If we have any cases that need to be updated, update them
      if (casesforupdate.size() > 0) {
         update casesforupdate;
      }
   }

   global void finish(Database.BatchableContext BC) {
   }
}
