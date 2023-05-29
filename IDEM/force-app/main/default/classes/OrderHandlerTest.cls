@isTest
public with sharing class OrderHandlerTest {
    @TestSetup
    static void makeData(){
        DataFactory.createOrdersFulljob('AccountName1', 'ContactName1', 'ProductName1', 100, 1, 1);
        DataFactory.createOrdersFulljob('AccountName2', 'ContactName2', 'ProductName2', 100, 1, 0);
        
        
    }
    @isTest
    static void checkIfProductsWithOneProductTest(){
        List<Order> orders = [SELECT Id, Name FROM Order 
            WHERE Products_purchased__c = 1
        ];

        List<Order> activatedOrders = new List<Order>();

        Test.startTest();

        for(Order order : orders){
            order.Status = 'Activated';
            activatedOrders.add(order);
        }
        update activatedOrders;

        Test.stopTest();

        List<Order> changedOrders = [SELECT Id, Name FROM Order 
            WHERE Status = 'Activated'
        ];

        Assert.areEqual(1, changedOrders.size());
    }

    @isTest
    static void checkIfProductsWithoutProductTest(){
        Order order = [SELECT Id, Name FROM Order 
            WHERE Products_purchased__c = 0 
            LIMIT 1
        ];

        order.Status = 'Activated';

        Test.startTest();
        
        try {
            update order;
        }catch(Exception e){

        }
        
        Test.stopTest();

        Order notActivatedOrder = [SELECT Id, Status FROM Order 
        WHERE Order.Name = :order.Name 
        LIMIT 1
        ];

        Assert.areEqual('Draft', notActivatedOrder.status);
    }

    @isTest
    static void checkIfNotActiveWhenAccountIsCreatedTest(){
        Account account = DataFactory.createAccount('AccountName3');
        insert account;
        // account created, default value for Active__c is false
        Assert.areEqual(false, account.Active__c);
    }

    @isTest
    static void checkIfActiveInAccountWhenOrderIsCreatedTest(){
        Account account = DataFactory.createAccount('AccountName3');
        insert account;

        Contract contract = DataFactory.createContract(account.id);
        insert contract;
        List<Order> orders = DataFactory.createOrders(account.id, 1);
        insert orders;

        Account targetedAccount = [SELECT Id, Name, Active__c FROM Account
            WHERE Name = 'AccountName3'
            LIMIT 1
        ];

        
        System.debug(account);
        Assert.areEqual(true, targetedAccount.Active__c);
        

    }

    @isTest 
    static void checkIfNotActiveOnAccountWhenAllOrdersDeleted(){
        Account account = DataFactory.createAccount('AccountName3');
        insert account;

        Contract contract = DataFactory.createContract(account.id);
        insert contract;
        List<Order> orders = DataFactory.createOrders(account.id, 2);
        insert orders;

        delete orders;

        Account targetedAccount = [SELECT Id, Name, Active__c FROM Account
            WHERE Name = 'AccountName3'
            LIMIT 1
        ];
        
        Assert.areEqual(false, targetedAccount.Active__c);


    }
}