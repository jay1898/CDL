declare module "@salesforce/apex/CDL_LeaveManagement.getUserList" {
  export default function getUserList(): Promise<any>;
}
declare module "@salesforce/apex/CDL_LeaveManagement.updateUserStatus" {
  export default function updateUserStatus(param: {userId: any, leaveStatus: any}): Promise<any>;
}
declare module "@salesforce/apex/CDL_LeaveManagement.getUserOrderList" {
  export default function getUserOrderList(param: {userId: any}): Promise<any>;
}
declare module "@salesforce/apex/CDL_LeaveManagement.updateOrderOwner" {
  export default function updateOrderOwner(param: {orderList: any}): Promise<any>;
}
