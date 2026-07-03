@isTest
private class TestVerifyDate {
	
    @isTest
    static void dateWithIn30Days() {
        Date date1 = Date.today();
        Date date2 = date1.addDays(15);
        
        Date dateResult = VerifyDate.CheckDates(date1, date2);
        System.assertEquals(date2, dateResult);
    }
    
    @isTest
    static void dateWithout30Days() {
        Date date1 = Date.today();
        Date date2 = date1.addDays(35);
        
        Date dateResult = VerifyDate.CheckDates(date1, date2);
        
        Integer totalDays = Date.daysInMonth(date1.year(), date1.month());
		Date lastDay = Date.newInstance(date1.year(), date1.month(), totalDays);
        System.assertEquals(lastDay, dateResult);
    }
    
}