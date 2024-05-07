# lib
SlidingWindowBuffer

Copyright: 2023 MR Research AG  
Main author: Timo Hanke (timohanke)  
Contributors: Andy Gura (AndyGura)  

## Class `SlidingWindowBuffer<X>`

``` motoko no-repl
class SlidingWindowBuffer<X>()
```

Sliding window buffer

A linear buffer with random access where we can add at end and delete from
the beginning.  Elements remain at their original position, despite
deletion, hence the data structure becomes in fact a sliding window into an
ever-growing buffer.

This data structure consists of a pair of Vectors called `old` and `new`.
We always add to `new`.  While `old` is empty we delete from `new` but only
until the waste in `new` exceeds sqrt(n). When `new` has >sqrt(n) waste
then we rename `new` to `old` and create a fresh empty `new`. Now deletions
happen from old, until old is empty. Then `old` is discarded and deletions
happen from `new` again until the waste in `new` exceeds sqrt(n). Then the
shift starts all over again. Etc.

Only the waste in `new` is limited to sqrt(n). The waste in `old` is not limited.
Hence, the largest waste occurs if we do n additions first, then n deletions.

### Function `add`
``` motoko no-repl
func add(x : X) : Nat
```

Add an element to the end


### Function `getOpt`
``` motoko no-repl
func getOpt(i : Nat) : ?X
```

Random access based on absolute (ever-growing) index.
Returns `null` if the index falls outside the sliding window on either end.


### Function `delete`
``` motoko no-repl
func delete(n : Nat)
```

Delete n elements from the beginning.
Traps if less than n elements are available.


### Function `offset`
``` motoko no-repl
func offset() : Nat
```

The offset of the sliding window.
If the window is non-empty then this equals the index of the first
element in the window.


### Function `size`
``` motoko no-repl
func size() : Nat
```

The size of the whole virtual buffer including deletions.
This equals the index of the next element that would be added.


### Function `len`
``` motoko no-repl
func len() : Nat
```

The length of the window, i.e. the number of elements that are actually
available to get.
