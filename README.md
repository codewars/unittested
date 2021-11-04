# unittesteD

D `unittest` runner for Codewars.

## Example

```d
module solution;

export int add(int a, int b) {
    import std.stdio : stdout;
    stdout.writefln("a = %d, b = %d", a, b);
    return a;
}
```

```d
module solution_test;

import solution : add;

version(unittest) import fluent.asserts;

@("add returns the sum")
unittest {
    add(1, 1).should.equal(2).because("1 + 1 == 2");
    // assert(add(1, 1) == 2);
}
```

Run tests with `dub test`.

The test runner is a heavily modified version of [`silly`], and you should use that instead when testing locally.

## Changes from `silly`

- Changed the output to Codewars format
- Removed multi-threaded mode to easily group outputs from submitted
  solution under the relevant test
- Removed filtering
- Removed discovery of tests in classes and structs
- Changed to use `std.datetime.stopwatch.StopWatch`

## Acknowledgements

The test runner is a heavily modified version of [`silly`].

```text
Copyright (c) 2019, Anton Fediushin

Permission to use, copy, modify, and/or distribute this software for any
purpose with or without fee is hereby granted, provided that the above
copyright notice and this permission notice appear in all copies.

THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
```

[`silly`]: https://code.dlang.org/packages/silly
