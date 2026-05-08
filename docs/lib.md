# lib

SlidingWindowBuffer

Copyright: 2023-2024 MR Research AG
Main author: Timo Hanke (timohanke)
Contributors: Andy Gura (AndyGura), Andrii Stepanov (AStepanov25)

## Type `VectorStableData`

```motoko no-repl
type VectorStableData<X> = {
  data_blocks : [var [var ?X]];
  i_block : Nat;
  i_element : Nat;
  start_ : Nat;
};

```

Stable data for a `Vector`

## Class `Vector<X>`

```motoko no-repl
class Vector<X>()

```

`Vector` class used by `SlidingWindowBuffer`

### Function `share`

```motoko no-repl
func share() : VectorStableData<X>

```

Converts the `Vector` to stable data

### Function `unshare`

```motoko no-repl
func unshare(data : VectorStableData<X>)

```

Restores the `Vector` from stable data

### Function `size`

```motoko no-repl
func size() : Nat

```

Returns the total capacity of the vector including deleted elements

### Function `add`

```motoko no-repl
func add(element : X) : Nat

```

Adds an element to the end of the vector.
Returns the absolute index of the added element.

### Function `getOpt`

```motoko no-repl
func getOpt(index : Nat) : ?X

```

Returns the element at the given index, or `null` if the index is out of bounds or the element has been deleted.

### Function `delete`

```motoko no-repl
func delete(n : Nat)

```

Deletes `n` elements from the beginning of the vector.

### Function `deleteTo`

```motoko no-repl
func deleteTo(end : Nat)

```

Deletes elements from the beginning up to but excluding position `end`.
If `end <= start_` then nothing gets deleted.
Traps if `end > size()`.

### Function `len`

```motoko no-repl
func len() : Nat

```

Returns the number of non-deleted entries.

### Function `start`

```motoko no-repl
func start() : Nat

```

Returns the number of deleted entries.

## Type `StableData`

```motoko no-repl
type StableData<X> = {
  old : ?VectorStableData<X>;
  new : VectorStableData<X>;
  i_old : Nat;
  i_new : Nat;
};

```

Stable data for a sliding window buffer

## Class `SlidingWindowBuffer<X>`

```motoko no-repl
class SlidingWindowBuffer<X>()

```

Sliding window buffer

A linear buffer with random access where we can add at end and delete from
the beginning. Elements remain at their original position, despite
deletion, hence the data structure becomes in fact a sliding window into an
ever-growing buffer.

This data structure consists of a pair of Vectors called `old` and `new`.
We always add to `new`. While `old` is empty we delete from `new` but only
until the waste in `new` exceeds sqrt(n). When `new` has >sqrt(n) waste
then we rename `new` to `old` and create a fresh empty `new`. Now deletions
happen from old, until old is empty. Then `old` is discarded and deletions
happen from `new` again until the waste in `new` exceeds sqrt(n). Then the
shift starts all over again. Etc.

Only the waste in `new` is limited to sqrt(n). The waste in `old` is not limited.
Hence, the largest waste occurs if we do n additions first, then n deletions.

### Function `share`

```motoko no-repl
func share() : StableData<X>

```

Converts the buffer to stable data

### Function `unshare`

```motoko no-repl
func unshare(data : StableData<X>)

```

Restores the buffer from stable data

### Function `add`

```motoko no-repl
func add(x : X) : Nat

```

Add an element to the end

### Function `getOpt`

```motoko no-repl
func getOpt(i : Nat) : ?X

```

Random access based on absolute (ever-growing) index.
Returns `null` if the index falls outside the sliding window on either end.

### Function `delete`

```motoko no-repl
func delete(n : Nat)

```

Delete n elements from the beginning.
Traps if less than n elements are available.

### Function `deleteTo`

```motoko no-repl
func deleteTo(end_ : Nat)

```

Delete elements from the beginning to the given end position (exclusive).

### Function `start`

```motoko no-repl
func start() : Nat

```

The starting position of the sliding window.
If the window is non-empty then this equals the index of the first
element in the window.

### Function `end`

```motoko no-repl
func end() : Nat

```

The ending position (exclusive) of the sliding window
= the index of the next element that would be added
= the total number of additions that have ever been made
= the size of the whole virtual buffer including deletions

### Function `len`

```motoko no-repl
func len() : Nat

```

The length of the window, i.e. the number of elements that are actually
available to get.
