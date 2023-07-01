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

* [OpenChat group](https://oc.app/2zyqk-iqaaa-aaaar-anmra-cai)
* [Twitter](https://twitter.com/mr_research_ag)
* [Dfinity forum](https://forum.dfinity.org/)

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
```
import SWB "mo:swb";
```

### Example

### Build & test

We need up-to-date versions of `node`, `moc` and `mops` installed.
Suppose `<path-to-moc>` is the path of the `moc` binary of the appropriate version.

Then run:
```
git clone git@github.com:research-ag/swb.git
mops install
DFX_MOC_PATH=<path-to-moc> mops test
```

## Copyright

MR Research AG, 2023
## Authors

Main author: Timo Hanke\
Contributors: Andy Gura
## License 

Apache-2.0
