/**
 * Proleptic Gregorian calendar: timestamp
 *
 * Copyright: Maxim Freck, 2016–2017.
 * Authors:   Maxim Freck <maxim@freck.pp.ru>
 * License:   $(LINK2 http://www.boost.org/LICENSE_1_0.txt, Boost License 1.0)
 */
module pgc.timestamp;

public import pgc.date;
public import pgc.exception;
public import pgc.time;

alias Timestamp = ulong;

/***********************************
 * Returns: Timestamp ulong for a given date and time
 *
 * Params:
 *  date = Date uint
 *  time = Time uint
 *
 * See_Also: `pgc.date.mkDate`, `pgc.time.mkTime`
 */
pure nothrow Timestamp mkTimestamp(Date date, Time time) @safe @nogc
{
	return ( (cast(ulong)(date) << 32) | time );
}

/***********************************
 * Returns: Date uint for a given timestamp
 *
 * Params:
 *  stamp = timestamp
 */
pure nothrow Date date(Timestamp stamp) @safe @nogc
{
	return cast(Date)(stamp >> 32);
}

/***********************************
 * Returns: Time uint for a given timestamp
 *
 * Params:
 *  stamp = timestamp
 */
pure nothrow Time time(Timestamp stamp) @safe @nogc
{
	return cast(Time)(stamp);
}

version(Posix) {
	import core.sys.posix.sys.time: gettimeofday, gmtime, localtime, timeval;

	/***********************************
	 * Returns: the current timestamp in UTC
	 */
	Timestamp ThisMomentUTC()
	{
		timeval time;
		gettimeofday(&time, null);
		auto tm = gmtime(&time.tv_sec);
		return mkTimestamp(
			mkDate(tm.tm_mday, tm.tm_mon+1, tm.tm_year+1900),
			mkTime(tm.tm_hour, tm.tm_min, tm.tm_sec, cast(int)(time.tv_usec/31))
		);
	}

	/***********************************
	 * Returns: the current timestamp in a local time zone
	 */
	Timestamp ThisMomentLocal()
	{
		timeval time;
		gettimeofday(&time, null);
		auto tm = localtime(&time.tv_sec);
		return mkTimestamp(
			mkDate(tm.tm_mday, tm.tm_mon+1, tm.tm_year+1900),
			mkTime(tm.tm_hour, tm.tm_min, tm.tm_sec, cast(int)(time.tv_usec/31))
		);
	}
}

version(Windows) {
	import core.sys.windows.windows: GetLocalTime, GetSystemTime, SYSTEMTIME;

	/***********************************
	 * Returns: the current timestamp in UTC
	 */
	Timestamp thisMomentUTC()
	{
		SYSTEMTIME time;
		GetSystemTime(&time);
		return mkTimestamp(
			mkDate(time.wDay, time.wMonth, time.wYear),
			mkTime(time.wHour, time.wMinute, time.wSecond, time.wMilliseconds*32)
		);
	}

	/***********************************
	 * Returns: the current timestamp in a local time zone
	 */
	Timestamp thisMomentLocal()
	{
		SYSTEMTIME time;
		GetLocalTime(&time);
		return mkTimestamp(
			mkDate(time.wDay, time.wMonth, time.wYear),
			mkTime(time.wHour, time.wMinute, time.wSecond, time.wMilliseconds*32)
		);
	}
}
