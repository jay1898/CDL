global class CDL_NextFolloupBatch implements Database.Batchable<sObject>,Schedulable,Database.AllowsCallouts {
    
    
    DateTime currentTime;
    Time systemCurrentTime = DateTime.now().time();
    global CDL_NextFolloupBatch(DateTime getCurrentTime){
        this.currentTime = getCurrentTime;
    }
    global CDL_NextFolloupBatch(){
        this.currentTime = dateTime.now();
    }
    
    global Database.QueryLocator start(Database.BatchableContext bc)
    {
        List<AsyncApexJob> listAA=[Select Id, Status,ApexClassId,ApexClass.Name, NumberOfErrors, 
                                   JobItemsProcessed,TotalJobItems, ExtendedStatus 
                                   From AsyncApexJob 
                                   Where ApexClass.Name='CDL_NextFolloupBatch'
                                   And Status in ('Holding','Processing')];
        if(listAA.size()>0){
            return Database.getQueryLocator([SELECT Id,Name,OwnerId,Grand_Total__c,Next_FollowUp_Time__c,Last_Delivery_Status_Change_Date__c,(select id,Order__c,Status__c,FollowUp_Stage__c,Expected_Follow_Up_Time__c ,Actual_Follow_Up_Time__c,comment__c from Order_Follow_Ups__r),FollowUp_Stage__c,Order_Delivery_Status__c FROM order__c 
                                             Where FollowUp_Stage__c in ('RTO','Abandoned','Out for Delivery','NDR','Manifest')
                                             and Next_FollowUp_Time__c<=:currentTime and Next_FollowUp_Time__c!=null limit 0
                                            ]); 
        }
        
        return Database.getQueryLocator([SELECT Id,Name,OwnerId,Grand_Total__c,Next_FollowUp_Time__c,Last_Delivery_Status_Change_Date__c,(select id,Order__c,Status__c,FollowUp_Stage__c,Expected_Follow_Up_Time__c ,Actual_Follow_Up_Time__c,comment__c from Order_Follow_Ups__r),FollowUp_Stage__c,Order_Delivery_Status__c FROM order__c 
                                         Where FollowUp_Stage__c in ('RTO','Abandoned','Out for Delivery','NDR','Manifest')
                                         and Next_FollowUp_Time__c<=:currentTime and Next_FollowUp_Time__c!=null
                                        ]);
    }
    global void execute(Database.BatchableContext bc, List<order__c> orderList)
    {
        Map<Id,User> userMap = new Map<Id,User>([Select Id,Name,Username,Ordering__c,On_Leave__c,Assign_Order_Above__c from User]);
        List<Order__c> listtoUpdateOrderOwner = new List<Order__c>();
        
        List<Order__c> listOrderToUpdate = new List<Order__c>();       
        List<Order_Follow_Up__c> followUpList = new List<Order_Follow_Up__c>();
        List<Order_Follow_Up__c> updateMissedfollowUpList = new List<Order_Follow_Up__c>();
        List<String> existforllowUPList = new List<String>();
        for(order__c  order : orderList){
            DateTime nextFollowupDate=CDL_Utility.getNextFollowUpDate(order.Last_Delivery_Status_Change_Date__c, order.FollowUp_Stage__c,systemCurrentTime);
            
            for(Order_Follow_Up__c orderFollowup : order.Order_Follow_Ups__r){
                existforllowUPList.add(orderFollowup.Order__c+orderFollowup.FollowUp_Stage__c+orderFollowup.Expected_Follow_Up_Time__c);
                if(orderFollowup.Status__c=='Pending'){
                    orderFollowup.Status__c='Missed';
                    orderFollowup.comment__c='Missed';
                    orderFollowup.Actual_Follow_Up_Time__c= Datetime.now();
                    updateMissedfollowUpList.add(orderFollowup);
                }
            }
            if(!existforllowUPList.contains(order.Id+order.FollowUp_Stage__c+order.Next_FollowUp_Time__c))
            {
                Order_Follow_Up__c createFollowUp = new Order_Follow_Up__c();
                createFollowUp.Order__c = order.Id;
                createFollowUp.Expected_Follow_Up_Time__c  = order.Next_FollowUp_Time__c;
                createFollowUp.Follow_Up_Order__c= order.Order_Follow_Ups__r.size()+1; 
                createFollowUp.FollowUp_Stage__c=order.FollowUp_Stage__c;
                createFollowUp.Status__c='Pending';
                followUpList.add(createFollowUp);
            }
            If(nextFollowupDate != null)
            {
                order.Next_FollowUp_Time__c=nextFollowupDate;
            }else{
                Datetime today = Datetime.now().date();
                order.Next_FollowUp_Time__c = Datetime.newInstance(today.year(), today.month(), today.day() + 1, 11, 0, 0);
            }
                      
            listOrderToUpdate.add(order);
            if(userMap.get(order.OwnerId).On_Leave__c == true){
                listtoUpdateOrderOwner.add(order);
            }            
        }
                
        if(updateMissedfollowUpList.Size() > 0){
            update updateMissedfollowUpList;
        }
        if(followUpList.Size() > 0){
            insert followUpList;
        }
        update listOrderToUpdate;
        
        //update Owner
        if(!listtoUpdateOrderOwner.isEmpty()){
            CDL_AssignOrderOwner.updateOrderOwner(listtoUpdateOrderOwner);
        }
    }
    global void finish(Database.BatchableContext bc)
    {
        
    }
    public void execute(SchedulableContext sc) 
    {    
        CDL_NextFolloupBatch b = new CDL_NextFolloupBatch(currentTime);
        database.executebatch(b);
        
    }   
    
    
}