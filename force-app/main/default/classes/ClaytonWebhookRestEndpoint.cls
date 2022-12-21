@RestResource(urlMapping='/api/webhooks/*')
global with sharing class ClaytonWebhookRestEndpoint {

    @HttpPost
    global static void myPostMethod(Event event){
        System.debug('Event received, type:' + event.type + ', externalId:'+event.externalId);
        
        Map<String, Object> myMap = new Map<String, Object>();
        myMap.put('ClaytonScanId', event.externalId);
        
        Flow.Interview.Save_Clayton_Diff_Analysis_Results saveClaytonDiffAnalysisResultFlow = new Flow.Interview.Save_Clayton_Diff_Analysis_Results(myMap);
        saveClaytonDiffAnalysisResultFlow.start();


    }

    global class Event {
        global String type;
        global String externalId;
    }    

}
