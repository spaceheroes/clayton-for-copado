@RestResource(urlMapping='/api/webhooks/*')
global with sharing class ClaytonWebhookRestEndpoint {

    @HttpPost
    global static void myPostMethod(){
        RestRequest restRequest = RestContext.request;
        RestResponse restResponse = RestContext.response;
        
        String requestPayload = restRequest.requestBody.toString();
        Webhook webhook = (Webhook)JSON.deserialize(requestPayload, Webhook.class);
        String signature = restRequest.headers.get('x-clayton-signature');

        if (!String.isBlank(signature)){
            String calculatedSignature = calculateSignature(restRequest);

            if (signature!=calculatedSignature){
                createRestResponseError(restResponse, 'Signature mismatch',401);
                return;
            }
        }

        if (webhook.action.event != 'PR_READY'){
            createRestResponseError(restResponse, 'Event ' + webhook.action.event + ' not supported',400);
            return;
        }

        Map<String, Object> myMap = new Map<String, Object>();
        myMap.put('ClaytonScanId', webhook.report.id);
        
        Flow.Interview.Save_Clayton_Diff_Analysis_Results saveClaytonDiffAnalysisResultFlow = new Flow.Interview.Save_Clayton_Diff_Analysis_Results(myMap);
        saveClaytonDiffAnalysisResultFlow.start();

        restResponse.statusCode = 200;
    }

    @TestVisible private static String calculateSignature(RestRequest restRequest) {
        List<clayton__ClaytonSettings__c> claytonSettings = [select clayton__WebhookSecret__c from clayton__ClaytonSettings__c limit 1];
        String webhookSecret = claytonSettings[0].clayton__WebhookSecret__c;
        Blob hmac = Crypto.generateMac('HMACSHA256', restRequest.requestBody, Blob.valueOf(webhookSecret)); 
        return EncodingUtil.convertToHex(hmac);
    }

    @TestVisible private static void createRestResponseError(RestResponse RestResponse, String errorMessage, Integer statusCode) {
        Error error = new Error();
        error.errorMessage = errorMessage;
        restResponse.responseBody = Blob.valueOf(JSON.serialize(error));
        restResponse.addHeader('Content-Type', 'application/json');
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
        global String result;
        global String htmlUrl;
    }  

    global class Error {
        global String errorMessage;
    }  
}
