// D unittest runner for Codewars.
module unittested;

version(unittest):

static if (!__traits(compiles, () { static import dub_test_root; })) {
    static assert(false, "Couldn't find 'dub_test_root'. Make sure you are running tests with `dub test`");
} else {
    static import dub_test_root;
}

import std.stdio : stdout;

shared static this() {
    import core.runtime : Runtime, UnitTestResult;

    Runtime.extendedModuleUnitTester = function () {
        ulong passed, failed;

        Test[] tests;
        // Test discovery
        foreach (m; dub_test_root.allModules) {
            import std.meta : Alias;
            import std.traits : fullyQualifiedName;
            static if (__traits(isModule, m)) {
                alias module_ = m;
            } else {
                // For cases when module contains member of the same name
                alias module_ = Alias!(__traits(parent, m));
            }

            // Unittests in the module
            foreach (test; __traits(getUnitTests, module_)) {
                tests ~= Test(fullyQualifiedName!test, getTestName!test, &test);
            }
        }

        foreach (test; tests) {
            TestResult result;
            test.onStart();
            test.run(result);
            if (result.passed) {
                test.onPassed(result);
                passed += 1;
            } else {
                test.onFailed(result);
                failed += 1;
            }
            test.onEnd(result);
        }

        return UnitTestResult(passed + failed, passed, false, false);
    };
}

void onStart(Test test) {
    stdout.writefln("\n<IT::>%s", escapeLF(test.testName));
}

void onEnd(Test test, TestResult result) {
    stdout.writefln("\n<COMPLETEDIN::>%d", result.duration);
}

void onPassed(Test test, TestResult result) {
    stdout.writefln("\n<PASSED::>Test Passed");
}

void onFailed(Test test, TestResult result) {
    import std.algorithm : canFind;

    foreach (th; result.thrown) {
        if (th.type == "core.exception.AssertError" || th.type == "fluentasserts.core.base.TestException") {
            stdout.writefln("\n<FAILED::>%s", escapeLF(th.message));
        } else {
            stdout.writefln("\n<ERROR::>%s: %s (%s:%d)",
                th.type,
                escapeLF(th.message),
                th.file,
                th.line,
            );

            if (th.info.length > 0) {
                stdout.write("\n<LOG::-Stack Trace>");
                for (size_t i = 0; i < th.info.length && !th.info[i].canFind(__FILE__); ++i) {
                    stdout.writef("    %s<:LF:>", escapeLF(th.info[i]));
                }
                stdout.writeln;
            }
        }
    }
}

void run(Test test, out TestResult result) {
    import core.exception : OutOfMemoryError;
    import std.datetime.stopwatch : StopWatch, AutoStart;

    auto sw = StopWatch(AutoStart.no);
    try {
        scope(exit) {
            sw.stop();
            result.duration = sw.peek.total!"msecs";
        }
        sw.start();
        test.ptr();
        result.passed = true;

    } catch (Throwable t) {
        foreach (th; t) {
            immutable(string)[] trace;
            try {
                foreach (i; th.info) trace ~= i.idup;
            } catch (OutOfMemoryError) {
                trace ~= "Failed to get stack trace. See https://gitlab.com/AntonMeep/silly/issues/31";
            }

            result.thrown ~= Thrown(typeid(th).name, th.message.idup, th.file, th.line, trace);
        }
    }
}

struct Test {
    string fullName, testName;
    void function() ptr;
}

struct TestResult {
    bool passed;
    long duration;
    immutable(Thrown)[] thrown;
}

struct Thrown {
    string type, message, file;
    size_t line;
    immutable(string)[] info;
}

string getTestName(alias test)() {
    string name = __traits(identifier, test);
    foreach (attribute; __traits(getAttributes, test)) {
        static if (is(typeof(attribute) : string)) {
            name = attribute;
            break;
        }
    }
    return name;
}

string escapeLF(string s) {
    import std.string : replace;
    return s.replace("\n", "<:LF:>");
}
