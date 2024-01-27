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

Id caseId = '500Wx000000suGYIAY'; // replace with your actual Case Id
List<Product2> products = caseToProductMap.get(caseId);

if (products != null) {
    for (Product2 p : products) {
        System.debug('Product Id: ' + p.Id);
        System.debug('Product Name: ' + p.Name);
    }
} else {
    System.debug('No related products found for this case.');
}



// ----------------------------

trigger MaintenanceRequest on Maintenance_Request__c (after update) {
    MaintenanceRequestHelper.handleClosedRequests(Trigger.new, Trigger.oldMap);
}

public class MaintenanceRequestHelper {
    public static void handleClosedRequests(List<Maintenance_Request__c> newRequests, Map<Id, Maintenance_Request__c> oldRequestsMap) {
        List<Maintenance_Request__c> closedRequests = new List<Maintenance_Request__c>();

        for (Maintenance_Request__c request : newRequests) {
            Maintenance_Request__c oldRequest = oldRequestsMap.get(request.Id);
            if (oldRequest.Status__c != 'Closed' && request.Status__c == 'Closed') {
                closedRequests.add(request);
            }
        }

        if (!closedRequests.isEmpty()) {
            createRoutineMaintenanceRequests(closedRequests);
        }
    }

    public static void createRoutineMaintenanceRequests(List<Maintenance_Request__c> closedRequests) {
        List<Maintenance_Request__c> newRequests = new List<Maintenance_Request__c>();

        for (Maintenance_Request__c closedRequest : closedRequests) {
            if (closedRequest.Type == 'Repair' || closedRequest.Type == 'Routine Maintenance') {
                Maintenance_Request__c newRequest = new Maintenance_Request__c();
                newRequest.Type = 'Routine Maintenance';
                newRequest.Subject__c = 'Routine Maintenance for ' + closedRequest.Equipment__r.Name;
                newRequest.Date_Reported__c = Date.today();
                newRequest.Equipment__c = closedRequest.Equipment__c;
                // Calculate due date based on maintenance cycle
                Integer maintenanceCycle = closedRequest.Equipment__r.Maintenance_Cycle__c;
                newRequest.Date_Due__c = Date.today().addDays(maintenanceCycle);
                newRequests.add(newRequest);
            }
        }

        if (!newRequests.isEmpty()) {
            insert newRequests;
        }
    }
    
}

