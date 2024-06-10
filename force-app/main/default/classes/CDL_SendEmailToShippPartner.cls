public class CDL_SendEmailToShippPartner {

    @InvocableMethod	//This InvocableMethod will be called from Flow to call FedEx API
    public static List<responses> callFedExFlow(List<requests> requestList)
    {
        List<responses> responsesList = new List<responses>();
        for(requests getRequest: requestList)
        {          
          	responses newresponse = new responses();
            System.debug('getRequest-orderId--'+getRequest.orderId);
            newresponse.outputBody = returnBody(getRequest.orderId);
            
            responsesList.add(newresponse);
        }
        
     return responsesList;    
    }
    
    public static String returnBody(String OrderId){
        List<Order__c> orderList = [Select Id,Name From Order__c Where Id=: OrderId];
       	System.debug('orderList--'+orderList);
        String returnBody = 'Order No. '+orderList[0].Name+ '\n\n'; 
        returnBody += 'Order Items: \n'; 
        /*returnBody = '<html><body><h1>order Details :'+orderList[0].Name+'</h1><p></p>';
        returnBody += '<h1>Order Items:</h1><table border="1"><tr><th>Item ID</th><th>Item Name</th><th>SKU</th></tr>';
        for(Order_Item__c orderItem : [Select Product_Name__c,Order_Item_ID__c,SKU__c From Order_Item__c Where Order__c In : orderList])
        {
            returnBody += '<tr><td>' +orderItem.Order_Item_ID__c+ '</td><td>' + orderItem.Product_Name__c + '</td><td>' + orderItem.SKU__c + '</td></tr>';
        }
        returnBody += '</table></body></html>';
        System.debug('returnBody--'+returnBody);*/
        for(Order_Item__c orderItem : [Select Product_Name__c,Order_Item_ID__c,SKU__c,Subtotal_Price__c From Order_Item__c Where Order__c In : orderList])
        {
            returnBody += orderItem.Order_Item_ID__c+ '  -  ' + orderItem.Product_Name__c + ' -  ₹'+orderItem.Subtotal_Price__c+ '\n';
        }
        
        return returnBody;
    }
    
    public class requests
    {
        @InvocableVariable(label='order Id' description='inputs')
        public String orderId;     
        
    }
    public class responses
    {
        @InvocableVariable(label='Response Body' )
        public String outputBody;
        
    }
}