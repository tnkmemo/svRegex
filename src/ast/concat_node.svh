class ConcatNode extends RegexNode;
  RegexNode left;
  RegexNode right;

  function new(RegexNode l, RegexNode r);
    left = l;
    right = r;
  endfunction

  function string to_string();
    return {left.to_string(), ".", right.to_string()};
  endfunction

endclass
