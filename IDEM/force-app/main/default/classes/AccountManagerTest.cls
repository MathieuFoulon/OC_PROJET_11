/**
 * @description       : Test Classe for AccountManager
 * @author            : Mathieu Foulon
 * @last modified on  : 12-06-2023
 * @last modified by  : Mathieu Foulon
**/
@isTest
public with sharing class AccountManagerTest {
    @TestSetup
    static void makeData(){
        Account account = DataFactory.createAccount('AccountTest1000');
        insert account;

        DataFactory.createOrdersFulljob('AccountTest2000', 'GerardMajax', 'ProductTest', 100, 1, 1);

        List<Account> accounts =[SELECT Id, OwnerId
            FROM Account 
            WHERE Name = 'AccountTest2000'
        ];
        List<Task> tasks = new List<Task>();
        for (Account acct : accounts){
            Task task = new Task(
                WhatId = acct.Id,
                OwnerId = acct.OwnerId,
                Subject = 'Call',
                ReminderDateTime = Date.today().addDays(5),
                IsReminderSet = true,
                Status = 'Not Started',
                Priority = 'Normal'
            );
            tasks.add(task);
        }
        insert tasks;




    }

    /**
    * @description Testing wit no order
    * @author Mathieu Foulon | 11-06-2023 
    **/
    @IsTest
    static void getAccountIdToOrderMapNoOrderTest(){
        List<Account> accountsList =[SELECT Id
            FROM Account 
            WHERE Name = 'AccountTest1000'
        ];
        Set<Id> AccountIdSet = (new Map<Id,SObject>(accountsList)).keySet();
        Test.startTest();
        Map<Id, Order> mapAccountIdToOrder = AccountManager.getAccountIdToOrderMap(AccountIdSet);
        Test.stopTest();
        for(Account account : accountsList){
            Assert.areEqual(null, mapAccountIdToOrder.get(account.Id));
        }
        Assert.areEqual(0, mapAccountIdToOrder.size());
        
    }

    /**
    * @description Testing with orders
    * @author Mathieu Foulon | 11-06-2023 
    **/
    @isTest
    static void getAccountIdToOrderMapWithOrderTest(){
        List<Account> accountsList =[SELECT Id, OwnerId
            FROM Account 
            WHERE Name = 'AccountTest2000'
        ];
        Set<Id> AccountIdSet = (new Map<Id,SObject>(accountsList)).keySet();
        Test.startTest();
        Map<Id, Order> mapAccountIdToOrder = AccountManager.getAccountIdToOrderMap(AccountIdSet);
        Test.stopTest();
        for(Account account : accountsList){
            Order order = [SELECT Id, Name, AccountId FROM Order WHERE AccountId = :account.id];
            Assert.areEqual(order, mapAccountIdToOrder.get(account.Id));
        }
        Assert.areEqual(1, mapAccountIdToOrder.size());
        
    }

    /**
    * @description Testing without task
    * @author Mathieu Foulon | 11-06-2023 
    **/
    @IsTest
    static void getAccountIdToTaskMapNoTaskTest(){
        List<Account> accountsList =[SELECT Id
            FROM Account 
            WHERE Name = 'AccountTest1000'
        ];
        Set<Id> AccountIdSet = (new Map<Id,SObject>(accountsList)).keySet();
        Test.startTest();
        Map<Id, Task> mapAccountIdToTask = AccountManager.getAccountIdToTaskMap(AccountIdSet);
        Test.stopTest();
        for(Account account : accountsList){
            Assert.areEqual(null, mapAccountIdToTask.get(account.Id));
        }
        Assert.areEqual(0, mapAccountIdToTask.size());
        
    }

    /**
    * @description testing with tasks
    * @author Mathieu Foulon | 11-06-2023 
    **/
    @IsTest
    static void getAccountIdToTaskMapWithTaskTest(){
        List<Account> accountsList =[SELECT Id, OwnerId
            FROM Account 
            WHERE Name = 'AccountTest2000'
        ];
        

        Set<Id> AccountIdSet = (new Map<Id,SObject>(accountsList)).keySet();

        Test.startTest();
        Map<Id, Task> mapAccountIdToTask = AccountManager.getAccountIdToTaskMap(AccountIdSet);
        Test.stopTest();
        for(Account account : accountsList){
            Task task = [SELECT Id, WhatId FROM Task WHERE WhatId = :account.id];
            Assert.areEqual(task, mapAccountIdToTask.get(account.Id));
        }
        Assert.areEqual(1, mapAccountIdToTask.size());
        
    }
}