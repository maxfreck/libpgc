/**
 * Proleptic Gregorian calendar: time
 *
 * Copyright: Maxim Freck, 2016–2017.
 * Authors:   Maxim Freck <maxim@freck.pp.ru>
 * License:   $(LINK2 http://www.boost.org/LICENSE_1_0.txt, Boost License 1.0)
 */
module pgc.time;

public import pgc.exception;

alias Time = uint;

/***********************************
 * Returns: Time uint for a given time value (hour, minute, second and split)
 *
 * Params:
 *  hour   = the number of the hour
 *  minute = the number of the minute
 *  second = the number of the second
 *  split  = the number of the split (1/32767 of a second)
 */
pure Time mkTime(int hour, int minute, int second, int split = 0) @safe
{
	assertTime(hour, minute, second, split);
	return (((hour & 0x1F) << 27) | ((minute & 0x3F) << 21) | ((second & 0x3F) << 15) | (split & 0x3FFF));
}

/***********************************
 * Checks the validity of a time
 *
 * Params:
 *  hour  = the number of the hour
 *  month = the number of the month
 *  year  = the number of the year
 */
pure private void assertTime(int hour, int minute, int second, int split = 0) @safe
{
	import std.conv: to;
	if (hour < 0 || hour > 23) throw new PgcException("Invalid hour value: "~to!string(hour));
	if (minute < 0 || minute > 59) throw new PgcException("Invalid minute value: "~to!string(minute));
	if (second < 0 || second > 59) throw new PgcException("Invalid second value: "~to!string(second));
	if (split < 0 || split > 32_768) throw new PgcException("Split "~to!string(split)~" is out of bound [0..32768]");
}

/***********************************
 * Returns: the hour of a given time
 *
 * Params:
 *  t = time
 */
pure nothrow ubyte hour(Time t) @safe @nogc
{
	return cast(ubyte)((t >> 27) & 0x1F);
}

/***********************************
 * Returns: the minute of a given time
 *
 * Params:
 *  t = time
 */
pure nothrow ubyte minute(Time t) @safe @nogc
{
	return cast(ubyte)((t >> 21) & 0x3F);
}

/***********************************
 * Returns: the second of a given time
 *
 * Params:
 *  t = time
 */
pure nothrow ubyte second(Time t) @safe @nogc
{
	return cast(ubyte)((t >> 15) & 0x3F);
}

/***********************************
 * Returns: the split (1/32767) of a given time
 *
 * Params:
 *  t = time
 */
pure nothrow ushort split(Time t) @safe @nogc
{
	return cast(ushort)(t & 0x7FFF);
}

version(Posix) {
	import core.sys.posix.sys.time: gettimeofday, gmtime, localtime, timeval;

	/***********************************
	 * Returns: the current time in UTC
	 */
	Time nowUTC()
	{
		timeval time;
		gettimeofday(&time, null);
		auto tm = gmtime(&time.tv_sec);

		return mkTime(tm.tm_hour, tm.tm_min, tm.tm_sec, cast(int)(time.tv_usec/31));
	}

	/***********************************
	 * Returns: the current local time
	 */
	Time nowLocal()
	{
		timeval time;
		gettimeofday(&time, null);
		auto tm = localtime(&time.tv_sec);

		return mkTime(tm.tm_hour, tm.tm_min, tm.tm_sec, cast(int)(time.tv_usec/31));
	}
}

version(Windows) {
	import core.sys.windows.windows: GetLocalTime, GetSystemTime, SYSTEMTIME;

	/***********************************
	 * Returns: the current time in UTC
	 */
	Time nowUTC()
	{
		SYSTEMTIME time;
		GetSystemTime(&time);
		return mkTime(time.wHour, time.wMinute, time.wSecond, time.wMilliseconds*16);
	}

	/***********************************
	 * Returns: the current local time
	 */
	Time nowLocal()
	{
		SYSTEMTIME time;
		GetLocalTime(&time);
		return mkTime(time.wHour, time.wMinute, time.wSecond, time.wMilliseconds*16);
	}
}