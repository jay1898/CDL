@isTest
public class CDL_AccountTriggerHandlerTest 
{
	static testMethod void updateAccountOwner() 
    {
    	account createAccount = new Account();
        createAccount.Name = 'test Account 1';
        Insert createAccount;
        
        account createAccount2 = new Account();
        createAccount2.Name = 'test Account 2';
        Insert createAccount2;
        System.assertNotEquals(null,createAccount.Id);
    }
}