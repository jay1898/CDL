public class CDL_Notification {

    public static void notifyUsers(Set<String> recipientsIds, String targetId,String title,String body) {

        CustomNotificationType notificationType = [SELECT Id, DeveloperName FROM CustomNotificationType WHERE DeveloperName='CDLOrderNotification' Limit 1];
        
        Messaging.CustomNotification notification = new Messaging.CustomNotification();

        notification.setTitle(title);
        notification.setBody(body);

        notification.setNotificationTypeId(notificationType.Id);
        notification.setTargetId(targetId);
        
        try {
            notification.send(recipientsIds);
        }
        catch (Exception e) {
            System.debug('Problem sending notification: ' + e.getMessage());
        }
    }
}