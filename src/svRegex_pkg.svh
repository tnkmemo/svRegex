`ifndef SVREGEX_PKG
`define SVREGEX_PKG

package svRegex_pkg;

  // ===== AST =====
  `include "ast/regex_node.svh"
  `include "ast/char_node.svh"
  `include "ast/concat_node.svh"
  `include "ast/alt_node.svh"
  `include "ast/star_node.svh"
  `include "ast/plus_node.svh"
  `include "ast/opt_node.svh"
  `include "ast/epsilon_node.svh"
  `include "ast/char_class_node.svh"
  `include "ast/dot_node.svh"
  `include "ast/repeat_node.svh"
  `include "ast/start_anchor_node.svh"
  `include "ast/end_anchor_node.svh"

  // ===== Parser =====
  `include "parser/parser.svh"

  // ===== NFA =====
  `include "nfa/nfa_types.svh"
  `include "nfa/nfa.svh"
  `include "nfa/nfa_builder.svh"
  `include "nfa/nfa_runner.svh"

  function automatic bit match(string pattern, string text);
    Parser     p;
    RegexNode  root;
    NfaBuilder builder;
    NFA        nfa;
    NfaRunner  runner;
    bit        ok;

    // Parse
    p    = new(pattern);
    root = p.parse();

    // Construct NFA
    builder = new();
    nfa     = builder.build(root);

    // Execute
    runner = new();
    match  = runner.run(nfa, text);
  endfunction

endpackage

`endif
