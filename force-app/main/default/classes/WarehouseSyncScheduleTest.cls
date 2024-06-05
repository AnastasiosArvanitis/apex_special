@isTest
public with sharing class WarehouseSyncScheduleTest {
    // implement scheduled code here
    @isTest
    public static void test() {
        Test.setMock(HttpCalloutMock.class, new WarehouseCalloutServiceMock());
        String cron = '0 0 1 * * ?';
        String jobName = 'WarehouseSyncScheduleJob';
        WarehouseSyncSchedule job = new WarehouseSyncSchedule();
        Test.startTest();
            System.schedule(jobName, cron, job);
        Test.stopTest();
        CronTrigger sceduledJob = [SELECT Id, CronJobDetail.Name FROM CronTrigger WHERE CronJobDetail.Name = :jobName];
        Assert.areEqual(jobName, sceduledJob.CronJobDetail.Name, 'job is ok');
    }
}