public with sharing class StoreClaytonStaticAnalysisResults {

    @InvocableMethod(label='Store Clayton Static Analysis Results' description='Store Clayton Static Analysis Results')
    public static void saveSarifAttachment(List<StoreClaytonStaticAnalysisResultsRequest> request){

        List<clayton__ClaytonSettings__c> claytonSettings = [select clayton__AccountId__c,clayton__ProjectId__c from clayton__ClaytonSettings__c];
        String accountId = claytonSettings[0].clayton__AccountId__c;
        String projectId = claytonSettings[0].clayton__ProjectId__c;
        String scanId = request.get(0).scanId;
        String userStoryId = request.get(0).userStoryId;
        copado__Static_Code_Analysis_Result__c staticAnalysisResult = createClaytonStaticAnalysisResult(accountId, projectId, scanId, userStoryId);
        
        createClaytonStaticAnalysisViolations(accountId, projectId, scanId, staticAnalysisResult.Id);
    }

    private static copado__Static_Code_Analysis_Result__c createClaytonStaticAnalysisResult(String accountId, String projectId, String scanId, String userStoryId){
        String scanPath = string.format('/api/workspaces/{0}/projects/{1}/scans/{2}', new string[]{accountId, projectId, scanId});

        HttpRequest httpRequest = new HttpRequest();
        httpRequest.setEndpoint('callout:Clayton/'+scanPath);
        httpRequest.setMethod('GET');
        Http http = new Http();
        HttpResponse response = http.send(httpRequest);
        
        String responseJson = response.getBody();
        PullRequest pullRequestScan = (PullRequest)JSON.deserialize(responseJson, PullRequest.class);

        copado__Static_Code_Analysis_Result__c result = new copado__Static_Code_Analysis_Result__c(RecordTypeId = 'Clayton', copado__User_Story__c=userStoryId);
        insert result;
        return result;
    }
    
    private static void createClaytonStaticAnalysisViolations(String accountId, String projectId, String scanId, String staticAnalysisResultId){
        String scanProblemsPath = string.format('/api/workspaces/{0}/projects/{1}/scans/{2}/problems', new string[]{accountId, projectId, scanId});

        HttpRequest httpRequest = new HttpRequest();
        httpRequest.setEndpoint('callout:Clayton/'+scanProblemsPath);
        httpRequest.setMethod('GET');
        Http http = new Http();
        HttpResponse response = http.send(httpRequest);
        
        String responseJson = response.getBody();
    }

    @TestVisible
    public class StoreClaytonStaticAnalysisResultsRequest{
        
        @InvocableVariable
        public String userStoryId;
        
        @InvocableVariable
        public String scanId;

    }


}