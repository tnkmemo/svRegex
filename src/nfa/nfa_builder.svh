class NfaBuilder;

  function void build_rec(
    RegexNode node,
    ref NFA nfa,
    output int start,
    output int accept
  );
    int s1, a1, s2, a2;
    CharNode        cn;
    ConcatNode      cnode;
    AltNode         an;
    StarNode        sn;
    PlusNode        pn;
    OptNode         on;
    EpsilonNode     en;
    CharClassNode   cc;
    StartAnchorNode san;
    EndAnchorNode   ean;
    RepeatNode      rn;
    DotNode         dn;

    if (node == null) begin
      start  = -1;
      accept = -1;
      return;
    end

    // ----------------------------------------
    // EpsilonNode
    // ----------------------------------------
    if ($cast(en, node)) begin
      start  = nfa.new_state();
      accept = nfa.new_state();
      nfa.add_transition(start, accept, -1); // epsilon
      return;
    end

    // ----------------------------------------
    // CharClassNode
    // ----------------------------------------
    if ($cast(cc, node)) begin
      int class_id = nfa.register_char_class(cc);
      start  = nfa.new_state();
      accept = nfa.new_state();
      nfa.add_transition(start, accept, -(class_id + 5));
      return;
    end

    // ----------------------------------------
    // CharNode
    // ----------------------------------------
    if ($cast(cn, node)) begin
      start  = nfa.new_state();
      accept = nfa.new_state();
      if (cn.ch == 0)
        nfa.add_transition(start, accept, -1);
      else
        nfa.add_transition(start, accept, cn.ch);
      return;
    end

    // ----------------------------------------
    // ConcatNode
    // ----------------------------------------
    if ($cast(cnode, node)) begin
      build_rec(cnode.left,  nfa, s1, a1);
      build_rec(cnode.right, nfa, s2, a2);
      nfa.add_transition(a1, s2, -1);
      start  = s1;
      accept = a2;
      return;
    end

    // ----------------------------------------
    // AltNode
    // ----------------------------------------
    if ($cast(an, node)) begin
      build_rec(an.left,  nfa, s1, a1);
      build_rec(an.right, nfa, s2, a2);
      start  = nfa.new_state();
      accept = nfa.new_state();
      nfa.add_transition(start, s1, -1);
      nfa.add_transition(start, s2, -1);
      nfa.add_transition(a1, accept, -1);
      nfa.add_transition(a2, accept, -1);
      return;
    end

    // ----------------------------------------
    // StarNode  (* / *?)
    // ----------------------------------------
    if ($cast(sn, node)) begin
      build_rec(sn.child, nfa, s1, a1);
      start  = nfa.new_state();
      accept = nfa.new_state();

      if (sn.greedy) begin
        // 貪欲：繰り返し優先
        nfa.add_transition(start, s1, -1);
        nfa.add_transition(start, accept, -1);
        nfa.add_transition(a1, s1, -1);
        nfa.add_transition(a1, accept, -1);
      end
      else begin
        // 非貪欲：抜ける優先
        nfa.add_transition(start, accept, -1);
        nfa.add_transition(start, s1, -1);
        nfa.add_transition(a1, accept, -1);
        nfa.add_transition(a1, s1, -1);
      end
      return;
    end

    // ----------------------------------------
    // PlusNode  (+ / +?)
    // ----------------------------------------
    if ($cast(pn, node)) begin
      build_rec(pn.child, nfa, s1, a1);
      start  = nfa.new_state();
      accept = nfa.new_state();

      if (pn.greedy) begin
        // greedy： prior repeating
        nfa.add_transition(start, s1, -1);
        nfa.add_transition(a1, s1, -1);
        nfa.add_transition(a1, accept, -1);
      end
      else begin
        // non-greedy: prior break
        nfa.add_transition(start, s1, -1);
        nfa.add_transition(a1, accept, -1);
        nfa.add_transition(a1, s1, -1);
      end
      return;
    end

    // ----------------------------------------
    // OptNode  (? / ??)
    // ----------------------------------------
    if ($cast(on, node)) begin
      build_rec(on.child, nfa, s1, a1);
      start  = nfa.new_state();
      accept = nfa.new_state();

      if (on.greedy) begin
        // greedy: prior match
        nfa.add_transition(start, s1, -1);
        nfa.add_transition(start, accept, -1);
        nfa.add_transition(a1, accept, -1);
      end
      else begin
        // non-greedy: prior skip
        nfa.add_transition(start, accept, -1);
        nfa.add_transition(start, s1, -1);
        nfa.add_transition(a1, accept, -1);
      end
      return;
    end

    // ----------------------------------------
    // RepeatNode {m,n} / {m,n}?
    // ----------------------------------------
    if ($cast(rn, node)) begin
      int last_accept;
      int cur_accept;
      int s_child, a_child;
      int prev_start, prev_accept;

      if (rn.m > 0) begin
        build_rec(rn.child, nfa, prev_start, prev_accept);
        start = prev_start;
        for (int k = 1; k < rn.m; k++) begin
          build_rec(rn.child, nfa, s_child, a_child);
          nfa.add_transition(prev_accept, s_child, -1);
          prev_accept = a_child;
        end
      end
      else begin
        start       = nfa.new_state();
        prev_accept = start;
      end

      // {m,}
      if (rn.n < 0) begin
        build_rec(rn.child, nfa, s_child, a_child);

        if (rn.greedy) begin
          nfa.add_transition(prev_accept, s_child, -1);
          nfa.add_transition(a_child, s_child, -1);
        end
        else begin
        end

        accept = nfa.new_state();

        // m
        nfa.add_transition(prev_accept, accept, -1);
        // m+1
        nfa.add_transition(a_child, accept, -1);

        if (!rn.greedy) begin
          nfa.add_transition(prev_accept, s_child, -1);
          nfa.add_transition(a_child, s_child, -1);
        end

        return;
      end

      // {m}
      if (rn.m == rn.n) begin
        accept = prev_accept;
        return;
      end

      // {m,n}
      last_accept = nfa.new_state();
      cur_accept  = prev_accept;

      for (int k = rn.m; k < rn.n; k++) begin
        build_rec(rn.child, nfa, s_child, a_child);

        if (rn.greedy) begin
          nfa.add_transition(cur_accept, s_child, -1);
          nfa.add_transition(cur_accept, last_accept, -1);
        end
        else begin
          nfa.add_transition(cur_accept, last_accept, -1);
          nfa.add_transition(cur_accept, s_child, -1);
        end

        cur_accept = a_child;
      end

      nfa.add_transition(cur_accept, last_accept, -1);

      accept = last_accept;
      return;
    end

    // DotNode
    if ($cast(dn, node)) begin
      start  = nfa.new_state();
      accept = nfa.new_state();
      nfa.add_transition(start, accept, -2);
      return;
    end

    // StartAnchor (^)
    if ($cast(san, node)) begin
      start  = nfa.new_state();
      accept = nfa.new_state();
      nfa.add_transition(start, accept, -3);
      return;
    end

    // EndAnchor ($)
    if ($cast(ean, node)) begin
      start  = nfa.new_state();
      accept = nfa.new_state();
      nfa.add_transition(start, accept, -4);
      return;
    end

    start  = -1;
    accept = -1;
  endfunction

  function NFA build(RegexNode root);
    NFA nfa;
    int start, accept;
    nfa = new();
    build_rec(root, nfa, start, accept);
    nfa.start_state  = start;
    nfa.accept_state = accept;
    if (accept >= 0 && accept < nfa.states.size())
      nfa.states[accept].is_accept = 1;
    return nfa;
  endfunction

endclass
