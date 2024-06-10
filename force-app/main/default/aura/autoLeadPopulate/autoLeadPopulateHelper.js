({
    
    doinitHelper: function(cmp, event, helper, timer) 
    {
        setTimeout($A.getCallback(function() {
        var action = cmp.get("c.getnewOrderList");
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state == 'SUCCESS') 
            {
                var result = JSON.parse(response.getReturnValue());
                if(result.orderList.length > 0) 
                {
                    console.log('Record Found');
                    helper.popupModal(cmp, event, helper,timer);
                }else{
                    helper.doinitHelper(cmp, event, helper, 900000);
                    console.log('Record Not Found');
                }
                
               
            }
        });
        $A.enqueueAction(action);
        }), timer); // 2000 milliseconds delay
    },
   
    popupModal: function(cmp, event, helper, timer) {
    // Create the LWC component dynamically
    $A.createComponent(
        "c:autoPopupNewLead", // LWC component name
        {},
        function(newComponent, status, errorMessage) {
            if (status === "SUCCESS") {
                var modalBody = [];

                // Create the combobox component dynamically
                $A.createComponent(
                    "lightning:combobox",
                    {
                        "name": "timer",
                        "label": "Snooze Time",
                        "value": timer,
                        "placeholder": "Select Timer",
                        "class": "custom-combobox",
                        "options": cmp.get("v.options"),
                        "onchange": cmp.getReference("c.handleTimerChange") 
                    },
                    function(comboboxComponent, status, errorMessage) {
                        if (status === "SUCCESS") {
                            modalBody.push(comboboxComponent); // Add combobox before LWC component
                            
                            // Create the button component dynamically
                            $A.createComponent(
                                "lightning:button",
                                {
                                    "label": "Snooze Close",
                                    "variant": "neutral",
                                    "class": "slds-m-vertical_x-small",
                                    "onclick": cmp.getReference("c.closeModal") 
                                },
                                function(buttonComponent, status, errorMessage) {
                                    if (status === "SUCCESS") {
                                        modalBody.push(buttonComponent); // Add button after combobox
                                        modalBody.push(newComponent); // Add LWC component last                                       
                                        cmp.find('overlayLib').showCustomModal({
                                            header: cmp.get("v.modalTitle"),
                                            body: modalBody,
                                            showCloseButton: true,
                                            cssClass: 'slds-modal_large',
                                            closeCallback: function() {
                                                var selectedTimer = cmp.get("v.selectedTime");
                                                console.log('on close selectedTimer', selectedTimer);
                                                
                                                helper.doinitHelper(cmp, event, helper, selectedTimer);
                                            }
                                        }).then(function (overlay) {
                                              cmp.set('v.overlayPanel', overlay);
                                            });
                                    } else {
                                        console.error("Error creating button component: " + errorMessage);
                                    }
                                }
                            );
                        } else {
                            console.error("Error creating combobox component: " + errorMessage);
                        }
                    }
                );
            } else {
                // Handle component creation error
                console.error("Error creating component: " + errorMessage);
            }
        }
    );
},

    
})