class Parser;
  string s;
  int idx;
  int len;

  function new(string str);
    s   = str;
    idx = 0;
    len = s.len();
  endfunction

  function byte peek();
    if (idx < len) return s[idx];
    return 0;
  endfunction

  function byte get();
    if (idx < len) return s[idx++];
    return 0;
  endfunction

  function RegexNode parse();
    return parse_expr();
  endfunction

  // Char class parser
  function RegexNode parse_char_class();
    CharClassNode cn;
    byte chars[$];
    bit inverted = 0;

    // '['
    void'(get());

    // [^...]
    if (peek() == "^") begin
      void'(get());
      inverted = 1;
    end

    // Body
    while (1) begin
      byte c;
      byte from_c, to_c;

      if (peek() == 0)
        $fatal("Unclosed character class");

      // ']'
      if (peek() == "]") begin
        void'(get());
        break;
      end

      // Escape
      if (peek() == "\\") begin
        void'(get());
        c = get();
      end
      else begin
        c = get();
      end

      // a-z / A-Z / 0-9
      if (peek() == "-" && idx+1 < len && s[idx+1] != "]") begin
        byte endc;
        void'(get()); // '-'

        // Escape
        if (peek() == "\\") begin
          void'(get());
          endc = get();
        end
        else begin
          endc = get();
        end

        from_c = c;
        to_c   = endc;
        if (from_c > to_c) begin
          byte tmp = from_c;
          from_c = to_c;
          to_c   = tmp;
        end

        for (byte x = from_c; x <= to_c; x++)
          chars.push_back(x);
      end
      else begin
        chars.push_back(c);
      end
    end

    cn = new(chars, inverted);
    return cn;
  endfunction

  // expr ::= term ('|' term)*
  function RegexNode parse_expr();
    RegexNode left;
    RegexNode right;
    AltNode alt;
    left = parse_term();
    while (peek() == "|") begin
      void'(get()); // consume '|'
      right = parse_term();
      alt = new (left, right);
      left = alt;
    end
    return left;
  endfunction

  // term ::= factor+
  function RegexNode parse_term();
    RegexNode left;
    RegexNode f;
    EpsilonNode en;
    ConcatNode cnode;
    byte p;
    left = null;

    while (1) begin
      p = peek();
      if (p == 0 || p == ")" || p == "|") break;
      f = parse_factor();
      if (left == null) left = f;
      else begin
        cnode = new(left, f);
        left = cnode;
      end
    end

    if (left == null) begin
      en = new();
      return en;
    end
    return left;
  endfunction

  // factor ::= base ('*'|'+'|'?'|'{m,n}')?
  function RegexNode parse_factor();
    RegexNode b;
    StarNode snode;
    PlusNode pnode;
    OptNode onode;
    RepeatNode rnode;
    byte p;

    b = parse_base();
    p = peek();

    // *, +, ?
    if (p == "*") begin
      bit greedy = 1;
      void'(get());
      if (peek() == "?") begin void'(get()); greedy = 0; end
      snode = new(b, greedy);
      return snode;
    end

    if (p == "+") begin
      bit greedy = 1;
      void'(get());
      if (peek() == "?") begin void'(get()); greedy = 0; end
      pnode = new(b, greedy);
      return pnode;
    end

    if (p == "?") begin
      bit greedy = 1;
      void'(get());
      if (peek() == "?") begin void'(get()); greedy = 0; end
      onode = new(b, greedy);
      return onode;
    end

    // {m,n}
    if (p == "{") begin
      int m = 0;
      int n = 0;
      bit has_n = 0;
      bit greedy = 1;

      void'(get()); // consume '{'

      // parse m
      while (peek() >= "0" && peek() <= "9")
        m = m * 10 + (get() - "0");

      if (peek() == ",") begin
        void'(get());
        has_n = 1;

        if (peek() >= "0" && peek() <= "9") begin
          while (peek() >= "0" && peek() <= "9")
            n = n * 10 + (get() - "0");
        end
        else begin
          n = -1; // {m,}
        end
      end
      else begin
        n = m; // {m}
      end

      if (peek() != "}") $fatal("Missing '}' in quantifier");
      void'(get()); // consume '}'

      greedy = 1;
      if (peek() == "?") begin void'(get()); greedy = 0; end

      rnode = new(b, m, n, greedy);
      return rnode;
    end

    return b;
  endfunction

  // base ::= '(' expr ')' | '\' escaped | '[' class ']' | literal | '.' | '^' | '$'
  function RegexNode parse_base();
    RegexNode r;
    CharNode rtnval;
    CharNode cn;
    DotNode dn;
    StartAnchorNode san;
    EndAnchorNode ean;
    byte p;
    byte c;

    p = peek();

    if (p == "(") begin
      void'(get());
      r = parse_expr();
      if (peek() == ")") void'(get());
      return r;
    end

    if (p == "[") begin
      return parse_char_class();
    end

    if (p == "\\") begin
      void'(get());
      c = get();
      cn = new(c);
      return cn;
    end

    if (p == ".") begin
      void'(get());
      dn = new();
      return dn;
    end

    if (p == "^") begin
      void'(get());
      san = new();
      return san;
    end

    if (p == "$") begin
      void'(get());
      ean = new();
      return ean;
    end

    c = get();
    cn = new(c);
    return cn;
  endfunction

endclass
