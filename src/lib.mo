/// Sliding window buffer
///
/// A linear buffer with random access where we can add at end and delete from
/// the beginning.  Elements remain at their original position, despite
/// deletion, hence the data structure becomes in fact a sliding window into an
/// ever-growing buffer.
///
/// This data structure consists of a pair of Vectors called `old` and `new`.
/// We always add to `new`.  While `old` is empty we delete from `new` but only
/// until the waste in `new` exceeds sqrt(n). When `new` has >sqrt(n) waste
/// then we rename `new` to `old` and create a fresh empty `new`. Now deletions
/// happen from old, until old is empty. Then `old` is discarded and deletions
/// happen from `new` again until the waste in `new` exceeds sqrt(n). Then the
/// shift starts all over again. Etc.
///
/// Only the waste in `new` is limited to sqrt(n). The waste in `old` is not limited.
/// Hence, the largest waste occurs if we do n additions first, then n deletions.
///
/// Copyright: 2023-26 MR Research AG
/// Main author: Timo Hanke (timohanke)
/// Contributors: Andy Gura (AndyGura), Andrii Stepanov (AStepanov25)

import Prim "mo:prim";
import { bitcountLeadingZero = leadingZeros; fromNat = nat32; toNat = nat } "mo:core/Nat32";
import VarArray "mo:core/VarArray";

