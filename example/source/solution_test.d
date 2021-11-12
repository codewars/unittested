module solution_test;

import solution : add;

version(unittest) import fluent.asserts;

@("failing add with fluent asserts")
unittest {
    add(1, 1).should.equal(2).because("1 + 1 == 2");
}

@("failing add with assert")
unittest {
    assert(add(1, 1) == 2);
}
