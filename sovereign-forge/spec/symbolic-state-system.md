SECTION 01 — FORMAL MODEL FOUNDATION


FORMAL_OBJECT: SYMBOLIC_STATE_SYSTEM
DEFINITION:
  S = (N, E, T, R, I)
  where:
    N = finite set of symbolic nodes (symbols, figures, objects, places, actions,
        colors, numbers, geometric forms, animals, elements, textual units,
        dream events, vision events, temporal events)
    E ⊆ N × N × L = set of labeled directed edges
    L = { PRECEDES, FOLLOWS, CONTAINS, TRANSFORMS, OPPOSES, MERGES,
          SEPARATES, REPEATS, DISAPPEARS, REAPPEARS, INTERRUPTS,
          RESOLVES, FAILS_TO_RESOLVE }
    T = (N ∪ E) → ℝ≥0, temporal assignment function mapping each node
        or edge to its first occurrence timestamp (measured in notebook
        page units or session units from Black Book 1 opening)
    R = set of transformation rules R_i : N → N (partial functions on
        symbolic nodes modeling observed transitions between symbol states)
    I ⊆ N ∪ E = interruption set, subset of nodes and edges that are
        marked as textually unresolved, incomplete, or terminal
SOURCE_BASIS: Model construction, no Jung source claims this structure
CONTRIBUTION_TYPE: NEW_FORMALISM
NOVELTY_STATUS: NOVEL_CANDIDATE
VERIFICATION_METHOD: Check that every observed symbol in the Black Books
  can be assigned a node in N; check that every observed symbol relationship
  can be assigned an edge in E with a label from L; check that T is consistent
  with the temporal ordering of notebook entries; check that I correctly
  identifies all textually unresolved sequences
FAILURE_CASE: If a symbol relationship observed in the source cannot be
  labeled by any element of L, then L is incomplete and must be extended;
  this is a detectable failure requiring L-expansion, not a model failure
DEPENDENCY: none


FORMAL_OBJECT: SYMBOLIC_NODE_ONTOLOGY
DEFINITION:
  N is partitioned into:
    N_SYMBOL     = recurring non-personal imaginal images
    N_FIGURE     = named or unnamed persons/entities in the dialogues
    N_OBJECT     = physical or quasi-physical items
    N_PLACE      = locations (real, imaginal, architectural)
    N_ACTION     = events, verbs, processes observed in the visions
    N_COLOR      = chromatic attributions
    N_NUMBER     = numerical occurrences (cardinal, ordinal, structural)
    N_FORM       = geometric shapes, spatial patterns
    N_ANIMAL     = zoomorphic entities
    N_ELEMENT    = classical or observed elemental forces (fire, water, etc.)
    N_TEXT       = textual units (individual speeches, passages)
    N_DREAM      = events marked as dream-mode
    N_VISION     = events marked as active imagination / vision-mode
    N_TEMPORAL   = named temporal references (years, seasons, phases)
  The partition is exhaustive: N = ∪ N_k
  The partition is not exclusive: a node may carry multiple type tags
  (e.g., an entity that is both a FIGURE and an ANIMAL)
SOURCE_BASIS: Observation of the source material structure
CONTRIBUTION_TYPE: NEW_FORMALISM (ontological partition)
NOVELTY_STATUS: NOVEL_CANDIDATE
VERIFICATION_METHOD: Apply partition to a 100-node sample; verify that
  each node receives at least one type assignment; verify that no node
  requires a type outside the partition
FAILURE_CASE: Existence of a node requiring a type not in the partition
  forces an ontology extension; this is recorded as ONTOLOGY_EXTENSION_EVENT
DEPENDENCY: SYMBOLIC_STATE_SYSTEM


FORMAL_OBJECT: TEMPORAL_ASSIGNMENT_FUNCTION
DEFINITION:
  Let BB = Black Books 1 through 7 (1913-1932)
  Let LN = Liber Novus calligraphic text
  Let E_i = epilogue of LN
  Let P_j = page j of BB_k (notebook k, page j)
  T: N → ℕ²
  T(n) = (k, j) where n first appears on page j of notebook k
  
  Ordering: T(n_1) < T(n_2) iff k_1 < k_2, or (k_1 = k_2 and j_1 < j_2)
  
  T is a partial order on N
  T is not necessarily total: symbols may appear in multiple positions
  T_first(n) = earliest (k, j) pair for node n
  T_last(n) = latest (k, j) pair for node n
  T_span(n) = T_last(n) - T_first(n) = temporal persistence of n
SOURCE_BASIS: Black Books publication structure (7 notebooks)
CONTRIBUTION_TYPE: NEW_FORMALISM (temporal coordinate system)
NOVELTY_STATUS: NOVEL_CANDIDATE
VERIFICATION_METHOD: For a sample of symbols with known first appearances,
  confirm T_first matches source; confirm T_span correctly identifies persistent
  vs transient symbols
FAILURE_CASE: Symbol with ambiguous first appearance due to undated entry
  forces T(n) = UNDEFINED for that node; these must be recorded in
  TEMPORAL_AMBIGUITY_LOG
DEPENDENCY: SYMBOLIC_STATE_SYSTEM


FORMAL_OBJECT: SYMBOL_TRANSITION_FUNCTION
DEFINITION:
  F: N × X → N
  where X = set of observable textual/imaginal events (textual input alphabet)
  
  F(s, x) = s' means: given current symbolic state s and input event x,
    the next symbolic state is s'
  
  Extended to sequences: F*(s, x_1 x_2 ... x_n) = s_n
    where s_0 = s and s_i = F(s_{i-1}, x_i)
  
  The function F is:
    DETERMINISTIC if ∀ s ∈ N, ∀ x ∈ X: |{F(s,x)}| ≤ 1
    NON_DETERMINISTIC if ∃ s ∈ N, x ∈ X: |{F(s,x)}| > 1
  
  HYPOTHESIS (to be tested): F is non-deterministic in the Black Books
    (same symbol input x with different contexts produces different transitions)
  
  FORMAL_CONSEQUENCE: if F is non-deterministic, the system must be
    modeled as a relation rather than a function
SOURCE_BASIS: General symbolic dynamics; not claimed by Jung
CONTRIBUTION_TYPE: NEW_FORMALISM
NOVELTY_STATUS: NOVEL_CANDIDATE
VERIFICATION_METHOD: For each attested symbol transition, verify that
  F(s, x) is uniquely defined or not; count non-deterministic cases;
  if > 0, reclassify F as a relation R ⊆ N × X × N
FAILURE_CASE: If F is everywhere undefined (no systematic transitions),
  the transition model is inapplicable; this is a falsification of the
  transition model for the Black Books material
DEPENDENCY: SYMBOLIC_STATE_SYSTEM, TEMPORAL_ASSIGNMENT_FUNCTION


