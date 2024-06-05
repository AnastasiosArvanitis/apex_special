public with sharing class WarehouseCalloutService  implements Queueable, Database.AllowsCallouts {

    private static final String WAREHOUSE_URL = 'https://th-superbadge-apex.herokuapp.com/equipment';
    
    public static void runWarehouseEquipmentSync() {
        HttpRequest req = new HttpRequest();
        req.setEndpoint(WAREHOUSE_URL);
        req.setMethod('GET');
        req.setHeader('Content-Type', 'application/json');
        // req.setBody('{"key":"value"}');

        Http http = new Http();
        HttpResponse res = http.send(req);

        if (res.getStatusCode() == 200) {
            List<Product2> equipmentToInsert = new List<Product2>();
            String responseBody = res.getBody();
            List<WarehouseCalloutService.Equipment> equipmentResponse = (List<WarehouseCalloutService.Equipment>) JSON.deserialize(responseBody, List<WarehouseCalloutService.Equipment>.class);
            // System.debug('----> response: '+equipmentResponse);
            // [cost=5000, lifespan=120, maintenanceperiod=365, name=Generator 1000 kW, quantity=5, replacement=false, sku=100003]
            for (WarehouseCalloutService.Equipment equipment : equipmentResponse) {
                Product2 p = new Product2();
                p.Cost__c = equipment.cost;
                p.Lifespan_Months__c = equipment.lifespan;
                p.Maintenance_Cycle__c = equipment.maintenanceperiod;
                p.Name = equipment.name;
                p.Current_Inventory__c = equipment.quantity;
                p.Replacement_Part__c = true;
                p.Warehouse_SKU__c = equipment.sku;
                equipmentToInsert.add(p);
            }
            if (!equipmentToInsert.isEmpty()) {
                if (Schema.sObjectType.Product2.isCreateable()) {
                    upsert equipmentToInsert;
                }
            }
        }
    }

    public static void execute(QueueableContext context){
        runWarehouseEquipmentSync();
    }

    public class Equipment {
        public Boolean replacement;
        public Double quantity;
        public String name;
        public Double maintenanceperiod;
        public Double lifespan;
        public Integer cost;
        public String sku;
    }
}