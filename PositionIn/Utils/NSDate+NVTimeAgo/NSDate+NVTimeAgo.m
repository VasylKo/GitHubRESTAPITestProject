//
//  NSDate+NVTimeAgo.m
//  Adventures
//
//  Created by Nikil Viswanathan on 4/18/13.
//  Copyright (c) 2013 Nikil Viswanathan. All rights reserved.
//

#import "NSDate+NVTimeAgo.h"

@implementation NSDate (NVFacebookTimeAgo)


#define SECOND  1
#define MINUTE  (SECOND * 60)
#define HOUR    (MINUTE * 60)
#define DAY     (HOUR   * 24)
#define WEEK    (DAY    * 7)
#define MONTH   (DAY    * 31)
#define YEAR    (DAY    * 365.24)

/*
    Mysql Datetime Formatted As Time Ago
    Takes in a mysql datetime string and returns the Time Ago date format
 */
+ (NSString *)mysqlDatetimeFormattedAsTimeAgo:(NSString *)mysqlDatetime
{
    //http://stackoverflow.com/questions/10026714/ios-converting-a-date-received-from-a-mysql-server-into-users-local-time
    //If this is not in UTC, we don't have any knowledge about
    //which tz it is. MUST BE IN UTC.
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    NSDate *date = [formatter dateFromString:mysqlDatetime];
    
    return [date formattedAsTimeAgo];
    
}


/*
    Formatted As Time Ago
    Returns the date formatted as Time Ago (in the style of the mobile time ago date formatting for Facebook)
 */
- (NSString *)formattedAsTimeAgo
{    
    //Now
    NSDate *now = [NSDate date];
    NSTimeInterval secondsSince = -(int)[self timeIntervalSinceDate:now];
    
    // Today = "1:28 PM"
    if([self isSameDayAs:now])
        return [self formatAsToday:secondsSince];
 
    
    // Yesterday = "Yesterday"
    if([self isYesterday:now])
        return [self formatAsYesterday];
  
    
    // < Last 7 days = "Friday"
    if([self isLastWeek:secondsSince])
        return [self formatAsLastWeek];
    
    // Anything else = "10/20/15"
    return [self formatAsOther];
    
}



/*
 ========================== Date Comparison Methods ==========================
 */

/*
    Is Same Day As
    Checks to see if the dates are the same calendar day
 */
- (BOOL)isSameDayAs:(NSDate *)comparisonDate
{
    //Check by matching the date strings
    NSDateFormatter *dateComparisonFormatter = [[NSDateFormatter alloc] init];
    [dateComparisonFormatter setDateFormat:@"yyyy-MM-dd"];
    
    //Return true if they are the same
    return [[dateComparisonFormatter stringFromDate:self] isEqualToString:[dateComparisonFormatter stringFromDate:comparisonDate]];
}




/*
 If the current date is yesterday relative to now
 Pasing in now to be more accurate (time shift during execution) in the calculations
 */
- (BOOL)isYesterday:(NSDate *)now
{
    return [self isSameDayAs:[now dateBySubtractingDays:1]];
}


//From https://github.com/erica/NSDate-Extensions/blob/master/NSDate-Utilities.m
- (NSDate *) dateBySubtractingDays: (NSInteger) numDays
{
	NSTimeInterval aTimeInterval = [self timeIntervalSinceReferenceDate] + DAY * -numDays;
	NSDate *newDate = [NSDate dateWithTimeIntervalSinceReferenceDate:aTimeInterval];
	return newDate;
}


/*
    Is Last Week
    We want to know if the current date object is the first occurance of
    that day of the week (ie like the first friday before today 
    - where we would colloquially say "last Friday")
    ( within 6 of the last days)
 
    TODO: make this more precise (1 week ago, if it is 7 days ago check the exact date)
 */
- (BOOL)isLastWeek:(NSTimeInterval)secondsSince
{
    return secondsSince < WEEK;
}


