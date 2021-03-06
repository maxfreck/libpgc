/**
 * Proleptic Gregorian calendar: date ranges
 *
 * Copyright: Maxim Freck, 2017.
 * Authors:   Maxim Freck <maxim@freck.pp.ru>
 * License:   $(LINK2 http://www.boost.org/LICENSE_1_0.txt, Boost License 1.0)
 */
module pgc.daterange;

public import pgc.date;

/***********************************
 * An implementation of a ForwardRange for dates.
 *
 * Examples:
 * --------------------
 * DateRange(mkDate(20, 3, 2016), mkDate(4, 4, 2016)); //returns the date range between 2016-03-20 and 2016-04-04
 * DateRange(2, 2016); //return the date range for the Feb. 2016
 * DateRange(2016); //return the date range for the whole 2016 year
 * --------------------
 */
struct DateRange {
	private Date frontDate;
	private Date endDate;

	@disable private this();

	/// Constructor
	this(Date start, Date end) @safe
	{
		import std.algorithm: max, min;
		this.frontDate = min(start, end);
		this.endDate = max(start, end).nextDay;
	}

	/// ditto
	this(int month, int year) @safe
	{
		this.frontDate = mkDate(1, month, year);
		this.endDate = mkDate(daysInMonth(month, year), month, year).nextDay;
	}

	/// ditto
	this(int year) @safe
	{
		this.frontDate = mkDate(1, 1, year);
		this.endDate = mkDateISO(1, 1, ++year);
	}

	/// for Range access
	pure nothrow bool empty() const @safe
	{
		return this.frontDate == this.endDate;
	}

	/// ditto
	pure nothrow auto front() @safe
	{
		return this.frontDate;
	}

	/// ditto
	pure void popFront() @safe
	{
		if (this.frontDate < this.endDate) this.frontDate = this.frontDate.nextDay;
	}

	/// ditto
	auto save() const @safe
	{
		return this;
	}

	/***********************************
	 * Returns the number of days in a range
	 */
	@property @safe pure nothrow auto days()
	{
		return daysBetween(this.frontDate, this.endDate);
	}
}


///
@safe unittest
{
	auto Feb2016 = DateRange(2,2016);

	assert(Feb2016.days == 29);

	Feb2016.popFront();
	assert(Feb2016.front == mkDate(2, 2, 2016));
}