class RepeatNode extends RegexNode;
  RegexNode child;
  int m;
  int n; // n = -1 is infinite.
  bit greedy; // 1=greedy, 0=non-greedy

  function new(RegexNode c, int min, int max, bit g = 1);
    child = c;
    m = min;
    n = max;
    greedy = g;
  endfunction

  function string to_string();
    if (n < 0) return { child.to_string(), "{", m, ",}", greedy ? "" : "?" };
    else if (m == n) return { child.to_string(), "{", m, "}", greedy ? "" : "?" };
    else return { child.to_string(), "{", m, ",", n, "}", greedy ? "" : "?" };
  endfunction

endclass
