public class CDL_OrderNotes {
    
    @AuraEnabled
    public static String getOrderNotes(String recordId)
    {
       String Notes = '';
        for(Order__c getNotes: [Select Id,Note__c From Order__c Where Id =:recordId Limit 1])
        {      
            	Notes = getNotes.Note__c+'\n\n';
   				/*List<String> lines = getNotes.Note__c.split('\n');
    			Notes = '';
                for (String line : lines) 
                {                   
                    line = line.trim();                    
                    Notes += line + '\\n';
                }
        	System.debug('Concatenated Note: ' + Notes);*/
        }       
        return Notes;
    }
    
    @AuraEnabled
    public static String addNotes(String recordId,String addNotes)
    {
     	System.debug('comming notes'+addNotes);	
        Id userId =UserInfo.getUserId(); 
		String currentUserName = [SELECT Name FROM User WHERE Id =: userId].Name;
        List<Order__c> orderList = [Select Id,Note__c From Order__c Where Id =:recordId Limit 1];
        for(Order__c getNotes: orderList)
        { 
            String Notes;
            if(getNotes.Note__c != null)
            {
                Notes = getNotes.Note__c+'\n\n'+'Comments: '+addNotes+'\n'+'User: '+currentUserName+' '+'Time: '+DateTime.now().format('yyyy-MM-dd hh:mm:ss a');//DateTime.Now();
            }else
            {            	
				Notes = 'Comments: '+addNotes+'\n'+'User: '+currentUserName+' '+'Time: '+DateTime.now().format('yyyy-MM-dd hh:mm:ss a');//DateTime.Now();
            }
            getNotes.Note__c = Notes;
            System.debug('@@getNotes.Note__c:: '+getNotes.Note__c);
        }
        
        update orderList;
        return null;
    }
    @AuraEnabled
    public static String AttachmentList(String OrderId)
    {
        set<Id> orderitemIds = new Set<Id>();
        LIst<Order_Item__c> lstOrderItem = [select id from Order_Item__c where Order__c =: OrderId];
        if(lstOrderItem.size()>0){
            for(Order_Item__c l : lstOrderItem){
               orderitemIds.add(l.Id); 
            }
        }
        List<Attachment> AttachmentList = [select Id, ParentId, Name from Attachment  where ParentId  In : orderitemIds LIMIT 50000];

        return JSON.serialize(AttachmentList);
    }
}