declare module "@salesforce/apex/CDL_LeadManagement.getOrderLit" {
  export default function getOrderLit(param: {orderStatus: any, orderDays: any}): Promise<any>;
}
declare module "@salesforce/apex/CDL_LeadManagement.updateOrderDetails" {
  export default function updateOrderDetails(param: {orderDetails: any}): Promise<any>;
}
declare module "@salesforce/apex/CDL_LeadManagement.verifiedOrder" {
  export default function verifiedOrder(param: {orderDetails: any}): Promise<any>;
}
declare module "@salesforce/apex/CDL_LeadManagement.orderItemList" {
  export default function orderItemList(param: {OrderId: any}): Promise<any>;
}
declare module "@salesforce/apex/CDL_LeadManagement.followupItemsList" {
  export default function followupItemsList(param: {OrderId: any}): Promise<any>;
}
declare module "@salesforce/apex/CDL_LeadManagement.latestfollowupItem" {
  export default function latestfollowupItem(param: {OrderId: any}): Promise<any>;
}
declare module "@salesforce/apex/CDL_LeadManagement.UpdateFollowUpIsVerified" {
  export default function UpdateFollowUpIsVerified(param: {folloupItemdetail: any, nextFollowUpTime: any, intialComment: any}): Promise<any>;
}
declare module "@salesforce/apex/CDL_LeadManagement.UpdateFollowUp" {
  export default function UpdateFollowUp(param: {folloupItemdetail: any}): Promise<any>;
}
declare module "@salesforce/apex/CDL_LeadManagement.getAllfollowupByStatus" {
  export default function getAllfollowupByStatus(param: {OrderStatus: any}): Promise<any>;
}
declare module "@salesforce/apex/CDL_LeadManagement.getnewOrderList" {
  export default function getnewOrderList(param: {orderId: any}): Promise<any>;
}
declare module "@salesforce/apex/CDL_LeadManagement.orderListOnPriorities" {
  export default function orderListOnPriorities(param: {deliveryStatus: any}): Promise<any>;
}
declare module "@salesforce/apex/CDL_LeadManagement.voidOrder" {
  export default function voidOrder(param: {orderId: any}): Promise<any>;
}
