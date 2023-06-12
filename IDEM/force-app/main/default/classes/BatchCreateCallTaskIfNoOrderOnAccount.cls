/**
 * @description       : Schedulable : Takes a list of account with Active__c == false, and checks if no orders or tasks related.
 *                      If ok, create a call task. 
 * @last modified on  : 12-06-2023
 * @author Mathieu Foulon | 09-06-2023 
 * @last modified by  : Mathieu Foulon
**/
global with sharing class BatchCreateCallTaskIfNoOrderOnAccount implements Database.Batchable<sObject>, Database.Stateful, Schedulable {

    public Integer recordsProcessed = 0;
    
    global Database.QueryLocator start(Database.BatchableContext bc){ 
       
        return Database.getQueryLocator([SELECT Id, OwnerId 
            FROM Account 
            WHERE Active__c = false]);
 
    }
     
    global void execute(Database.BatchableContext bc, List<Account> scope){    

        List<Task> tasksList = new List<Task>();
        Set<Id> AccountIdSet = (new Map<Id,SObject>(scope)).keySet();
        Map<Id, Order> mapAccountIdToOrder = AccountManager.getAccountIdToOrderMap(AccountIdSet);
        Map<Id, Task> mapAccountIdToTask = AccountManager.getAccountIdToTaskMap(AccountIdSet);
      
        for(Account account : scope){
            Contact contact = [SELECT Id, LastName FROM Contact WHERE AccountId = :account.Id LIMIT 1];
            if(mapAccountIdToOrder.get(account.Id) == null && mapAccountIdToTask.get(account.Id) == null){
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
