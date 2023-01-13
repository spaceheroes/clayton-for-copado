@isTest
public class GetTargetBranchFromUserStoryIdTest {

    @isTest
    public static void testReadFromUserStory() {

        // Given
        String accountId = '123';
        String projectId = '456';
        String targetBranch = 'main';
        String userStoryTargetBranch = 'dev';
        clayton__ClaytonSettings__c customSettings = TestDataFactory.createClaytonSettingsWithAccountProjectAndTargetBranch(accountId,projectId, targetBranch);
        copado__User_Story__c userStory = TestDataFactory.createCopadoUserStoryWithBaseBranch(userStoryTargetBranch);

        List<GetTargetBranchFromUserStoryId.Request> requests = new List<GetTargetBranchFromUserStoryId.Request>();
        GetTargetBranchFromUserStoryId.Request request = new GetTargetBranchFromUserStoryId.Request();
        request.userStoryId = userStory.Id;
        requests.add(request);

        // When
        List<GetTargetBranchFromUserStoryId.Response> responses = GetTargetBranchFromUserStoryId.GetTargetBranchFromUserStoryId(requests);

        // Then
        GetTargetBranchFromUserStoryId.Response response = responses[0];
        System.assertEquals(response.targetBranch, userStoryTargetBranch, 'Target branch read from user story');
    }

    @isTest
    public static void testFallbackCustomSetting() {

        // Given
        String targetBranch = 'main';
        String accountId = '123';
        String projectId = '456';
        clayton__ClaytonSettings__c customSettings = TestDataFactory.createClaytonSettingsWithAccountProjectAndTargetBranch(accountId,projectId, targetBranch);
        copado__User_Story__c userStory = TestDataFactory.createCopadoUserStoryWithBaseBranch('');

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
        String accountId = '123';
        String projectId = '456';
        clayton__ClaytonSettings__c customSettings = TestDataFactory.createClaytonSettingsWithAccountProjectAndTargetBranch(accountId,projectId, '');
        copado__User_Story__c userStory = TestDataFactory.createCopadoUserStoryWithBaseBranch('');

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
