public class CDL_LeadManagement
{
    @AuraEnabled
    public static String getOrderLit(String orderStatus,String orderDays)
    {
        String days = '';
        if (orderDays != 'All' && orderDays != 'today') {
            days = ' AND CreatedDate = LAST_N_DAYS:' + orderDays;
        }if(orderDays == 'today')
        {
            days = ' AND CreatedDate = today';
        }if(orderDays == 'yesterday')
        {
            days = ' AND CreatedDate = yesterday';
        }
        String soqlQuery = 'SELECT Id,CreatedDate, Name,Pending_Followup_Time__c,FollowUp_Stage__c ,Next_FollowUp_Time__c, Status__c, Payment_Status__c, isVerified__c, Order_Delivery_Status__c, Total_Price__c, Grand_Total__c, Order_Amount__c, Account__r.Name, Account__r.Phone__c, Billing_Street__c, Billing_City__c, Billing_State__c, Billing_PostalCode__c, Billing_Country__c, Shipping_Street__c, Shipping_City__c, Shipping_State__c, Shipping_PostalCode__c, Shipping_Country__c FROM Order__c ';
        
        if (orderStatus == 'All') {
            soqlQuery += 'WHERE Status__c != null AND Account__c != null' + days + ' ORDER BY CreatedDate DESC LIMIT 50000';
        } else if (orderStatus == 'Abandoned' || orderStatus == 'Confirm' || orderStatus == 'Voided') {
            soqlQuery += 'WHERE Status__c = \'' + orderStatus + '\' AND Account__c != null' + days + ' ORDER BY Next_FollowUp_Time__c ASC LIMIT 50000';
        } else if (orderStatus == 'Out for Delivery') {
            soqlQuery += 'WHERE Status__c = \'' + orderStatus + '\' AND Account__c != null' + days + ' ORDER BY Next_FollowUp_Time__c ASC LIMIT 50000';
        }
        
        System.debug('soqlQuery:: ' + soqlQuery);
        List<Order__c> orderList = Database.query(soqlQuery);
        System.debug('soqlQuery:: ' + orderList.size());
        return JSON.serialize(orderList);
    }
    
    @AuraEnabled
    public static String updateOrderDetails(String orderDetails)
    {
        String result;
        Map<String,Object> orderDetailsMap = (Map<String,Object>) JSON.DeserializeUntyped(orderDetails);
        
        List<Order__c> orderList = [SELECT Id,Name,Status__c,isVerified__c,Order_Delivery_Status__c,Total_Price__c,Grand_Total__c,Order_Amount__c,
                                    Account__r.name,Account__r.Phone__c,Billing_Street__c,Billing_City__c,Billing_State__c,Billing_PostalCode__c,Billing_Country__c,
                                    Shipping_Street__c,Shipping_City__c,Shipping_State__c,Shipping_PostalCode__c,Shipping_Country__c FROM Order__c where Id =:String.valueOf(orderDetailsMap.get('Id')) ];
        
        if(orderList.Size() > 0)
        {
            for(Order__c updateOrder : orderList)
            {
                updateOrder.Call__c = String.valueOf(orderDetailsMap.get('Call__c'));
                //update billing address
                updateOrder.Billing_Street__c = String.valueOf(orderDetailsMap.get('Billing_Street__c'));
                updateOrder.Billing_City__c = String.valueOf(orderDetailsMap.get('Billing_City__c'));
                updateOrder.Billing_State__c = String.valueOf(orderDetailsMap.get('Billing_State__c'));
                updateOrder.Billing_PostalCode__c = String.valueOf(orderDetailsMap.get('Billing_PostalCode__c'));
                updateOrder.Billing_Country__c = String.valueOf(orderDetailsMap.get('Billing_Country__c'));
                
                //update Shipping address
                updateOrder.Shipping_Street__c = String.valueOf(orderDetailsMap.get('Shipping_Street__c'));
                updateOrder.Shipping_City__c = String.valueOf(orderDetailsMap.get('Shipping_City__c'));
                updateOrder.Shipping_State__c = String.valueOf(orderDetailsMap.get('Shipping_State__c'));
                updateOrder.Shipping_PostalCode__c = String.valueOf(orderDetailsMap.get('Shipping_PostalCode__c'));
                updateOrder.Shipping_Country__c = String.valueOf(orderDetailsMap.get('Shipping_Country__c'));
                
            }
            
            //update orderList;
            Database.SaveResult [] updateResult = Database.update(orderList, false);
            for (Database.SaveResult r : updateResult)
            {
                if (r.isSuccess())
                {
                    result = 'Order has been Updated';
                }
                else
                {
                    for (Database.Error e : r.getErrors())
                    {
                        result = e.getMessage() ;
                    }
                }
            }
        }
        return result;
    }
    
