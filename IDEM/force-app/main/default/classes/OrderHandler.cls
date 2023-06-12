/**
 * @description       : Class supporting OrderTrigger job processes
 * @author            : Mathieu Foulon
 * @last modified on  : 12-06-2023
 * @last modified by  : Mathieu Foulon
**/
public with sharing class OrderHandler {

    
    /**
    * @description  Well, this is a native funtionnality of Salesforce, but we can reproduce it and change the message
    * @author Mathieu Foulon | 11-06-2023 
    * @param List<Order> ordersList 
    **/
    public static void checkIfProducts(List<Order> ordersList) {
        for(Order order : ordersList){
            // Products_purchased__c = roll up summary SUM of quantity of Order Product
            if(order.status == 'Activated' && order.Products_purchased__c == 0) {
                
                order.addError('You should have at least 1 product purchased to let the status pass to Activated');
            }
        }
    }

    
    /**
    * @description  checks that Active__c == true if order related to account, if not assigns true
    * @author Mathieu Foulon | 11-06-2023 
    * @param List<Order> ordersList 
    **/
    public static void checkIfActiveInAccount(List<Order> ordersList){
        List<Id> accountsIds = new List<Id>();
        for(Order order : ordersList){
            accountsIds.add(order.AccountId);
        }

        // targets accounts with at least one order
        List<Account> accountsList = [SELECT Id, Active__c, (SELECT Id, AccountId FROM Orders) 
            FROM Account
            WHERE Id IN :accountsIds];
        
        for(Account account : accountsList){
            if(account.Active__c == false){
                account.Active__c = true;
            }
        }

        update accountsList;
    }

    
    /**
    * @description  checks if at least one order is related to account, if none : set Active__c to false
    * @author Mathieu Foulon | 11-06-2023 
    * @param List<Order> ordersList 
    **/
    public static void checkIfStillOrderInAccount(List<Order> ordersList){
        List<Id> accountsIdsList = new List<Id>();
        for(Order order : ordersList){
            accountsIdsList.add(order.AccountId);
        }

        // targets accounts with no orders
        List<Account> accountsList = [SELECT Id, Active__c 
            FROM Account 
            WHERE Id IN :accountsIdsList
            AND Id NOT IN (SELECT AccountId FROM Order)];

        for(Account account : accountsList){
            account.Active__c = false;
        }

        update accountsList;
    }
}