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
      rows = ["add", "delete", "get"];
      cols = ["swb", "List"];
    };

    let swbAdd = SWB.empty<Nat>();
    let listAdd = List.empty<Nat>();

    let swbDel = SWB.empty<Nat>();
    let listDel = List.empty<Nat>();
    var i = 0;
    while (i < PREFILL) {
      ignore SWB.add(swbDel, i);
      List.add(listDel, i);
      i += 1;
    };

    let swbGet = SWB.empty<Nat>();
    let listGet = List.empty<Nat>();
    var j = 0;
    while (j < BATCH) {
      ignore SWB.add(swbGet, j);
      List.add(listGet, j);
      j += 1;
    };

    let routines : [[() -> ()]] = [
      [
        func() {
          var k = 0;
          while (k < BATCH) { ignore SWB.add(swbAdd, k); k += 1 };
        },
        func() {
          var k = 0;
          while (k < BATCH) { List.add(listAdd, k); k += 1 };
        },
      ],
      [
        func() {
          var k = 0;
          while (k < BATCH) { SWB.delete(swbDel, 1); k += 1 };
        },
        func() {
          var k = 0;
          while (k < BATCH) { ignore List.removeLast(listDel); k += 1 };
        },
      ],
      [
        func() {
          var k = 0;
          while (k < BATCH) { ignore SWB.get(swbGet, k); k += 1 };
        },
        func() {
          var k = 0;
          while (k < BATCH) { ignore List.get(listGet, k); k += 1 };
        },
      ],
    ];

    Bench.V1(schema, func(ri : Nat, ci : Nat) = routines[ri][ci]());
  };
};
