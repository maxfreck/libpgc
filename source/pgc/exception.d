/**
 * Proleptic Gregorian calendar exception
 *
 * License:   $(LINK2 http://www.boost.org/LICENSE_1_0.txt, Boost License 1.0)
 * Copyright: Maxim Freck, 2016–2017.
 * Authors:   Maxim Freck <maxim@freck.pp.ru>
 */
module pgc.exception;

/// Library exception
class PgcException : Exception {
	/// constructor
	pure nothrow this(string s, string fn = __FILE__, size_t ln = __LINE__) @safe
	{
		super(s, fn, ln);
	}
}
