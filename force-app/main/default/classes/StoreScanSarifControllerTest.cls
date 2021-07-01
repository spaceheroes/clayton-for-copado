@isTest
public class StoreScanSarifControllerTest {

    static testMethod void testPredict() {
        List<StoreScanSarifController.StoreScanSarifRequest> requests = new List<StoreScanSarifController.StoreScanSarifRequest>();
        StoreScanSarifController.StoreScanSarifRequest request = new StoreScanSarifController.StoreScanSarifRequest();
        requests.add(request);
        StoreScanSarifController.saveSarifAttachment(requests);
    }
}