/*
    Is Last Month
    Previous 31 days?
    TODO: Validate on fb
    TODO: Make last day precise
 */
- (BOOL)isLastMonth:(NSTimeInterval)secondsSince
{
    return secondsSince < MONTH;
}


/*
    Is Last Year
    TODO: Make last day precise
 */

- (BOOL)isLastYear:(NSTimeInterval)secondsSince
{
    return secondsSince < YEAR;
}

/*
 =============================================================================
 */





/*
   ========================== Formatting Methods ==========================
 */


// < 1 hour = "x minutes ago"
- (NSString *)formatMinutesAgo:(NSTimeInterval)secondsSince
{
    //Convert to minutes
    int minutesSince = (int)secondsSince / MINUTE;
    
    //Handle Plural
    if(minutesSince == 1)
        return @"1 minute ago";
    else
        return [NSString stringWithFormat:@"%d minutes ago", minutesSince];
}


// Today = "time format"
- (NSString *)formatAsToday:(NSTimeInterval)secondsSince
{
    //Create date formatter
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    NSString *format = [NSDateFormatter dateFormatFromTemplate:@"j" options:0 locale:[NSLocale currentLocale]];
    BOOL is24Hour = ([format rangeOfString:@"a"].location == NSNotFound);
    //Format
    if (is24Hour) {
        [dateFormatter setDateFormat:@"'Today', H:mm"];
    } else {
        [dateFormatter setDateFormat:@"'Today', h:mm a"];
    }
    return [NSString stringWithFormat:@"%@", [dateFormatter stringFromDate:self]];
}


// Yesterday = "Yesterday"
- (NSString *)formatAsYesterday
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSString *format = [NSDateFormatter dateFormatFromTemplate:@"j" options:0 locale:[NSLocale currentLocale]];
    BOOL is24Hour = ([format rangeOfString:@"a"].location == NSNotFound);
    //Format
    if (is24Hour) {
        [dateFormatter setDateFormat:@"'Yesterday', H:mm"];
    } else {
        [dateFormatter setDateFormat:@"'Yesterday', h:mm a"];
    }
    return [NSString stringWithFormat:@"%@", [dateFormatter stringFromDate:self]];
}


// < Last 7 days = "Friday"
- (NSString *)formatAsLastWeek
{
    //Create date formatter

    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    //Format
    
    NSString *format = [NSDateFormatter dateFormatFromTemplate:@"j" options:0 locale:[NSLocale currentLocale]];
    BOOL is24Hour = ([format rangeOfString:@"a"].location == NSNotFound);
    //Format
    if (is24Hour) {
        [dateFormatter setDateFormat:@"EEEE, H:mm"];
    } else {
        [dateFormatter setDateFormat:@"EEEE, h:mm a"];
    }
    return [NSString stringWithFormat:@"%@", [dateFormatter stringFromDate:self]];
}


// < Last 30 days = "March 30 at 1:14 PM"
- (NSString *)formatAsLastMonth
{
    //Create date formatter
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    //Format
    NSString *format = [NSDateFormatter dateFormatFromTemplate:@"j" options:0 locale:[NSLocale currentLocale]];
    
    BOOL is24Hour = ([format rangeOfString:@"a"].location == NSNotFound);
    //Format
    if (is24Hour) {
        [dateFormatter setDateFormat:@"MMMM d, H:mm"];
    } else {
        [dateFormatter setDateFormat:@"MMMM d, h:mm a"];
    }
    return [NSString stringWithFormat:@"%@", [dateFormatter stringFromDate:self]];
    return [dateFormatter stringFromDate:self];
}


// < 1 year = "September 15"
- (NSString *)formatAsLastYear
{
    //Create date formatter
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    //Format
    [dateFormatter setDateFormat:@"MMMM d"];
    return [dateFormatter stringFromDate:self];
}


