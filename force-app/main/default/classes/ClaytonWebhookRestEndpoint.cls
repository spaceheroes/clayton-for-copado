@RestResource(urlMapping='/api/webhooks/*')
global with sharing class ClaytonWebhookRestEndpoint {

    @HttpPost
    global static void myPostMethod(Webhook webhook){
        RestRequest restRequest = RestContext.request;
        RestResponse restResponse = RestContext.response;

        String requestPayload = restRequest.requestBody.toString();

        String signature = restRequest.headers.get('x-clayton-signature');
        //List<clayton__ClaytonSettings__c> claytonSettings = [select clayton__WebhooksSecret__c from clayton__ClaytonSettings__c limit 1];
        //String secret = claytonSettings[0].clayton__WebhooksSecret__c;
        String secret = 'aaaa';
        Blob hmac = Crypto.generateMac('HMACSHA256', restRequest.requestBody, EncodingUtil.base64Decode(secret)); 
        String matchWithSignature =  EncodingUtil.convertToHex(hmac);

        System.debug('Event received, event:' + webhook.action.event + ', payload:' + requestPayload + ', signature : ' + signature + ', calculated signature : ' + matchWithSignature);

        if (signature!=matchWithSignature){
            restResponse.addHeader('Content-Type', 'text/plain');
            restResponse.responseBody = Blob.valueOf('Signature mismatch');
            restResponse.statusCode = 401;
            return;
        }

        if (webhook.action.event != 'PR_READY'){
            restResponse.addHeader('Content-Type', 'text/plain');
            restResponse.responseBody = Blob.valueOf('Event ' + webhook.action.event + ' not supported');
            restResponse.statusCode = 400;
            return;
        }

        Map<String, Object> myMap = new Map<String, Object>();
        myMap.put('ClaytonScanId', webhook.report.id);
        
        Flow.Interview.Save_Clayton_Diff_Analysis_Results saveClaytonDiffAnalysisResultFlow = new Flow.Interview.Save_Clayton_Diff_Analysis_Results(myMap);
        saveClaytonDiffAnalysisResultFlow.start();


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
        global String html_url;
    }  

}
