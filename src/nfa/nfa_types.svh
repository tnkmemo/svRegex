typedef struct {
  int to;
  int ch; // -1 = epsilon
} transition_t;

typedef struct {
  int id;
  transition_t transitions[$];
  bit is_accept;
} nfa_state_t;
