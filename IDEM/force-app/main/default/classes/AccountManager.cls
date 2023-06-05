public with sharing class AccountManager {
    public static Map<Id, Order> getAccountIdToOrderMap(Set<Id> accIdSet) {
        List<Order> orderList = [Select Id, AccountId FROM Order WHERE AccountId IN: accIdSet];
        Map<Id, Order> mapAccountIdToOrder = new Map<Id, Order>();
        for(Order ord : orderList){
            mapAccountIdToOrder.put(ord.AccountId, ord);
        }
        return mapAccountIdToOrder;        
    }
    
    public static Map<Id, Task> getAccountIdToTaskMap(Set<Id> accIdSet) {
        List<Task> tasksList = [Select Id, WhatId FROM Task WHERE WhatId IN: accIdSet];
        Map<Id, Task> mapAccountIdToTask = new Map<Id, Task>();
        for(Task task : tasksList){
            mapAccountIdToTask.put(task.WhatId, task);
        }
        return mapAccountIdToTask;  
    }
}