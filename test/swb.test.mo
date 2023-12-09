import SWB "../src/lib";
import Iter "mo:base/Iter";

let buf = SWB.SlidingWindowBuffer<Text>();

// test defaults
assert buf.end() == 0;
assert buf.len() == 0;
assert buf.start() == 0;

// test that empty buffer will not crash:
assert buf.getOpt(0) == null;

// add some values:
assert buf.add("a") == 0;
assert buf.add("b") == 1;
assert buf.add("c") == 2;
assert buf.add("d") == 3;
assert buf.add("e") == 4;
assert buf.add("f") == 5;

assert buf.end() == 6;
assert buf.len() == 6;
assert buf.start() == 0;

// test getOpt
assert buf.getOpt(0) == ?"a";
assert buf.getOpt(0) == ?"a";
assert buf.getOpt(2) == ?"c";
assert buf.getOpt(5) == ?"f";

// test delete
buf.delete(1);
assert buf.getOpt(0) == null;
assert buf.getOpt(1) == ?"b";
assert buf.getOpt(2) == ?"c";
assert buf.end() == 6;
assert buf.len() == 5;
assert buf.start() == 1;

buf.delete(2);
assert buf.getOpt(1) == null;
assert buf.getOpt(2) == null;
assert buf.getOpt(3) == ?"d";
assert buf.end() == 6;
assert buf.len() == 3;
assert buf.start() == 3;

// test deleteTo
buf.deleteTo(1); // pos < start (nothing deleted)
assert buf.end() == 6;
assert buf.len() == 3;
assert buf.start() == 3;

buf.deleteTo(3); // pos == start (nothing deleted)
assert buf.end() == 6;
assert buf.len() == 3;
assert buf.start() == 3;

// test rotation
buf.delete(1); // triggers rotation
assert buf.getOpt(3) == null;
assert buf.getOpt(4) == ?"e";
assert buf.end() == 6;
assert buf.len() == 2;
assert buf.start() == 4;

// test addition after rotation
assert buf.add("g") == 6;
assert buf.getOpt(5) == ?"f";
assert buf.getOpt(6) == ?"g";
assert buf.end() == 7;
assert buf.len() == 3;
assert buf.start() == 4;

// test add many values
for (i in Iter.range(1, 10000)) {
  ignore buf.add("test");
};
assert buf.getOpt(7) == ?"test";
assert buf.getOpt(10006) == ?"test";
assert buf.end() == 10007;
assert buf.len() == 10003;
assert buf.start() == 4;

// test delete many values
buf.delete(5000);
assert buf.getOpt(5003) == null;
assert buf.getOpt(5004) == ?"test";
assert buf.getOpt(10004) == ?"test";
assert buf.end() == 10007;
assert buf.len() == 5003;
assert buf.start() == 5004;

// test get value in the middle
assert buf.getOpt(1) == null;
assert buf.getOpt(1000000) == null;
assert buf.getOpt(3000) == null; 
assert buf.getOpt(6000) == ?"test";
