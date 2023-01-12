@RestResource(urlMapping='/api/webhooks/*')
global with sharing class ClaytonWebhookRestEndpoint {

    public static final String HEADER_SIGNATURE = 'x-clayton-signature';
    public static final String HEADER_CONTENT_TYPE = 'Content-Type';
    public static final String SIGNATURE_CRYPTO_ALGORITHM = 'HMACSHA256';
    public static final String WEBHOOK_EVENT_DIFF_READY = 'DIFF_READY';
    public static final String CONTENT_TYPE_JSON = 'application/json';

    @HttpPost
    global static void processNotification(){
        final RestRequest restRequest = RestContext.request;
        final RestResponse restResponse = RestContext.response;
        final Webhook webhook = fetchWebhook(restRequest);
        final String signature = fetchSignature(restRequest);
        if (!String.isBlank(signature)){
            String calculatedSignature = calculateSignature(restRequest);

            if (signature!=calculatedSignature){
                createRestResponseError(restResponse, 'Signature mismatch',401);
                return;
            }
        }
        if (webhook.action.event == WEBHOOK_EVENT_DIFF_READY){
            manageDiffReadyEvent(webhook.workspace.id, webhook.project.id, webhook.report.pull_request_id);
        }
        restResponse.statusCode = 200;
    }

    @TestVisible private static Webhook fetchWebhook(final RestRequest restRequest) {
        final String requestPayload = restRequest.requestBody.toString();
        return (Webhook)JSON.deserialize(requestPayload, Webhook.class);
    }

    @TestVisible private static String fetchSignature(final RestRequest restRequest) {
        return restRequest.headers.get(HEADER_SIGNATURE);
    }

    @TestVisible private static String calculateSignature(final RestRequest restRequest) {
        final List<clayton__ClaytonSettings__c> claytonSettings = [select clayton__WebhookSecret__c from clayton__ClaytonSettings__c limit 1];
        final String webhookSecret = claytonSettings[0].clayton__WebhookSecret__c;
        final Blob hmac = Crypto.generateMac(SIGNATURE_CRYPTO_ALGORITHM, restRequest.requestBody, Blob.valueOf(webhookSecret)); 
        return EncodingUtil.convertToHex(hmac);
    }

    @future(callout=true)
    @TestVisible private static void manageDiffReadyEvent(final String accountId, final String projectId, final String claytonScanId){
        final Map<String, Object> myMap = new Map<String, Object>();
        myMap.put('AccountId', accountId);
        myMap.put('ProjectId', projectId);
        myMap.put('ClaytonScanId', claytonScanId);
       
        try {
            final Flow.Interview.clayton.Save_Clayton_Diff_Analysis_Results saveClaytonDiffAnalysisResultFlow = new Flow.Interview.clayton.Save_Clayton_Diff_Analysis_Results(myMap);
            saveClaytonDiffAnalysisResultFlow.start();
        } catch(Exception e) {
            System.debug('Unable to trigger flow: ' + e.getMessage());
        }

    }

    @TestVisible private static void createRestResponseError(final RestResponse RestResponse, final String errorMessage, final Integer statusCode) {
        final Error error = new Error();
        error.errorMessage = errorMessage;
        restResponse.responseBody = Blob.valueOf(JSON.serialize(error));
        restResponse.addHeader(HEADER_CONTENT_TYPE, CONTENT_TYPE_JSON);
        restResponse.statusCode = statusCode;
    }

    global class Webhook {
        global Action action;
        global Workspace workspace;
        global Project project;
        global PullRequestReviewReport report;
    }  

    global class Action {
        global String event;
    }   

    global class Workspace {
        global String id;
        global String name;
    }   

    global class Project {
        global String id;
        global String name;
    }   

    global class PullRequestReviewReport {
        global String id;
        global String pull_request_id;
        global String result;
        global String html_url;
    }  

    global class Error {
        global String errorMessage;
    }  
}