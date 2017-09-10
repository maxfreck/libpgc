/**
 * Proleptic Gregorian calendar: dates
 *
 * Copyright: Maxim Freck, 2016–2017.
 * Authors:   Maxim Freck <maxim@freck.pp.ru>
 * License:   $(LINK2 http://www.boost.org/LICENSE_1_0.txt, Boost License 1.0)
 */
module pgc.date;

public import pgc.exception;

alias Date = uint;

private enum int YEAR_MASK = 0x7FFFFF; //8_388_607
/// 4_194_303 – maximum year value is 4_194_303 BCE or 4_194_303 CE
enum int MAX_YEAR  = 0x3FFFFF; 
/// Common era start 01.01.01
enum int CE_START  = 0x80000021;

///Date era enum
enum Era:byte {
	BCE = -1,
	CE  = 1,
}

/***********************************
 * Returns: Date uint for a given date (day, month and year)
 *
 * Params:
 *  day   = the number of the day
 *  month = the number of the month
 *  year  = the number of the year
 */
pure Date mkDate(int day, int month, int year) @safe
{
	assertDate(day, month, year);
	return ( (day & 0x1F) | ((month & 0x0F) << 5) | (((year+MAX_YEAR)&YEAR_MASK) << 9) );
}

/***********************************
 * Returns: Date uint for a given date using ISO year (1 BC = 0, 2 BC = -1 and so on)
 *
 * Params:
 *  day   = the number of the day
 *  month = the number of the month
 *  year  = the number of the year accroding to ISO 8601
 */
pure Date mkDateISO(int day, int month, int year) @safe
{
	return mkDate(day, month, (year < 1) ? --year : year);
}

/***********************************
 * Checks the validity of a date
 *
 * Params:
 *  day   = the number of the day
 *  month = the number of the month
 *  year  = the number of the year
 */
pure private void assertDate(int day, int month, int year) @safe
{
	import std.conv: to;
	if (year < -MAX_YEAR || year == 0 || year > MAX_YEAR) {
		throw new PgcException("The absolute year value "~to!string(year)~" is out of bounds [1..4 194 303]");
	}
	if (month < 1 || month > 12) {
		throw new PgcException("The month value "~to!string(month)~" is out of bounds [1..12]");
	}
	auto maxDay = daysInMonth(month, year);
	if (day < 1 || day > maxDay) {
		throw new PgcException(
			"The day value "~to!string(day)~" is out of bounds [1.."~to!string(maxDay)~
			"] (month "~to!string(month)~", year "~to!string(year)~")"
		);
	}
}

/***********************************
 * Returns: the quantity of days in a given month
 *
 * Params:
 *  month = the number of the month
 *  year  = the number of the year
 */
@safe pure nothrow ubyte daysInMonth(int month, int year)
{
	switch (month) {
		case 4:
		case 6:
		case 9:
		case 11:
			return 30;
		case 2:
			return year.isLeap ? 29 : 28;
		default:
			return 31;
	}
}

/***********************************
 * Returns: true for a Leap year
 *
 * Params:
 *  year  = the number of the year
 */
pure nothrow bool isLeap(int year) @safe @nogc
{
	if (year <= 0) year++;
	if (year%4 != 0) return false;
	if (year%100 != 0) return true;
	if (year%400 != 0) return false;
	return true;
}

/***********************************
 * Returns: the number of days between two given dates
 *
 * Params:
 *  d1 = first date
 *  d2 = second date
 */
pure nothrow uint daysBetween(Date d1, Date d2) @safe @nogc
{
	import std.algorithm: max, min;
	auto dateMin = min(d1, d2);
	auto dateMax = max(d1, d2);

	return g(dateMax.day, dateMax.month, dateMax.isoYear) - g(dateMin.day, dateMin.month, dateMin.isoYear);
}

private pure nothrow uint g(ubyte d, ubyte m, int y) @safe @nogc
{
	m = (m + 9) % 12;
	y = y - m/10;
	return 365*y + y/4 - y/100 + y/400 + (m*306 + 5)/10 + ( d - 1 );
}

/***********************************
 * Returns: the day of a given date
 *
 * Params:
 *  d = date
 */
pure nothrow ubyte day(Date d) @safe @nogc
{
	return cast(ubyte)(d & 0x1F);
}

/***********************************
 * Returns: the month of a given date
 *
 * Params:
 *  d = date
 */
pure nothrow ubyte month(Date d) @safe @nogc
{
	return cast(ubyte)((d >> 5) & 0x0F);
}