// Anything else = "20/10/15"
- (NSString *)formatAsOther
{
    //Create date formatter
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    //Format
    
    NSString *format = [NSDateFormatter dateFormatFromTemplate:@"j" options:0 locale:[NSLocale currentLocale]];
    BOOL is24Hour = ([format rangeOfString:@"a"].location == NSNotFound);
    //Format
    if (is24Hour) {
        [dateFormatter setDateFormat:@"dd MMM, H:mm"];
    } else {
        [dateFormatter setDateFormat:@"dd MMM, h:mm a"];
    }
    return [NSString stringWithFormat:@"%@", [dateFormatter stringFromDate:self]];
    return [dateFormatter stringFromDate:self];
}

/*
 =======================================================================
 */





/*
 ========================== Test Method ==========================
 */

/*
    Test the format
    TODO: Implement unit tests
 */
+ (void)runTests
{
    NSLog(@"1 Second in the future: %@\n", [[NSDate dateWithTimeIntervalSinceNow:1] formattedAsTimeAgo]);
    NSLog(@"Now: %@\n", [[NSDate dateWithTimeIntervalSinceNow:0] formattedAsTimeAgo]);
    NSLog(@"1 Second: %@\n", [[NSDate dateWithTimeIntervalSinceNow:-1] formattedAsTimeAgo]);
    NSLog(@"10 Seconds: %@\n", [[NSDate dateWithTimeIntervalSinceNow:-10] formattedAsTimeAgo]);
    NSLog(@"1 Minute: %@\n", [[NSDate dateWithTimeIntervalSinceNow:-60] formattedAsTimeAgo]);
    NSLog(@"2 Minutes: %@\n", [[NSDate dateWithTimeIntervalSinceNow:-120] formattedAsTimeAgo]);
    NSLog(@"1 Hour: %@\n", [[NSDate dateWithTimeIntervalSinceNow:-HOUR] formattedAsTimeAgo]);
    NSLog(@"2 Hours: %@\n", [[NSDate dateWithTimeIntervalSinceNow:-2*HOUR] formattedAsTimeAgo]);
    NSLog(@"1 Day: %@\n", [[NSDate dateWithTimeIntervalSinceNow:-1*DAY] formattedAsTimeAgo]);
    NSLog(@"1 Day + 3 seconds: %@\n", [[NSDate dateWithTimeIntervalSinceNow:-1*DAY-3] formattedAsTimeAgo]);
    NSLog(@"2 Days: %@\n", [[NSDate dateWithTimeIntervalSinceNow:-2*DAY] formattedAsTimeAgo]);
    NSLog(@"3 Days: %@\n", [[NSDate dateWithTimeIntervalSinceNow:-3*DAY] formattedAsTimeAgo]);
    NSLog(@"5 Days: %@\n", [[NSDate dateWithTimeIntervalSinceNow:-5*DAY] formattedAsTimeAgo]);
    NSLog(@"6 Days: %@\n", [[NSDate dateWithTimeIntervalSinceNow:-6*DAY] formattedAsTimeAgo]);
    NSLog(@"7 Days - 1 second: %@\n", [[NSDate dateWithTimeIntervalSinceNow:-7*DAY+1] formattedAsTimeAgo]);
    NSLog(@"10 Days: %@\n", [[NSDate dateWithTimeIntervalSinceNow:-10*DAY] formattedAsTimeAgo]);
    NSLog(@"1 Month + 1 second: %@\n", [[NSDate dateWithTimeIntervalSinceNow:-MONTH-1] formattedAsTimeAgo]);
    NSLog(@"1 Year - 1 second: %@\n", [[NSDate dateWithTimeIntervalSinceNow:-YEAR+1] formattedAsTimeAgo]);
    NSLog(@"1 Year + 1 second: %@\n", [[NSDate dateWithTimeIntervalSinceNow:-YEAR+1] formattedAsTimeAgo]);
}
/*
 =======================================================================
 */



@end
