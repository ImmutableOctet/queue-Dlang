/*
	Very basic queue module for the D programming language.
*/

module queue;

// Imports:
private import std.algorithm;

// Classes:
class Queue(T)
{
	public:
		// Functions:
		static bool compareQueues(const Queue X, const Queue Y, const bool checkLengths=true)
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
		this(const bool ignore=false, const bool reuse=true)
		{
			this(16, ignore, reuse);
		}

		this(const size_t size, const bool ignore=false, const bool reuse=true)
		{
			this(new T[size], size, ignore, reuse);
		}

		this(T[] data, const bool ignore=false, const bool reuse=true)
		{
			this(data, data.length, ignore, reuse);
		}

		this(T[] data, const size_t size, const bool ignore=false, const bool reuse=true)
		{
			this.initSize = size;
			this._data = data;

			this.ignoreInfo = ignore;
			this.reuseIndices = reuse;
		}

		this(const Queue queue)
		{
			this(queue, queue.ignoreInfo, queue.reuseIndices);
		}

		this(const Queue queue, const bool ignore=false, const bool reuse=true)
		{
			this(queue._data.dup(), queue.initSize, ignore, reuse);

			inPosition = queue.inPosition;
			outPosition = queue.outPosition;
		}

		// Destructor(s):
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
		Queue clone() const
		{
			return new Queue(this);
		}
		
		// Generates a new 'Queue' with reverse contents.
		// To reverse this queue, call 'reverseContents'.
		Queue reverse() const
		{
			auto q = new Queue(this);

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

			// copy(...);

			//return area.dup();

			return output;
		}

		bool compare(const Queue queue, const bool checkLengths=true) const
		{
			return compareQueues(this, queue, checkLengths);
		}

		void push(T value) // void put(...)
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

		// Properties:
		
		// The current "area" of the internal array.
		// This only slices the internal array,
		// to generate a new array, call 'toArray'.
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

		@property size_t high() const
		{
			return max(inPosition, outPosition);
		}

		@property size_t low() const
		{
			return min(inPosition, outPosition);
		}

		@property bool empty() const
		{
			return (length == 0);
		}

		@property size_t length() const
		{
			return (high-low);
		}

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
	private:
		// Fields (Private):
		T[] _data;

		size_t inPosition;
		size_t outPosition;
		
		const size_t initSize;
};