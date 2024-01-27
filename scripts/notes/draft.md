### Objects

- Vehicle -> Maintenance Request -> Equipement Maintenance Item <- Equipement

- Vehicle (Vehicle__c)
- Maintenance Request (Case)
    - Vehicle__c - Lookup (child of Vehicle)
    - Status
    - Type
- Equipment_Maintenance_Item__c
    - Maintenance_Request__c - Master-Detail (child of Maintenance Request)
    - Equipment__c (Product2) - Lookup (child of Equipment)
- Equipment (Product2)


When an existing maintenance request of type Repair or Routine Maintenance is closed, create a new maintenance request for a future routine checkup. This new maintenance request is tied to the same Vehicle and Equipment Records as the original closed request. For record keeping purposes the existing equipment maintenance items must remain tied to the original close request so new records must be created. This new request's Type should be set as Routine Maintenance. The Subject should not be null and the Report Date field reflects the day the request was created. Remember, all equipment has maintenance cycles.

Calculate the maintenance request due dates by using the maintenance cycle defined on the related equipment records. If multiple pieces of equipment are used in the maintenance request, define the due date by applying the shortest maintenance cycle to today’s date.

Design the code to work for both single and bulk maintenance requests. Bulkify the system to successfully process approximately 300 records of offline maintenance requests that are scheduled to import together. For now, don’t worry about changes that occur on the equipment record itself.

Also expose the logic for other uses in the org. Separate the trigger (named MaintenanceRequest) from the application logic in the handler (named MaintenanceRequestHelper). This setup makes it simpler to delegate actions and extend the app in the future.