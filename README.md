[![mops](https://oknww-riaaa-aaaam-qaf6a-cai.raw.ic0.app/badge/mops/swb)](https://mops.one/swb)
[![documentation](https://oknww-riaaa-aaaam-qaf6a-cai.raw.ic0.app/badge/documentation/swb)](https://mops.one/swb/docs)

# Sliding window buffer for Motoko

## Overview

The package provides a buffer with random access to its elements by index like an array.
The buffer can dynamically grow at the end (where the high indices are) by appending new elements
and it can shrink at the beginning (where the low indices are) by deleting elements.
When deletion happens then the indices are not re-calculated or "shifted" back to start at 0 again.
Instead, they remain unchanged which makes the data structure a sliding window into a virtual ever-growing buffer.

### Links

The package is published on [MOPS](https://mops.one/swb) and [GitHub](https://github.com/research-ag/swb).
Please refer to the README on GitHub where it renders properly with formulas and tables.

The API documentation can be found [here](https://mops.one/swb/docs/lib) on Mops.

For updates, help, questions, feedback and other requests related to this package join us on:

- [OpenChat group](https://oc.app/2zyqk-iqaaa-aaaar-anmra-cai)
- [Twitter](https://twitter.com/mr_research_ag)
- [Dfinity forum](https://forum.dfinity.org/)

### Motivation

The data structure was written to use it as a base for sliding window protocols for inter-canister communication.

### Interface

## Usage

### Install with mops

You need `mops` installed. In your project directory run:

```
mops add swb
```

In the Motoko source file import the package as:

```motoko
import SWB "mo:swb";

```

### Example

```motoko
import SWB "mo:swb";

let buf = SWB.empty<Text>();
ignore buf.add("a");
ignore buf.add("b");
ignore buf.add("c");

assert buf.get(0) == ?"a";
assert buf.get(1) == ?"b";
assert buf.start() == 0;
assert buf.end() == 3;
assert buf.size() == 3;

buf.deleteTo(1);
assert buf.get(0) == null;
assert buf.get(1) == ?"b";
assert buf.start() == 1;
assert buf.end() == 3;
assert buf.size() == 2;
```

### Build & test

We need up-to-date versions of `node` and `mops` installed.
Then run:

```
git clone git@github.com:research-ag/swb.git
mops install
mops test
```

To run with a specific version of `moc` you can edit `mops.toml`.

## Benchmark

We measured the number of instructions per operation for `add`, `delete` and `get`, averaged over batches of 1000 (compared to `mo:core/List`). `List` has no delete-from-start, so for the `delete` row we compare swb's `delete` to `List.removeLast`.

| method | swb   | List |
| ------ | ----: | ---: |
| add    |   730 |  391 |
| delete | 1_510 |  305 |
| get    |   404 |  247 |

The measurement was done with `moc 1.7.0` via `mops bench` (default settings, no `optimize` flag). See [bench/swb_vs_list.bench.mo](bench/swb_vs_list.bench.mo).

## Development

### Formatting

To format the code, run:

```bash
npx -y prettier --plugin prettier-plugin-motoko --write '**/*.{mo,json,md}'
```

## Copyright

MR Research AG, 2023-26

## Authors

Main author: Timo Hanke (timohanke)

Contributors: Andy Gura (andygura), Andrii Stepanov (AStepanov25)

## License

Apache-2.0
