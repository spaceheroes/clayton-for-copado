@isTest
public class GetClaytonProjectIdFromUserStoryIdTest {

    @isTest
    public static void testReadFromUserStory() {

        // Given
        String accountId = 'ca6e81ac-5c10-4e11-88ee-6ff4a01f913e';
        String projectId = 'd8959b82-0154-4156-89ea-bd303f4083ea';
        clayton__ClaytonSettings__c customSettings = TestDataFactory.createClaytonSettingsWithAccountProject(accountId,projectId);
        copado__Project__c project = TestDataFactory.createCopadoProject(projectId);
        copado__User_Story__c userStory = TestDataFactory.createCopadoUserStoryWithProject(project);

        List<GetClaytonProjectIdFromUserStoryId.Request> requests = new List<GetClaytonProjectIdFromUserStoryId.Request>();
        GetClaytonProjectIdFromUserStoryId.Request request = new GetClaytonProjectIdFromUserStoryId.Request();
        request.userStoryId = userStory.Id;
        requests.add(request);

        // When
        List<GetClaytonProjectIdFromUserStoryId.Response> responses = GetClaytonProjectIdFromUserStoryId.GetClaytonProjectIdFromUserStoryId(requests);

        // Then
        GetClaytonProjectIdFromUserStoryId.Response response = responses[0];
        System.assertEquals(response.projectId, projectId, 'Project Id read from user story');
    }

    @isTest
    public static void testFallbackCustomSetting() {

        // Given
        String accountId = 'ca6e81ac-5c10-4e11-88ee-6ff4a01f913e';
        String projectId = 'd8959b82-0154-4156-89ea-bd303f4083ea';
        clayton__ClaytonSettings__c customSettings = TestDataFactory.createClaytonSettingsWithAccountProject(accountId,projectId);
        copado__Project__c project = TestDataFactory.createCopadoProject('');
        copado__User_Story__c userStory = TestDataFactory.createCopadoUserStoryWithProject(project);

        List<GetClaytonProjectIdFromUserStoryId.Request> requests = new List<GetClaytonProjectIdFromUserStoryId.Request>();
        GetClaytonProjectIdFromUserStoryId.Request request = new GetClaytonProjectIdFromUserStoryId.Request();
        request.userStoryId = userStory.Id;
        requests.add(request);

        // When
        List<GetClaytonProjectIdFromUserStoryId.Response> responses = GetClaytonProjectIdFromUserStoryId.GetClaytonProjectIdFromUserStoryId(requests);

        // Then
        GetClaytonProjectIdFromUserStoryId.Response response = responses[0];
        System.assertEquals(response.projectId, projectId, 'Project Id read from custom settings when not available at user story level');
    }

}
