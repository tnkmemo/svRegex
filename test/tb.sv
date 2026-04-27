`timescale 1ns/1ps
`include "svRegex_pkg.svh"

module tb;
  import svRegex_pkg::*;

  task automatic test(string pattern, string text, bit expected);
    bit ok;
    int s, e;
    ok = match(pattern, text, s, e);

    $display("%s: exp=%0d act=%0d pattern=%s text=%s (%0d, %0d)",
      (ok == expected) ? "OK" : "NG ***",
      expected, ok, pattern, text, s, e
    );
  endtask

  initial begin

    // Simple string
    test("abc", "abc", 1);
    test("abc", "ab",  0);
    test("abc", "xabc", 1);

    // |
    test("a|b", "a", 1);
    test("a|b", "b", 1);
    test("a|b", "c", 0);

    test("ab|cd", "ab", 1);
    test("ab|cd", "cd", 1);
    test("ab|cd", "ad", 0);

    // *
    test("a*", "",      1);
    test("a*", "a",     1);
    test("a*", "aaaa",  1);
    test("ab*", "a",    1);
    test("ab*", "abbb", 1);

    // +
    test("a+", "",      0);
    test("a+", "a",     1);
    test("a+", "aaaa",  1);

    // ?
    test("ab?", "a",    1);
    test("ab?", "ab",   1);
    test("ab?", "abb",  1);

    // ()
    test("(ab)*c", "c",      1);
    test("(ab)*c", "abc",    1);
    test("(ab)*c", "ababc",  1);
    test("(ab)*c", "ababa",  0);

    // Escape
    test("a\\*", "a*", 1);
    test("a\\*", "aa", 0);

    // [abc]
    test("[abc]", "a", 1);
    test("[abc]", "b", 1);
    test("[abc]", "c", 1);
    test("[abc]", "d", 0);

    // [a-z]
    test("[a-z]", "a", 1);
    test("[a-z]", "m", 1);
    test("[a-z]", "z", 1);
    test("[a-z]", "A", 0);
    test("[a-z]", "0", 0);

    // [A-Za-z0-9]
    test("[A-Za-z0-9]", "A", 1);
    test("[A-Za-z0-9]", "z", 1);
    test("[A-Za-z0-9]", "5", 1);
    test("[A-Za-z0-9]", "_", 0);
    test("[A-Za-z0-9]", "-", 0);

    // [^a-z]
    test("[^a-z]", "A", 1);
    test("[^a-z]", "Z", 1);
    test("[^a-z]", "0", 1);
    test("[^a-z]", "a", 0);
    test("[^a-z]", "m", 0);

    // [\]
    test("[\\]]", "]", 1);
    test("[\\-]", "-", 1);
    test("[a\\-z]", "-", 1);
    test("[a\\-z]", "b", 0);

    // Dot
    test(".", "a", 1);
    test(".", "Z", 1);
    test(".", "", 0);
    test("a.c", "abc", 1);
    test("a.c", "axc", 1);
    test("a.c", "ac", 0);

    // ^
    test("^abc", "abc", 1);
    test("^abc", "xabc", 0);
    test("^abc", "abcx", 1);
    test("^a", "ba", 0);
    test("^", "abc", 1);

    // $
    test("abc$", "abc", 1);
    test("abc$", "abcz", 0);
    test("abc$", "zabc", 1);
    test("c$", "abc", 1);
    test("$", "abc", 1);

    // {}
    test("a{3}", "aaa", 1);
    test("a{3}", "aa", 0);

    test("a{2,4}", "a", 0);
    test("a{2,4}", "aa", 1);
    test("a{2,4}", "aaa", 1);
    test("a{2,4}", "aaaa", 1);

    test("a{2,}", "aa", 1);
    test("a{2,}", "aaaaa", 1);

    test("a{0,3}", "", 1);
    test("a{0,3}", "aaa", 1);
    test("a{0,3}", "aaaa", 1);

    test("a{0,}", "", 1);
    test("a{0,}", "bbb", 1);

    // *?
    test("a*?", "", 1);
    test("a*?", "a", 1);
    test("a*?", "aa", 1);
    test("a*?", "bbb", 1);

    // +?
    test("a+?", "a", 1);
    test("a+?", "aa", 1);
    test("a+?", "aaa", 1);
    test("a+?", "baaa", 1);
    test("a+?", "bbb", 0);

    // ??
    test("a??", "", 1);
    test("a??", "a", 1);
    test("a??", "aa", 1);
    test("a??", "bbb", 1);

    // {n,m}?
    test("a{2,4}?", "aa", 1);
    test("a{2,4}?", "aaa", 1);
    test("a{2,4}?", "aaaa", 1);
    test("a{2,4}?", "aaaaa", 1);
    test("a{2,4}?", "baaa", 1);
    test("a{2,4}?", "a", 0);

    // {n,}?
    test("a{2,}?", "aa", 1);
    test("a{2,}?", "aaa", 1);
    test("a{2,}?", "aaaaa", 1);
    test("a{2,}?", "baaa", 1);
    test("a{2,}?", "a", 0);

    // {0,m}?
    test("a{0,3}?", "", 1);
    test("a{0,3}?", "a", 1);
    test("a{0,3}?", "aaa", 1);
    test("a{0,3}?", "aaaa", 1);
    test("a{0,3}?", "bbb", 1);

    // {0,}?
    test("a{0,}?", "", 1);
    test("a{0,}?", "a", 1);
    test("a{0,}?", "bbb", 1);
    test("a{0,}?", "aaaa", 1);

    $display("all tests done.");
    $finish;
  end

endmodule
