@isTest
public class TestDataFactory {

    public static clayton__ClaytonSettings__c createClaytonSettingsWithAccountProjectAndWebhookSecret(final String accountId, final String projectId, final String webhookSecret) {
        clayton__ClaytonSettings__c customSettings = new clayton__ClaytonSettings__c();
        customSettings.clayton__AccountId__c = accountId;
        customSettings.clayton__ProjectId__c = projectId;
        customSettings.clayton__WebhookSecret__c = webhookSecret;
        insert customSettings;
        return customSettings;
    }

    public static clayton__ClaytonSettings__c createClaytonSettingsWithAccountProject(final String accountId, final String projectId) {
        clayton__ClaytonSettings__c customSettings = new clayton__ClaytonSettings__c();
        customSettings.clayton__AccountId__c = accountId;
        customSettings.clayton__ProjectId__c = projectId;
        insert customSettings;
        return customSettings;
    }

    public static clayton__ClaytonSettings__c createClaytonSettingsWithAccountProjectAndTargetBranch(final String accountId, final String projectId, final String targetBranch) {
        clayton__ClaytonSettings__c customSettings = new clayton__ClaytonSettings__c();
        customSettings.clayton__AccountId__c = accountId;
        customSettings.clayton__ProjectId__c = projectId;
        customSettings.clayton__TargetBranch__c = targetBranch;
        insert customSettings;
        return customSettings;
    }

    public static copado__Project__c createCopadoProject(final String projectId) {
        copado__Project__c project = new copado__Project__c();
        project.Clayton_Project_Id__c = projectId;
        insert project;
        return project;
    }

    public static copado__User_Story__c createCopadoUserStoryWithProject(final copado__Project__c project){
        copado__User_Story__c userStory = new copado__User_Story__c();
        userStory.copado__Project__c = project.Id;
        insert userStory;
        return userStory;
    }

    public static copado__User_Story__c createCopadoUserStoryWithBaseBranch(final String baseBranch){
        copado__User_Story__c userStory = new copado__User_Story__c();
        userStory.copado__Base_Branch__c = baseBranch;
        insert userStory;
        return userStory;
    }

    public static copado__Result__c createCopadoResult(final copado__User_Story__c userStory, final String pullRequestId){
        copado__Result__c result = new copado__Result__c();
        result.copado__User_Story__c=userStory.Id;
        result.copado__Job_Id__c = pullRequestId;
        result.copado__Job_Type__c = 'Clayton Scan';
        result.copado__Description__c = 'Clayton Scan';
        result.copado__Status__c = 'In Progress';
        insert result;
        return result;
    }
 
}