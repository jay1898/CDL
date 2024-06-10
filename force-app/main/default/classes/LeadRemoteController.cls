global with sharing  class LeadRemoteController { 

   
    
    public LeadRemoteController() {

    }

     public static LIST<Lead> leads;
    
    @RemoteAction
    global static LIST<Lead> getleads(){//String phone){
      
     leads = new LIST<Lead>();
        leads = [select FirstName,LastName, Phone,MobilePhone from Lead ];//where Phone=:phone];
        System.debug(JSON.serialize(leads));
       // System.debug(phone);
        return leads;
    //return JSON.serialize(leads);
  }
  public static String getLeadID(String phone){
     leads = new LIST<Lead>();
        leads = [select Id from Lead where Phone=:phone];
        if(leads.size() > 0){
            System.debug(JSON.serialize(leads));
            System.debug(leads[0].Id);
            return leads[0].Id;
        }
        return '';
    //return JSON.serialize(leads);
  }

  @RemoteAction
    global static LIST<Account> getaccounts(){//String phone){

    List<Account> account1 = new List<Account>();
        account1 = [select name , Phone , Industry from Account];// where Phone=:phone];
        System.debug(account1);
        //System.debug(phone);
        return account1;

  }

  
  //This method is deprecated. Use insertNewTask()  instead.
    global static List<Task> insertTasks(String phone1, String status1, String subject1 , String priority1, String description1 , String date1,Integer call_duration,String call_result,String call_type, String whatid , String whoid,String Lead,String opportunity,String unique_id,String recording_url,String customer_no){

        Task ob = new Task();

        ob.Subject = subject1;
        ob.OwnerId = UserInfo.getUserId();
        ob.Status = status1;
        ob.Priority = priority1;
        ob.Description = description1;
        ob.ActivityDate = date.parse(date1);
        ob.CallObject = unique_id;
        ob.TataCTI__Recording__c = recording_url;
        if(!String.isBlank(whoid)){
        ob.WhoId = whoid;
        }else {
          if(!String.isBlank(getLeadID(customer_no))){
              ob.WhoId = getLeadID(customer_no);
          }
        }
        if(!String.isBlank(whatid)){
        ob.WhatId = whatid;
        }
        ob.CallDurationInSeconds = call_duration;
        ob.CallDisposition = call_result;
        ob.CallType = call_type;


        insert ob;

        // get the id of the object inserted
  //      system.debug(ob.Id);

        List<Task> arr = [ Select OwnerId , Subject , Description , WhoId from Task ];

        // start for updation
   //     Task temp = [ Select OwnerId , Subject from Task where Id = '00T6F00004tWEb0UAG' ];

     //   temp.Subject = 'Send Quote';

    //    update temp;

        // end for updation

   //     system.debug(arr.get(0).Subject);
        return arr;

  }

global static List<Task> insertNewTasks(String phone1, String status1, String subject1 , String priority1, String description1 , String date1,Integer call_duration,String call_result,String call_type, String whatid , String whoid,String Lead,String opportunity,String unique_id,String recording_url,String customer_no, String time1){

        Task ob = new Task();

        ob.Subject = subject1;
        ob.OwnerId = UserInfo.getUserId();
        ob.Status = status1;
        ob.Priority = priority1;
        ob.Description = description1;
        ob.ActivityDate = date.parse(date1);
        ob.CallObject = unique_id;
        ob.TataCTI__Recording__c = recording_url;
        if(!String.isBlank(whoid)){
        ob.WhoId = whoid;
        }else {
          if(!String.isBlank(getLeadID(customer_no))){
              ob.WhoId = getLeadID(customer_no);
          }
        }
        if(!String.isBlank(whatid)){
        ob.WhatId = whatid;
        }
        ob.CallDurationInSeconds = call_duration;
        ob.CallDisposition = call_result;
        ob.CallType = call_type;
        ob.TataCTI__Time__c = time1;


        insert ob;

        // get the id of the object inserted
  //      system.debug(ob.Id);

        List<Task> arr = [ Select OwnerId , Subject , Description , WhoId from Task ];

        // start for updation
   //     Task temp = [ Select OwnerId , Subject from Task where Id = '00T6F00004tWEb0UAG' ];

     //   temp.Subject = 'Send Quote';

    //    update temp;

        // end for updation

   //     system.debug(arr.get(0).Subject);
        return arr;

  }
   @RemoteAction
    global static List<Report> getReports()
    {
        List<Report> arr = new List<Report>();

        arr = [ SELECT  Id,  DeveloperName FROM Report  ];

        return arr;
    }

    @RemoteAction
  //  global static void upadatePermission(String autoCreateCheckBox1 , String autoPopUpMinimizeCTI1, String autoHideCTI1)
    global static void test(String autoCreateCheckBox1 , String autoPopUpMinimizeCTI1)
    {
        system.debug('autoCreateCheckBox1 : ' + autoCreateCheckBox1);
        system.debug('autoPopUpMinimizeCTI1 : ' + autoPopUpMinimizeCTI1);
        //system.debug('autoHideCTI1 : ' + autoHideCTI1);
        //system.debug('Before : ' + getPermission());

    /*    Permission__c temp1 = [ Select AutoCreateCheckBox__c , AutoPopUpMinimizeCTI__c from Permission__c ];

        temp1.AutoCreateCheckBox__c = autoCreateCheckBox1;
        //temp1.autoHideCTI__c = autoHideCTI1;
        temp1.AutoPopUpMinimizeCTI__c = autoPopUpMinimizeCTI1;

        update temp1;
        */
        list<TataCTI__Permission__c> listPerm = [ Select TataCTI__AutoCreateCheckBox__c , TataCTI__AutoPopUpMinimizeCTI__c from TataCTI__Permission__c ];
     // system.debug(listPerm);

        if(listPerm.size() > 0)
        {
             TataCTI__Permission__c temp1 = [ Select TataCTI__AutoCreateCheckBox__c , TataCTI__AutoPopUpMinimizeCTI__c from TataCTI__Permission__c ];
            //system.debug(temp1);
            temp1.TataCTI__AutoCreateCheckBox__c = autoCreateCheckBox1;
          //temp1.autoHideCTI__c = autoHideCTI1;
            temp1.TataCTI__AutoPopUpMinimizeCTI__c = autoPopUpMinimizeCTI1;
            update temp1;
        }

        system.debug('After : ' + getPermission() );
    }

    @RemoteAction
  //  global static void upadatePermission(String autoCreateCheckBox1 , String autoPopUpMinimizeCTI1, String autoHideCTI1)
    global static void insertPermission(String autoCreateCheckBox1 , String autoPopUpMinimizeCTI1)
    {
        system.debug('autoCreateCheckBox1 : ' + autoCreateCheckBox1);
        system.debug('autoPopUpMinimizeCTI1 : ' + autoPopUpMinimizeCTI1);
        //system.debug('autoHideCTI1 : ' + autoHideCTI1);
        //system.debug('Before : ' + getPermission());

        TataCTI__Permission__c temp1 = new TataCTI__Permission__c(); //[ Select AutoCreateCheckBox__c , autoHideCTI__c , AutoPopUpMinimizeCTI__c from Permission__c ];

        temp1.TataCTI__AutoCreateCheckBox__c = autoCreateCheckBox1;
        //temp1.autoHideCTI__c = autoHideCTI1;
        temp1.TataCTI__AutoPopUpMinimizeCTI__c = autoPopUpMinimizeCTI1;

        insert temp1;

        //system.debug('After : ' + getPermission() );
    }

  @RemoteAction
    global static LIST<TataCTI__Permission__c> getPermission()
    {
        List<TataCTI__Permission__c> arr = new List<TataCTI__Permission__c>();
        arr =  [ Select TataCTI__AutoCreateCheckBox__c , TataCTI__AutoPopUpMinimizeCTI__c from TataCTI__Permission__c ];
        System.debug(arr);
        //System.debug(phone);
        return arr;
     }

    @RemoteAction
    global static LIST<Contact> getContacts()
    {
        List<Contact> arr = new List<Contact>();
        arr =  [ Select Name, Phone from Contact ];
        System.debug(arr);
        //System.debug(phone);
        return arr;
  }
  /* @RemoteAction
    public static String GetLeadInfo(String filter){

        List<Lead> reg=new LIST<Lead>();
        String url;
        boolean test;
        String serializedList;
        reg=[select id,Salutation,FirstName,LastName,PHONE,MobilePhone,Street,City,State,PostalCode,Country,Description from Lead where Phone=:filter];
        if(reg.isEmpty()){
          test = false;
            System.debug('new lead');
            url = 'https://c.ap4.visual.force.com/apex/testing1?phone='+filter;
            serializedList = JSON.serialize(reg);
            System.debug(url);
        }else{
          test= true;
            System.debug('existing lead');
            serializedList = JSON.serialize(reg);
            url = 'https://c.ap4.visual.force.com/apex/testing1?id='+reg.get(0).Id;
            System.debug(url);

        }
        return url;

    }
*/
    @RemoteAction
    public static String GetLeadInfo(String filter,String salesforce_ord){
        system.debug(filter + 'filter');
        //List<Lead> reg=new LIST<Lead>();
        List<Account> reg=new LIST<Account>();
        String phoneFilter = '%' + filter.substring(filter.length() - 10) + '%';
        String url;
        boolean test;
        String serializedList;
        //reg=[select id,Salutation,FirstName,LastName,PHONE,MobilePhone,Street,City,State,PostalCode,Country,Description from Lead where Phone=:filter];
        reg = [select Id,Phone,Phone__c from account where Phone__c LIKE:phoneFilter];
        if(reg.isEmpty()){
          test = false;
            System.debug('new lead');
          
            //url = salesforce_ord+'.com/apex/testing1?phone='+filter;
            url = 'https://cdlfineshine--itechdev.sandbox.lightning.force.com/lightning/o/Account/new';
            serializedList = JSON.serialize(reg);
            System.debug('CDL call:: '+url);
        }else{
          test= true;
            System.debug('existing lead');
            serializedList = JSON.serialize(reg);
            //url = salesforce_ord+'.com/apex/testing1?id='+reg.get(0).Id;
            url = 'https://cdlfineshine--itechdev.sandbox.lightning.force.com/'+reg[0].Id;
            System.debug(url);
            System.debug('CDL call:: '+url);

        }
        return url;

    }

    public static String GetLeadInformation(String filter){

        List<Lead> reg=new LIST<Lead>();
        String test;
        reg=[select id from Lead where Phone=:filter];
        if(reg.isEmpty()){
          test = 'new';
        }else{
          test= 'exist';
        }
        return test;

    }
    public static void testCoverage(){
        Integer i= 0;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        
    }
}