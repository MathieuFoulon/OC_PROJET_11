/**
 * @description       : Test class for BatchCreateCallTaskIfNoOrderOnAccount
 * @author            : Mathieu Foulon
 * @group             : 
 * @last modified on  : 12-06-2023
 * @last modified by  : Mathieu Foulon
**/
@isTest
public with sharing class BatchCreateCallTaskIfNoOrderOnAccTest {
    @TestSetup
    static void makeData(){

        //Creating account and contact but no orders
        Account account = DataFactory.createAccount('AccountName1');
        insert account;
        Contact contact = DataFactory.createContact('ContactName1', account.Id);
        insert contact;

        //creating account and contact with order
        DataFactory.createOrdersFulljob('AccountName2', 'ContactName2', 'ProductName2', 100, 1, 1);

        List<Account> accounts = new List<Account>();
        
        for(Integer i = 0; i < 101 ; i++){
            Account accountLimit = DataFactory.createAccount('AccountLimitName' + i);
            accounts.add(accountLimit);
        }
        insert accounts;


        List<Contact> contacts = new List<Contact>();
        for(Account accountOfaccountsLimit : accounts){
            Integer j = 1;
            Contact contactLimit = DataFactory.createContact('ContactLimitName'+ j, accountOfaccountsLimit.id);
            contacts.add(contactLimit);
            j++;
        }

        insert contacts;



    }

    /**
    * @description Testing that 1 task is created
    * @author Mathieu Foulon | 11-06-2023 
    **/
    @isTest
    static void BatchCreateTaskToAccountNoOrderTest(){
        // one account with order, one account without order
        List<Account> accountsList = [SELECT Id, Name FROM Account WHERE Name LIKE 'AccountName%'];

        Test.startTest();
        BatchCreateCallTaskIfNoOrderOnAccount batch = new BatchCreateCallTaskIfNoOrderOnAccount();
        Id batchId = Database.executeBatch(batch);
        Test.stopTest();
        List<Task> tasksFromAccountsList = [SELECT Id, Subject FROM Task WHERE WhatId IN :accountsList];
        Assert.areEqual(1, tasksFromAccountsList.size());
    }

    /**
    * @description Testing that 102 tasks are created
    * @author Mathieu Foulon | 11-06-2023 
    **/
    @isTest
    static void BatchCreateTaskToAccountsNoOrderTest(){
        // one account with order, 102 account without order
        List<Account> accountsList = [SELECT Id, Name FROM Account WHERE Name LIKE 'Account%'];

        Test.startTest();
        BatchCreateCallTaskIfNoOrderOnAccount batch = new BatchCreateCallTaskIfNoOrderOnAccount();
        Id batchId = Database.executeBatch(batch);
        Test.stopTest();
        List<Task> tasksFromAccountsList = [SELECT Id, Subject FROM Task WHERE WhatId IN :accountsList];
        // we still have here the 'AccountName1', so 1 + 101 created for loop
        Assert.areEqual(102, tasksFromAccountsList.size());
    }
}