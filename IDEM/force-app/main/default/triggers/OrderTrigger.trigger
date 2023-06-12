/**
 * @description       : Trigger fired on Order when : before update, after insert, after delete
 * @author            : Mathieu Foulon
 * @last modified on  : 12-06-2023
 * @last modified by  : Mathieu Foulon
**/
trigger OrderTrigger on Order (before update, after insert, after delete) {

    if(Trigger.isBefore){
        if(Trigger.isUpdate){
            OrderHandler.checkIfProducts(trigger.new);
        }
    }
    
    if(Trigger.isAfter){
        if(Trigger.isInsert){
            OrderHandler.checkIfActiveInAccount(trigger.new);
        }
    
        if(Trigger.isDelete){
            OrderHandler.checkIfStillOrderInAccount(trigger.old);
        }
    }
    


}