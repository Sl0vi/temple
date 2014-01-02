/**
 * Temple (C) Dylan Knutson, 2013, distributed under the:
 * Boost Software License - Version 1.0 - August 17th, 2003
 *
 * Permission is hereby granted, free of charge, to any person or organization
 * obtaining a copy of the software and accompanying documentation covered by
 * this license (the "Software") to use, reproduce, display, distribute,
 * execute, and transmit the Software, and to prepare derivative works of the
 * Software, and to permit third-parties to whom the Software is furnished to
 * do so, all subject to the following:
 *
 * The copyright notices in the Software and this entire statement, including
 * the above license grant, this restriction and the following disclaimer,
 * must be included in all copies of the Software, in whole or in part, and
 * all derivative works of the Software, unless such copies or derivative
 * works are solely in the form of machine-executable object code generated by
 * a source language processor.
 */

module temple.output_stream;

version(Have_vibe_d)
{
	public import vibe.core.stream : OutputStream;
	private import vibe.core.stream : InputStream;
}
else
{
	// vibe.d OutputStream compatibility

	interface OutputStream {
		/** Writes an array of bytes to the stream.
		*/
		void write(in ubyte[] bytes);

		/** Writes an array of chars to the stream.
		*/
		final void write(in char[] bytes)
		{
			write(cast(const(ubyte)[])bytes);
		}

		/** These methods provide an output range interface.

			Note that these functions do not flush the output stream for performance reasons. flush()
			needs to be called manually afterwards.

			See_Also: $(LINK http://dlang.org/phobos/std_range.html#isOutputRange)
		*/
		final void put(ubyte elem) { write((&elem)[0 .. 1]); }
		/// ditto
		final void put(in ubyte[] elems) { write(elems); }
		/// ditto
		final void put(char elem) { write((&elem)[0 .. 1]); }
		/// ditto
		final void put(in char[] elems) { write(elems); }
		/// ditto
		final void put(dchar elem) { import std.utf; char[4] chars; encode(chars, elem); put(chars); }
		/// ditto
		final void put(in dchar[] elems) { foreach( ch; elems ) put(ch); }
	}
}

class AppenderOutputStream : OutputStream
{
	import std.array;

	Appender!string accum;

	void write(in ubyte[] bytes)
	{
		accum.put(cast(string) bytes);
	}

	string data()
	{
		return accum.data;
	}

	void clear()
	{
		if(__ctfe)
		{
			// Screw memory usage! We're a compiler!
			accum = appender!string;
		}
		else
		{
			accum.clear();
		}
	}

	version(Have_vibe_d)
	{
		// Stubbed out to conform to vibed interface
		void flush() {}
		void finalize() {}
		void write(InputStream stream, ulong nbytes = 0LU)
		{
			writeDefault(stream, nbytes);
		}
	}
}