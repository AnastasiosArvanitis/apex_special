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


- When maintenance request is closed:
    - Create a new -> Same Vehicle and Equipment
    - Type: Routine Maintenance
    - Subject: not null
    - Report Date : Today
    - due dates : Product2.Maintenance_Cycle__c  -> if many take shortest