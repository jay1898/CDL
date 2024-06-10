public class CDL_GetAbandonedCheckoutsQueue implements Queueable, Database.AllowsCallouts {
    public void execute(QueueableContext context) {
        getAbandonedCheckouts();
    }
    
    public void getAbandonedCheckouts() {
        String endpointUrl = Label.Shopify_Store_URL+'/admin/api/2023-07/checkouts.json?created_at_min='+string.valueOf(system.Date.today());//https://hatton-garden.myshopify.com
        system.debug('endpointUrl: '+endpointUrl);
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint(endpointUrl);
        req.setHeader('X-Shopify-Access-Token', System.Label.Shopify_Secret);
        req.setMethod('GET');
        HttpResponse res = h.send(req);
        System.debug('response data: '+res.getBody());
        System.debug('res status code '+res.getStatusCode());
        if (res.getStatusCode() == 200) {
            orderDetailsWrapper orderDetailsWrapperLst = (orderDetailsWrapper)JSON.deserialize(string.valueOf(res.getBody()), orderDetailsWrapper.class);
            //List<Checkouts> orderDetailsWrapperLst = (List<Checkouts>)System.JSON.deserialize(JSON.serialize(res.getBody()),List<Checkouts>.class);
            for(checkouts orderDetailsWrapper : orderDetailsWrapperLst.checkouts){
                if(orderDetailsWrapper != null){
                    if(orderDetailsWrapper.Customer != null){ 
                        
                        
                        Account a = new Account();
                        List<Account> exist = [Select Id,AccountNumber,Phone__c from Account Where AccountNumber =: orderDetailsWrapper.Customer.id limit 1];
                        if(exist.size()>0){
                            a = exist[0];
                            system.debug('a--->'+a);
                        }
                        else{
                            
                            a.Name = orderDetailsWrapper.Customer.first_name + ' '+ orderDetailsWrapper.Customer.last_name;
                            a.AccountNumber = orderDetailsWrapper.Customer.id;
                            a.AccountSource = 'Other';
                            a.Email__c =  orderDetailsWrapper.Customer.email;
                            a.State__c =  orderDetailsWrapper.Customer.state;
                            a.Description =  orderDetailsWrapper.Customer.note;
                            a.Verified_Email__c =  orderDetailsWrapper.Customer.verified_email;
                            a.Phone__c =  orderDetailsWrapper.Customer.phone;
                            if(orderDetailsWrapper.Customer.default_address != null){
                                a.ShippingStreet =  orderDetailsWrapper.Customer.default_address.address1;
                                a.ShippingCity =  orderDetailsWrapper.Customer.default_address.city;
                                a.ShippingState =  orderDetailsWrapper.Customer.default_address.province;
                                a.ShippingCountry =  orderDetailsWrapper.Customer.default_address.country;
                                a.ShippingPostalCode =  orderDetailsWrapper.Customer.default_address.zip;
                                a.BillingStreet =  orderDetailsWrapper.Customer.default_address.address1;
                                a.BillingCity =  orderDetailsWrapper.Customer.default_address.city;
                                a.BillingState =  orderDetailsWrapper.Customer.default_address.province;
                                a.BillingCountry =  orderDetailsWrapper.Customer.default_address.country;
                                a.BillingPostalCode =  orderDetailsWrapper.Customer.default_address.zip;
                            }
                            insert a;
                        }
                        if(a != null){
                            Order__c objo = new Order__c();
                            List<Order__c> existOrder = [Select Id,Fulfillment_Status__c, Track_Id__c,Tracking_URL__c,Tracking_Company__c,Shipment_Status__c,Payment_Status__c from Order__c Where Order_Id__c =: orderDetailsWrapper.id limit 1];
                            if(existOrder.size()>0){
                                objo = existOrder[0];
                            }
                            else{
                                //String ownerId = [select Id,OwnerId From account where Id =: a.Id Limit 1].OwnerId;
                                //System.debug('ownerId:: '+ownerId);
                                Id recordTypeId = Schema.SObjectType.Order__c.getRecordTypeInfosByName().get('Abandoned Order').getRecordTypeId();
                                objo.Account__c = a.Id;
                                objo.Name = orderDetailsWrapper.name;
                                objo.Order_Id__c = orderDetailsWrapper.id;
                                //objo.Currency_Type__c = orderDetailsWrapper.currency_Z;
                                objo.RecordTypeId = recordTypeId;
                                objo.Order_Amount__c = orderDetailsWrapper.total_price;
                                //objo.Order_Id__c = orderDetailsWrapper.number_Z;
                                //objo.Order_Id__c = orderDetailsWrapper.device_id;
                                objo.Status__c = 'Abandoned';//orderDetailsWrapper.financial_status;
                                objo.Payment_Status__c = 'pending';
                                //objo.Order_Id__c = orderDetailsWrapper.fulfillment_status;
                                objo.Note__c = orderDetailsWrapper.note;
                                objo.Source_Identifier__c = orderDetailsWrapper.source_identifier;
                                objo.Source_Name__c = orderDetailsWrapper.source_name;
                                objo.shipping_City__c =  orderDetailsWrapper.shipping_address.city;
                                objo.shipping_Country__c = orderDetailsWrapper.shipping_address.country ;
                                objo.shipping_PostalCode__c =  orderDetailsWrapper.shipping_address.zip ;
                                objo.shipping_State__c = orderDetailsWrapper.shipping_address.province ;
                                objo.shipping_Street__c = orderDetailsWrapper.shipping_address.address1;
                                objo.abandoned_checkout_url__c = orderDetailsWrapper.abandoned_checkout_url;
                                objo.Order_Delivery_Status__c = 'Abandoned';
                                objo.FollowUp_Stage__c = 'Abandoned';
                                Time systemCurrentTime = DateTime.now().time();
                                objo.Next_FollowUp_Time__c=CDL_Utility.getNextFollowUpDate(DateTime.now(), 'Abandoned',systemCurrentTime);
                                objo.Last_Delivery_Status_Change_Date__c=DateTime.now();
                                if(orderDetailsWrapper.line_items.size() >0 ){
                                    objo.Vendor_Store__c = orderDetailsWrapper.line_items[0].vendor;
                                }
                                insert objo;
                                
                                Shopify_Data__c  createResponseRecord = new Shopify_Data__c();
                                createResponseRecord.Name = 'Create Abandoned checkouts Order '+ orderDetailsWrapper.id;
                                //createResponseRecord.Response_Data__c  = res.getBody();
                                createResponseRecord.Status__c = string.valueOf(res.getStatusCode());
                                Insert createResponseRecord; 
                                system.debug('createResponseRecord--->'+createResponseRecord);
                                
                                if(orderDetailsWrapper.shipping_address.phone != null && orderDetailsWrapper.shipping_address.phone != ''){
                                    a.Phone__c = orderDetailsWrapper.shipping_address.phone;
                                    update a;
                                }
                                List<Order_Item__c> lstline = new List<Order_Item__c>();
                                if(orderDetailsWrapper.line_items.size() >0 ){
                                    for(Line_items line : orderDetailsWrapper.line_items){
                                        Order_Item__c objline = new Order_Item__c();
                                        objline.Order_Item_ID__c = line.id;
                                        objline.Order__c = objo.Id;
                                        objline.Quantity__c = line.quantity;
                                        //objline.Order_Item_ID__c = line.gift_card;
                                        objline.Weight_gm__c = line.grams;
                                        objline.Product_Name__c = line.title;
                                        objline.List_Price__c = line.price;
                                        objline.Subtotal_Price__c = objline.List_Price__c * objline.Quantity__c;
                                        objline.SKU__c = line.sku;
                                        //objline.Order_Item_ID__c = line.product_id;
                                        //objline.Order_Item_ID__c = line.requires_shipping;
                                        objline.Discounts__c = line.total_discount;
                                        objline.Product_Variant_Id__c = line.variant_id;
                                        objline.Vendor__c = line.vendor;
                                        //tax details
                                        lstline.add(objline);
                                    }
                                    insert lstline;
                                }
                            }
                            
                        }
                    }
                }
            }
        }
        else{
            Shopify_Data__c  createResponseRecord = new Shopify_Data__c();
            createResponseRecord.Name = 'Create Abandoned checkouts Order Fail';
            createResponseRecord.Response_Data__c  = res.getBody();
            createResponseRecord.Error_Log__c  = 'not created';
            createResponseRecord.Status__c =  string.valueOf(res.getStatusCode());
            Insert createResponseRecord;
        }
        
    }
    public class orderDetailsWrapper {
        public List<Checkouts> checkouts {get;set;}
    }
    public class Checkouts {
        
        public string id {get;set;} 
        //public String token {get;set;}  
        //public String email {get;set;}   
        //public String created_at {get;set;} 
        //public String updated_at {get;set;}  
        public String note {get;set;} 
        //public Boolean taxes_included {get;set;} 
        //public Integer total_weight {get;set;} 
        //public String customer_locale {get;set;} 
        public List<Line_items> line_items {get;set;} 
        public String name {get;set;} 
        public String abandoned_checkout_url {get;set;} 
        public String source_name {get;set;}  
        public String source_identifier {get;set;}  
        public decimal total_price {get;set;} 
        //public String total_tax {get;set;} 
        //public String subtotal_price {get;set;} 
        public address shipping_address {get;set;} 
        public Customer customer {get;set;} 
        public Decimal current_total_price {get;set;} 
    }
    public class address {
        //public string id {get;set;} 
        //public string customer_id {get;set;} 
        //public String first_name {get;set;} 
        //public String last_name {get;set;} 
        //public String company {get;set;} 
        public String address1 {get;set;} 
        //public string address2 {get;set;} 
        public String city {get;set;} 
        public String province {get;set;} 
        public String country {get;set;} 
        public String zip {get;set;} 
        public string phone {get;set;} 
        //public String province_code {get;set;} 
        //public String country_code {get;set;} 
    }
    public class Customer {
        public string id {get;set;} 
        public String email {get;set;} 
        public String first_name {get;set;} 
        public String last_name {get;set;} 
        public String state {get;set;} 
        public string note {get;set;} 
        public Boolean verified_email {get;set;} 
        public String phone {get;set;} 
        //public String currency_Z {get;set;} // in json: currency
        public address default_address {get;set;} 
    }
    public class Line_items {
        public string id {get;set;} 
        //public Integer fulfillable_quantity {get;set;} 
        //public Boolean gift_card {get;set;} 
        public decimal grams {get;set;} 
        public String title {get;set;} 
        public decimal price {get;set;} 
       // public Boolean product_exists {get;set;} 
        //public string product_id {get;set;} 
        public decimal quantity {get;set;} 
       // public Boolean requires_shipping {get;set;} 
        public String sku {get;set;} 
       // public Boolean taxable {get;set;}
        public decimal total_discount {get;set;} 
        public String vendor {get;set;} 
        public String variant_id {get;set;} 
        //public List<Tax_lines> tax_lines {get;set;}  
        
    }
}