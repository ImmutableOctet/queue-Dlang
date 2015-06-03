// Imports:
import queue;

// Standard library:
import std.stdio;
import std.conv;

// Functions:
int main(string[] argv)
{
	const size_t entries = 32; // 128;

    auto q = Queue!int(entries);

	size_t removedEntries = 0;

	writeln("Adding " ~ to!string(entries) ~ " entries to a queue, whilst removing entries for each even number.\n");

	for (size_t i = 1; i <= entries; i++)
	{
		q.push(i);

		if ( i < 8 || (i % 2) == 0)
		{
			q.pop();

			removedEntries++;
		}
	}

	q.reverseContents();

	const int[] area = q.area;
	int[] contents = q.toArray();

	writeln("Contents (Reversed):\n");

	writeln("First: " ~ to!string(q.front()));
	writeln("Last: " ~ to!string(q.back()));

	//foreach (int item; contents)
	//while(!q.empty())
	for (auto i = 0; i < area.length; i++)
	{
		writeln(to!string(contents[i]) ~ ", " ~ to!string(area[i]) ~ ", " ~ to!string(q.pop()));
	}

	/*
	foreach (int item; contents)
	{
		writeln(item);
	}
	*/

	writeln();
	writeln(to!string(removedEntries) ~ " entries removed.");

	readln();

	// Return the default response.
    return 0;
}