    @AuraEnabled
    public static String verifiedOrder(String orderDetails)
    {
        String result;
        System.debug('@@orderDetails:: '+orderDetails);
        Map<String,Object> orderDetailsMap = (Map<String,Object>) JSON.DeserializeUntyped(orderDetails);
        
        List<Order__c> orderList = [SELECT Id,Name,Status__c,FollowUp_Stage__c,isVerified__c,Order_Delivery_Status__c,Total_Price__c,Grand_Total__c,Order_Amount__c,
                                    Account__r.name,Account__r.Phone__c,Billing_Street__c,Billing_City__c,Billing_State__c,Billing_PostalCode__c,Billing_Country__c,
                                    Shipping_Street__c,Shipping_City__c,Shipping_State__c,Shipping_PostalCode__c,Shipping_Country__c FROM Order__c where Id =:String.valueOf(orderDetailsMap.get('Id')) ];
        
        if(orderList.Size() > 0)
        {
            for(Order__c updateOrder : orderList)
            {
                updateOrder.isVerified__c = true;
                updateOrder.FollowUp_Stage__c = 'Verified';
            }
            //delete followup
            List<Order_Follow_Up__c> latestfollowupItem = [SELECT Id,Order__c,FollowUp_Stage__c,Actual_Follow_Up_Time__c,Expected_Follow_Up_Time__c,Status__c,Comment__c,Follow_Up_Order__c FROM Order_Follow_Up__c Where Order__c =:String.valueOf(orderDetailsMap.get('Id')) and Comment__c ='' and FollowUp_Stage__c = 'Manifest' order by createddate desc LIMIT 1];
            if(latestfollowupItem.size()>0){
                delete latestfollowupItem[0];
            }
            //update orderList;
            Database.SaveResult [] updateResult = Database.update(orderList, false);
            for (Database.SaveResult r : updateResult)
            {
                if (r.isSuccess())
                {
                    result = 'Order has been successfuly Verified';
                }
                else
                {
                    for (Database.Error e : r.getErrors())
                    {
                        result = e.getMessage() ;
                    }
                }
            }
        }
        return result;
    }
    
    @AuraEnabled
    public static String orderItemList(String OrderId)
    {
        List<Order_Item__c> orderItemList = [SELECT Id,Order__c, Product_Name__c, Subtotal_Price__c, Discounts__c, Order_Item_ID__c,
                                             Weight_gm__c, Quantity__c, Vendor__c, Tax_Price__c, List_Price__c, SKU__c, Product_Id__c FROM Order_Item__c Where Order__c =:OrderId  LIMIT 50000];
        
        return JSON.serialize(orderItemList);
    }
    @AuraEnabled
    public static String followupItemsList(String OrderId)
    {
        List<Order_Follow_Up__c> followupItemsList = [SELECT Id,Order__c,FollowUp_Stage__c,Actual_Follow_Up_Time__c,Expected_Follow_Up_Time__c,Status__c,Comment__c,Follow_Up_Order__c FROM Order_Follow_Up__c Where Order__c =:OrderId order by createddate desc LIMIT 50000];
        
        return JSON.serialize(followupItemsList);
    }
    @AuraEnabled
    public static String latestfollowupItem(String OrderId)
    {
        Order_Follow_Up__c latestfollowupItem = new Order_Follow_Up__c();        
        List<Order_Follow_Up__c> latestfollowupItemList = [SELECT Id,Order__c,FollowUp_Stage__c,Actual_Follow_Up_Time__c,Expected_Follow_Up_Time__c,Status__c,Comment__c,Follow_Up_Order__c FROM Order_Follow_Up__c Where Order__c =:OrderId order by createddate desc LIMIT 1];
        if(latestfollowupItemList.size() > 0)
        {
            return JSON.serialize(latestfollowupItemList[0]);
        }else{
            return null;    
        }
        
        
    }
    
