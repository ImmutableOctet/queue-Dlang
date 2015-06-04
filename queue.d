/*
	Very basic queue module for the D programming language.

	TO DO:
		* Optimize the deep-copy routines to account for unused space.
*/

module queue;

// Imports:

// Standard library:
private import std.algorithm;
import std.stdio;

// Structures:
struct Queue(T)
{
	public:
		// Global variable(s):
		static size_t default_size = 16;

		// Functions:

		// This specifies if the two 'Queue' objects are identical.
		static bool compareQueues(in Queue X, in Queue Y, const bool checkLengths=true)
		{
			if (X == Y)
			{
				return true;
			}

			if (checkLengths && (X.length != Y.length))
			{
				return false;
			}

			for (size_t index = max(X.outPosition, Y.outPosition); index < min(X.inPosition, Y.inPosition); index++)
			{
				if (X._data[index] != Y._data[index])
				{
					return false;
				}
			}

			// Return the default response.
			return true;
		}

		// Constructor(s):
		@property @safe static Queue init() nothrow
		{
			return Queue(false, true);
		}

		//@disable this();

		/*
			The 'ignore' argument (Represented by 'ignoreInfo') specifies
			if "phantom" entries should be ignored, or cleared upon removal.
			Unless you plan to clear this queue afterword, or you're
			dealing with scope-allocated types, do not enable this.

			The 'reuse' argument (Represented by 'reuseIndices') specifies
			if previous segments of the internal buffer/array
			should be reused before attempting a resize operation.
		*/
		this(const bool ignore=false, const bool reuse=true)
		{
			this(default_size, ignore, reuse);
		}

		// This will allocate a queue with the size specified;
		// for details on the other arguments, please view the default implementation's documentation.
		this(const size_t size, const bool ignore=false, const bool reuse=true)
		{
			this(new T[size], size, ignore, reuse);
		}

		// See the primary implementation for details; 'data' is used as the internal buffer.
		this(T[] data, const bool ignore=false, const bool reuse=true)
		{
			this(data, data.length, ignore, reuse);
		}

		// This constructor uses the array specified, it does not duplicate it.
		this(T[] data, const size_t size, const bool ignore=false, const bool reuse=true)
		{
			this.initSize = size;
			this._data = data;

			this.ignoreInfo = ignore;
			this.reuseIndices = reuse;
		}

		// This will assume all settings from the 'queue' argument.
		// The internal array will be copied; deep copy operation.
		this(in Queue queue)
		{
			this(queue, queue.ignoreInfo, queue.reuseIndices);
		}

		// All settings (Excluding the arguments) will be copied from 'queue'.
		this(in Queue queue, const bool ignore, const bool reuse=true)
		{
			this(queue._data.dup(), queue.initSize, ignore, reuse);

			inPosition = queue.inPosition;
			outPosition = queue.outPosition;
		}

		// Automated copy constructor.
		/*
		this(this)
		{
			// Make a duplicate of the internal buffer.
			_data = _data.dup();
		}
		*/

		// Destructor(s):

		/*
			This will reset a queue to an empty state, clearing
			and/or remaking the internal array if needed/requested.

			The 'flush' argument will ensure that every element
			of the internal array is default-initialized.

			The 'remake' argument will recreate the internal array completely.
			This will use the size this queue was created with.
		*/
		void clear(const bool flush=true, bool remake=false)
		{
			if (remake)
			{
				this._data = new T[initSize];
			}
			else
			{
				if (flush)
				{
					for (auto i = 0; i < this._data.length; i++)
					{
						this._data[i] = T();
					}
				}
			}
			
			inPosition = 0;
			outPosition = 0;
			
			return;
		}

		// Methods:

		// Performs a deep-copy of this queue, generating a new object.
		Queue save() const
		{
			return Queue(this);
		}
		
		// Generates a new 'Queue' with reverse contents.
		// To reverse this queue, call 'reverseContents'.
		Queue reverse() const
		{
			auto q = Queue(this);

			q.reverseContents();

			return q;
		}

