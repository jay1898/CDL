@isTest
public class CDL_GetAbandonedCheckoutsQueueTest {
    
    @isTest
    static void testGetAbandonedCheckoutsQueue() {
        Test.setMock(HttpCalloutMock.class, new MyHttpCalloutMock());
        Test.startTest();
        System.enqueueJob(new CDL_GetAbandonedCheckoutsQueue());
        Test.stopTest();
    }
    @isTest
    static void testGetAbandonedCheckoutsQueueFail() {
        Test.setMock(HttpCalloutMock.class, new MyHttpCalloutMockFail());
        try{
            Test.startTest();
            //decimal d = 1/0;
            System.enqueueJob(new CDL_GetAbandonedCheckoutsQueue());
            Test.stopTest();
        }
        catch(Exception ex){
            
        }
    }
    public class MyHttpCalloutMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            // Create a mock HTTPResponse to simulate the response
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{ "checkouts":[ { "id":31682025914423, "token":"fe0505167d52f7bb4e111691be355170", "cart_token":null, "email":"annzsuzan1998@gmail.com", "gateway":null, "buyer_accepts_marketing":false, "created_at":"2023-11-01T15:05:07+05:30", "updated_at":"2023-11-01T15:05:07+05:30", "landing_site":"/api/2022-10/graphql.json", "note":"https://fieryflair.com/cart?mrid=2f500d9e-3bd8-40a9-9cf2-51c5726eb255", "note_attributes":[ { "name":"utm_source", "value":"google" }, { "name":"utm_medium", "value":"paid" }, { "name":"utm_campaign", "value":"{campaignname}" }, { "name":"utm_content", "value":".x." }, { "name":"token", "value":"c1-b5bcfb46e8b458bad9fd9f8164757bde" } ], "referring_site":null, "shipping_lines":[ ], "taxes_included":false, "total_weight":1, "currency":"INR", "completed_at":null, "closed_at":null, "user_id":null, "location_id":null, "source_identifier":null, "source_url":null, "device_id":null, "phone":null, "customer_locale":"en-IN", "line_items":[ { "applied_discounts":[ ], "discount_allocations":[ ], "key":"cfc28525d6c87edaf990df12fe016397", "destination_location_id":3690890559543, "fulfillment_service":"manual", "gift_card":false, "grams":1, "origin_location_id":3623422394423, "presentment_title":"Center Cross Design Diamond Ring", "presentment_variant_title":"White / 14KT Gold / SI-IJ", "product_id":6791607320631, "properties":[ { "name":"Ring-Size", "value":"16" } ], "quantity":1, "requires_shipping":true, "sku":"LWLR-185", "tax_lines":[ ], "taxable":true, "title":"Center Cross Design Diamond Ring", "variant_id":40137751986231, "variant_title":"White / 14KT Gold / SI-IJ", "variant_price":"11263.00", "vendor":"FIERY FLAIR", "user_id":null, "unit_price_measurement":{ "measured_type":null, "quantity_value":null, "quantity_unit":null, "reference_value":null, "reference_unit":null }, "rank":0, "compare_at_price":"14134.00", "line_price":"11263.00", "price":"11263.00" } ], "name":"#31682025914423", "source":null, "abandoned_checkout_url":"https://hatton-garden.myshopify.com/26667253815/checkouts/fe0505167d52f7bb4e111691be355170/recover?key=b7690513423855b8153d5af432ae37f6", "discount_codes":[ ], "tax_lines":[ ], "source_name":"44930990081", "presentment_currency":"INR", "buyer_accepts_sms_marketing":false, "sms_marketing_phone":null, "total_discounts":"0.00", "total_line_items_price":"11263.00", "total_price":"11263.00", "total_tax":"0.00", "subtotal_price":"11263.00", "total_duties":null, "shipping_address":{ "first_name":"Amal", "address1":"Thadathil House Amayannoor P O Near Sree Mahadeva Temple", "phone":"7025544235", "city":"KOTTAYAM", "zip":"686019", "province":"Kerala", "country":"India", "last_name":"Nandhan", "address2":"", "company":null, "latitude":9.622494699999999, "longitude":76.6022778, "name":"Amal Nandhan", "country_code":"IN", "province_code":"KL" }, "customer":{ "id":6353252483127, "email":"annzsuzan1998@gmail.com", "accepts_marketing":true, "created_at":"2023-11-01T15:05:07+05:30", "updated_at":"2023-11-01T16:12:33+05:30", "first_name":"Amal", "last_name":"Nandhan", "orders_count":1, "state":"disabled", "total_spent":"11263.00", "last_order_id":5390695596087, "note":null, "verified_email":true, "multipass_identifier":null, "tax_exempt":false, "tags":"QuickReply.ai", "last_order_name":"#2883", "currency":"INR", "phone":"+917025544235", "accepts_marketing_updated_at":"2023-11-01T16:12:33+05:30", "marketing_opt_in_level":"single_opt_in", "tax_exemptions":[ ], "email_marketing_consent":{ "state":"subscribed", "opt_in_level":"single_opt_in", "consent_updated_at":"2023-11-01T16:12:33+05:30" }, "sms_marketing_consent":{ "state":"subscribed", "opt_in_level":"single_opt_in", "consent_updated_at":"2023-11-01T16:12:33+05:30", "consent_collected_from":"OTHER" }, "admin_graphql_api_id":"gid://shopify/Customer/6353252483127", "default_address":{ "id":7831188734007, "customer_id":6353252483127, "first_name":"Amal", "last_name":"Nandhan", "company":null, "address1":"Thadathil House Amayannoor P O Near Sree Mahadeva Temple", "address2":"", "city":"KOTTAYAM", "province":"Kerala", "country":"India", "zip":"686019", "phone":"7025544235", "name":"Amal Nandhan", "province_code":"KL", "country_code":"IN", "country_name":"India", "default":true } } } ] }');
            res.setStatusCode(200);
            return res;
        }
    }
     public class MyHttpCalloutMockFail implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            // Create a mock HTTPResponse to simulate the response
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{ "checkouts":[ { "ids":31682025914423, "token":"fe0505167d52f7bb4e111691be355170", "cart_token":null, "email":"annzsuzan1998@gmail.com", "gateway":null, "buyer_accepts_marketing":false, "created_at":"2023-11-01T15:05:07+05:30", "updated_at":"2023-11-01T15:05:07+05:30", "landing_site":"/api/2022-10/graphql.json", "note":"https://fieryflair.com/cart?mrid=2f500d9e-3bd8-40a9-9cf2-51c5726eb255", "note_attributes":[ { "name":"utm_source", "value":"google" }, { "name":"utm_medium", "value":"paid" }, { "name":"utm_campaign", "value":"{campaignname}" }, { "name":"utm_content", "value":".x." }, { "name":"token", "value":"c1-b5bcfb46e8b458bad9fd9f8164757bde" } ], "referring_site":null, "shipping_lines":[ ], "taxes_included":false, "total_weight":1, "currency":"INR", "completed_at":null, "closed_at":null, "user_id":null, "location_id":null, "source_identifier":null, "source_url":null, "device_id":null, "phone":null, "customer_locale":"en-IN", "line_items":[ { "applied_discounts":[ ], "discount_allocations":[ ], "key":"cfc28525d6c87edaf990df12fe016397", "destination_location_id":3690890559543, "fulfillment_service":"manual", "gift_card":false, "grams":1, "origin_location_id":3623422394423, "presentment_title":"Center Cross Design Diamond Ring", "presentment_variant_title":"White / 14KT Gold / SI-IJ", "product_id":6791607320631, "properties":[ { "name":"Ring-Size", "value":"16" } ], "quantity":1, "requires_shipping":true, "sku":"LWLR-185", "tax_lines":[ ], "taxable":true, "title":"Center Cross Design Diamond Ring", "variant_id":40137751986231, "variant_title":"White / 14KT Gold / SI-IJ", "variant_price":"11263.00", "vendor":"FIERY FLAIR", "user_id":null, "unit_price_measurement":{ "measured_type":null, "quantity_value":null, "quantity_unit":null, "reference_value":null, "reference_unit":null }, "rank":0, "compare_at_price":"14134.00", "line_price":"11263.00", "price":"11263.00" } ], "name":"#31682025914423", "source":null, "abandoned_checkout_url":"https://hatton-garden.myshopify.com/26667253815/checkouts/fe0505167d52f7bb4e111691be355170/recover?key=b7690513423855b8153d5af432ae37f6", "discount_codes":[ ], "tax_lines":[ ], "source_name":"44930990081", "presentment_currency":"INR", "buyer_accepts_sms_marketing":false, "sms_marketing_phone":null, "total_discounts":"0.00", "total_line_items_price":"11263.00", "total_price":"11263.00", "total_tax":"0.00", "subtotal_price":"11263.00", "total_duties":null, "shipping_address":{ "first_name":"Amal", "address1":"Thadathil House Amayannoor P O Near Sree Mahadeva Temple", "phone":"7025544235", "city":"KOTTAYAM", "zip":"686019", "province":"Kerala", "country":"India", "last_name":"Nandhan", "address2":"", "company":null, "latitude":9.622494699999999, "longitude":76.6022778, "name":"Amal Nandhan", "country_code":"IN", "province_code":"KL" }, "customer":{ "id":6353252483127, "email":"annzsuzan1998@gmail.com", "accepts_marketing":true, "created_at":"2023-11-01T15:05:07+05:30", "updated_at":"2023-11-01T16:12:33+05:30", "first_name":"Amal", "last_name":"Nandhan", "orders_count":1, "state":"disabled", "total_spent":"11263.00", "last_order_id":5390695596087, "note":null, "verified_email":true, "multipass_identifier":null, "tax_exempt":false, "tags":"QuickReply.ai", "last_order_name":"#2883", "currency":"INR", "phone":"+917025544235", "accepts_marketing_updated_at":"2023-11-01T16:12:33+05:30", "marketing_opt_in_level":"single_opt_in", "tax_exemptions":[ ], "email_marketing_consent":{ "state":"subscribed", "opt_in_level":"single_opt_in", "consent_updated_at":"2023-11-01T16:12:33+05:30" }, "sms_marketing_consent":{ "state":"subscribed", "opt_in_level":"single_opt_in", "consent_updated_at":"2023-11-01T16:12:33+05:30", "consent_collected_from":"OTHER" }, "admin_graphql_api_id":"gid://shopify/Customer/6353252483127", "default_address":{ "id":7831188734007, "customer_id":6353252483127, "first_name":"Amal", "last_name":"Nandhan", "company":null, "address1":"Thadathil House Amayannoor P O Near Sree Mahadeva Temple", "address2":"", "city":"KOTTAYAM", "province":"Kerala", "country":"India", "zip":"686019", "phone":"7025544235", "name":"Amal Nandhan", "province_code":"KL", "country_code":"IN", "country_name":"India", "default":true } } } ] }');
            res.setStatusCode(201);
            return res;
        }
    }
}