    @AuraEnabled
    public static String UpdateFollowUpIsVerified(string folloupItemdetail,String nextFollowUpTime,Boolean intialComment)
    {
        String result;
        nextFollowUpTime = nextFollowUpTime.substring(0, nextFollowUpTime.length() - 9).replace('T', ' ');
        datetime followuptime = DateTime.valueOfGmt(nextFollowUpTime);
        Order_Follow_Up__c latestFU = (Order_Follow_Up__c)System.JSON.deserialize(folloupItemdetail, Order_Follow_Up__c.class);
        if(!intialComment){          
            Order_Follow_Up__c latestfollowupItem = [SELECT Id,Order__c,FollowUp_Stage__c,Order__r.Order_Delivery_Status__c,Actual_Follow_Up_Time__c,Expected_Follow_Up_Time__c,Status__c,Comment__c,Follow_Up_Order__c FROM Order_Follow_Up__c Where Id =:latestFU.Id order by createddate desc LIMIT 1];
            latestfollowupItem.Actual_Follow_Up_Time__c = system.Datetime.now();
            latestfollowupItem.Comment__c = latestFU.Comment__c;
            latestfollowupItem.Status__c = 'On Time';
            update  latestfollowupItem;
            
            Order__c initialfollowup = [SELECT Id,Initial_FollowUp_Comment__c,FollowUp_Stage__c,Next_FollowUp_Time__c FROM Order__c where Id =: latestFU.Order__c limit 1];  
            initialfollowup.Initial_FollowUp_Comment__c = latestFU.Comment__c;
            initialfollowup.Next_FollowUp_Time__c = followuptime;
            update  initialfollowup;
        }
        else{
            Order__c initialfollowup = [SELECT Id,Initial_FollowUp_Comment__c,FollowUp_Stage__c,Next_FollowUp_Time__c FROM Order__c where Id =: latestFU.Order__c limit 1];  
            initialfollowup.Initial_FollowUp_Comment__c = latestFU.Comment__c;
            initialfollowup.Next_FollowUp_Time__c = followuptime;
            update  initialfollowup;
        }
        return result;
    }
    
    @AuraEnabled
    public static String UpdateFollowUp(string folloupItemdetail)
    {
        String result;
        system.debug('folloupItemdetail: '+folloupItemdetail);
        //Update Current FollowUp Step
        Order_Follow_Up__c latestFU = (Order_Follow_Up__c)System.JSON.deserialize(folloupItemdetail, Order_Follow_Up__c.class);
        Order_Follow_Up__c latestfollowupItem = [SELECT Id,Order__c,Order__r.Order_Delivery_Status__c,Actual_Follow_Up_Time__c,Expected_Follow_Up_Time__c,Status__c,Comment__c,Follow_Up_Order__c FROM Order_Follow_Up__c Where Id =:latestFU.Id order by createddate desc LIMIT 1];
        latestfollowupItem.Actual_Follow_Up_Time__c = system.Datetime.now();
        latestfollowupItem.Comment__c = latestFU.Comment__c;
        if(latestfollowupItem.Expected_Follow_Up_Time__c< latestfollowupItem.Actual_Follow_Up_Time__c){
            latestfollowupItem.Status__c = 'Delayed';
        }
        else{
            latestfollowupItem.Status__c = 'On Time';
        }
        update  latestfollowupItem;
        
        //create Next FollowUp Step
        Order_Follow_Up__c obj = new Order_Follow_Up__c();
        obj.Order__c = latestfollowupItem.Order__c;
        datetime followuptime = null;        
        obj.Expected_Follow_Up_Time__c = followuptime;
        obj.Follow_Up_Order__c =  latestfollowupItem.Follow_Up_Order__c + 1;
        obj.Status__c = 'Pending';
        insert obj;
        result = latestfollowupItem.Status__c;
        return result;
    }
    
