public with sharing class GetClaytonProjectIdFromUserStoryId {

    @InvocableMethod(label='GetClaytonProjectIdFromUserStoryId' description='Get Clayton Project Id from User Story Id')
    public static List<Response> GetClaytonProjectIdFromUserStoryId(List<Request> requests) {
        Request request = requests[0];
        List<clayton__ClaytonSettings__c> claytonSettings = [select clayton__ProjectId__c from clayton__ClaytonSettings__c limit 1];
        String claytonProjectId = claytonSettings[0].clayton__ProjectId__c;

        List<copado__Project__c> projects = [select Clayton_Project_Id__c from copado__Project__c where Id IN (select copado__Project__c from copado__User_Story__c where Id=:request.userStoryId) limit 1];
        if (projects.size()>0){
            copado__Project__c project = projects[0];
            claytonProjectId = String.isBlank(project.Clayton_Project_Id__c) ? claytonProjectId : project.Clayton_Project_Id__c;
        }
        
        List<Response> responses = new List<Response>();
        Response response = new Response();
        response.projectId = claytonProjectId;
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
        public String projectId;

    }
}
