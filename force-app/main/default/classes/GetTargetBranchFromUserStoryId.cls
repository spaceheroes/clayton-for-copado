public with sharing class GetTargetBranchFromUserStoryId {

    @InvocableMethod(label='GetTargetBranchFromUserStoryId' description='Get Branch Name from User Story Id')
    public static List<Response> GetTargetBranchFromUserStoryId(List<Request> requests) {
        Request request = requests[0];
        List<clayton__ClaytonSettings__c> claytonSettings = [select TargetBranch__c from clayton__ClaytonSettings__c LIMIT 1];
        String customSettingsTargetBranch = String.isBlank(claytonSettings[0].TargetBranch__c) ? 'main' : claytonSettings[0].TargetBranch__c;

        List<copado__User_Story__c> userStories = [SELECT copado__Base_Branch__c from copado__User_Story__c where Id=:request.userStoryId LIMIT 1];
        
        if (userStories.size()>0){
            copado__User_Story__c userStory = userStories[0];
            customSettingsTargetBranch = String.isBlank(userStory.copado__Base_Branch__c) ? customSettingsTargetBranch : userStory.copado__Base_Branch__c;
        }

        List<Response> responses = new List<Response>();
        Response response = new Response();
        response.targetBranch = customSettingsTargetBranch;
        responses.add(response);
        return responses;
    }

    @TestVisible
    public class Request{
        
        @InvocableVariable
        public String userStoryId;

    }

    @TestVisible
    public class Response{
        
        @InvocableVariable
        public String targetBranch;

    }
}
