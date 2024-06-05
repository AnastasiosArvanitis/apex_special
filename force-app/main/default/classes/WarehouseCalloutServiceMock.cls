public class WarehouseCalloutServiceMock implements HttpCalloutMock{
    // implement http mock callout
    public static HttpResponse respond(HttpRequest req) {
        // Create a fake response
        // [cost=5000, lifespan=120, maintenanceperiod=365, name=Generator 1000 kW, quantity=5, replacement=false, sku=100003]
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('[{"name":"Generator 1000 kW", "cost":5000, "lifespan":120, "maintenanceperiod":365, "quantity":5, "replacement":false, "sku":100059}]');
        res.setStatusCode(200);
        return res;
    }
}
