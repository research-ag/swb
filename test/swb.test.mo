import SlidingWindowBuffer "../src/lib";
import Nat "mo:core/Nat";

do {
  let buf = SlidingWindowBuffer.empty<Text>();

  // test defaults
  assert buf.end() == 0;
  assert buf.size() == 0;
  assert buf.start() == 0;

  // test that empty buffer will not crash:
  assert buf.get(0) == null;

  // add some values:
  assert buf.add("a") == 0;
  assert buf.add("b") == 1;
  assert buf.add("c") == 2;
  assert buf.add("d") == 3;
  assert buf.add("e") == 4;
  assert buf.add("f") == 5;

  assert buf.end() == 6;
  assert buf.size() == 6;
  assert buf.start() == 0;

  // test get
  assert buf.get(0) == ?"a";
  assert buf.get(0) == ?"a";
  assert buf.get(2) == ?"c";
  assert buf.get(5) == ?"f";

  // test delete
  buf.delete(1);
  assert buf.get(0) == null;
  assert buf.get(1) == ?"b";
  assert buf.get(2) == ?"c";
  assert buf.end() == 6;
  assert buf.size() == 5;
  assert buf.start() == 1;

  buf.delete(2);
  assert buf.get(1) == null;
  assert buf.get(2) == null;
  assert buf.get(3) == ?"d";
  assert buf.end() == 6;
  assert buf.size() == 3;
  assert buf.start() == 3;

  // test deleteTo
  buf.deleteTo(1); // pos < start (nothing deleted)
  assert buf.end() == 6;
  assert buf.size() == 3;
  assert buf.start() == 3;

  buf.deleteTo(3); // pos == start (nothing deleted)
  assert buf.end() == 6;
  assert buf.size() == 3;
  assert buf.start() == 3;

  // test rotation
  buf.delete(1); // triggers rotation
  assert buf.get(3) == null;
  assert buf.get(4) == ?"e";
  assert buf.end() == 6;
  assert buf.size() == 2;
  assert buf.start() == 4;

  // test addition after rotation
  assert buf.add("g") == 6;
  assert buf.get(5) == ?"f";
  assert buf.get(6) == ?"g";
  assert buf.end() == 7;
  assert buf.size() == 3;
  assert buf.start() == 4;

  // test add many values
  for (i in Nat.range(1, 10000 + 1)) {
    ignore buf.add("test");
  };
  assert buf.get(7) == ?"test";
  assert buf.get(10006) == ?"test";
  assert buf.end() == 10007;
  assert buf.size() == 10003;
  assert buf.start() == 4;

  // test delete many values
  buf.delete(5000);
  assert buf.get(5003) == null;
  assert buf.get(5004) == ?"test";
  assert buf.get(10004) == ?"test";
  assert buf.end() == 10007;
  assert buf.size() == 5003;
  assert buf.start() == 5004;

  // test get value in the middle
  assert buf.get(1) == null;
  assert buf.get(1000000) == null;
  assert buf.get(3000) == null;
  assert buf.get(6000) == ?"test";
};

// Test stable storage (record is directly stable)
do {
  let buf = SlidingWindowBuffer.empty<Nat>();
  for (i in Nat.range(0, 100)) {
    ignore buf.add(i);
  };
  buf.delete(50);
  for (i in Nat.range(0, 100)) {
    assert buf.get(i) == (if (i < 50) { null } else { ?i });
  };
  let buf1 : SlidingWindowBuffer.SlidingWindowBuffer<Nat> = buf;
  for (i in Nat.range(0, 100)) {
    assert buf1.get(i) == (if (i < 50) { null } else { ?i });
  };
};

// Test access and deletion after rotation
do {
  let buf = SlidingWindowBuffer.empty<Nat>();
  let N = 2;
  for (i in Nat.range(1, N + 1)) {
    ignore buf.add(i);
  };
  buf.delete(N); // this will cause rotation if N >= 2, set old to null
  assert buf.get(0) == null;
  buf.deleteTo(N); // this will set old to null
  assert buf.get(0) == null;
  buf.deleteTo(0);
  buf.deleteTo(1);
  buf.deleteTo(2);
};
