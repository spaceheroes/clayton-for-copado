@isTest
public class TestDataFactory {

    public static clayton__ClaytonSettings__c createClaytonSettingsWithAccountProjectAndWebhookSecret(final String accountId, final String projectId, final String secretKey) {
        clayton__ClaytonSettings__c customSettings = new clayton__ClaytonSettings__c();
        customSettings.clayton__AccountId__c = accountId;
        customSettings.clayton__ProjectId__c = projectId;
        customSettings.clayton__WebhookSecret__c = secretKey;
        insert customSettings;
        return customSettings;
    }

}