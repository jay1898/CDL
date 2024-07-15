@RestResource(urlMapping='/shopifyWebhook/*')
global without sharing class CDL_ShopifyCreateOrdersWebhook {
    
    @HttpPost
    global static void receiveShopifyWebhook() {
        string data = '';
        Shopify_Data__c  createResponseRecord = new Shopify_Data__c();
        try
        {
            RestRequest req = RestContext.request;
            Blob body = req.requestBody;
            system.debug(JSON.serializePretty(body.toString()));
            data = body.toString();
            System.debug('@@@data: ' + data);
            createResponseRecord.Name = 'get details for Create Order ';
            createResponseRecord.Response_Data__c  = body.toString();
            orderDetailsWrapper orderDetailsWrapper = (orderDetailsWrapper)System.JSON.deserialize(data, orderDetailsWrapper.class);
            if(orderDetailsWrapper != null){
                if(orderDetailsWrapper.Customer != null){
                    createResponseRecord.Name = 'Create Order '+ orderDetailsWrapper.order_number;
                    
                    Account a = new Account();
                    List<Account> exist = [Select Id,OwnerId,AccountNumber,Phone__c from Account Where AccountNumber =: orderDetailsWrapper.Customer.id limit 1];
                    if(exist.size()>0){
                        a = exist[0];
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
                        system.debug('a'+a);
                    }
                    if(a != null){
                        //String ownerId = [select Id,OwnerId From account where Id =: a.Id Limit 1].OwnerId;
                        Id recordTypeId = Schema.SObjectType.Order__c.getRecordTypeInfosByName().get('Confirm Order').getRecordTypeId();
                        Order__c objo = new Order__c();
                        objo.Account__c = a.Id;
                        objo.Name = orderDetailsWrapper.order_number;
                        objo.Order_Id__c = orderDetailsWrapper.id;
                        //objo.OwnerId = ownerId;
                        objo.App_Id__c = orderDetailsWrapper.app_id;
                        objo.Confirmation_Number__c = orderDetailsWrapper.confirmation_number;
                        objo.Is_Confirmed__c = orderDetailsWrapper.confirmed;
                        objo.Order_Amount__c = orderDetailsWrapper.total_price;
                        //objo.Currency_Type__c = orderDetailsWrapper.currency_Z;
                        objo.RecordTypeId = recordTypeId;
                        //objo.Order_Id__c = orderDetailsWrapper.number_Z;
                        //objo.Order_Id__c = orderDetailsWrapper.device_id;
                        objo.Status__c = 'Confirm';
                        objo.Order_Delivery_Status__c = 'Manifest';
                        objo.FollowUp_Stage__c = 'Manifest';
                        Time systemCurrentTime = DateTime.now().time();
                        objo.Next_FollowUp_Time__c=CDL_Utility.getNextFollowUpDate(DateTime.now(), 'Manifest',systemCurrentTime);
                        objo.Last_Delivery_Status_Change_Date__c=DateTime.now();
                        objo.Payment_Status__c = orderDetailsWrapper.financial_status;
                        //objo.Order_Id__c = orderDetailsWrapper.fulfillment_status;
                        objo.Note__c = orderDetailsWrapper.note;
                        objo.Source_Identifier__c = orderDetailsWrapper.source_identifier;
                        if(objo.Source_Identifier__c == 'SF Abandon Order'){
                        	objo.Abandon_Order__c = orderDetailsWrapper.source_name;
                            List<Order__c> abandonOrderList = [Select Id,IsAbandontoConfirm__c from Order__c Where Id =: orderDetailsWrapper.source_name limit 1];
                            if(abandonOrderList.size()>0){
                                Order__c abandonOrder = abandonOrderList[0];
                                abandonOrder.IsAbandontoConfirm__c = true;
                                update abandonOrder;
                            }
                        }
                        objo.Source_Name__c = orderDetailsWrapper.source_name;
                        address billingAddress = orderDetailsWrapper.billing_address;
                        address shippingAddress = orderDetailsWrapper.shipping_address;
                        if(billingAddress != null){
                            objo.Billing_City__c =  billingAddress.city;
                            objo.Billing_Country__c = billingAddress.country ;
                            objo.Billing_PostalCode__c =  billingAddress.zip ;
                            objo.Billing_State__c = billingAddress.province ;
                            objo.Billing_Street__c = billingAddress.address1;
                        }
                        else{
                            objo.Billing_Street__c =  orderDetailsWrapper.Customer.default_address.address1;
                            objo.Billing_City__c =  orderDetailsWrapper.Customer.default_address.city;
                            objo.Billing_State__c =  orderDetailsWrapper.Customer.default_address.province;
                            objo.Billing_Country__c =  orderDetailsWrapper.Customer.default_address.country;
                            objo.Billing_PostalCode__c =  orderDetailsWrapper.Customer.default_address.zip;
                        }
                        
                        if(shippingAddress != null){
                            objo.shipping_City__c =  shippingAddress.city;
                            objo.shipping_Country__c = shippingAddress.country ;
                            objo.shipping_PostalCode__c =  shippingAddress.zip ;
                            objo.shipping_State__c = shippingAddress.province ;
                            objo.shipping_Street__c = shippingAddress.address1;
                        }
                        else{
                            objo.shipping_Street__c =  orderDetailsWrapper.Customer.default_address.address1;
                            objo.shipping_City__c =  orderDetailsWrapper.Customer.default_address.city;
                            objo.shipping_State__c =  orderDetailsWrapper.Customer.default_address.province;
                            objo.shipping_Country__c =  orderDetailsWrapper.Customer.default_address.country;
                            objo.shipping_PostalCode__c =  orderDetailsWrapper.Customer.default_address.zip;
                        }
                        
                        if(orderDetailsWrapper.tax_lines.size()>0){
                            objo.Tax_Price__c = orderDetailsWrapper.tax_lines[0].price;
                            objo.Tax_Rate__c = orderDetailsWrapper.tax_lines[0].rate;
                            objo.Tax_Title__c	 = orderDetailsWrapper.tax_lines[0].title;
                        }
                        if(orderDetailsWrapper.shipping_lines.size()>0){
                            objo.Shipping_Chanrge__c = orderDetailsWrapper.shipping_lines[0].price;
                        }
                         objo.Total_Discounts__c = orderDetailsWrapper.total_discounts;
                        if(orderDetailsWrapper.line_items.size() >0 ){
                            objo.Vendor_Store__c = orderDetailsWrapper.line_items[0].vendor;
                        }
                        insert objo;
                        if(shippingAddress != null && shippingAddress.phone != null && shippingAddress.phone != ''){
                            a.Phone__c = shippingAddress.phone;
                            update a;
                        }
                        else if(a.Phone__c != null && a.Phone__c != '' && billingAddress != null && billingAddress.phone != null && billingAddress.phone != ''){
                            a.Phone__c = billingAddress.phone;                           
                            update a;
                        }
                        List<Order_Item__c> lstline = new List<Order_Item__c>();
                        //string ProList = '';
                        if(orderDetailsWrapper.line_items.size() >0 ){
                            
                            for(Line_items line : orderDetailsWrapper.line_items){
                                for(Integer i = 0; i < line.quantity; i++) {
                                    Order_Item__c objline = new Order_Item__c();
                                    //ProList +=line.name+' - SKU: ' +line.sku+ '\n';
                                    objline.Order_Item_ID__c = line.id;
                                    objline.Order__c = objo.Id;
                                    //objline.Quantity__c = line.quantity;
                                    objline.Quantity__c = 1;
                                    //objline.Order_Item_ID__c = line.gift_card;
                                    objline.Weight_gm__c = line.grams;
                                    //objline.Product_Name__c = line.name;
                                    
                                    if (line.name.contains('VVS-VS-FG')) {
                                        objline.Product_Name__c = line.name + ' / ' +'Lab-Grown';
                                        //system.debug('objline.Product_Name__c ::--->' + objline.Product_Name__c);
                                    } else {
                                        objline.Product_Name__c = line.name;
                                    }                                                                                                
                                    
                                    objline.List_Price__c = line.price;
                                    objline.SKU__c = line.sku;
                                    objline.Subtotal_Price__c = objline.List_Price__c * objline.Quantity__c;
                                    //objline.Order_Item_ID__c = line.product_exists;
                                    objline.Product_Id__c = line.product_id;
                                    //objline.Order_Item_ID__c = line.requires_shipping;
                                    objline.Discounts__c = line.total_discount;
                                    //objline.Order_Item_ID__c = line.taxable;
                                    objline.Product_Variant_Id__c = line.variant_id;
                                    objline.Vendor__c = line.vendor;
                                    //objline.Variant_Type__c = line.variant_title.contains('Yellow') ? 'Yellow': 'Silver';
                                    objline.Variant_Type__c = line.title.contains('Moissanite') ? 'Moissanite Diamond' : (line.title.contains('Silver') ? 'AD Diamond' : 'AD Diamond');
                                    
                                    // Extract Bangle Size from properties
                                    String bangleSize = null;
                                    if (line.properties != null) {
                                        for (Properties prop : line.properties) {
                                            if (prop.name == 'Bangle Size') {
                                                bangleSize = prop.value;
                                                break;
                                            }
                                        }
                                    }
                                    objline.Product_Size__c = bangleSize;
                                    lstline.add(objline);
                                }
                            }
                            insert lstline;
                            system.debug('lstline----------->'+lstline);
                        }                        
                            createTrelloCard(orderDetailsWrapper.id);
                    }
                }
                
            }
            Insert createResponseRecord;
        }
        catch(Exception ex)
        {
            createResponseRecord.Name = 'Create Order fail';
            createResponseRecord.Error_Log__c  = 'Line No: '+ex.getLineNumber()+' '+ ex.getMessage();
            Insert createResponseRecord;
            system.debug('Error'+ ex.getStackTraceString());
        }
    }
    
    private static Blob getImageDataFromUrl(String imageUrl) {
        HttpRequest request = new HttpRequest();
        request.setEndpoint(imageUrl);
        request.setMethod('GET');

        Http http = new Http();
        HttpResponse response = http.send(request);

        if (response.getStatusCode() == 200) {
            return response.getBodyAsBlob();
        }

        return null;
    }
    
    @future(callout=true)
    public static void createTrelloCard(String orderId) {
        List<Shopify_Data__c>  createResponseRecordlst = new List<Shopify_Data__c>();
        try{
            Order__c objo = new Order__c();
            List<Order__c> exist = [Select Id,Name,Trello_Card_Id__c from Order__c Where Order_Id__c =: orderId limit 1];
            if(exist.size()>0){
                objo = exist[0];
            }
            if(objo != null){
                String Key = system.Label.Trelllo_Key;
                string Token = System.Label.Trello_Token;
                //String endpointUrl = 'https://api.trello.com/1/cards?idList='+System.Label.Trello_Card_List_Id+'&name='+objo.Name+'&desc='+productList+'&key='+Key+'&token='+Token;//Board Id OsQICQy5
                
                //insert image to SF from Shopify
                List<Order_Item__c> prolst = [select id,name,Product_Name__c,Trello_Card_ID__c, SKU__c, Product_Variant_Id__c, Product_Id__c,Variant_Type__c,Product_Size__c from Order_Item__c where Order__c =: objo.Id ];
                List<Attachment> lstAttach = new List<Attachment>();
                List<Order_Item__c> orderlines = new List<Order_Item__c>();
                if(prolst.size()>0){
                    for(Order_Item__c p : prolst){
                        string trelloContent = p.Product_Name__c + ' \n SKU: '+p.SKU__c;
                        String variantType = p.Variant_Type__c;
                        //get Product Details
                        String endpointUrlP = Label.Shopify_Store_URL+'/admin/api/2023-10/products/'+p.Product_Id__c+'.json';
                        system.debug('endpointUrlP: '+endpointUrlP);
                        Http hP = new Http();
                        HttpRequest reqP = new HttpRequest();
                        reqP.setEndpoint(endpointUrlP);
                        reqP.setHeader('X-Shopify-Access-Token', System.Label.Shopify_Secret);
                        reqP.setMethod('GET');
                        HttpResponse resP = hP.send(reqP);
                        system.debug('JSON Serialize'+JSON.serialize(resP.getBody()));
                        productWrapper proData = (productWrapper)JSON.deserialize((String)resP.getBody(), productWrapper.class);
                        system.debug('proData @@'+proData);
                        if(proData != null && proData.product != null){
                            if(proData.product.product_type.contains('Nose Ring')){
                                trelloContent = trelloContent + ' \n It doesn\'t have adjustable mechanism'+' \n '+ variantType;
                            }
                            else if(proData.product.product_type.contains('Ring')){
                                trelloContent = trelloContent + ' \n It will adjustable mechanism (Inside Mechanism)  \n min size - US 5.5 max US 9'+' \n ' + variantType +' \n '+'FIERY FLAIR Metal stamp';
                            }
                            else if(proData.product.product_type.contains('Earring')){
                                trelloContent = trelloContent +  '\n FIERY FLAIR 925 '+' \n '+ variantType;
                            }
                            else if(proData.product.product_type.contains('Necklace')){
                                trelloContent = trelloContent +  '\n 16+2 inches silver chain \n Engraving - FIERY FLAIR Metal stamp'+' \n '+ variantType;
                            }
                            /*
                            else if(proData.product.product_type.contains('Bangle')){
                                trelloContent = trelloContent +  '\n 2 Anna size (50.80mm Diameter) \n FIERY FLAIR 925'+' \n '+ variantType;
                            }*/
                            
                            else if(proData.product.product_type.contains('Bangle')){
                                if (p.Product_Size__c != null) {
                                    List<String> sizeParts = p.Product_Size__c.split('_');
                                    if (sizeParts.size() == 4) {
                                        String annaSize = sizeParts[0] + '.' + sizeParts[1] + ' Anna';
                                        String diameter = sizeParts[2] + '.' + sizeParts[3] + 'mm Diameter';
                                        trelloContent = trelloContent +  '\n ' + annaSize + ' size (' + diameter + ') \n FIERY FLAIR 925' + ' \n ' + variantType;
                                    }
                                }
                            }
                            else if(proData.product.product_type.contains('Bracelet')){
                                trelloContent = trelloContent +  '\n 6+2 inch length \n FIERY FLAIR 925'+' \n '+ variantType;
                            } 
                        }
                        String endpointUrl = 'https://api.trello.com/1/cards' +
                            '?idList=' + '645ce773ea3d4e031cd7c80f' +
                            '&name=' + EncodingUtil.urlEncode('#'+objo.Name, 'UTF-8') +
                            '&desc=' + EncodingUtil.urlEncode(trelloContent, 'UTF-8') +
                            '&key=' + Key +
                            '&token=' + Token;
                        system.debug('endpointUrl: '+endpointUrl);
                        Http h = new Http();
                        HttpRequest req = new HttpRequest();
                        req.setEndpoint(endpointUrl);
                        req.setHeader('Accept', 'application/json');
                        req.setMethod('POST');
                        req.setBody('');
                        HttpResponse res = h.send(req);
                        System.debug('response data: '+res.getBody());
                        System.debug('res status code '+res.getStatusCode());
                        Map<String, Object> objJson = (Map<String, Object>)JSON.deserializeUntyped(res.getBody());
                        p.Trello_Card_ID__c = (String)objJson.get('id');
                        //get image Shopify callout
                       // String endpointUrl1 = 'https://testsfstoredata.myshopify.com/admin/api/2023-10/products/'+p.Product_Id__c+'/images.json';
                       /* String endpointUrl1 = Label.Shopify_Store_URL+'/admin/api/2023-10/products/'+p.Product_Id__c+'/images.json';
                        system.debug('endpointUrl1: '+endpointUrl1);
                        Http h1 = new Http();
                        HttpRequest req1 = new HttpRequest();
                        req1.setEndpoint(endpointUrl1);
                        req1.setHeader('X-Shopify-Access-Token', System.Label.Shopify_Secret);
                        req1.setMethod('GET');
                        HttpResponse res1 = h1.send(req1);
                          ProductImageData imageData = (ProductImageData)JSON.deserialize((String)res1.getBody(), ProductImageData.class);*/
                        if(proData.product.images != null){
                            for(ProductImage pi : proData.product.images){
                                if(pi.variant_ids != null && pi.variant_ids.size()>0){
                                    boolean isimage = false;
                                    for(long vid : pi.variant_ids){
                                        if(String.valueOf(vid) == p.Product_Variant_Id__c){
                                           isimage = true; 
                                        }
                                    }
                                    if(pi.src != null && pi.src != '' && isimage){
                                        Blob imageDatab = getImageDataFromUrl(pi.src);
                                        system.debug('imageDatab: '+imageDatab);
                                        Attachment attachment = new Attachment();
                                        attachment.Name = p.Product_Name__c+' '+pi.id; 
                                        attachment.Body = imageDatab;
                                        attachment.ContentType = 'image/png';
                                        attachment.ParentId = p.Id; 
                                        lstAttach.add(attachment);
                                        
                                        //attach image to trello callout
                                        Map<String, String> attachmentParams = new Map<String, String>();
                                        attachmentParams.put('url', pi.src); // Replace with the URL of your attachment
                                        attachmentParams.put('name', attachment.Name); // Replace with the desired attachment name
                                        
                                        //String endpointUrl = 'https://api.trello.com/1/cards?idList='+System.Label.Trello_Card_List_Id+'&name='+objo.Name+'&desc='+productList+'&key='+Key+'&token='+Token;//Board Id OsQICQy5
                                        String endpointUrlImg = 'https://api.trello.com/1/cards/'+p.Trello_Card_ID__c+'/attachments?key=' + Key +
                                            '&token=' + Token;
                                        system.debug('endpointUrlImg: '+endpointUrlImg);
                                        Http h2 = new Http();
                                        HttpRequest req2 = new HttpRequest();
                                        req2.setEndpoint(endpointUrlImg);
                                        req2.setHeader('Content-Type', 'application/json');
                                        req2.setMethod('POST');
                                        req2.setBody(JSON.serialize(attachmentParams));
                                        HttpResponse res2 = h2.send(req2);
                                        System.debug('response data 2: '+res2.getBody());
                                        System.debug('res status code 2 '+res2.getStatusCode());
                                    }
                                }
                            }
                        }
                        //System.debug('response data 1: '+res1.getBody());
                        //System.debug('res status code 1 '+res1.getStatusCode());
                        Shopify_Data__c  createResponseRecord = new Shopify_Data__c();
                        createResponseRecord.Name = 'Create Trello Card '+ OrderId;
                        createResponseRecord.Response_Data__c  = res.getBody();
                        createResponseRecord.Status__c = string.valueOf(res.getStatusCode());
                        createResponseRecordlst.add(createResponseRecord);
                        orderlines.add(p);
                    }
                }
                //update objo;
                
                if(lstAttach.size()>0){
                    insert lstAttach;
                }
                if(createResponseRecordlst.size()>0){
                    Insert createResponseRecordlst;
                }
                if(orderlines.size()>0){
                    update orderlines;
                }
            }
        }
        catch(Exception ex){
            Shopify_Data__c  createResponseRecord = new Shopify_Data__c();
            createResponseRecord.Name = 'Create Trello Card Fail';
            createResponseRecord.Error_Log__c  = 'Line No: '+ex.getLineNumber()+' '+ ex.getMessage(); 
            createResponseRecord.Status__c = ''; //string.valueOf(res.getStatusCode());
            Insert createResponseRecord;
        }
    }
    
    public class orderDetailsWrapper{
        public Customer customer {get;set;} 
        public string id {get;set;} 
        public string app_id {get;set;} 
        public string company {get;set;} 
        public String confirmation_number {get;set;} 
        public Boolean confirmed {get;set;} 
        public String financial_status {get;set;}  
        public String name {get;set;} 
        public string note {get;set;} 
        public string order_number {get;set;} 
        public String order_status_url {get;set;} 
        public String phone {get;set;} 
        public String source_identifier {get;set;} 
        public String source_name {get;set;}  
        public address billing_address {get;set;} 
        public List<Line_items> line_items {get;set;}  
        public address shipping_address {get;set;} 
        public List<Tax_lines> tax_lines {get;set;} 
        public Decimal total_price {get;set;} 
        public List<Shipping_lines> shipping_lines {get;set;} 
        public decimal total_discounts {get;set;}
    }
    public class address { 
        public String address1 {get;set;} 
        public String city {get;set;} 
        public String province {get;set;} 
        public String country {get;set;} 
        public String zip {get;set;} 
        public string phone {get;set;} 
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
        public address default_address {get;set;} 
    }
    
    public class Line_items {
        public string id {get;set;} 
        public decimal grams {get;set;} 
        public String name {get;set;} 
        public decimal price {get;set;} 
        public Boolean product_exists {get;set;} 
        public string product_id {get;set;} 
        public decimal quantity {get;set;} 
        public Boolean requires_shipping {get;set;} 
        public String sku {get;set;} 
        public Boolean taxable {get;set;}
        public decimal total_discount {get;set;} 
        public String vendor {get;set;} 
        public List<Tax_lines> tax_lines {get;set;}
        public String title {get;set;}
        public String variant_id {get;set;} 
        public String variant_title {get;set;}
        public List<Properties> properties {get;set;} //
        
    }
    public class Tax_lines {
        public decimal price {get;set;} 
        public decimal rate {get;set;} 
        public String title {get;set;}
    }
    public class Shipping_lines {
		public string id {get;set;} 
		public decimal price {get;set;} 
    }
    
    //Product Wrapper
    //
    public class ProductImage {
        public string id;
        public string product_id;
        public String src;
        public List<Long> variant_ids;
    }
    
    public class ProductImageData {
        public List<ProductImage> images;
    }
    public class productWrapper {
        public Product product;
    }
    public class Product {
		public Long id;
		public String title;
		public String product_type;
		public List<ProductImage> images;
		//public ProductImage image;
	}
    
    public class Properties{ //
        public String name{get;set;}
        public String value{get;set;}
    }
}