		// This reverses the contents of this container.
		void reverseContents()
		{
			// Local variable(s):
			const auto low = this.low;
			const auto finalIndex = (this.high-1);

			// Iterate through every element, swapping it with the inverse element:
			for (size_t i = finalIndex; i > low; i -= 2)
			{
				auto inversePosition = (finalIndex-(i-low));
				auto current = _data[i];

				_data[i] = _data[inversePosition];
				_data[inversePosition] = current;
			}

			return;
		}

		/*
			Experimental; use at your own risk.
			
			The 'sorter' argument specifies if the first
			argument should be swapped with the second.

			This does not do full relational sorting, only sequential.
		*/
		void sort(bool function(in T, in T) sorter)
		{
			const auto low = this.low;
			const auto high = this.high;

			//if (length < 2)
			if ((high-low) < 2)
			{
				return;
			}
			
			for (size_t i = low; i < high; i++)
			{
				if (sorter(_data[i], _data[i+1]))
				{
					const auto nextIndex = (i+1);
					const auto current = _data[i];

					_data[i] = _data[nextIndex];
					_data[nextIndex] = current;
				}
			}
			
			return;
		}

		// This generates a copy of the internal contents.
		// Basically, this is 'area', only it copies instead.
		T[] toArray() const
		{
			auto output = new T[length];

			const auto low = this.low;
			const auto high = this.high;

			for (size_t i = low; i < high; i++)
			{
				output[i-low] = _data[i];
			}

			//copy(...);

			//return area.dup();

			return output;
		}

		bool compare(in Queue queue, const bool checkLengths=true) const
		{
			return compareQueues(this, queue, checkLengths);
		}

		void push(in T value) // void put(...)
		{
			// Local variable(s):

			// Cache the high and low points:
			const auto high = this.high;
			const auto low = this.low;

			if (reuseIndices && outPosition >= initSize && ((outPosition % initSize) == 0))
			{
				for (size_t i = low; i < high; i++)
				{
					_data[i-low] = _data[i];
					_data[i] = T();

					inPosition -= low;
					outPosition -= low;
				}
			}
			else
			{
				if (inPosition >= _data.length)
				{
					_data.length = _data.length * 2; // 1.5;
				}
			}

			_data[inPosition] = value;

			inPosition++; // % length;

			return;
		}

		T pop()
		{
			if (empty)
			{
				return T();
			}

			auto value = _data[outPosition];

			if (!ignoreInfo)
			{
				_data[outPosition] = T();
			}

			outPosition++;

			// Reset the input and output positions:
			if (empty)
			{
				inPosition = 0;
				outPosition = 0;
			}

			return value;
		}

		// Properties (Public):
		
		/*
			The current "area" of the internal array.
			
			This only slices the internal array,
			to generate a new array, call 'toArray'.

			Use this at your own risk.
		*/
		@property T[] area() // const
		{
			/*
			for (auto i = low; i < high; i++)
			{
				output[i-low] = _data[i];
			}
			*/

			return _data[low..high];
		}

		// The entry 'pop' will return next.
		@property T front() const
		{
			if (empty)
				return T();

			return _data[outPosition];
		}

		@property T back() const
		{
			if (empty)
				return T();
			
			return _data[inPosition-1];
		}

		@property bool empty() const
		{
			return (length == 0);
		}

		@property size_t length() const
		{
			return (high-low);
		}

		// API aliases:

		// Used for standard 'foreach' compliance.
		alias popfront = pop;

		// An alias used to represent the active
		// portion of the internal buffer/array.
		// For details, please view 'area'.
		alias data = area;

		// Fields (Public):

		/*
			If enabled, references previously taken out of the queue will linger.
			
			This is technically faster, just don't use this,
			unless you're planning to clear the queue after.
		*/
		bool ignoreInfo;

		// If enabled, previously utilized indices will be reused.
		// Causes occasional copy operations; use at your own risk.
		bool reuseIndices;
	protected:
		// Properties (Protected):
		@property size_t high() const
		{
			return max(inPosition, outPosition);
		}

		@property size_t low() const
		{
			return min(inPosition, outPosition);
		}
	private:
		// Fields (Private):

		// An array representing the internal elements of the queue.
		T[] _data;

		// The input and output positions of the queue:
		size_t inPosition;
		size_t outPosition;
		
		// The initial size of the internal buffer; used for internal purposes.
		size_t initSize;
};