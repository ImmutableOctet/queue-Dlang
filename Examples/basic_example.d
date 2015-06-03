// Imports:
import queue;

// Standard library:
import std.stdio;

// Functions:
int main(string[] argv)
{
	auto x = Queue!int(64); // (1024*1024*128);

	writeln("Running example...");

	for (int i = 1; i <= 16; i++)
	{
		for (int test = i; test <= (i+20); test++)
		{
			x.push(test);
		}

		if ((i % 4) == 0)
		{
			while (!x.empty())
			{
				auto value = x.pop();
				
				writeln(value);
				
				/*
				if ((value % 20) == 0)
				{
					writeln("------");
				}
				*/
			}

			writeln();
		}
	}

	writeln("Example finished; enter a line to exit.");

	readln();
	
	// Return the default response.
    return 0;
}
