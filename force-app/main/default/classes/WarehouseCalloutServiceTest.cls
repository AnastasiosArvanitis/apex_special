@IsTest
private class WarehouseCalloutServiceTest {
    // implement your mock callout test here
    @IsTest
    static void testGetWarehouse() {
        // Create the mock response based on a sample JSON response
        Test.setMock(HttpCalloutMock.class, new WarehouseCalloutServiceMock());
        HttpRequest req = new HttpRequest();
        req.setMethod('GET');
        req.setHeader('Content-Type', 'application/json');
        HttpResponse res = WarehouseCalloutServiceMock.respond(req);
        System.debug('---> resBody: '+res.getBody());
        List<WarehouseCalloutService.Equipment> equipmentResponse = (List<WarehouseCalloutService.Equipment>) JSON.deserialize(res.getBody(), List<WarehouseCalloutService.Equipment>.class);

        Test.startTest();
            WarehouseCalloutService.runWarehouseEquipmentSync();
            Id jobId = System.enqueueJob(New WarehouseCalloutService());
        Test.stopTest();
        List<Product2> newEquipment = [SELECT Id, Warehouse_SKU__c FROM Product2 WHERE Warehouse_SKU__c = '100059'];
        Assert.areEqual(newEquipment.size(), 2, 'There should be one');
        AsyncApexJob jobInfo = [SELECT Status, NumberOfErrors FROM AsyncApexJob WHERE Id = :jobId];
        Assert.areEqual(jobInfo.Status, 'Completed', 'The job should have completed');
    }

}