FORMAL_OBJECT: INTERRUPTION_SET_DEFINITION
DEFINITION:
  I ⊆ N ∪ E is the interruption set.
  
  Elements of I are classified:
    I_TEXT = textual interruptions (sentences that break off)
    I_IMAGE = imaginal sequences without resolution
    I_DIALOGUE = dialogues without formal closure
    I_TERMINAL = the final interruption at the end of the Epilogue
  
  I_TERMINAL is a distinguished singleton: {final_unresolved_clause}
  
  Let LC = last complete syntactic unit before the terminal break
  Let TU = the terminal unresolved sequence (partial clause)
  
  Then I_TERMINAL = { TU }
  
  TU is associated with:
    TU_GRAMMAR_CLASS = syntactic class of TU (clause type, if determinable)
    TU_SEMANTIC_FIELD = range of semantic fields consistent with TU
    TU_POSSIBLE_CONTINUATIONS = set of grammatically valid continuations
    TU_AMBIGUITY_MEASURE = |TU_POSSIBLE_CONTINUATIONS| (or entropy thereof)
  
  TU_POSSIBLE_CONTINUATIONS is computed WITHOUT claiming authorial intent.
  
  CONSTRAINT: No element of TU_POSSIBLE_CONTINUATIONS shall be presented
    as the intended completion.
SOURCE_BASIS: Explicit record that the Liber Novus Epilogue breaks mid-sentence
  (Library of Congress documentation; Shamdasani editorial notes in Liber Novus)
CONTRIBUTION_TYPE: NEW_FORMALISM, NEW_OBJECT
NOVELTY_STATUS: NOVEL_CANDIDATE
VERIFICATION_METHOD: Confirm existence of terminal break by consulting
  primary source; confirm TU classification; enumerate at least 5
  grammatically valid continuations without asserting authorial intent
FAILURE_CASE: If the terminal break is editorial rather than authorial,
  the interruption model is applied to the wrong object; this is a
  SOURCE_VERIFICATION_FAILURE
DEPENDENCY: SYMBOLIC_STATE_SYSTEM


SECTION 02 — NOVEL SYMBOLIC OPERATORS


FORMAL_OBJECT: SYMBOL_RESONANCE
OPERATOR: RESONANCE(a, b) → ℝ≥0
DEFINITION:
  RESONANCE(a, b) = |{ t : T(a) ≤ t ≤ T_last(a) AND T(b) ≤ t ≤ T_last(b) }| / T_total
  
  Informally: the fraction of total notebook time during which both symbols a
  and b are active (have appeared and not yet disappeared from the text)
  
  RESONANCE(a, b) = 0 if symbols never co-occur in any temporal window
  RESONANCE(a, b) = 1 if symbols co-occur across the entire text span
  
  Note: this is NOT the Jungian concept of "resonance" (which is qualitative)
  This is an operationally defined co-occurrence measure
CONTRIBUTION_TYPE: NEW_MATHEMATICAL_OBJECT, NEW_ALGORITHM
NOVELTY_STATUS: NOVEL_CANDIDATE
PRIOR_ART_CONCERN: general co-occurrence measures exist in corpus linguistics;
  the novelty here is the application to temporal imaginal sequences with
  specific textual boundary conditions
VERIFICATION_METHOD: Compute RESONANCE for (Philemon, Serpent/Dragon figure);
  verify that result is nonzero only during periods when both are active;
  compare to baseline co-occurrence metrics
FAILURE_CASE: If all symbol pairs have identical resonance values, the metric
  has no discriminative power; this falsifies the metric's utility
DEPENDENCY: TEMPORAL_ASSIGNMENT_FUNCTION


FORMAL_OBJECT: SYMBOL_DRIFT
OPERATOR: DRIFT(n, t_1, t_2) → context_vector_distance
DEFINITION:
  For symbol n, at times t_1 and t_2 (with t_1 < t_2):
  
  CONTEXT(n, t) = multiset of symbols co-occurring with n within a window
    of w textual units centered at t
  
  DRIFT(n, t_1, t_2) = d( CONTEXT(n, t_1), CONTEXT(n, t_2) )
  
  where d is a distance metric on multisets (e.g., cosine distance on
  symbol frequency vectors)
  
  SEMANTIC_DRIFT(n) = max_{t_1, t_2} DRIFT(n, t_1, t_2)
  
  DRIFT > threshold_stable: symbol has undergone contextual transformation
  DRIFT ≤ threshold_stable: symbol is semantically stable across the text
CONTRIBUTION_TYPE: NEW_MATHEMATICAL_OBJECT, NEW_MEASUREMENT
NOVELTY_STATUS: NOVEL_CANDIDATE
PRIOR_ART_CONCERN: semantic drift is studied in diachronic NLP; novelty
  is application to short imaginal sequence with symbolic (not linguistic) units
VERIFICATION_METHOD: Compute DRIFT for a known transforming symbol (e.g.,
  serpent figure which undergoes explicit transformation in the text);
  verify that DRIFT value is higher than for a stable background symbol
FAILURE_CASE: If no symbol shows DRIFT > threshold_stable, the text is
  symbolically static; this is a falsifiable prediction about the Black Books
DEPENDENCY: TEMPORAL_ASSIGNMENT_FUNCTION, SYMBOL_RESONANCE


