class CharClassNode extends RegexNode;
  byte chars[$];
  bit inverted;  // [^...] is 1

  function new(byte chars_in[$], bit inv = 0);
    chars = chars_in;
    inverted = inv;
  endfunction

  function string to_string();
    string s = "[";
    if (inverted) s = "[^";
    foreach (chars[i]) s = {s, $sformatf("%c", chars[i])};
    s = {s, "]"};
    return s;
  endfunction

endclass
