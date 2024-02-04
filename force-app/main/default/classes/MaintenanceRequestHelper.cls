public with sharing class MaintenanceRequestHelper {
    
    public static void updateWorkOrders(List<Case> closedCases) {
        // TODO: Complete the method to update workorders

        Map<Id, AggregateResult> results = new Map<Id, AggregateResult>();
        if (Schema.sObjectType.Equipment_Maintenance_Item__c.isAccessible()) {
            for (AggregateResult result : [SELECT Maintenance_Request__c, MIN(Equipment__r.Maintenance_Cycle__c) min
                                        FROM Equipment_Maintenance_Item__c 
                                        WHERE Maintenance_Request__c IN :closedCases
                                        GROUP BY Maintenance_Request__c]) {
                results.put((Id)result.get('Maintenance_Request__c'), result);
            }
        }

        List<Case> requestsToInsert = new List<Case>();
        
        Date dueDate = System.today();
        for (Case closedRequest : closedCases) {
            if (closedRequest.Status == 'Closed') {
                if (closedRequest.Type == 'Repair' || closedRequest.Type == 'Routine Maintenance') {
                    Case newRequest = new Case();
                    newRequest.Status = 'New';
                    newRequest.Type = 'Routine Maintenance';
                    newRequest.Subject = 'Routine Maintenance of vehicle';
                    newRequest.Vehicle__c = closedRequest.Vehicle__c;
                    newRequest.ParentId = closedRequest.Id;
                    newRequest.Origin = 'Web';
                    newRequest.Date_reported__c = Date.today();
                    newRequest.Date_due__c = getDueDate(results.get(closedRequest.Id));
                    requestsToInsert.add(newRequest);
                }
            }
        }
        if (!requestsToInsert.isEmpty()) {
            try {
                if (Schema.sObjectType.Case.isCreateable()) {
                    List<Database.SaveResult> saveResults = Database.insert(requestsToInsert);
                    for (Database.SaveResult sr : saveResults) {
                        if (sr.isSuccess()) {
                            // Operation was successful, so get the ID of the record that was processed
                            System.debug('--- Successfully inserted record with ID: ' + sr.getId());
                        }
                        else {
                            // Operation failed, so get all errors                
                            for(Database.Error err : sr.getErrors()) {
                                System.debug('--- The following error has occurred.');                    
                                System.debug(err.getStatusCode() + ': ' + err.getMessage());
                                System.debug('--- Record that caused error: ' + err.getFields());
                            }
                        }
                    }
                    Set<Id> parentIds = new Set<Id>();
                    for (Case request : requestsToInsert){
                        parentIds.add(request.ParentId);
                    }
                    //! Has to search in a list of parent ids to get parent id, from closed cases
                    Map<Id, Case> closedCasesMap = new Map<Id, Case>([SELECT Id, ParentId,
                                                    (SELECT Id, Equipment__c FROM Equipment_Maintenance_Items__r) 
                                                    FROM Case WHERE Id IN :parentIds]);
                    List<Equipment_Maintenance_Item__c> copyEMI = new List<Equipment_Maintenance_Item__c>();

                    for (Case request : requestsToInsert){                      
                        Case parentCase = closedCasesMap.get(request.ParentId);
                        if (parentCase != null && parentCase.Equipment_Maintenance_Items__r != null){
                            for (Equipment_Maintenance_Item__c item : parentCase.Equipment_Maintenance_Items__r){
                                Equipment_Maintenance_Item__c itemClone = item.clone();
                                itemClone.Maintenance_Request__c = request.Id;
                                copyEMI.add(itemClone);
                            }
                        }
                    }
                    List<Database.SaveResult> saveResultsEMI = Database.insert(copyEMI);
                    for (Database.SaveResult sr : saveResultsEMI) {
                        if (sr.isSuccess()) {
                            // Operation was successful, so get the ID of the record that was processed
                            System.debug('--- Successfully inserted record with ID: ' + sr.getId());
                        }
                        else {
                            // Operation failed, so get all errors                
                            for(Database.Error err : sr.getErrors()) {
                                System.debug('--- The following error has occurred.');                    
                                System.debug(err.getStatusCode() + ': ' + err.getMessage());
                                System.debug('--- Record that caused error: ' + err.getFields());
                            }
                        }
                    }
                }
            } catch (Exception e) {
                System.debug('Exception: ' + e.getMessage());
            }
        }
    }

    public static Date getDueDate(AggregateResult result) {
        Date dueDate = Date.today();
        if (result != null) {
            Decimal shortestMaintenanceCycle = (Decimal)result.get('min');
            dueDate = dueDate.addDays(Integer.valueOf(shortestMaintenanceCycle));
        }
        return dueDate;
    }
        
}