@isTest
public with sharing class MaintenanceRequestHelperTest {
    // implement scheduled code here
    @TestSetup
    static void makeData(){
        List<Vehicle__c> vehiclesList = new List<Vehicle__c>();
        List<Product2> equipmentsList = new List<Product2>();
        List<Case> oldCases = new List<Case>();
        List<Equipment_Maintenance_Item__c> maintenanceItems = new List<Equipment_Maintenance_Item__c>();

        Profile adminProfile = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        User testUser = new User(
            Alias = 'standt', 
            Email = 'standarduser@testorg.com', 
            EmailEncodingKey = 'UTF-8', 
            LastName = 'Testing', 
            LanguageLocaleKey = 'en_US', 
            LocaleSidKey = 'en_US', 
            ProfileId = adminProfile.Id,
            TimeZoneSidKey = 'Europe/Paris', 
            UserName = 'standarduser@anastasatestorg.com'
        );
        insert testUser;

        Vehicle__c vehicle1 = new Vehicle__c();
        vehicle1.Air_Conditioner__c = true;
        vehicle1.Awning__c = 'None';
        vehicle1.Backup_Camera_Monitor__c = false;
        vehicle1.Bedrooms__c = 1;
        vehicle1.Fancy_Sound_System__c = false;
        vehicle1.Generator__c = false;
        vehicle1.Name = 'Test Vehicle 1';
        vehicle1.VIN_Number__c = '';
        vehicle1.Type__c = 'Economy';
        vehicle1.Tub__c = false;
        vehiclesList.add(vehicle1);

        Vehicle__c vehicle2 = new Vehicle__c();
        vehicle2.Air_Conditioner__c = true;
        vehicle2.Awning__c = 'None';
        vehicle2.Backup_Camera_Monitor__c = false;
        vehicle2.Bedrooms__c = 1;
        vehicle2.Fancy_Sound_System__c = false;
        vehicle2.Generator__c = false;
        vehicle2.Name = 'Test Vehicle 1';
        vehicle2.VIN_Number__c = '';
        vehicle2.Type__c = 'Economy';
        vehicle2.Tub__c = false;
        vehiclesList.add(vehicle2);
        insert vehiclesList;

        Product2 equipment1 = new Product2();
        equipment1.Name = 'Test GenWatt Diesel 1000kW';
        equipment1.Cost__c = 10;
        equipment1.Current_Inventory__c = 10;
        equipment1.Description = 'Test Description';
        equipment1.IsActive = true;
        equipment1.Lifespan_Months__c = 5;
        equipment1.Maintenance_Cycle__c = 15;
        equipment1.Replacement_Part__c = true;
        equipmentsList.add(equipment1);

        Product2 equipment2 = new Product2();
        equipment2.Name = 'Test Honda Diesel 2000kW';
        equipment2.Cost__c = 10;
        equipment2.Current_Inventory__c = 10;
        equipment2.Description = 'Test Description 2';
        equipment2.IsActive = true;
        equipment2.Lifespan_Months__c = 5;
        equipment2.Maintenance_Cycle__c = 15;
        equipment2.Replacement_Part__c = true;
        equipmentsList.add(equipment2);
        insert equipmentsList;

        Case oldRequest = new Case();
        oldRequest.Status = 'New';
        oldRequest.Type = 'Routine Maintenance';
        oldRequest.Subject = 'Routine Maintenance of vehicle1';
        oldRequest.Vehicle__c = vehicle1.Id;
        // oldRequest.ParentId = closedRequest.Id;
        oldRequest.Origin = 'Web';
        oldRequest.Date_reported__c = Date.today();
        oldRequest.Date_due__c = Date.today().addDays(15);
        oldCases.add(oldRequest);
        insert oldRequest;

        Equipment_Maintenance_Item__c maintenanceItem1 = new Equipment_Maintenance_Item__c();
        maintenanceItem1.Equipment__c = equipment1.Id;
        maintenanceItem1.Maintenance_Request__c = oldRequest.Id;
        maintenanceItems.add(maintenanceItem1);

        Equipment_Maintenance_Item__c maintenanceItem2 = new Equipment_Maintenance_Item__c();
        maintenanceItem2.Equipment__c = equipment2.Id;
        maintenanceItem2.Maintenance_Request__c = oldRequest.Id;
        maintenanceItems.add(maintenanceItem2);
        insert maintenanceItems;
    }

    @isTest
    static void testMaintenanceRequestHelper(){
        User testUser = [SELECT Id FROM User WHERE Alias = 'standt'];

        List<Case> oldCases = [SELECT Id, Status, Type, Vehicle__c, Date_reported__c, Date_due__c, Origin 
                                FROM Case WHERE Subject = 'Routine Maintenance of vehicle1'
                                LIMIT 1];
        Case oldCase = new Case();
        oldCase = oldCases.isEmpty() ? null : oldCases[0];
        oldCase.Status = 'Closed';
        update oldCase;

        System.runAs(testUser){
            Test.startTest();
                List<Case> newCases = [SELECT Id, Status, Type, Vehicle__c, Date_reported__c, 
                                        Date_due__c, Origin, ParentId 
                                        FROM Case 
                                        WHERE ParentId = :oldCase.Id
                                        LIMIT 1];
                Case newCase = new Case();
                newCase = newCases.isEmpty() ? null : newCases[0];

                Assert.areEqual(newCase.ParentId, oldCase.Id, 'ParentId should be the same');
            Test.stopTest();
        }
    }
}