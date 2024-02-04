// Collect all ParentIds from requestsToInsert
Set<Id> parentIds = new Set<Id>();
for (Case request : requestsToInsert){
    parentIds.add(request.ParentId);
}

// Query for all Cases and related Equipment_Maintenance_Item__c records at once
Map<Id, Case> cCases = new Map<Id, Case>([SELECT Id, ParentId, 
                                        (SELECT Id FROM Equipment_Maintenance_Items__r) 
                                        FROM Case WHERE Id IN :parentIds]);

// Process the requests
List<Equipment_Maintenance_Item__c> copyEMI = new List<Equipment_Maintenance_Item__c>();
for (Case request : requestsToInsert){
    Case parentCase = cCases.get(request.ParentId);
    if (parentCase != null && parentCase.Equipment_Maintenance_Items__r != null){
        for (Equipment_Maintenance_Item__c item : parentCase.Equipment_Maintenance_Items__r){
            Equipment_Maintenance_Item__c itemClone = item.clone();
            itemClone.Maintenance_Request__c = request.Id;
            copyEMI.add(itemClone);
        }
    }
}
insert copyEMI;