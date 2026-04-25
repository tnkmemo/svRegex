class CharNode extends RegexNode;
  byte ch;

  function new(byte c);
    this.ch = c;
  endfunction

  function string to_string();
    return $sformatf("'%c'", ch);
  endfunction

endclass
