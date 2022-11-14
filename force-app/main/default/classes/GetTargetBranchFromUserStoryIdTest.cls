@isTest
public class GetTargetBranchFromUserStoryIdTest {

    @isTest
    public static void testReadFromUserStory() {

        // Given
        String targetBranch = 'dev';
        clayton__ClaytonSettings__c customSettings = new clayton__ClaytonSettings__c();
        customSettings.TargetBranch__c = 'main';
        customSettings.clayton__ProjectId__c='123';
        customSettings.clayton__AccountId__c='123';
        insert customSettings;
        copado__User_Story__c userStory = new copado__User_Story__c();
        userStory.copado__Base_Branch__c = targetBranch;
        insert userStory;


        List<GetTargetBranchFromUserStoryId.Request> requests = new List<GetTargetBranchFromUserStoryId.Request>();
        GetTargetBranchFromUserStoryId.Request request = new GetTargetBranchFromUserStoryId.Request();
        request.userStoryId = userStory.Id;
        requests.add(request);

        // When
        List<GetTargetBranchFromUserStoryId.Response> responses = GetTargetBranchFromUserStoryId.GetTargetBranchFromUserStoryId(requests);

        // Then
        GetTargetBranchFromUserStoryId.Response response = responses[0];
        System.assertEquals(response.targetBranch, targetBranch, 'Target branch read from user story');
    }

    @isTest
    public static void testFallbackCustomSetting() {

        // Given
        String targetBranch = 'main';
        clayton__ClaytonSettings__c customSettings = new clayton__ClaytonSettings__c();
        customSettings.TargetBranch__c = targetBranch;
        customSettings.clayton__ProjectId__c='123';
        customSettings.clayton__AccountId__c='123';
        insert customSettings;
        copado__User_Story__c userStory = new copado__User_Story__c();
        userStory.copado__Base_Branch__c = '';
        insert userStory;


        List<GetTargetBranchFromUserStoryId.Request> requests = new List<GetTargetBranchFromUserStoryId.Request>();
        GetTargetBranchFromUserStoryId.Request request = new GetTargetBranchFromUserStoryId.Request();
        request.userStoryId = userStory.Id;
        requests.add(request);

        // When
        List<GetTargetBranchFromUserStoryId.Response> responses = GetTargetBranchFromUserStoryId.GetTargetBranchFromUserStoryId(requests);

        // Then
        GetTargetBranchFromUserStoryId.Response response = responses[0];
        System.assertEquals(response.targetBranch, targetBranch, 'Target branch read from custom settings when not available at user story level');
    }

    @isTest
    public static void testDefaultValue() {

        // Given
        String defaultTargetBranch = 'main';
        clayton__ClaytonSettings__c customSettings = new clayton__ClaytonSettings__c();
        customSettings.TargetBranch__c = '';
        customSettings.clayton__ProjectId__c='123';
        customSettings.clayton__AccountId__c='123';
        insert customSettings;
        copado__User_Story__c userStory = new copado__User_Story__c();
        userStory.copado__Base_Branch__c = '';
        insert userStory;


        List<GetTargetBranchFromUserStoryId.Request> requests = new List<GetTargetBranchFromUserStoryId.Request>();
        GetTargetBranchFromUserStoryId.Request request = new GetTargetBranchFromUserStoryId.Request();
        request.userStoryId = userStory.Id;
        requests.add(request);

        // When
        List<GetTargetBranchFromUserStoryId.Response> responses = GetTargetBranchFromUserStoryId.GetTargetBranchFromUserStoryId(requests);

        // Then
        GetTargetBranchFromUserStoryId.Response response = responses[0];
        System.assertEquals(response.targetBranch, defaultTargetBranch, 'Default Target branch when not available at custom settings and user story levels');
    }

}
