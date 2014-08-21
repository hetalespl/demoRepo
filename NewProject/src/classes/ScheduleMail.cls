/*	Class that implements the system.schedulable interface
	Schedules the batch job for sending the mails
		
	Version: 1.0	Date: 17-7-14	Author: Saket Joshi
*/

global class ScheduleMail implements System.Schedulable{
	
	global ScheduleMail(){
		
	}
	
	//Function that actually schedules the batch job
	global void execute(System.SchedulableContext sc){
		MailBatchJob job = new MailBatchJob();
		database.executeBatch(job);
	}
	
}