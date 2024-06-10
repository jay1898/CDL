public class CDL_createTrelloCard {
    
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
                List<Order_Item__c> prolst = [select id,name,Product_Name__c,Trello_Card_ID__c, SKU__c, Product_Variant_Id__c, Product_Id__c from Order_Item__c where Order__c =: objo.Id ];
                List<Attachment> lstAttach = new List<Attachment>();
                List<Order_Item__c> orderlines = new List<Order_Item__c>();
                if(prolst.size()>0){
                    for(Order_Item__c p : prolst){
                        string trelloContent = p.Product_Name__c + ' \n SKU: '+p.SKU__c;
                        //get Product Details
                        String endpointUrlP = Label.Shopify_Store_URL+'/admin/api/2023-10/products/'+p.Product_Id__c+'.json';
                        system.debug('endpointUrlP: '+endpointUrlP);
                        Http hP = new Http();
                        HttpRequest reqP = new HttpRequest();
                        reqP.setEndpoint(endpointUrlP);
                        reqP.setHeader('X-Shopify-Access-Token', System.Label.Shopify_Secret);
                        reqP.setMethod('GET');
                        HttpResponse resP = hP.send(reqP);
                        productWrapper proData = (productWrapper)JSON.deserialize((String)resP.getBody(), productWrapper.class);
                        if(proData != null && proData.product != null){
                            if(proData.product.product_type.contains('Ring')){
                                trelloContent = trelloContent + ' \n It will adjustable mechanism (Inside Mechanism)  \n min size - US 5.5 max US 9 \n AD Diamonds \n FIERY FLAIR Metal stamp';
                            }
                            else if(proData.product.product_type.contains('Earring')){
                                trelloContent = trelloContent +  '\n FIERY FLAIR 925 \n AD Diamonds';
                            }
                            else if(proData.product.product_type.contains('Necklace')){
                                trelloContent = trelloContent +  '\n 16+2 inches silver chain \n Engraving - FIERY FLAIR Metal stamp \n AD Diamonds';
                            }
                            else if(proData.product.product_type.contains('Bangle')){
                                trelloContent = trelloContent +  '\n 2 Anna size (50.80mm Diameter) \n FIERY FLAIR 925 \n AD Diamonds';
                            }
                            else if(proData.product.product_type.contains('Bracelet')){
                                trelloContent = trelloContent +  '\n 6+2 inch length \n FIERY FLAIR 925 \n AD Diamonds';
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
        public String variant_id {get;set;} 
        public String variant_title {get;set;}
        
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
}