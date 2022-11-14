@isTest
public class GetClaytonProjectIdFromUserStoryIdTest {

    @isTest
    public static void testReadFromUserStory() {

        // Given
        String projectId = 'd8959b82-0154-4156-89ea-bd303f4083ea';
        clayton__ClaytonSettings__c customSettings = new clayton__ClaytonSettings__c();
        customSettings.clayton__ProjectId__c='c56dea19-1cce-431f-891f-d6dea0a0fc26';
        customSettings.clayton__AccountId__c='ca6e81ac-5c10-4e11-88ee-6ff4a01f913e';
        insert customSettings;
        copado__Project__c project = new copado__Project__c();
        project.Clayton_Project_Id__c = projectId;
        insert project;
        copado__User_Story__c userStory = new copado__User_Story__c();
        userStory.copado__Project__c = project.Id;
        insert userStory;


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
        String projectId = 'd8959b82-0154-4156-89ea-bd303f4083ea';
        clayton__ClaytonSettings__c customSettings = new clayton__ClaytonSettings__c();
        customSettings.clayton__ProjectId__c=projectId;
        customSettings.clayton__AccountId__c='ca6e81ac-5c10-4e11-88ee-6ff4a01f913e';
        insert customSettings;
        copado__Project__c project = new copado__Project__c();
        project.Clayton_Project_Id__c = '';
        insert project;
        copado__User_Story__c userStory = new copado__User_Story__c();
        userStory.copado__Project__c = project.Id;
        insert userStory;


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
