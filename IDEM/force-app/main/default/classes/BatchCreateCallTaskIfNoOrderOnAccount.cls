global with sharing class BatchCreateCallTaskIfNoOrderOnAccount implements Database.Batchable<sObject>, Database.Stateful, Schedulable {

    public Integer recordsProcessed = 0;
    
    global Database.QueryLocator start(Database.BatchableContext bc){ 

        List<Id> idOfAccountsWithCallsTasks = new List<Id>();
        List<Task> tasksWithCalls = [SELECT WhatId FROM Task WHERE What.type = 'Account' AND Type = 'Call'];
        for(Task taskWithCall : tasksWithCalls){
            idOfAccountsWithCallsTasks.add(taskWithCall.WhatId);
        }


        return Database.getQueryLocator([SELECT Id, Name, OwnerId FROM Account 
        WHERE Id NOT IN (SELECT AccountId FROM Order) 
        AND Id NOT IN :idOfAccountsWithCallsTasks]);
 
    }
     
    global void execute(Database.BatchableContext bc, List<Account> scope){    
        
        List<Task> tasks = new List<Task>();

        for(Account account : scope){
            Contact contact = [SELECT Id, LastName FROM Contact WHERE AccountId = :account.id LIMIT 1];
            Task task = new Task(
                WhatId = account.Id,
                OwnerId = account.OwnerId,
                WhoId = contact.Id,
                Subject = 'Call',
                ReminderDateTime = Date.today().addDays(5),
                IsReminderSet = true,
                Status = 'Not Started',
                Priority = 'Normal'
                );
            tasks.add(task);
            recordsProcessed = recordsProcessed + 1;
        }

        if(tasks.size() > 0){
            insert tasks;
        }
    }    
     
    global void finish(Database.BatchableContext bc){     
        System.debug('Batch done. Records processed : ' + recordsProcessed);
    }

    global void execute(SchedulableContext sc){
        BatchCreateCallTaskIfNoOrderOnAccount batch = new BatchCreateCallTaskIfNoOrderOnAccount();
        Database.executeBatch(batch);
    }
}