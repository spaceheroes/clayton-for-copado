@isTest
public class ClaytonWebhookRestEndpointTest {

    @isTest
    public static void testFetchSignature() {
        // Given
        RestRequest restRequest = new RestRequest();
        String signature = '1234567890';
        restRequest.addHeader(ClaytonWebhookRestEndpoint.HEADER_SIGNATURE, signature);

        // When
        String fetchedSignature = ClaytonWebhookRestEndpoint.fetchSignature(restRequest);

        // Then
        System.assertEquals(signature, fetchedSignature, 'Signature must match');
    }

    @isTest
    public static void testFetchWebhook() {
        // Given
        RestRequest restRequest = new RestRequest();
        String event = 'DIFF_READY';
        String pullRequestId = '5c0f4eff-4ad9-4942-8232-5daf0978df18';
        String projectId = '12345678910';
        String accountId = '12345678911';
        restRequest.requestBody = Blob.valueOf('{"action":{"event":"'+event+'"},"workspace":{"id":"'+accountId+'","name":"Clayton"},"project":{"id":"'+projectId+'","name":"CopadoTrial"},"report":{"id":"ab55e9d3-f3c0-4701-8014-14594da499d5","pull_request_id":"'+pullRequestId+'","result":"PASSED","html_url":"https://staging.claytonapp.com/preview/repositories/'+projectId+'/diffs-issues/5c0f4eff-4ad9-4942-8232-5daf0978df18"}}');
        
        // When
        ClaytonWebhookRestEndpoint.Webhook webhook = ClaytonWebhookRestEndpoint.fetchWebhook(restRequest);

        // Then
        System.assertEquals(event, webhook.action.event, 'Event must match');
        System.assertEquals(pullRequestId, webhook.report.pull_request_id, 'Pull Request Id must match');
    }

    @isTest
    public static void testCalculateSignature() {
        // Given
        RestRequest restRequest = new RestRequest();
        String event = 'DIFF_READY';
        String pullRequestId = '5c0f4eff-4ad9-4942-8232-5daf0978df18';
        String signature = 'db2426439f290da3d16cfeb14e860e74fd8e5d720538396017398d013b6b375c';
        String secretKey = 'test-secret';
        String projectId = '12345678910';
        String accountId = '12345678911';
        restRequest.requestBody = Blob.valueOf('{"action":{"event":"'+event+'"},"workspace":{"id":"'+accountId+'","name":"Clayton"},"project":{"id":"'+projectId+'","name":"CopadoTrial"},"report":{"id":"ab55e9d3-f3c0-4701-8014-14594da499d5","pull_request_id":"'+pullRequestId+'","result":"PASSED","html_url":"https://staging.claytonapp.com/preview/repositories/'+projectId+'/diffs-issues/5c0f4eff-4ad9-4942-8232-5daf0978df18"}}');
        clayton__ClaytonSettings__c customSettings = new clayton__ClaytonSettings__c();
        customSettings.clayton__AccountId__c= accountId;
        customSettings.clayton__ProjectId__c= projectId;
        customSettings.clayton__WebhookSecret__c = secretKey;
        insert customSettings;

        // When
        String calculatedSignature = ClaytonWebhookRestEndpoint.calculateSignature(restRequest);

        // Then
        System.assertEquals(signature, calculatedSignature, 'Calculated signature must match');
    }

    @isTest
    public static void testCreateRestResponseError() {
        // Given
        RestResponse restResponse = new RestResponse();
        String errorMessage = 'Signature mismatch';
        Integer statusCode = 401;

        // When
        ClaytonWebhookRestEndpoint.createRestResponseError(restResponse, errorMessage, statusCode);

        // Then
        ClaytonWebhookRestEndpoint.Error error = (ClaytonWebhookRestEndpoint.Error) JSON.deserialize(restResponse.responseBody.toString(), ClaytonWebhookRestEndpoint.Error.class);
        System.assertEquals(statusCode, restResponse.statusCode, 'Status code must match');
        System.assertEquals(errorMessage, error.errorMessage, 'Error message must match');
        System.assertEquals(restResponse.headers.get(ClaytonWebhookRestEndpoint.HEADER_CONTENT_TYPE),ClaytonWebhookRestEndpoint.CONTENT_TYPE_JSON, 'Content-Type header must match');
    }

    @isTest
    public static void testManageDiffReadyEvent() {
        // Given
        RestResponse restResponse = new RestResponse();
        Integer statusCode = 200;
        String pullRequestId = '345234243234';
        String projectId = '12345678910';
        String accountId = '12345678911';
        ClaytonWebhookRestEndpoint.Webhook webhook = new ClaytonWebhookRestEndpoint.Webhook();
        webhook.action = new ClaytonWebhookRestEndpoint.Action();
        webhook.action.event = 'DIFF_READY';
        webhook.report = new ClaytonWebhookRestEndpoint.PullRequestReviewReport();
        webhook.report.pull_request_id = pullRequestId;
        copado__Project__c project = new copado__Project__c();
        project.Clayton_Project_Id__c = projectId;
        insert project;
        copado__User_Story__c userStory = new copado__User_Story__c();
        userStory.copado__Project__c = project.Id;
        insert userStory;
        copado__Result__c result = new copado__Result__c();
        result.copado__User_Story__c=userStory.Id;
        result.copado__Job_Id__c = pullRequestId;
        result.copado__Job_Type__c = 'Clayton Scan';
        result.copado__Description__c = 'Clayton Scan';
        result.copado__Status__c = 'In Progress';
        insert result;
        clayton__ClaytonSettings__c customSettings = new clayton__ClaytonSettings__c();
        customSettings.clayton__AccountId__c= accountId;
        customSettings.clayton__ProjectId__c= projectId;
        Test.startTest();
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/json');
        Test.setMock(HttpCalloutMock.class, mock);

        // When
        ClaytonWebhookRestEndpoint.manageDiffReadyEvent(restResponse, webhook);

        // Then
        System.assertEquals(statusCode, restResponse.statusCode, 'Status code must match');
    }

    @isTest
    public static void testProcessNotification() {
        // Given
        RestContext.request = new RestRequest();
        RestContext.response = new RestResponse();
        Integer statusCode = 200;
        String event = 'DIFF_READY';
        String pullRequestId = '5c0f4eff-4ad9-4942-8232-5daf0978df18';
        String secretKey = 'test-secret';
        String projectId = '12345678910';
        String accountId = '12345678911';
        RestContext.request.requestBody = Blob.valueOf('{"action":{"event":"'+event+'"},"workspace":{"id":"'+accountId+'","name":"Clayton"},"project":{"id":"'+projectId+'","name":"CopadoTrial"},"report":{"id":"ab55e9d3-f3c0-4701-8014-14594da499d5","pull_request_id":"'+pullRequestId+'","result":"PASSED","html_url":"https://staging.claytonapp.com/preview/repositories/'+projectId+'/diffs-issues/5c0f4eff-4ad9-4942-8232-5daf0978df18"}}');

        // When
        ClaytonWebhookRestEndpoint.processNotification();

        // Then
        System.assertEquals(statusCode, RestContext.response.statusCode, 'Status code must match');
    }
}