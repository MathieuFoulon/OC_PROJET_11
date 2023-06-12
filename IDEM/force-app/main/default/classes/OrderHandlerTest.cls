/**
 * @description       : This class is built to test OrderHandler methods
**/
@isTest
public with sharing class OrderHandlerTest {
    @TestSetup
    static void makeData(){
        DataFactory.createOrdersFulljob('AccountName1', 'ContactName1', 'ProductName1', 100, 1, 1);
        DataFactory.createOrdersFulljob('AccountName2', 'ContactName2', 'ProductName2', 100, 1, 0);
        
        
    }
    
    /**
    * @description Test on update : order status changed
    * @author Mathieu Foulon | 09-06-2023 
    **/
    @isTest
    static void checkIfProductsWithOneProductTest(){
        List<Order> ordersList = [SELECT Id, Name FROM Order 
            WHERE Products_purchased__c = 1
        ];

        List<Order> activatedOrders = new List<Order>();

        Test.startTest();

        for(Order order : ordersList){
            order.Status = 'Activated';
            activatedOrders.add(order);
        }
        update activatedOrders;

        Test.stopTest();

        List<Order> changedOrdersList = [SELECT Id, Name FROM Order 
            WHERE Status = 'Activated'
        ];

        Assert.areEqual(1, changedOrdersList.size());
    }

    /**
    * @description Test on update : order status not changed
    * @author Mathieu Foulon | 09-06-2023 
    **/
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

    /**
    * @description Test on create : good status assigned on account
    * @author Mathieu Foulon | 09-06-2023 
    **/
    @isTest
    static void checkIfNotActiveWhenAccountIsCreatedTest(){
        Account account = DataFactory.createAccount('AccountName3');
        insert account;
        // account created, default value for Active__c is false
        Assert.areEqual(false, account.Active__c);
    }

    /**
    * @description Test good status on account is assigned when Order is created
    * @author Mathieu Foulon | 11-06-2023 
    **/
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

    /**
    * @description Test good status is assigned to account if no orders left
    * @author Mathieu Foulon | 11-06-2023 
    **/
    @isTest 
    static void checkIfNotActiveOnAccountWhenAllOrdersDeleted(){
        Account account = DataFactory.createAccount('AccountName3');
        insert account;

        Contract contract = DataFactory.createContract(account.id);
        insert contract;
        List<Order> ordersList = DataFactory.createOrders(account.id, 2);
        insert ordersList;

        delete ordersList;

        Account targetedAccount = [SELECT Id, Name, Active__c FROM Account
            WHERE Name = 'AccountName3'
            LIMIT 1
        ];
        
        Assert.areEqual(false, targetedAccount.Active__c);


    }
}