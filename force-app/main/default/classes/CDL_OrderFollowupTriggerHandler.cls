public class CDL_OrderFollowupTriggerHandler {
    public static void updateOrderNote(List<Order_Follow_Up__c> orderList, Map<Id,Order_Follow_Up__c> oldMap) {
        
        List<Order_Follow_Up__c> orderfollowList = new List<Order_Follow_Up__c>();
        Id userId =UserInfo.getUserId();
        String currentUserName = [SELECT Name FROM User WHERE Id =: userId].Name;
        set<Id> orderfollowlat = new set<Id>();
        List<Order__c> OrderUpd = new list<Order__c>();   
        
        if(orderList.size() > 0)
        {
            for(Order_Follow_Up__c newOrderfollow :orderList){
                Order_Follow_Up__c oldOrderfollow = (Order_Follow_Up__c)oldMap.get(newOrderfollow.Id); 
                if(oldMap.get(newOrderfollow.Id).Comment__c != newOrderfollow.Comment__c && newOrderfollow.Comment__c != null)
                {
                    orderfollowlat.add(oldOrderfollow.Id);
                }
            }
        }
        if(!orderfollowlat.isEmpty())
        {
            orderfollowList = [SELECT Id,Order__c,Comment__c,Order__r.Id,Order__r.Note__c FROM Order_Follow_Up__c where Id IN:orderfollowlat];
        }
        if(orderfollowList.size()>0){
            for(Order_Follow_Up__c OrderFollow : orderfollowList)
            {
                Order__c Ordercre = new Order__c();
                Ordercre.id = OrderFollow.Order__r.Id;
                if(OrderFollow.Comment__c != null && OrderFollow.Comment__c != 'Missed') //OrderFollow.Comment__c
                {
                    String Notes;
                    Notes = 'Comments: '+ OrderFollow.Comment__c +'\n'+'User: '+ currentUserName +' '+'Time: '+DateTime.now().format('yyyy-MM-dd hh:mm:ss a');//DateTime.Now();
                    system.debug('Notes'+Notes);
                    if(OrderFollow.Order__r.Note__c != null){
                        Ordercre.Note__c = Notes+'\n\n'+OrderFollow.Order__r.Note__c;
                    }
                    else
                    {
                        Ordercre.Note__c = Notes;
                    }
                    
                }
                OrderUpd.add(Ordercre);
                
            }    
        } 
        if (OrderUpd.size()>0){
            update OrderUpd;    
        }
    }
}