    @AuraEnabled
    public static String getAllfollowupByStatus(String OrderStatus)
    {
        List<Order_Follow_Up__c> getAllfollowupByStatus = [SELECT Id,Order__c,Order__r.Name,Actual_Follow_Up_Time__c,Expected_Follow_Up_Time__c,Status__c,Comment__c,Follow_Up_Order__c FROM Order_Follow_Up__c Where (Order__r.Order_Delivery_Status__c =:OrderStatus AND Comment__c = NULL AND Expected_Follow_Up_Time__c <= TODAY) order by createddate LIMIT 50000];
        return JSON.serialize(getAllfollowupByStatus);
    }
    
    @AuraEnabled
    public static String getnewOrderList(String orderId)
    {
        Map<String,Object> returnMap = new Map<String,Object>();
        List<Order__c> setOrderList = new  List<Order__c>();     
        returnMap.put('currentStage','');
        returnMap.put('orderList',setOrderList);
        if(String.isNotBlank(orderId) && orderId != null){
            returnMap.put('currentStage','');
            setOrderList = selectedOrderDetails(orderId);
            returnMap.put('orderList',setOrderList);
        }
        else{
            setOrderList = orderListOnPriorities('Manifest');
            if(setOrderList.size() > 0){
                returnMap.put('currentStage','Manifest');
                returnMap.put('orderList',setOrderList);           
            }
            else{
                setOrderList = orderListOnPriorities('NDR');
                if(setOrderList.size() > 0){
                    returnMap.put('currentStage','NDR');
                    returnMap.put('orderList',setOrderList);
                }
                else{
                    setOrderList = orderListOnPriorities('Out for Delivery');
                    if(setOrderList.size() > 0){
                        returnMap.put('currentStage','Out for Delivery');
                        returnMap.put('orderList',setOrderList);            
                    }
                    else{      
                        setOrderList = orderListOnPriorities('Abandoned');
                        if(setOrderList.size() > 0){
                            returnMap.put('currentStage','Abandoned');
                            returnMap.put('orderList',setOrderList);    
                        }
                        else{
                            setOrderList = orderListOnPriorities('RTO');
                            if(setOrderList.size() > 0){
                                returnMap.put('currentStage','RTO');
                                returnMap.put('orderList',setOrderList);
                            }
                        }
                    }
                }            
            }
        }
        return JSON.serialize(returnMap);
    }
    