FORMAL_OBJECT: SYMBOL_INVERSION
OPERATOR: INVERSION(n) → n'
DEFINITION:
  A symbol n is INVERTED at time t if:
  
  There exists n' ∈ N such that:
    (1) T(n') > T(n)
    (2) n' occupies a structurally opposing position to n in E
        (i.e., ∃ edge (n, n', OPPOSES) ∈ E or (n', n, OPPOSES) ∈ E)
    (3) n' shares at least k contextual neighbors with n (k is a parameter)
    (4) n' is explicitly generated from n in the text or dialogue
  
  When all four conditions hold: INVERSION(n) = n'
  
  PARTIAL_INVERSION: conditions (1), (2), (3) hold but (4) does not
    → relationship is hypothetical, must be marked UNVERIFIED_HYPOTHESIS
  
  INVERSION is NOT the same as Jungian "enantiodromia" (which is qualitative)
  INVERSION is operationally testable
CONTRIBUTION_TYPE: NEW_MATHEMATICAL_OBJECT, NEW_DEFINITION
NOVELTY_STATUS: NOVEL_CANDIDATE
VERIFICATION_METHOD: Apply to a known pair of figures that are textually
  presented as opposites; verify all four conditions are satisfied
FAILURE_CASE: If condition (4) is never satisfied for any pair, INVERSION
  is an empty operator; this falsifies the claim that the text contains
  formal symbolic inversions
DEPENDENCY: SYMBOLIC_NODE_ONTOLOGY, SYMBOLIC_STATE_SYSTEM


FORMAL_OBJECT: SYMBOL_RECURSION
OPERATOR: RECURSION(n, depth) → tree
DEFINITION:
  RECURSION(n, 0) = {n}
  RECURSION(n, d) = {n} ∪ { RECURSION(m, d-1) : ∃ edge (n, m, TRANSFORMS) ∈ E }
  
  This generates the TRANSFORMATION_TREE of symbol n:
    the tree of all symbols reachable from n by TRANSFORMS edges
    up to depth d
  
  RECURSION_DEPTH(n) = max d such that RECURSION(n, d) ≠ RECURSION(n, d-1)
  
  A symbol n is RECURSIVELY_STABLE if RECURSION_DEPTH(n) = 0
    (no transformations originate from n)
  A symbol n is RECURSIVELY_DEEP if RECURSION_DEPTH(n) > threshold_deep
CONTRIBUTION_TYPE: NEW_MATHEMATICAL_OBJECT
NOVELTY_STATUS: NOVEL_CANDIDATE
VERIFICATION_METHOD: Build TRANSFORMATION_TREE for a major transforming figure;
  verify depth matches textual transformations; verify terminal leaves are
  symbolically stable (no further transformation observed)
FAILURE_CASE: If RECURSION_DEPTH(n) = 0 for all n, the text contains no
  symbol transformations; this is a falsifiable prediction
DEPENDENCY: SYMBOLIC_STATE_SYSTEM


FORMAL_OBJECT: SYMBOL_ENTROPY
OPERATOR: H(S) → ℝ≥0
DEFINITION:
  Let p(n) = T_span(n) / T_total for each n ∈ N
  (probability of a symbol being "active" at a random time)
  
  Normalize: Σ_n p(n) may exceed 1 since multiple symbols are active
  simultaneously; use conditional probability: p(n | t) = 1 if T(n) ≤ t ≤ T_last(n),
  else 0
  
  At time t: p(n, t) = p(n | t) / Z(t) where Z(t) = Σ_m p(m | t)
  
  H(t) = -Σ_n p(n,t) log p(n,t)     [local symbolic entropy at time t]
  
  H_global = (1/T_total) ∫ H(t) dt   [average symbolic entropy]
  
  H_max = log |N|                     [maximum possible entropy]
  
  H_normalized(t) = H(t) / H_max
  
  INTERPRETATION (as research hypothesis, not fact):
    High H(t) → many symbols active simultaneously → imaginal complexity peak
    Low H(t) → few symbols active → narrative concentration
  
  This is HYPOTHESIS, not established fact. It requires empirical test.
CONTRIBUTION_TYPE: NEW_MATHEMATICAL_OBJECT, NEW_MEASUREMENT
NOVELTY_STATUS: NOVEL_CANDIDATE
PRIOR_ART_CONCERN: Shannon entropy applied to text exists; applying it to
  imaginal symbol states (not word frequencies) in this specific material
  is the proposed novel operation
VERIFICATION_METHOD: Compute H(t) at known narrative peaks (e.g., extended
  vision sequences) and verify H(t) is higher than at transitional passages
FAILURE_CASE: If H(t) shows no correlation with narrative complexity markers,
  the entropy model has no explanatory power for this material
DEPENDENCY: TEMPORAL_ASSIGNMENT_FUNCTION


FORMAL_OBJECT: SYMBOL_ATTRACTOR
DEFINITION:
  A symbol n ∈ N is an ATTRACTOR if:
  
  (1) T_span(n) / T_total > threshold_persistent   [persistent across text]
  (2) RECURSION(n, 1) ⊇ {other nodes that eventually transform to n}
      [other symbols transform toward n]
  (3) RESONANCE(n, m) > threshold_resonance for multiple m ∈ N
      [high co-occurrence with many other symbols]
  
  ATTRACTOR_BASIN(n) = { m ∈ N : ∃ path n → ... → n in TRANSFORMS-edges
    with m on the path }  [symbolic basin of attraction]
  
  REPELLOR: dual concept; a symbol n is a REPELLOR if it appears once,
    generates transformations away from itself, and does not recur
CONTRIBUTION_TYPE: NEW_DEFINITION, NEW_MATHEMATICAL_OBJECT
NOVELTY_STATUS: NOVEL_CANDIDATE
PRIOR_ART_CONCERN: attractor concept from dynamical systems; application
  to symbolic imaginal sequences is the proposed novel extension
VERIFICATION_METHOD: Identify candidate attractors by criteria (1)-(3);
  verify ATTRACTOR_BASIN contains known transforming symbols from the text
FAILURE_CASE: If no symbol satisfies all three criteria, no attractors
  exist in the model; this is a testable prediction
DEPENDENCY: SYMBOL_RECURSION, SYMBOL_RESONANCE, TEMPORAL_ASSIGNMENT_FUNCTION


FORMAL_OBJECT: SYMBOL_BOUNDARY
DEFINITION:
  The BOUNDARY of a symbol set A ⊆ N is:
  
  ∂A = { n ∈ A : ∃ m ∉ A such that (n, m, ·) ∈ E or (m, n, ·) ∈ E }
  
  Intuitively: ∂A is the set of symbols in A that have direct edges to
  symbols outside A (the "frontier" of the symbolic cluster)
  
  BOUNDARY_DENSITY(A) = |∂A| / |A|
  
  A cluster A is CLOSED if ∂A = ∅ (no external connections)
  A cluster A is OPEN if ∂A = A (all nodes have external connections)
  
  Research question: Are there closed symbol clusters in the Black Books?
  This would indicate isolated symbolic subsystems.
CONTRIBUTION_TYPE: NEW_DEFINITION
NOVELTY_STATUS: NOVEL_CANDIDATE
VERIFICATION_METHOD: Identify candidate closed clusters by spectral clustering
  on E; verify ∂A = ∅ empirically by checking all edges
FAILURE_CASE: If no closed cluster exists, the symbol graph is connected
  (all symbols are eventually reachable from all others); this is itself
  a research finding
DEPENDENCY: SYMBOLIC_STATE_SYSTEM


SECTION 03 — NOVELTY LEDGER (NB-N001 through NB-N200)


NB-N001
ID: NB-N001
SOURCE: Black Books structural observation
OBSERVATION: The Black Books span 7 notebooks over approximately 19 years
  (1913–1932); this creates a minimum temporal granularity of notebook-level
  for symbol tracking
EXISTING_CONCEPT: Temporal analysis of texts exists in general narratology
NEW_OPERATION: Defining T: N → ℕ² (notebook × page) as a formal coordinate
  system for symbolic events specific to this material
NEW_RELATION: Lexicographic order on T provides a total temporal ordering
  on first symbol appearances
NOVELTY_CLAIM: The specific coordinate system T = (notebook_index, page_index)
  defined over the Black Books as primary data is new as a formal object
POTENTIAL_PRIOR_ART: Diachronic corpus analysis; timeline annotation in
  digital humanities
DISTINCTION: This is not a linguistic timeline; it tracks imaginal symbol
  states with partial order semantics and interruption states
TEST: Verify T is well-defined for a 50-symbol sample; verify lexicographic
  ordering is consistent with known temporal sequence of entries
STATUS: NOVEL_CANDIDATE


NB-N002
ID: NB-N002
SOURCE: Liber Novus Epilogue (editorial notes, Shamdasani)
OBSERVATION: The Epilogue of Liber Novus breaks off mid-sentence around 1959
EXISTING_CONCEPT: Unfinished texts are studied in literary theory; manuscript
  studies treats incomplete texts as objects of study
NEW_OPERATION: Classifying TU (terminal unresolved sequence) as a formal
  object with computable properties (ambiguity measure, possible-continuation
  distribution, syntactic class)
NEW_RELATION: TU is an element of I_TERMINAL ⊂ I ⊂ S; this embeds the
  interruption into the formal model S
NOVELTY_CLAIM: Treating the specific terminal break of Liber Novus as a
  formal mathematical object with computable properties (rather than as
  a purely hermeneutic phenomenon) is new
POTENTIAL_PRIOR_ART: Manuscript completion studies; computational linguistics
  work on sentence completion
DISTINCTION: The novel operation is specifically computing the ambiguity
  measure of TU and generating a constrained completion distribution without
  asserting authorial intent — this is a formal constraint that does not
  exist in purely hermeneutic or philological treatments
TEST: Count grammatically valid English continuations of TU; measure
  semantic entropy of the continuation distribution
STATUS: NOVEL_CANDIDATE


NB-N003
ID: NB-N003
SOURCE: Black Books content observation
OBSERVATION: Philemon appears as a named figure in the Black Books dialogues
EXISTING_CONCEPT: Philemon is discussed as a symbol of the "Wise Old Man"
  archetype in Jungian literature
NEW_OPERATION: Treating Philemon as a node n_Philemon ∈ N_FIGURE and computing
  T_first(n_Philemon), T_last(n_Philemon), T_span(n_Philemon), RESONANCE
  with other nodes, SYMBOL_DRIFT across appearances
NEW_RELATION: Computing ATTRACTOR_BASIN(n_Philemon) to determine which other
  symbols transform toward or through Philemon
NOVELTY_CLAIM: The formal network properties of n_Philemon (centrality,
  resonance vector, attractor basin size) have not been computed as formal
  objects
POTENTIAL_PRIOR_ART: Social network analysis of literary characters;
  character network analysis in digital humanities
DISTINCTION: The novelty is embedding n_Philemon in the full S = (N, E, T, R, I)
  structure and computing its formal properties including transformation
  tree and attractor basin — not merely identifying it as a character
TEST: Compute degree centrality of n_Philemon in E; compare to degree
  centrality of background figures; hypothesis: n_Philemon has significantly
  higher centrality than average
STATUS: NOVEL_CANDIDATE


NB-N004
ID: NB-N004
SOURCE: Black Books observation, general
OBSERVATION: Serpent/dragon figures appear recurrently in the imaginal sequences
EXISTING_CONCEPT: Serpent as a symbol is catalogued in Jungian and general
  mythological literature
NEW_OPERATION: Distinguishing TOKEN occurrences of serpent figures from TYPE
  (i.e., tracking whether each serpent appearance is the same entity or a
  new instantiation); constructing TOKEN_SEQUENCE(SERPENT_TYPE)
NEW_RELATION: TYPE_RECURRENCE vs TOKEN_RECURRENCE distinction applied to
  imaginal entities for the first time as a formal classification
NOVELTY_CLAIM: Formally distinguishing type-recurrence from token-recurrence
  for symbolic entities in an imaginal text is a new taxonomic operation
POTENTIAL_PRIOR_ART: Type/token distinction is standard in linguistics;
  application to imaginal symbol tracking is proposed novel extension
DISTINCTION: In linguistics, type/token applies to word forms; here it applies
  to imaginal entities with continuity of identity — a different kind of
  object requiring different operational criteria for identity
TEST: Define IDENTITY_CRITERIA for serpent entities; apply to all serpent
  appearances; classify each as same-entity or new-entity; compute
  TYPE_COUNT and TOKEN_COUNT
STATUS: NOVEL_CANDIDATE


NB-N005
ID: NB-N005
SOURCE: Liber Novus structure
OBSERVATION: The Liber Novus text is organized into titled sections/chapters
EXISTING_CONCEPT: Chapter structure in manuscripts is standard
NEW_OPERATION: Treating each chapter boundary as a temporal event in T;
  computing symbol persistence across chapter boundaries (which symbols
  survive chapter transitions vs which are confined to a single chapter)
NEW_RELATION: CHAPTER_CROSSING(n) = number of chapter boundaries crossed
  by symbol n during its active span
NOVELTY_CLAIM: Quantifying chapter-boundary persistence as a formal property
  of imaginal symbols is new
POTENTIAL_PRIOR_ART: Narrative arc analysis; chapter-level character tracking
DISTINCTION: Chapter boundaries in Liber Novus are thematically significant
  in ways that differ from standard narrative chapters; applying persistence
  across these specific boundaries as a formal metric is distinct
TEST: For each symbol, compute CHAPTER_CROSSING; compare to SYMBOL_ATTRACTOR
  classification; hypothesis: attractors have higher CHAPTER_CROSSING than
  non-attractors
STATUS: NOVEL_CANDIDATE


NB-N006
ID: NB-N006
SOURCE: Black Books observation
OBSERVATION: Numbers appear explicitly in some symbolic contexts in the
  Black Books (e.g., numerical structures, quaternities)
EXISTING_CONCEPT: Quaternary symbolism (four-fold structures) is analysed
  in Aion and other Jung works
NEW_OPERATION: Extracting all numerical symbols as N_NUMBER ⊂ N; computing
  NUMBER_RECURRENCE(n) for each numeric value; testing whether specific
  numbers appear as structural organizers of the symbol graph
NEW_RELATION: NUMBER_CENTRALITY(k) = degree centrality of the node
  corresponding to number k in the symbol graph E
NOVELTY_CLAIM: Computing formal graph-theoretic centrality of numerical symbols
  in the Black Books symbol graph is new; this tests whether numbers function
  as structural hubs in the imaginal network
POTENTIAL_PRIOR_ART: Numerological analysis exists; graph centrality of
  symbolic numbers in a formal graph is proposed as new operation
DISTINCTION: Jungian numerology is qualitative interpretation; this is a
  computable centrality metric on a formal graph
TEST: Build sub-graph of N_NUMBER and their edges in E; compute betweenness
  centrality for each numeric node; identify high-centrality numbers
STATUS: NOVEL_CANDIDATE


NB-N007
ID: NB-N007
SOURCE: Model construction
OBSERVATION: The transformation rules R = {R_i} are partial functions on N
EXISTING_CONCEPT: Rewriting systems, term rewriting in formal computation theory
NEW_OPERATION: Defining the TRANSFORMATION_MONOID M(R) = (R, ∘, id) where
  R_i ∘ R_j is the composition of transformation rules and id is the identity
  transformation
NEW_RELATION: The algebraic structure of R determines whether compound
  transformations are order-dependent (non-commutative monoid) or
  order-independent (commutative monoid)
NOVELTY_CLAIM: Studying the algebraic (monoid) structure of symbolic
  transformation rules derived from the Black Books is new
POTENTIAL_PRIOR_ART: Transformation monoids exist in automata theory;
  applying this to imaginal symbol transformations is proposed novel extension
DISTINCTION: Standard rewriting systems are defined over formal languages;
  this monoid is defined over imaginal symbol nodes, a different ontological
  domain
TEST: Identify three observed compound transformations in the text; check
  whether R_i ∘ R_j = R_j ∘ R_i for these pairs (testing commutativity);
  hypothesis: the monoid is non-commutative
STATUS: NOVEL_CANDIDATE


NB-N008
ID: NB-N008
SOURCE: Observation of the symbol graph structure
OBSERVATION: Some symbols in the Black Books are related by OPPOSES edges
EXISTING_CONCEPT: Opposites (enantiodromia, polarity) are central to
  Jungian theory
NEW_OPERATION: Extracting the OPPOSITION_SUBGRAPH G_opp = (N, E_opp) where
  E_opp = { (a, b) : (a, b, OPPOSES) ∈ E }; analyzing the structure of G_opp
NEW_RELATION: Testing whether G_opp is bipartite (i.e., symbols can be
  2-colored such that all opposition edges go between colors); bipartiteness
  would indicate a clean dual structure
NOVELTY_CLAIM: Testing the bipartiteness of the opposition subgraph of the
  Black Books symbol graph is new as a formal claim
POTENTIAL_PRIOR_ART: Signed graph theory; balance theory in social networks
DISTINCTION: This is not a claim about the psychology of opposites; it is
  a graph-theoretic property of the specific edge structure
TEST: Extract G_opp; run bipartiteness test; if not bipartite, find the
  minimum odd cycle (which identifies which opposition is "incomplete")
FAILURE_CASE: If G_opp has no edges (no oppositions are recorded), the test
  is vacuous; this would indicate a failure of the source annotation
STATUS: NOVEL_CANDIDATE


NB-N009
ID: NB-N009
SOURCE: Model construction
OBSERVATION: The RESONANCE operator produces a matrix R ∈ [0,1]^{|N| × |N|}
NEW_OPERATION: Computing the RESONANCE_MATRIX and its spectral properties:
  eigenvalue spectrum, spectral gap, dominant eigenvectors
NEW_RELATION: The dominant eigenvectors of R identify the most resonant
  symbol clusters (the "spectral cores" of the symbolic system)
NOVELTY_CLAIM: Applying spectral analysis to the resonance matrix of a
  symbolic imaginal system to identify structural symbol clusters is new
POTENTIAL_PRIOR_ART: Spectral graph theory; spectral clustering
DISTINCTION: The matrix here is a continuous-valued resonance matrix (not
  a discrete adjacency matrix); spectral analysis of this continuous
  co-activity structure is the proposed novel operation
TEST: Compute RESONANCE_MATRIX for a 50-symbol sample; perform eigendecomposition;
  verify that dominant eigenvectors correspond to interpretable symbol clusters
FAILURE_CASE: If all eigenvalues are equal, there is no cluster structure;
  this is a falsifiable prediction
STATUS: NOVEL_CANDIDATE


NB-N010
ID: NB-N010
SOURCE: Black Books observation
OBSERVATION: Some symbols reappear after extended absence in the notebooks
EXISTING_CONCEPT: Recurrence is noted in Jungian analysis as "return of the
  repressed" or symbol re-emergence; no formal model is given
NEW_OPERATION: Defining REAPPEARANCE_LAG(n) = T_reappearance(n) - T_disappearance(n)
  where T_disappearance = last time before a gap of > k pages with no occurrence,
  and T_reappearance = first time after that gap
NEW_RELATION: REAPPEARANCE_LAG distribution across N; testing whether
  reappearance lag correlates with symbol "weight" (centrality, persistence)
NOVELTY_CLAIM: Formal measurement of reappearance lag for imaginal symbols is new
POTENTIAL_PRIOR_ART: Event recurrence analysis in time series; gap analysis
DISTINCTION: The distinction between "suppression" and "absence" of a symbol
  is a novel formal question: is absence evidence of suppression or simply
  non-occurrence? This requires a decision rule not present in prior literature
TEST: Identify three symbols with documented reappearance; compute REAPPEARANCE_LAG;
  test correlation with symbol degree centrality
STATUS: NOVEL_CANDIDATE


NB-N011
ID: NB-N011
SOURCE: Model construction
OBSERVATION: The transformation rules R define a directed graph on N
NEW_OPERATION: Computing the STRONGLY_CONNECTED_COMPONENTS of the
  TRANSFORMATION_GRAPH G_R = (N, E_R) where E_R = { (a, b) : R_i(a) = b
  for some R_i ∈ R }
NEW_RELATION: Symbols in the same SCC are mutually transformable (there
  exist transformation paths in both directions); symbols in different SCCs
  have asymmetric transformation relationships
NOVELTY_CLAIM: Applying SCC analysis to the transformation graph of an
  imaginal symbol system is new as a formal operation on this material
POTENTIAL_PRIOR_ART: SCC analysis is standard in graph theory
DISTINCTION: The novel contribution is constructing G_R from the Black Books
  and applying SCC analysis to determine the transformation structure of the
  specific imaginal system
TEST: Identify at least one SCC of size > 2; verify that symbols within
  the SCC undergo documented mutual transformations in the text
FAILURE_CASE: If G_R is a DAG (no cycles), there are no SCCs of size > 1;
  this means all transformations are irreversible — a strong structural claim
STATUS: NOVEL_CANDIDATE


NB-N012
ID: NB-N012
SOURCE: Black Books structural observation
OBSERVATION: The text contains both DREAM_MODE and VISION_MODE (active
  imagination) sequences; these are distinct in the source
EXISTING_CONCEPT: Jung distinguishes dreams from active imagination
  theoretically in various works
NEW_OPERATION: Formally partitioning N_DREAM and N_VISION and computing
  cross-partition edges: CROSS_MODAL_EDGES = { (a, b) ∈ E : a ∈ N_DREAM,
  b ∈ N_VISION or vice versa }
NEW_RELATION: Defining MODAL_TRANSFER(n): a symbol n undergoes MODAL_TRANSFER
  if it appears in both N_DREAM and N_VISION contexts
NOVELTY_CLAIM: Formalizing the modal (dream vs vision) partition and measuring
  cross-modal symbol transfer rates is new
POTENTIAL_PRIOR_ART: Narrative modal analysis exists in literary theory
DISTINCTION: The specific distinction dream-mode/vision-mode with the
  operational definition of modal transfer and cross-modal edge counting
  is not present in the existing literature
TEST: Identify symbols appearing in both modes; compute |MODAL_TRANSFER|;
  test whether cross-modal symbols have higher centrality than modal-confined symbols
STATUS: NOVEL_CANDIDATE


NB-N013
ID: NB-N013
SOURCE: Model construction, symbol graph theory
OBSERVATION: The symbol graph E has multiple edge label types
NEW_OPERATION: Defining the LABEL_DISTRIBUTION: for each node n,
  P_n(l) = |{ (n, m, l) ∈ E }| / |{ (n, m, ·) ∈ E }|
  (fraction of outgoing edges from n that carry label l)
NEW_RELATION: LABEL_SIGNATURE(n) = vector P_n over L; symbols with similar
  label signatures are "structurally similar" in their relational behavior
NOVELTY_CLAIM: Defining label signatures for symbols in the imaginal graph
  and using them to define structural similarity is new
POTENTIAL_PRIOR_ART: Graph node role analysis; attributed graph analysis
DISTINCTION: The label set L is specific to imaginal/symbolic relations;
  the signature is computed over this specific label set
TEST: Compute LABEL_SIGNATURE for n_Philemon and a background symbol;
  compare signatures; hypothesis: major figures have distinctive label signatures
FAILURE_CASE: If all signatures are identical, the label structure conveys
  no differential information about symbol roles
STATUS: NOVEL_CANDIDATE


NB-N014
ID: NB-N014
SOURCE: Black Books observation
OBSERVATION: Colors appear as symbolic attributes of figures and scenes
EXISTING_CONCEPT: Color symbolism is extensively treated in alchemical and
  Jungian literature (nigredo, albedo, citrinitas, rubedo)
NEW_OPERATION: Treating N_COLOR as a node set and computing COLOR_FREQUENCY
  distribution; building the COLOR_CO_OCCURRENCE_MATRIX: C[c1, c2] = number
  of textual units where colors c1 and c2 both appear
NEW_RELATION: CHROMATIC_CLUSTERING: applying community detection to
  the color co-occurrence graph to identify which color combinations
  tend to co-occur (independent of alchemical interpretations)
NOVELTY_CLAIM: Computing the chromatic co-occurrence structure of the
  Black Books as a formal graph and applying community detection to it
  is new; this is prior to and independent of alchemical interpretation
POTENTIAL_PRIOR_ART: Color co-occurrence analysis in art history; chromatic
  analysis of manuscripts
DISTINCTION: The novel constraint is that the analysis is prior to
  interpretive mapping onto alchemical stages; the empirical co-occurrence
  structure may or may not align with alchemical color theory
TEST: Build C matrix; apply community detection; check whether detected
  communities align with known alchemical color groupings; if they do not,
  this falsifies the simple application of alchemical color schemes
STATUS: NOVEL_CANDIDATE


NB-N015
ID: NB-N015
SOURCE: Model construction, interruption theory
OBSERVATION: I (interruption set) includes both terminal and non-terminal
  interruptions
NEW_OPERATION: Defining INTERRUPTION_DENSITY(t₁, t₂) = |I ∩ [t₁, t₂]| / (t₂ - t₁)
  (frequency of interruptions per unit time in an interval)
NEW_RELATION: Testing whether interruption density is uniform across the
  text or concentrated in specific temporal regions
NOVELTY_CLAIM: Quantifying interruption density as a temporal metric over
  the Black Books text is new
POTENTIAL_PRIOR_ART: Narrative gap analysis; lacuna studies in manuscript
  research
DISTINCTION: The formal metric INTERRUPTION_DENSITY is defined over the
  specific formal time coordinate T used in this model; it is not a simple
  count of lacunae
TEST: Compute INTERRUPTION_DENSITY in 5 equal time intervals; test for
  uniformity using a chi-squared test; hypothesis: interruption density
  is non-uniform (concentrated at specific periods)
FAILURE_CASE: If interruption density is uniform, the temporal structure of
  interruptions carries no information
STATUS: NOVEL_CANDIDATE


NB-N016
ID: NB-N016
SOURCE: Black Books observation, textual analysis
OBSERVATION: Dialogue sequences have initiating and terminating events
NEW_OPERATION: Extracting all DIALOGUE_SEQUENCES; for each sequence D_i,
  recording INITIATOR, TERMINATOR, PARTICIPANT_SET, DURATION, OUTCOME
  (resolved / unresolved / interrupted)
NEW_RELATION: Constructing the DIALOGUE_GRAPH: nodes = dialogue sessions,
  edges = when same figures appear in multiple dialogues (tracking figure
  continuity across dialogue sessions)
NOVELTY_CLAIM: Formal network analysis of dialogue sessions in the Black Books
  as a graph of recurrent participatory events is new
POTENTIAL_PRIOR_ART: Conversation network analysis; dialogue analysis in
  natural language processing
DISTINCTION: The figures in these dialogues are imaginal entities (not real
  conversational partners); applying network analysis to imaginal dialogue
  continuity is the novel extension
TEST: Build DIALOGUE_GRAPH; compute connectivity; identify central dialogue-figure
  nodes; compare to centrality in the full symbol graph E
STATUS: NOVEL_CANDIDATE


NB-N017
ID: NB-N017
SOURCE: Model construction
OBSERVATION: The transition function F: N × X → N defines an automaton
NEW_OPERATION: Identifying the LANGUAGE recognized by the symbolic automaton:
  L(A) = { x_1 x_2 ... x_n : F*(s_0, x_1 ... x_n) ∈ ACCEPT_STATES }
  where ACCEPT_STATES ⊆ N is a designated set (e.g., symbols associated
  with resolution states)
NEW_RELATION: If L(A) is regular, the symbolic dynamics can be described
  by a finite-state machine; if not, higher-complexity models are required
NOVELTY_CLAIM: Characterizing the symbolic dynamics of the Black Books as
  a formal language and testing its complexity class is new
POTENTIAL_PRIOR_ART: Formal language theory; automata theory
DISTINCTION: The automaton here is defined over imaginal symbol sequences;
  the novelty is applying formal language complexity theory to this domain
TEST: Extract observed symbol sequences; test whether they satisfy regularity
  (Myhill-Nerode theorem); hypothesis: the language is not regular
  (requires context-dependent or more powerful model)
FAILURE_CASE: If the language is empty or trivial, the automaton model
  is inapplicable
STATUS: NOVEL_CANDIDATE


NB-N018
ID: NB-N018
SOURCE: Black Books observation
OBSERVATION: Some figures are named, others are described without names
NEW_OPERATION: Partitioning N_FIGURE into N_NAMED and N_UNNAMED; computing
  the relational structure between named and unnamed figures; testing whether
  named figures have higher graph centrality than unnamed figures
NEW_RELATION: NAME_CENTRALITY_HYPOTHESIS: ∀ n ∈ N_NAMED:
  degree(n) > median(degree(N_UNNAMED))
NOVELTY_CLAIM: Testing the naming-centrality hypothesis as a formal testable
  proposition about the Black Books symbol graph is new
POTENTIAL_PRIOR_ART: Character importance vs naming in narrative studies
DISTINCTION: The formal graph-theoretic test distinguishes this from
  qualitative narrative analysis
TEST: Compute degree for all n ∈ N_NAMED and all n ∈ N_UNNAMED;
  perform Mann-Whitney U test for degree difference; report significance
FAILURE_CASE: If unnamed figures have equal or higher centrality, the
  naming-centrality hypothesis is falsified
STATUS: NOVEL_CANDIDATE


NB-N019
ID: NB-N019
SOURCE: Model construction, symbolic information theory
OBSERVATION: Sequences of symbolic events have varying predictability
NEW_OPERATION: Computing the k-th order SYMBOLIC_MARKOV_ENTROPY:
  H_k = -Σ P(n_t | n_{t-1}, ..., n_{t-k}) log P(n_t | n_{t-1}, ..., n_{t-k})
  (conditional entropy of the next symbol given the previous k symbols)
NEW_RELATION: EXCESS_ENTROPY(k) = H_0 - H_k (reduction in entropy from
  k-th order context); measuring how much context reduces symbolic uncertainty
NOVELTY_CLAIM: Computing Markov-order conditional entropy for symbolic
  imaginal sequences in the Black Books is new
POTENTIAL_PRIOR_ART: Markov models of text; entropy of symbolic sequences
DISTINCTION: The "symbols" here are imaginal entities in a vision sequence;
  the Markov chain is defined over imaginal states, not word frequencies
TEST: Compute H_k for k = 0, 1, 2, 3; plot H_k vs k; test for convergence;
  hypothesis: H_k decreases with k (context reduces uncertainty)
FAILURE_CASE: If H_k is constant for all k, the sequence is maximally random
  (no sequential structure); this is a testable falsification
STATUS: NOVEL_CANDIDATE


NB-N020
ID: NB-N020
SOURCE: Black Books observation
OBSERVATION: Geometric forms appear explicitly in some Black Book drawings
  and descriptions (circles, crosses, quaternary structures)
EXISTING_CONCEPT: Mandala geometry is discussed extensively in Jung's
  "Concerning Mandala Symbolism" and related works
NEW_OPERATION: Formally representing N_FORM as a set with topological
  attributes: EULER_CHARACTERISTIC(f) for geometric forms where f ∈ N_FORM;
  computing the FORM_GRAPH where nodes are forms and edges represent
  CONTAINS or TRANSFORMS relationships
NEW_RELATION: TOPOLOGICAL_INVARIANT_PRESERVATION: testing whether TRANSFORMS
  edges between forms preserve topological invariants (Euler characteristic,
  genus, connectedness)
NOVELTY_CLAIM: Testing topological invariant preservation under symbolic
  geometric transformations in the Black Books is new
POTENTIAL_PRIOR_ART: Topological analysis of symbols exists in general;
  application to the specific formal transformations in this material is new
DISTINCTION: The Jungian treatment of mandalas is symbolic-psychological;
  the formal topological invariant test is a mathematical operation
  independent of psychological interpretation
TEST: Identify three documented form-transformations in the text; compute
  Euler characteristics before and after transformation; test for invariance
FAILURE_CASE: All transformations preserve Euler characteristic → topology
  is invariant; or no transformations are attested → test is vacuous
STATUS: NOVEL_CANDIDATE


NB-N021
ID: NB-N021
SOURCE: Model construction, symbolic compression theory
OBSERVATION: The symbol sequence in the Black Books has a finite length
  over T_total time units
NEW_OPERATION: Computing the KOLMOGOROV_COMPLEXITY_ESTIMATE of the symbolic
  sequence using compression ratio (lossless compression of the encoded
  symbol sequence as a proxy for K-complexity)
NEW_RELATION: SYMBOLIC_COMPRESSIBILITY = 1 - (compressed_size / raw_size);
  testing whether the sequence is more compressible than a random sequence
  of the same length over the same alphabet
NOVELTY_CLAIM: Computing symbolic compressibility of the Black Books imaginal
  sequence as a formal information-theoretic property is new
POTENTIAL_PRIOR_ART: Kolmogorov complexity of texts; sequence compression
DISTINCTION: The encoding applies to imaginal symbol sequences (not raw text);
  the comparison to a random baseline is the formal novel test
TEST: Encode symbol sequence; apply gzip or LZ77; compare compression ratio
  to random permutation of same sequence; hypothesis: structured sequence
  compresses significantly better than random permutation
FAILURE_CASE: If compression ratio is not significantly better than random,
  the sequence has no detectable global structure (maximal entropy)
STATUS: NOVEL_CANDIDATE


NB-N022
ID: NB-N022
SOURCE: Black Books content observation
OBSERVATION: Certain events in the Black Books are associated with external
  events (e.g., the beginning of WWI in 1914 coinciding with intense vision
  activity)
EXISTING_CONCEPT: The relationship between Jung's inner confrontation and
  historical events is discussed biographically
NEW_OPERATION: Formalizing EXTERNAL_EVENT_SET as a set of dated historical
  events; computing SYMBOLIC_RESPONSE(e) = change in symbolic entropy H(t)
  in the window [T(e)-w, T(e)+w] around external event e
NEW_RELATION: EXTERNAL_COUPLING_COEFFICIENT = correlation between external
  event frequency and local symbolic entropy H(t)
NOVELTY_CLAIM: Computing the formal coupling between external historical
  events and local symbolic entropy in the Black Books sequence is new
POTENTIAL_PRIOR_ART: Biographical scholarship on Jung; event studies in
  historical analysis
DISTINCTION: The formal coupling coefficient is computed over the symbolic
  entropy model, not over subjective biographical interpretation
TEST: Identify 5 external events with known dates; compute SYMBOLIC_RESPONSE
  for each; test against null hypothesis of no response
FAILURE_CASE: Zero coupling (no correlation) would falsify the model;
  this is a testable prediction
STATUS: NOVEL_CANDIDATE


NB-N023
ID: NB-N023
SOURCE: Model construction, graph invariants
OBSERVATION: The full symbol graph G = (N, E) has computable graph invariants
NEW_OPERATION: Computing CHROMATIC_NUMBER χ(G) of the symbol graph: the
  minimum number of colors needed to color N such that no two adjacent
  symbols share a color
NEW_RELATION: χ(G) is a global invariant; testing whether χ(G) equals
  the number of "opposition pairs" provides a structural test of the
  opposition structure
NOVELTY_CLAIM: Computing the chromatic number of the Black Books symbol graph
  is new as a formal mathematical operation
POTENTIAL_PRIOR_ART: Graph coloring is standard; application to symbolic graphs
  as formal research objects is proposed novel
DISTINCTION: χ(G) here is not interpreted psychologically; it is a mathematical
  property tested for structural information
TEST: Compute (or bound) χ(G) for the symbol graph; compare to |OPPOSITION_PAIRS|;
  test whether the graph has structure exploitable by graph coloring algorithms
STATUS: NOVEL_CANDIDATE


NB-N024
ID: NB-N024
SOURCE: Black Books observation
OBSERVATION: Some symbols undergo explicit self-reference (a symbol refers
  to itself or its own nature in the text)
NEW_OPERATION: Defining SELF_REFERENTIAL(n) = TRUE if there exists a
  CONTAINS or TRANSFORMS edge (n, n) in E (self-loop); computing the
  SELF_REFERENCE_COUNT = |{ n : SELF_REFERENTIAL(n) }|
NEW_RELATION: Self-referential symbols may form a sub-automaton; testing
  whether the sub-graph induced by self-referential symbols is connected
NOVELTY_CLAIM: Formally identifying and analyzing self-referential imaginal
  symbols as a distinct sub-population is new
POTENTIAL_PRIOR_ART: Self-reference in logic, linguistics; reflexive symbols
  in semiotics
DISTINCTION: Self-reference for imaginal entities requires a specific
  operational definition (self-loop in a specific edge category, not
  general semantic reflexivity)
TEST: Identify candidate self-referential symbols; verify self-loop edges
  in E; count; hypothesis: self-reference count > 0 and < |N| (some but
  not all symbols are self-referential)
FAILURE_CASE: If self-reference count = 0, no symbol self-references;
  if = |N|, all symbols self-reference — both are testable
STATUS: NOVEL_CANDIDATE


NB-N025
ID: NB-N025
SOURCE: Model construction, temporal analysis
OBSERVATION: The transformation rules R may change over time
NEW_OPERATION: Defining TIME_VARYING_R(t) = the subset of R that is active
  at time t; constructing the RULE_TIMELINE showing which transformation
  rules are active in each temporal segment
NEW_RELATION: RULE_STABILITY(R_i) = fraction of total time during which
  R_i is active; identifying "stable" rules (active throughout) vs
  "transient" rules (active only in specific periods)
NOVELTY_CLAIM: Treating transformation rules as time-varying objects with
  stability metrics is new
POTENTIAL_PRIOR_ART: Time-varying networks; evolving rewriting systems
DISTINCTION: Time-varying transformation rules for imaginal symbols
  specifically require defining what "rule activation" means for a
  symbolic (not computational) transformation
TEST: Identify 5 transformation rules from the text; record their temporal
  extent; compute RULE_STABILITY; hypothesis: a stable core of 2-3 rules
  persists throughout while peripheral rules are transient
STATUS: NOVEL_CANDIDATE


NB-N026
ID: NB-N026
SOURCE: Black Books observation
OBSERVATION: Some figures appear in the text as guides or messengers
  between different symbolic domains
NEW_OPERATION: Defining MEDIATOR(n) = TRUE if n has outgoing edges to
  both a high-entropy cluster and a low-entropy cluster (connecting
  high-complexity and low-complexity symbolic regions)
NEW_RELATION: MEDIATION_SCORE(n) = H(CLUSTER_A) - H(CLUSTER_B) where n
  connects cluster A (high entropy) to cluster B (low entropy)
NOVELTY_CLAIM: Defining symbolic mediation in terms of entropy differential
  between connected clusters is new; this operationalizes "bridge" figures
  in the imaginal network without appealing to archetypal categories
POTENTIAL_PRIOR_ART: Bridge node analysis in networks; broker role analysis
DISTINCTION: The entropy-differential definition of mediation is specific
  to the symbolic entropy model defined here; it is not a standard network
  bridging metric
TEST: Identify candidate mediator nodes; compute entropy differential for
  connected clusters; verify MEDIATION_SCORE > 0 for candidates
FAILURE_CASE: All bridge nodes have zero entropy differential → no entropy-
  differential mediation exists in the graph
STATUS: NOVEL_CANDIDATE


NB-N027
ID: NB-N027
SOURCE: Black Books observation
OBSERVATION: Certain figures are associated with specific elemental forces
EXISTING_CONCEPT: Elemental attribution exists in alchemical and classical
  symbolic traditions
NEW_OPERATION: Computing the ELEMENTAL_SIGNATURE of each figure n ∈ N_FIGURE:
  ES(n) = normalized distribution over N_ELEMENT of co-occurrence strength
NEW_RELATION: ELEMENTAL_DISTANCE(n, m) = d(ES(n), ES(m)) between two figures'
  elemental signatures; figures with low elemental distance are "elementally similar"
NOVELTY_CLAIM: Computing elemental signatures as formal vectors and using them
  to measure elemental similarity between figures is new
POTENTIAL_PRIOR_ART: Co-occurrence analysis; vector space models
DISTINCTION: The elemental attribution here is observed from the co-occurrence
  data, not from prior alchemical mappings; this is a data-driven test
  of whether alchemical elemental mappings are reflected in the text structure
TEST: Compute ES for a known fire-associated figure and a known water-associated
  figure; verify ELEMENTAL_DISTANCE is high; compare to same-element figures
STATUS: NOVEL_CANDIDATE


NB-N028
ID: NB-N028
SOURCE: Model construction, symbolic topology
OBSERVATION: The symbol graph E can be analyzed for topological properties
NEW_OPERATION: Computing the HOMOLOGY of the clique complex of G = (N, E):
  the simplicial complex Δ(G) whose k-simplices are (k+1)-cliques in G;
  computing H_0(Δ(G)), H_1(Δ(G)), H_2(Δ(G)) (connected components, cycles, voids)
NEW_RELATION: BETTI_NUMBERS β_0, β_1, β_2 of Δ(G) as global topological
  invariants of the symbol system
NOVELTY_CLAIM: Computing the persistent homology (or static homology) of the
  clique complex of the Black Books symbol graph is new
POTENTIAL_PRIOR_ART: Topological data analysis; persistent homology of
  co-occurrence networks
DISTINCTION: Application of persistent homology to an imaginal symbol graph
  derived from the Black Books specifically, to test for symbolic "holes"
  (topological cycles) in the data
TEST: Build Δ(G) for a 50-node subgraph; compute Betti numbers; hypothesis:
  β_1 > 0 (there exist non-trivial topological cycles in the symbol network)
FAILURE_CASE: β_1 = 0 (no topological cycles): the symbol network is
  topologically trivial (contractible)
STATUS: NOVEL_CANDIDATE


NB-N029
ID: NB-N029
SOURCE: Model construction
OBSERVATION: The interruption set I and the transformation rules R interact:
  some transformations are interrupted before completion
NEW_OPERATION: Defining PARTIAL_TRANSFORMATION(R_i, n) = TRUE if R_i is
  applied to n but the result R_i(n) is in I (the transformation produces
  an interrupted state)
NEW_RELATION: INTERRUPTED_TRANSFORMATION_RATE = |{ (R_i, n) : PARTIAL_TRANSFORMATION }|
  / |{ (R_i, n) : R_i(n) is defined }|
NOVELTY_CLAIM: Formalizing the rate of interrupted transformations as a
  ratio metric and its relationship to I is new
POTENTIAL_PRIOR_ART: Incomplete transformations in process algebra
DISTINCTION: The interruption here is textual (the transformation breaks off
  in the manuscript), not a computational timeout or exception
TEST: Identify all attested transformations; classify each as COMPLETE or
  PARTIAL (via I membership of result); compute rate; hypothesis: rate > 0
FAILURE_CASE: Rate = 0 (all transformations complete): I contains no
  transformation endpoints
STATUS: NOVEL_CANDIDATE
