// Use .apex files to store anonymous Apex.
// You can execute anonymous Apex in VS Code by selecting the
//     apex text and running the command:
//     SFDX: Execute Anonymous Apex with Currently Selected Text
// You can also execute the entire file by running the command:
//     SFDX: Execute Anonymous Apex with Editor Contents

string tempvar = 'Enter_your_name_here';
System.debug('Hello World!');
System.debug('My name is ' + tempvar);

// make an instance of the Equipment_Maintenance_Item__c

Equipment_Maintenance_Item__c emi = new Equipment_Maintenance_Item__c();
// set the fields on the record
emi.Name = 'Test Equipment Maintenance Item';
// print name of record
System.debug('emi.Name: ' + emi.Name);

# q: What is the difference between a class and an object?
# a: A class is a blueprint for an object. An object is an instance of a class.

ctr + shift i

# function to get the current date and time
public static String getDateTime() {
    DateTime dt = DateTime.now();
    String date = dt.format('MM/dd/yyyy');
    String time = dt.format('h:mm a');
    return date + ' ' + time;
}

@workspace 
@vscode
@terminal

# create a new scratch org
sfdx force:org:create -f config/project-scratch-def.json -a myscratchorg -s -d 30

Map<Id, Product2> caseToProductMap = new Map<Id, Product2>();

for (Case c : [SELECT Id, (SELECT Equipment__r.Id, Equipment__r.Name FROM Equipment_Maintenance_Items__r) 
               FROM Case WHERE Id = '500Wx000000suGYIAY']) {
    for (Equipment_Maintenance_Item__c item : c.Equipment_Maintenance_Items__r) {
        caseToProductMap.put(c.Id, item.Equipment__r);
    }
}


Map<Id, List<Product2>> caseToProductMap = new Map<Id, List<Product2>>();

for (Case c : [SELECT Id, (SELECT Equipment__r.Id, Equipment__r.Name FROM Equipment_Maintenance_Items__r) 
               FROM Case WHERE Id = '500Wx000000suGYIAY']) {
    List<Product2> products = new List<Product2>();
    for (Equipment_Maintenance_Item__c item : c.Equipment_Maintenance_Items__r) {
        products.add(item.Equipment__r);
    }
    caseToProductMap.put(c.Id, products);
}

Case c = [SELECT Id, (SELECT Equipment__r.Id, Equipment__r.Name FROM Equipment_Maintenance_Items__r) 
          FROM Case WHERE Id = '500Wx000000jL7dIAE' LIMIT 1];
System.debug('------ ' +c);

Case c = [SELECT Id FROM Case WHERE Id = '500Wx000000jL7dIAE' LIMIT 1];
System.debug('------ ' +c);

List<Product2> equipmentRecords = [SELECT Maintenance_Cycle__c FROM Product2 WHERE Id IN 
        (SELECT Equipment__c FROM Equipment_Maintenance_Item__c WHERE Maintenance_Request__c = '500Wx000000suGYIAY')];

System.debug('------ ' +equipmentRecords);


Case myCase = new Case();
newRequest.Status = 'New';
newRequest.Type = 'Routine Maintenance';
newRequest.Subject = 'Routine Maintenance of vehicle';

// 500Wx000000suGYIAY

List<Case> cases = [SELECT Id FROM Case WHERE Id = '500Wx000000suGYIAY' LIMIT 1];
if (!cases.isEmpty()) {
    Case myCase = cases[0];
    AggregateResult result = [SELECT MIN(Equipment__r.Maintenance_Cycle__c) 
                              FROM Equipment_Maintenance_Item__c 
                              WHERE Maintenance_Request__c = :myCase.Id];
    System.debug('------ ' + result);
}

WarehouseCalloutService.runWarehouseEquipmentSync();

System.enqueueJob(New WarehouseCalloutService());

// WarehouseSyncScheduleJob

String cron = '0 0 1 * * ?';
String jobName = 'WarehouseSyncScheduleJob';
WarehouseSyncSchedule job = new WarehouseSyncSchedule();
System.schedule(jobName, cron, job);

String jobName = 'WarehouseSyncScheduleJob';
CronTrigger job = [SELECT Id FROM CronTrigger WHERE CronJobDetail.Name = :jobName];

// Abort the job
System.abortJob('08eWx000000QR7p');







