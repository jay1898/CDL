@isTest
public class CDL_SendEmailToShippPartnerTest {

    @isTest
    static void testCallFedExFlow() {
		Order__c createOrder = new Order__c();
        createOrder.Order_Id__c = '77801128915';
        createOrder.Name = 'Test Order';
        createOrder.Track_Id__c = '77801128915';
        createOrder.Order_Delivery_Status__c = 'IN_PROGRESS';
        createOrder.Note__c = '';
        insert createOrder;

        CDL_SendEmailToShippPartner.requests request = new CDL_SendEmailToShippPartner.requests();
        request.orderId = createOrder.Id;

        List<CDL_SendEmailToShippPartner.requests> requestList = new List<CDL_SendEmailToShippPartner.requests>{request};

        Test.startTest();
        List<CDL_SendEmailToShippPartner.responses> responsesList = CDL_SendEmailToShippPartner.callFedExFlow(requestList);
        Test.stopTest();

        System.assertEquals(1, responsesList.size(), 'Expected one response');
        CDL_SendEmailToShippPartner.responses response = responsesList[0];
        System.assertNotEquals(null, response.outputBody, 'Response body should not be null');
    }

    @isTest
    static void testReturnBody() {
    	Order__c createOrder1 = new Order__c();
        createOrder1.Order_Id__c = '77801128917';
        createOrder1.Name = 'Test Order1';
        createOrder1.Track_Id__c = '77801128917';
        createOrder1.Order_Delivery_Status__c = 'IN_PROGRESS';
        createOrder1.Note__c = '';
        insert createOrder1;

        Order_Item__c testOrderItem = new Order_Item__c(
            Order__c = createOrder1.Id,
            Product_Name__c = 'Test Product',
            Order_Item_ID__c = '12345',
            SKU__c = 'SKU123',
            Subtotal_Price__c = 100
        );
        insert testOrderItem;

        Test.startTest();
        String returnBody = CDL_SendEmailToShippPartner.returnBody(createOrder1.Id);
        Test.stopTest();

        System.assertNotEquals(null, returnBody, 'Return body should not be null');
    }
}