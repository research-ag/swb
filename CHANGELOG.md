# Swb changelog

## 2.0.1

- Complete documentation

## 2.0.0

- Converted API from class-based to static module (record type). SWB is now directly stable.
- Constructor `SlidingWindowBuffer<X>()` becomes function `empty<X>()`.
- Support for dot-notation.
- Renamed `getOpt` → `get`.
- Renamed `len` → `size`.
- Removed `share()` / `unshare()`.
- Added `at(buf, i) : X` — like `get`, but traps if `i` is outside `[start, end)`.
- Added `put(buf, i, value)` — overwrite the element at absolute index `i`; traps if `i` is outside `[start, end)`.
- Added `isEmpty(buf) : Bool`.

## 1.2.3

- Bump `core` dependency to `2.5.0`
- Require `moc 1.6.0`

## 1.2.2

- Remove dev-dependency

## 1.2.1

- Switch base dependency to core

## 1.2.0

- Bump all dependencies
- Base dependency is 0.11.1

## 1.1.1

- Fixed a bug that can cause a trap when attempting to access an already deleted position

## 1.1.0

- Added `share/unshare()` interface to the class

## 1.0.1

- Fixed a bug in `deleteTo(pos)` when `pos < start`

## 1.0.0.

- Initial version
