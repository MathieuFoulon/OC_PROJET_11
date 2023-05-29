global with sharing class BatchCreateCallTaskIfNoOrderOnAccount implements Database.Batchable<sObject>, Database.Stateful, Schedulable {

    public Integer recordsProcessed = 0;
    
    global Database.QueryLocator start(Database.BatchableContext bc){ 
        return Database.getQueryLocator([SELECT Id, OwnerId, 
            (SELECT Id FROM Orders), 
            (SELECT Id FROM Tasks WHERE Subject='Call') 
            FROM Account 
            WHERE Active__c = false
        ]);
 
    }
     
    global void execute(Database.BatchableContext bc, List<Account> scope){    
        
        List<Task> tasksList = new List<Task>();

        for(Account account : scope){
            Contact contact = [SELECT Id, LastName FROM Contact WHERE AccountId = :account.id LIMIT 1];
            if(account.Orders.size() == 0 && account.Tasks.size() == 0){
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
            tasksList.add(task);
            recordsProcessed = recordsProcessed + 1;
            }
            
        }

        if(tasksList.size() > 0){
            insert tasksList;
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