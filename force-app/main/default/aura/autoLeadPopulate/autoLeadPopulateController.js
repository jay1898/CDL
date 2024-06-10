({
    onScriptsLoaded:  function(cmp, event, helper) {
        console.log('@@ Load')
    },
     handleTimerChange: function(cmp, event, helper) {
        var selectedTimer = event.getParam("value");
         console.log('selectedTimer',selectedTimer);
         cmp.set("v.selectedTime", parseInt(selectedTimer));
    
        // You can perform any necessary logic here with the selected timer value
    },
    closeModal: function(cmp, event, helper) {
        var overlayPanel = cmp.get('v.overlayPanel');
    	overlayPanel[0].close();
         
    },
    
    onInit : function(cmp, event, helper) {
        console.log('auto-popup load');
        helper.doinitHelper(cmp, event, helper);   
        var userId = $A.get("$SObjectType.CurrentUser.Id");
     	var channel = '/event/newOrderPopup__e';
        const replayId = -1;
        
        const empApi = cmp.find("empApi");
        
        //A callback function that's invoked for every event received
        const callback = function (message) {
            var msg = message.data.payload;
            //Fire Helper to get Order Pending Order
            if(userId == msg.userId__c){
                 console.log('user id match');
            	helper.doinitHelper(cmp, event, helper);    
            }else{
                console.log('user id not match');
            }
            
        };
        // Subscribe to the channel and save the returned subscription object.
        empApi.subscribe(channel, replayId, callback).then(function(newSubscription) {
            //console.log("Subscribed to channel 1" + channel);
        });
        const errorHandler = function (message) {
            console.error("Received error ", JSON.stringify(message));
        };
        //A callback function that's called when an error response is received from the server for the handshake, connect, subscribe, and unsubscribe meta channels.
        empApi.onError(errorHandler); 
     	
    }
    
})