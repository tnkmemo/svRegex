class NfaRunner;

  // ------------------------------------------------------------
  // epsilon-closure
  // ------------------------------------------------------------
  function void epsilon_closure(
    NFA nfa,
    ref int in_states[$],
    output int out_states[$]
  );
    bit visited[int];
    int q[$];
    int head;
    int cur;
    int i;
    int t;
    transition_t tr;

    out_states = {};
    q = {};
    head = 0;

    foreach (in_states[i]) begin
      if (!visited.exists(in_states[i])) begin
        visited[in_states[i]] = 1;
        q.push_back(in_states[i]);
      end
    end

    while (head < q.size()) begin
      cur = q[head];
      head++;
      out_states.push_back(cur);

      foreach (nfa.states[cur].transitions[t]) begin
        tr = nfa.states[cur].transitions[t];
        if (tr.ch == -1 && !visited.exists(tr.to)) begin
          visited[tr.to] = 1;
          q.push_back(tr.to);
        end
      end
    end
  endfunction

  // ------------------------------------------------------------
  // Anchor
  // ------------------------------------------------------------
  function void anchor_step(
    NFA nfa,
    ref int cur_closure[$],
    int pos,
    int i,
    string idata
  );
    int next[$];
    int s, t;
    transition_t tr;

    next = {};

    foreach (cur_closure[s]) begin
      foreach (nfa.states[cur_closure[s]].transitions[t]) begin
        tr = nfa.states[cur_closure[s]].transitions[t];

        // StartAnchor (^)
        if (tr.ch == -3) begin
          if (pos == 0 && i == 0)
            next.push_back(tr.to);
        end

        // EndAnchor ($)
        else if (tr.ch == -4) begin
          if (i == idata.len())
            next.push_back(tr.to);
        end
      end
    end

    if (next.size() > 0)
      epsilon_closure(nfa, next, cur_closure);
  endfunction

  // ------------------------------------------------------------
  // Execute NFA from pos
  // ------------------------------------------------------------
  function int run_from_pos(NFA nfa, string idata, int pos);
    int cur_set[$];
    int cur_closure[$];
    int next_set[$];
    int i, j, t, s;
    int ip;
    byte ch;
    transition_t tr;

    // epsilon-closure
    cur_set = {};
    cur_set.push_back(nfa.start_state);
    epsilon_closure(nfa, cur_set, cur_closure);

    // anchor before reading
    anchor_step(nfa, cur_closure, pos, pos, idata);

    for (i = pos; i < idata.len(); i++) begin
      ch = idata[i];
      next_set = {};

      foreach (cur_closure[j]) begin
        s = cur_closure[j];
        foreach (nfa.states[s].transitions[t]) begin
          tr = nfa.states[s].transitions[t];

          // epsilon
          if (tr.ch == -1) begin end

          // Dot
          else if (tr.ch == -2) begin
            next_set.push_back(tr.to);
          end

          // StartAnchor
          else if (tr.ch == -3) begin end

          // EndAnchor
          else if (tr.ch == -4) begin
            if (i == idata.len())
              next_set.push_back(tr.to);
          end

          // Char class
          else if (tr.ch <= -5) begin
            int class_id = -(tr.ch + 5);
            CharClassNode cc = nfa.char_classes[class_id];

            bit match = 0;
            int k;
            foreach (cc.chars[k]) begin
              if (cc.chars[k] == ch) begin
                match = 1;
                break;
              end
            end
            if (cc.inverted) match = !match;

            if (match) next_set.push_back(tr.to);
          end

          // Literal
          else if (tr.ch == ch) begin
            next_set.push_back(tr.to);
          end
        end
      end

      if (next_set.size() == 0) break;

      epsilon_closure(nfa, next_set, cur_closure);

      // anchor
      ip = i + 1;
      anchor_step(nfa, cur_closure, pos, ip, idata);
    end

    // accept check
    foreach (cur_closure[j]) begin
      if (nfa.states[cur_closure[j]].is_accept)
        return i;
    end

    return -1;
  endfunction

  // ------------------------------------------------------------
  // Execute NFA
  // ------------------------------------------------------------
  function bit run (
    NFA nfa,
    string idata,
    output int start_pos,
    output int end_pos
  );
    int e;

    for (int pos = 0; pos <= idata.len(); pos++) begin
      e = run_from_pos(nfa, idata, pos);
      if (e >= 0) begin
        start_pos = pos;
        end_pos   = e;
        return 1;
      end
    end

    start_pos = -1;
    end_pos   = -1;
    return 0;
  endfunction

endclass
