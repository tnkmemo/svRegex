# svRegex
SystemVerilog regular expression package without DPI-C

# Features
- A regular expression engine implemented entirely in SystemVerilog  
- Supports greedy and lazy quantifiers, character classes, anchors, and other core regex features  
- Implements the essential functionality of a general-purpose regex engine  

# Supported Features

## Basic Syntax
- Character literals  
- Escaped single character `\x`  
- Concatenation (implicit)  
- Alternation `|`  

## Quantifiers (Greedy / Lazy)
- `*` / `*?`  
- `+` / `+?`  
- `?` / `??`  
- `{m}` / `{m}?`  
- `{m,n}` / `{m,n}?`  
- `{m,}` / `{m,}?`  

## Character Classes
- `[abc]`  
- `[a-z]`  
- `[A-Z]`  
- `[0-9]`  
- Negated classes `[^...]`  
- Escaped characters inside classes `[\]]`  
- Mixed ranges `[a-zA-Z0-9_]`

## Special Characters
- `.` (matches any single character)  
- `^` (start-of-line anchor)  
- `$` (end-of-line anchor)

# Unsupported Features

## Advanced Escape Sequences
- `\d` / `\D`  
- `\w` / `\W`  
- `\s` / `\S`  
- `\t` `\n` `\r`  
- `\xNN` (hex)  
- `\uNNNN` (Unicode)

## Boundary Assertions
- `\b` (word boundary)  
- `\B` (non-word boundary)  
- `\A` (start of string)  
- `\Z` (end of string)  
- `\G` (previous match position)

## Grouping / Backreferences
- Capturing groups `( … )`  
- Non-capturing groups `(?: … )`  
- Named capturing groups `(?<name> … )`  
- Backreferences `\1` `\2` `\k<name>`

## Lookaround
- Positive lookahead `(?= … )`  
- Negative lookahead `(?! … )`  
- Positive lookbehind `(?<= … )`  
- Negative lookbehind `(?<! … )`

## Flags (Mode Modifiers)
- `(?i)` case-insensitive  
- `(?m)` multiline mode  
- `(?s)` dot-all  
- `(?x)` extended mode  
- `(?u)` Unicode mode  
- Scoped flags `(?i: … )`

## Advanced Character Classes
- POSIX classes `[[:digit:]]` etc.  
- Unicode properties `\p{Han}` etc.

## Backtracking Control
- Atomic groups `(?> … )`  
- Conditional expressions `(?(cond)yes|no)`

## Comments
- `(?# comment )`

# Setup
```sh
git clone https://github.com/tnkmemo/svRegex.git
```

# Usage
```systemverilog
`include "svRegex_pkg.svh"

module tb;
  import svRegex_pkg::*;

  int s, e;
  string pattern = "a+?";
  string text    = "aaaa";

  bit ok = match(pattern, text, s, e);  // substring match → OK

  initial $display("match = %0d (%0d, %0d)", ok, s, e);
endmodule
```

# Reference

## `function bit match(string pattern, string text, output int s, output int e);`

Applies the regular expression `pattern` to the input string `text`.  
Returns `1` if **substring matching** succeeds, otherwise returns `0`.

### Parameters
| Name | Type | Description |
|------|------|-------------|
| `pattern` | `string` | Regular expression pattern (SystemVerilog string) |
| `text` | `string` | Input text to be matched |
| `s` | `output int` | Start position |
| `e` | `output int` | End position |

---

### Return Value
| Type | Description |
|------|-------------|
| `bit` | Returns `1` on match success, `0` on failure |
