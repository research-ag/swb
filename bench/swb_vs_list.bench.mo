import Bench "mo:bench-helper";
import SWB "../src/lib";
import List "mo:core/List";

module {
  public func init() : Bench.V1 {
    let BATCH = 1_000;
    let PREFILL = 1_000_000;

    let schema : Bench.Schema = {
      name = "swb vs core/List";
      description = "Instructions per " # debug_show BATCH # " operations. swb deletes from the start (`delete`); List has no delete-from-start, so the `delete` row uses `List.removeLast` instead.";
      rows = ["add", "delete", "get", "at"];
      cols = ["swb", "List"];
    };

    let swbAdd = SWB.empty<Nat>();
    let listAdd = List.empty<Nat>();

    let swbDel = SWB.empty<Nat>();
    let listDel = List.empty<Nat>();
    var i = 0;
    while (i < PREFILL) {
      ignore swbDel.add(i);
      listDel.add(i);
      i += 1;
    };

    let swbGet = SWB.empty<Nat>();
    let listGet = List.empty<Nat>();
    var j = 0;
    while (j < BATCH) {
      ignore swbGet.add(j);
      listGet.add(j);
      j += 1;
    };

    let routines : [[() -> ()]] = [
      [
        func() {
          var k = 0;
          while (k < BATCH) { ignore swbAdd.add(k); k += 1 };
        },
        func() {
          var k = 0;
          while (k < BATCH) { listAdd.add(k); k += 1 };
        },
      ],
      [
        func() {
          var k = 0;
          while (k < BATCH) { swbDel.delete(1); k += 1 };
        },
        func() {
          var k = 0;
          while (k < BATCH) { ignore listDel.removeLast(); k += 1 };
        },
      ],
      [
        func() {
          var k = 0;
          while (k < BATCH) { ignore swbGet.get(k); k += 1 };
        },
        func() {
          var k = 0;
          while (k < BATCH) { ignore listGet.get(k); k += 1 };
        },
      ],
      [
        func() {
          var k = 0;
          while (k < BATCH) { ignore swbGet.at(k); k += 1 };
        },
        func() {
          var k = 0;
          while (k < BATCH) { ignore listGet.at(k); k += 1 };
        },
      ],
    ];

    Bench.V1(schema, func(ri : Nat, ci : Nat) = routines[ri][ci]());
  };
};
