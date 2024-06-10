public class CDL_AccountTriggerHandler 
{
   public static void beforeInsert(List<Account> accountList)
    {
     /*   String setOwnerId;
        Map<String,Object> outputMap = (Map<String,Object>) JSON.deserializeUntyped(CDL_AssignOwner.setSobjectOwner('Account'));
        Map<String,Object> availableUserId = (Map<String,Object>) outputMap.get('availableUserId');
        Map<String,Object> ownerIdCount = (Map<String,Object>) outputMap.get('ownerIdCount');
        
        for(Account currentAccount : accountList)
        {
            setOwnerId = CDL_AssignOwner.selectOwnerId(availableUserId,ownerIdCount);
            if(String.isNotBlank(setOwnerId)){
                currentAccount.OwnerId = setOwnerId;
                Integer recordCount = Integer.valueOf(ownerIdCount.get(setOwnerId)) + 1;
                ownerIdCount.put(setOwnerId,recordCount);
            }
        }*/ 
    }      
    
}