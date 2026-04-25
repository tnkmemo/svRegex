class NFA;
  nfa_state_t states[$];
  int start_state;
  int accept_state;

  CharClassNode char_classes[$];

  function int new_state();
    nfa_state_t s;
    s.id = states.size();
    s.is_accept = 0;
    states.push_back(s);
    return s.id;
  endfunction

  function void add_transition(int from, int to, int ch);
    transition_t t;
    t.to = to;
    t.ch = ch;
    states[from].transitions.push_back(t);
  endfunction

  function int register_char_class(CharClassNode c);
    int id = char_classes.size();
    char_classes.push_back(c);
    return id;
  endfunction

endclass
