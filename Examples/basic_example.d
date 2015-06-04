// Imports:
import queue;

// Standard library:
import std.stdio;
import std.conv;

// Functions:
int main(string[] argv)
{
	Queue!int.default_size = 16; // 64;

	auto queue = Queue!int.init;

	writeln("Running example...");

	for (int x = 0; x <= 16; x++)
	{
		queue.push(x);
	}

	while (!queue.empty)
	{
		const auto f = queue.front;
		const auto element = queue.pop();

		if (element == f)
		{
			writeln(to!string(f) ~ " == " ~ to!string(element));
		}
		else
		{
			writeln("Internal error.");

			break;
		}
	}

	writeln("Example finished; enter a line to exit.");

	readln();
	
	// Return the default response.
	return 0;
}
