/**
 * VerifyDate utility class for date validation and manipulation.
*/
public class VerifyDate {

	/**
     * Checks two dates and returns date2 if it's within 30 days of date1.
     * Otherwise, returns the end of month date for date1.
     * @param date1 The reference date.
     * @param date2 The date
	*/
    //method to handle potential checks against two dates
	public static Date CheckDates(Date date1, Date date2) {
		//if date2 is within the next 30 days of date1, use date2.  Otherwise use the end of the month
		if(DateWithin30Days(date1,date2)) {
			return date2;
		} else {
			return SetEndOfMonthDate(date1);
		}
	}
	
	/**
     * Checks two dates and returns date2 if it's within 30 days of date1.
     * @param date1 The reference date.
     * @param date2 The date
	*/
	private static Boolean DateWithin30Days(Date date1, Date date2) {
		//check for date2 being in the past
        	if( date2 < date1) { return false; }
        
        	//check that date2 is within (>=) 30 days of date1
        	Date date30Days = date1.addDays(30); //create a date 30 days away from date1
		if( date2 >= date30Days ) { return false; }
		else { return true; }
	}

	/**
     * Return the last date of the given month
     * @param date1 The reference date.
	*/
	private static Date SetEndOfMonthDate(Date date1) {
		Integer totalDays = Date.daysInMonth(date1.year(), date1.month());
		Date lastDay = Date.newInstance(date1.year(), date1.month(), totalDays);
		return lastDay;
	}
    
}