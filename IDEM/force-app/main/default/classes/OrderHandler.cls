public with sharing class OrderHandler {

    //Well, this is a native funtionnality of Salesforce, but we can reproduce it and change the message as follow
    public static void checkIfProducts(List<Order> orders) {
        for(Order order : orders){
            // Products_purchased__c = roll up summary SUM of quantity of Order Product
            if(order.status == 'Activated' && order.Products_purchased__c == 0) {
                
                order.addError('You should have at least 1 product purchased to let the status pass to Activated');
            }
        }
    }

    // checks that Active__c == true if order related to account, if not assigns true
    public static void checkIfActiveInAccount(List<Order> orders){
        List<Id> accountsIds = new List<Id>();
        for(Order order : orders){
            accountsIds.add(order.AccountId);
        }

        List<Account> accounts = [SELECT Id, Active__c, (SELECT Id, AccountId FROM Orders) 
            FROM Account
            WHERE Id IN :accountsIds];
        
        for(Account account : accounts){
            if(account.Active__c == false){
                account.Active__c = true;
            }
        }

        update accounts;
    }

    // checks if at least one order is related to account, if not : Active__c = false
    public static void checkIfStillOrderInAccount(List<Order> orders){
        List<Id> accountsIds = new List<Id>();
        for(Order order : orders){
            accountsIds.add(order.AccountId);
        }

        List<Account> accounts = [SELECT Id, Active__c 
            FROM Account 
            WHERE Id IN :accountsIds
            AND Id NOT IN (SELECT AccountId FROM Order)];

        for(Account account : accounts){
            account.Active__c = false;
        }

        update accounts;
    }
}