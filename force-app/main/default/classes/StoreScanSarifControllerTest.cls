@isTest
public class StoreScanSarifControllerTest {

    @isTest
    public static void testPredict() {

        // Given
        SObject task = new Task();
        insert task;

        Test.startTest();
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('SarifTestBundle');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/json');
        Test.setMock(HttpCalloutMock.class, mock);

        List<StoreScanSarifController.StoreScanSarifRequest> requests = new List<StoreScanSarifController.StoreScanSarifRequest>();
        StoreScanSarifController.StoreScanSarifRequest request = new StoreScanSarifController.StoreScanSarifRequest();
        request.recordId = task.Id;
        request.title = 'Test';
        request.sarifUrl = 'http://something.io';
        requests.add(request);

        // When
        StoreScanSarifController.saveSarifAttachment(requests);

        // Then
        List<Attachment> results = [SELECT id FROM Attachment where ParentId=:task.Id LIMIT 1];
        System.assert(results.size()>0, 'Attachment must be present');
    }
}
