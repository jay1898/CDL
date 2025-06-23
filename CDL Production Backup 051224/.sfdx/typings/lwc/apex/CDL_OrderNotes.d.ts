declare module "@salesforce/apex/CDL_OrderNotes.getOrderNotes" {
  export default function getOrderNotes(param: {recordId: any}): Promise<any>;
}
declare module "@salesforce/apex/CDL_OrderNotes.addNotes" {
  export default function addNotes(param: {recordId: any, addNotes: any}): Promise<any>;
}
declare module "@salesforce/apex/CDL_OrderNotes.AttachmentList" {
  export default function AttachmentList(param: {OrderId: any}): Promise<any>;
}