/***********************************
 * Returns: the year of a given date
 *
 * Params:
 *  d = date
 */
pure nothrow int year(Date d) @safe @nogc
{
	return cast(int)( ((d >> 9) & YEAR_MASK) - MAX_YEAR);
}

/***********************************
 * Returns: the absolute year value of a given date
 *
 * Params:
 *  d = date
 */
pure nothrow int absYear(Date d) @safe @nogc
{
	auto year = d.year;
	return (year < 0) ? -year : year;
}

/***********************************
 * Returns: the year of a given date according to ISO 8601
 *
 * Params:
 *  d = date
 */
pure nothrow int isoYear(Date d) @safe @nogc
{
	auto year = d.year;
	return (year < 0) ? year+1 : year;
}

/***********************************
 * Returns: the holocene year of a given date
 *
 * Params:
 *  d = date
 */
pure nothrow int holoceneYear(Date d) @safe @nogc
{
	return 10_000 + d.isoYear;
}

/***********************************
 * Returns: the era of a given date (Common Era, Before Common Era)
 *
 * Params:
 *  d = date
 */
pure nothrow Era era(Date d) @safe @nogc
{
	return (d < CE_START) ? Era.BCE : Era.CE;
}

/***********************************
 * Returns: the next day of a given date
 *
 * Params:
 *  d = date
 */
pure Date nextDay(Date d) @safe
{
	int day = d.day;
	int month = d.month;
	int year = d.year;
	if (++day > daysInMonth(month, year)) {
		day = 1;
		if (++month > 12) {
			month = 1;
			year++;
			if (year == 0) year++;
		}
	}
	return mkDate(day, month, year);
}

/***********************************
 * Returns: the previous day of a given date
 *
 * Params:
 *  d = date
 */
pure Date prevDay(Date d) @safe
{
	int day = d.day;
	int month = d.month;
	int year = d.year;

	if (--day < 1) {
		if (--month < 1) {
			month = 12;
			year--;
			if (year == 0) year--;
		}
		day = daysInMonth(month, year);
	}

	return mkDate(day, month, year);
}


version(Posix) {
	import core.stdc.time: gtime, time;

	/***********************************
	 * Returns: the current date in UTC
	 */
	Date todayUTC()
	{
		auto timer = time(null);
		auto tm = gmtime(&timer);
		return mkDate(tm.tm_mday, tm.tm_mon+1, tm.tm_year+1900);
	}

	/***********************************
	 * Returns: the current local date
	 */
	Date todayLocal()
	{
		auto timer = time(null);
		auto tm = localtime(&timer);
		return mkDate(tm.tm_mday, tm.tm_mon+1, tm.tm_year+1900);
	}
}

version(Windows) {
	import core.sys.windows.windows: GetSystemTime, SYSTEMTIME;

	/***********************************
	 * Returns: the current date in UTC
	 */
	Date todayUTC()
	{
		SYSTEMTIME time;
		GetSystemTime(&time);
		return mkDate(time.wDay, time.wMonth, time.wYear);
	}

	/***********************************
	 * Returns: the current local date
	 */
	Date todayLocal()
	{
		SYSTEMTIME time;
		GetLocalTime(&time);
		return mkDate(time.wDay, time.wMonth, time.wYear);
	}
}


@safe unittest
{
	void assertLeap()
	{
		assert(800.isLeap == true);
		assert((-1).isLeap == true);
		assert((-97).isLeap == true);
	
		assert((-1500).isLeap == false);
		assert((-101).isLeap == false);
	}

	void assertCreation()
	{
		immutable platonBirth = mkDate(10,11,-427);

		assert(platonBirth.day == 10);
		assert(platonBirth.month == 11);

		assert(platonBirth.year == -427);
		assert(platonBirth.absYear == 427);
		assert(platonBirth.isoYear == -426);
		assert(platonBirth.holoceneYear == 9574);

		assert(platonBirth.era == Era.BCE);
	}

	void assertIntervals()
	{
		auto sputnikOne = mkDate(4,10,1957);
		auto gagarin = mkDate(12,4,1961);

		assert(daysBetween(sputnikOne, gagarin) == 1286);
	}

	void assertIteration()
	{
		immutable date = mkDate(31,12,-1);
		immutable next = date.nextDay;

		assert(next.day == 1);
		assert(next.month == 1);
		assert(next.year == 1);

		immutable prev = next.prevDay;
		assert(prev == date);
	}


	assertLeap();
	assertCreation();
	assertIntervals();
	assertIteration();
}