    @AuraEnabled
    public static List<Order__c> orderListOnPriorities(String deliveryStatus)
    {
        String userId = UserInfo.getUserId();
        DateTime currentTimeMinusOneMinute = System.now();
        
        List<String> orderIds = new List<String>();
        for(Order_Follow_Up__c todayFUOnly : [SELECT Id, Order__c, FollowUp_Stage__c, Actual_Follow_Up_Time__c, Expected_Follow_Up_Time__c, Status__c, Comment__c, Follow_Up_Order__c 
                                              FROM Order_Follow_Up__c 
                                              WHERE (Comment__c = null OR Comment__c = '') 
                                              AND Expected_Follow_Up_Time__c <= :currentTimeMinusOneMinute
                                              AND Status__c = 'Pending'
                                              //AND Expected_Follow_Up_Time__c <= today  
                                              ORDER BY CreatedDate DESC 
                                              LIMIT 50000]) {
                                                  orderIds.add(todayFUOnly.Order__c); 
                                              }	
        List<Order__c> getInitialOrderList = [SELECT Id,CreatedDate, Name, Status__c, Payment_Status__c,Call__c, isVerified__c, Order_Delivery_Status__c,
                                              (SELECT Id, Status__c, Comment__c FROM Order_Follow_Ups__r), Next_FollowUp_Time__c,FollowUp_Stage__c, 
                                              Total_Price__c, Grand_Total__c, Order_Amount__c, Account__r.Name, Account__r.Phone__c, 
                                              Billing_Street__c, Billing_City__c, Billing_State__c, Billing_PostalCode__c, Billing_Country__c, 
                                              Shipping_Street__c, Shipping_City__c, Shipping_State__c, Shipping_PostalCode__c, Shipping_Country__c
                                              FROM Order__c where Account__c !=null AND ownerId =: userId
                                              AND isVerified__c != true AND Initial_FollowUp_Comment__c = null
                                              ORDER BY CreatedDate DESC LIMIT 1];
        
        List<Order__c> getFollowUpOrderList = [SELECT Id,CreatedDate, Name, Status__c,FollowUp_Stage__c,Payment_Status__c,Call__c, isVerified__c, Order_Delivery_Status__c, 
                                               Total_Price__c, Grand_Total__c, Order_Amount__c, Account__r.Name, Account__r.Phone__c, Next_FollowUp_Time__c, 
                                               Billing_Street__c, Billing_City__c, Billing_State__c, Billing_PostalCode__c, Billing_Country__c, 
                                               Shipping_Street__c, Shipping_City__c, Shipping_State__c, Shipping_PostalCode__c, Shipping_Country__c
                                               FROM Order__c where Id In : orderIds AND Account__c !=null AND ownerId =: userId
                                               AND FollowUp_Stage__c=:deliveryStatus ORDER BY CreatedDate DESC LIMIT 1];   
        
        List<Order__c> getOrderList = new List<Order__c>();    
        
        if(getInitialOrderList.Size() > 0){    
            for(Order__c getOrder: getInitialOrderList)
            {
                if (getOrder.Order_Follow_Ups__r.isEmpty()) 
                {
                    getOrderList.add(getOrder);
                }else{
                    getOrderList.addAll(getFollowUpOrderList);
                }
                
            } 
        }
        else{
            getOrderList.addAll(getFollowUpOrderList);
        }
        
        return getOrderList;
    } 
    
    public static List<Order__c> selectedOrderDetails(String orderId)
    {
        
        return [SELECT Id,CreatedDate, Name, Status__c,FollowUp_Stage__c,Payment_Status__c,Call__c, isVerified__c, Order_Delivery_Status__c, 
                Total_Price__c, Grand_Total__c, Order_Amount__c, Account__r.Name, Account__r.Phone__c, Next_FollowUp_Time__c, 
                Billing_Street__c, Billing_City__c, Billing_State__c, Billing_PostalCode__c, Billing_Country__c, 
                Shipping_Street__c, Shipping_City__c, Shipping_State__c, Shipping_PostalCode__c, Shipping_Country__c
                FROM Order__c where Id =: orderId LIMIT 1];
    }
    
    //For status change on click of Voided Button
    @AuraEnabled
    public static void voidOrder(Id orderId) {
        List<Order__c> orderList = [SELECT Id, Status__c, FollowUp_Stage__c FROM Order__c WHERE Id = :orderId];
        List<Order__c> updOrdLst = new List<Order__c>();
        if (orderList.Size() > 0) {
            for(Order__c ord : orderList){
                ord.Status__c = 'Voided';
                ord.FollowUp_Stage__c = 'No Stage';
                updOrdLst.add(ord);
            }
            update orderList;
        }
    }
}