/**
 * @description       : Service class for Account
 * @author            : Mathieu Foulon
 * @group             : 
 * @last modified on  : 11-06-2023
 * @last modified by  : Mathieu Foulon
**/
public with sharing class AccountManager {
    /**
    * @description Method that takes a Set of Account Ids and return a Map of Account Id and Order.
    * @author Mathieu Foulon | 11-06-2023 
    * @param Set<Id> accIdSet 
    * @return Map<Id, Order> 
    **/
    public static Map<Id, Order> getAccountIdToOrderMap(Set<Id> accIdSet) {
        List<Order> orderList = [Select Id, AccountId FROM Order WHERE AccountId IN: accIdSet];
        Map<Id, Order> mapAccountIdToOrder = new Map<Id, Order>();
        for(Order ord : orderList){
            mapAccountIdToOrder.put(ord.AccountId, ord);
        }
        return mapAccountIdToOrder;        
    }
    
    /**
    * @description Method that takes a Set of Account Ids and return a Map of Account Id and Task.
    * @author Mathieu Foulon | 11-06-2023 
    * @param Set<Id> accIdSet 
    * @return Map<Id, Task> 
    **/
    public static Map<Id, Task> getAccountIdToTaskMap(Set<Id> accIdSet) {
        List<Task> tasksList = [Select Id, WhatId FROM Task WHERE WhatId IN: accIdSet];
        Map<Id, Task> mapAccountIdToTask = new Map<Id, Task>();
        for(Task task : tasksList){
            mapAccountIdToTask.put(task.WhatId, task);
        }
        return mapAccountIdToTask;  
    }
}