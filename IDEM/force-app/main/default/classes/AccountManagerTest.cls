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

    @IsTest
    static void getAccountIdToOrderMapNoOrderTest(){
        List<Account> accounts =[SELECT Id
            FROM Account 
            WHERE Name = 'AccountTest1000'
        ];
        Set<Id> AccountIdSet = (new Map<Id,SObject>(accounts)).keySet();
        Test.startTest();
        Map<Id, Order> mapAccountIdToOrder = AccountManager.getAccountIdToOrderMap(AccountIdSet);
        Test.stopTest();
        for(Account account : accounts){
            Assert.areEqual(null, mapAccountIdToOrder.get(account.Id));
        }
        Assert.areEqual(0, mapAccountIdToOrder.size());
        
    }

    @isTest
    static void getAccountIdToOrderMapWithOrderTest(){
        List<Account> accounts =[SELECT Id, OwnerId
            FROM Account 
            WHERE Name = 'AccountTest2000'
        ];
        Set<Id> AccountIdSet = (new Map<Id,SObject>(accounts)).keySet();
        Test.startTest();
        Map<Id, Order> mapAccountIdToOrder = AccountManager.getAccountIdToOrderMap(AccountIdSet);
        Test.stopTest();
        for(Account account : accounts){
            Order order = [SELECT Id, Name, AccountId FROM Order WHERE AccountId = :account.id];
            Assert.areEqual(order, mapAccountIdToOrder.get(account.Id));
        }
        Assert.areEqual(1, mapAccountIdToOrder.size());
        
    }

    @IsTest
    static void getAccountIdToTaskMapNoTaskTest(){
        List<Account> accounts =[SELECT Id
            FROM Account 
            WHERE Name = 'AccountTest1000'
        ];
        Set<Id> AccountIdSet = (new Map<Id,SObject>(accounts)).keySet();
        Test.startTest();
        Map<Id, Task> mapAccountIdToTask = AccountManager.getAccountIdToTaskMap(AccountIdSet);
        Test.stopTest();
        for(Account account : accounts){
            Assert.areEqual(null, mapAccountIdToTask.get(account.Id));
        }
        Assert.areEqual(0, mapAccountIdToTask.size());
        
    }

    @IsTest
    static void getAccountIdToTaskMapWithTaskTest(){
        List<Account> accounts =[SELECT Id, OwnerId
            FROM Account 
            WHERE Name = 'AccountTest2000'
        ];
        

        Set<Id> AccountIdSet = (new Map<Id,SObject>(accounts)).keySet();

        Test.startTest();
        Map<Id, Task> mapAccountIdToTask = AccountManager.getAccountIdToTaskMap(AccountIdSet);
        Test.stopTest();
        for(Account account : accounts){
            Task task = [SELECT Id, WhatId FROM Task WHERE WhatId = :account.id];
            Assert.areEqual(task, mapAccountIdToTask.get(account.Id));
        }
        Assert.areEqual(1, mapAccountIdToTask.size());
        
    }
}