class OptNode extends RegexNode;
  RegexNode child;
  bit greedy;

  function new(RegexNode c, bit g = 1);
    child  = c;
    greedy = g;
  endfunction

  function string to_string();
    return {child.to_string(), "?", greedy ? "" : "?"};
  endfunction

endclass
