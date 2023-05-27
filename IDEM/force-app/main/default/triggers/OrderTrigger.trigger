trigger OrderTrigger on Order (after insert, before update, after delete) {

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