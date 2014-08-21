/*	Test class for testing the scheduler class
	
	Version: 1.0	Date: 17-7-14	Author: Saket Joshi
*/

@isTest
public with sharing class TestBatchMailer {

	/*	Function that tests the scheduer. Checks if the cron expression is set as expected
		The batch job is executed after the stopTest method. As we are only sending the mails
		via the batch job, we cannot test that class. 
	*/
	@isTest(SeeAllData=true)
	static void testBatch(){
		
		String CRON_EXP = '0 30 20 ? * MON-FRI';
		ScheduleMail obj = new ScheduleMail();
		String jobID = system.schedule('New Job', CRON_EXP, obj);
		
		test.startTest();
		
		CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered FROM CronTrigger WHERE Id = :jobID];
		
		System.assertEquals(CRON_EXP,ct.CronExpression);
 	    System.assertEquals(0, ct.TimesTriggered);
 	    test.stopTest();
	}

}