module {
  // Deletable vector
  //
  // This data structure starts with a small subset of the Vector data structure
  // from https://mops.one/vector. Only the code for `add`, `getOpt` and `size`
  // is present here.
  //
  // Then we add a `delete` function which deleted from the beginning. It does
  // so not by shrinking the Vector but simply by overwriting the deleted
  // entries with `null`.
  //
  // Deletion will leave overhead that cannot be freed. But this problem will be
  // mitigated at the next level in the code that uses this Vector (in the
  // SlidingWindowBuffer module).
  module Vector {
    public type Vector<X> = {
      var data_blocks : [var [var ?X]];
      var i_block : Nat;
      var i_element : Nat;
      var start_ : Nat;
    };

    public func new<X>() : Vector<X> = {
      var data_blocks = [var [var]];
      var i_block = 1;
      var i_element = 0;
      var start_ = 0;
    };

    /// Returns the total capacity of the vector including deleted elements
    public func size<X>(self : Vector<X>) : Nat {
      let d = nat32(self.i_block);
      let i = nat32(self.i_element);
      let lz = leadingZeros(d / 3);
      nat((d -% (1 <>> lz)) <>> lz +% i);
    };

    func data_block_size(i_block : Nat) : Nat {
      nat(1 <>> leadingZeros(nat32(i_block) / 3));
    };

    func new_index_block_length(i_block : Nat32) : Nat {
      if (i_block <= 1) 2 else {
        let s = 30 - leadingZeros(i_block);
        nat(((i_block >> s) +% 1) << s);
      };
    };

    func grow_index_block_if_needed<X>(self : Vector<X>) {
      if (self.data_blocks.size() == self.i_block) {
        let new_blocks = VarArray.repeat<[var ?X]>([var], new_index_block_length(nat32(self.i_block)));
        var i = 0;
        while (i < self.i_block) {
          new_blocks[i] := self.data_blocks[i];
          i += 1;
        };
        self.data_blocks := new_blocks;
      };
    };

    /// Adds an element to the end of the vector.
    /// Returns the absolute index of the added element.
    public func add<X>(self : Vector<X>, element : X) : Nat {
      if (self.i_element == 0) {
        grow_index_block_if_needed(self);

        if (self.data_blocks[self.i_block].size() == 0) {
          self.data_blocks[self.i_block] := VarArray.repeat<?X>(
            null,
            data_block_size(self.i_block),
          );
        };
      };

      let last_data_block = self.data_blocks[self.i_block];

      last_data_block[self.i_element] := ?element;

      self.i_element += 1;
      if (self.i_element == last_data_block.size()) {
        self.i_element := 0;
        self.i_block += 1;
      };

      return self.size() - 1;
    };

    func locate(index : Nat) : (Nat, Nat) {
      let i = nat32(index);
      let lz = leadingZeros(i);
      let lz2 = lz >> 1;
      if (lz & 1 == 0) {
        (nat(((i << lz2) >> 16) ^ (0x10000 >> lz2)), nat(i & (0xFFFF >> lz2)));
      } else {
        (nat(((i << lz2) >> 15) ^ (0x18000 >> lz2)), nat(i & (0x7FFF >> lz2)));
      };
    };

    /// Returns the element at the given index, or `null` if the index is out of bounds or the element has been deleted.
    public func getOpt<X>(self : Vector<X>, index : Nat) : ?X {
      let (a, b) = locate(index);
      if (a < self.i_block or self.i_element != 0 and a == self.i_block) {
        self.data_blocks[a][b];
      } else {
        null;
      };
    };

    /// Overwrites the element at `index` with `element`.
    /// Traps if the index is out of bounds or the slot has been deleted.
    public func put<X>(self : Vector<X>, index : Nat, element : X) {
      let (a, b) = locate(index);
      let inRange = a < self.i_block or self.i_element != 0 and a == self.i_block;
      if (not inRange) Prim.trap("index out of bounds in put");
      switch (self.data_blocks[a][b]) {
        case (?_) self.data_blocks[a][b] := ?element;
        case null Prim.trap("index out of bounds in put");
      };
    };

    /// Deletes `n` elements from the beginning of the vector.
    public func delete<X>(self : Vector<X>, n : Nat) = deleteTo(self, self.start_ + n);

    /// Deletes elements from the beginning up to but excluding position `end`.
    /// If `end <= start_` then nothing gets deleted.
    /// Traps if `end > size()`.
    public func deleteTo<X>(self : Vector<X>, end : Nat) {
      if (end > self.size()) Prim.trap("index out of bounds in deleteTo");
      if (end <= self.start_) return;
      var pos = self.start_;
      while (pos < end) {
        let (a, b) = locate(pos);
        self.data_blocks[a][b] := null;
        pos += 1;
      };
      self.start_ := end;
    };

    /// Returns the number of non-deleted entries.
    public func len<X>(self : Vector<X>) : Nat = self.size() - self.start_;

    /// Returns the number of deleted entries.
    public func start<X>(self : Vector<X>) : Nat = self.start_;
  };

  public type SlidingWindowBuffer<X> = {
    var old : ?Vector.Vector<X>;
    var new : Vector.Vector<X>;
    var i_old : Nat;
    var i_new : Nat;
  };

  public func empty<X>() : SlidingWindowBuffer<X> = {
    var old = null;
    var new = Vector.new<X>();
    var i_old = 0;
    var i_new = 0;
  };

  /// Add an element to the end
  public func add<X>(self : SlidingWindowBuffer<X>, x : X) : Nat {
    self.new.add(x) + self.i_new;
  };

  /// Random access based on absolute (ever-growing) index.
  /// Returns `null` if the index falls outside the sliding window on either end.
  public func get<X>(self : SlidingWindowBuffer<X>, i : Nat) : ?X {
    if (i >= self.i_new) {
      self.new.getOpt(i - self.i_new : Nat);
    } else if (i >= self.i_old) {
      let ?vec = self.old else Prim.trap("old is null in Buffer");
      vec.getOpt(i - self.i_old : Nat);
    } else null;
  };

  /// Random access based on absolute (ever-growing) index.
  /// Traps if the index falls outside the sliding window on either end.
  public func at<X>(self : SlidingWindowBuffer<X>, i : Nat) : X {
    switch (get(self, i)) {
      case (?x) x;
      case null Prim.trap("index out of bounds in SlidingWindowBuffer.at");
    };
  };

  /// Overwrite the element at absolute index `i` with `value`.
  /// Traps if `i` is outside the sliding window [start(), end()).
  public func put<X>(self : SlidingWindowBuffer<X>, i : Nat, value : X) {
    if (i >= self.end()) Prim.trap("index out of bounds in SlidingWindowBuffer.put");
    if (i < self.start()) Prim.trap("index out of bounds in SlidingWindowBuffer.put");
    if (i >= self.i_new) {
      self.new.put(i - self.i_new : Nat, value);
    } else {
      let ?vec = self.old else Prim.trap("old is null in SlidingWindowBuffer.put");
      vec.put(i - self.i_old : Nat, value);
    };
  };

  func rotateIfNeeded<X>(self : SlidingWindowBuffer<X>) {
    let size = self.new.size();
    let s = nat32(size);
    let d = nat32(self.new.start());
    let bits = 32 - leadingZeros(s);
    let limit = s >> (bits >> 1);
    if (d > limit) {
      self.old := ?self.new;
      self.i_old := self.i_new;
      self.new := Vector.new<X>();
      self.i_new += size;
    };
  };

  /// Delete n elements from the beginning.
  /// Traps if less than n elements are available.
  public func delete<X>(self : SlidingWindowBuffer<X>, n : Nat) = deleteTo(self, self.start() + n);

  /// Delete elements from the beginning to the given end position (exclusive).
  public func deleteTo<X>(self : SlidingWindowBuffer<X>, end_ : Nat) {
    if (end_ > self.end()) Prim.trap("index out of bounds in SlidingWindowBuffer.deleteTo");
    if (end_ >= self.i_new) {
      self.new.deleteTo(end_ - self.i_new : Nat);
      rotateIfNeeded(self);
      // free old is possible
      if (end_ >= self.i_new) {
        self.old := null;
        self.i_old := self.i_new;
      };
    } else if (end_ >= self.i_old) {
      let ?vec = self.old else Prim.trap("cannot happen");
      vec.deleteTo(end_ - self.i_old : Nat);
    };
  };

  /// The starting position of the sliding window.
  /// If the window is non-empty then this equals the index of the first
  /// element in the window.
  public func start<X>(self : SlidingWindowBuffer<X>) : Nat = switch (self.old) {
    case (?vec) { self.i_old + vec.start() };
    case (null) { self.i_new + self.new.start() };
  };

  /// The ending position (exclusive) of the sliding window
  /// = the index of the next element that would be added
  /// = the total number of additions that have ever been made
  /// = the size of the whole virtual buffer including deletions
  public func end<X>(self : SlidingWindowBuffer<X>) : Nat = self.i_new + self.new.size();

  /// The size of the window, i.e. the number of elements that are actually
  /// available to get.
  public func size<X>(self : SlidingWindowBuffer<X>) : Nat = self.end() - self.start();

  /// Returns `true` if the window contains no elements.
  public func isEmpty<X>(self : SlidingWindowBuffer<X>) : Bool = size(self) == 0;
};
