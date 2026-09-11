NB-N061
ID: NB-N061
SOURCE: Black Books observation
OBSERVATION: Some transformation sequences pass through intermediate states
  that are explicitly named in the text
NEW_OPERATION: Defining INTERMEDIATE_STATE(R_i, n): a node m such that the
  transformation from n to R_i(n) passes through m as an explicitly attested
  intermediate; building the TRANSFORMATION_PATH_GRAPH where edges are
  labeled with intermediate states
NEW_RELATION: INTERMEDIATE_CENTRALITY(m) = number of transformation paths
  that pass through m; high INTERMEDIATE_CENTRALITY identifies symbols
  that function as transition mediators
NOVELTY_CLAIM: Extracting intermediate transformation states from the text
  and computing their centrality in the full transformation path structure is new
POTENTIAL_PRIOR_ART: Intermediate state analysis in chemical kinetics;
  transition states in reaction path theory
DISTINCTION: The intermediate states here are imaginal symbolic nodes
  explicitly attested in visionary narrative, not inferred from dynamics
TEST: Identify 5 transformation paths with intermediates; compute
  INTERMEDIATE_CENTRALITY; hypothesis: a small set of symbols has
  disproportionately high intermediate centrality
STATUS: NOVEL_CANDIDATE


NB-N062
ID: NB-N062
SOURCE: Model construction, lattice theory
OBSERVATION: The symbol types in N_ONTOLOGY form a partial order under
  the "is-a-subtype-of" relation
NEW_OPERATION: Constructing the ONTOLOGY_LATTICE L_O = (N_ONTOLOGY, ≤)
  where A ≤ B iff A is a subtype of B; computing MEET (greatest lower bound)
  and JOIN (least upper bound) operations for pairs of symbol types
NEW_RELATION: LATTICE_DEPTH(A) = length of longest chain from A to ⊤
  (the top element); LATTICE_WIDTH = size of maximum antichain in L_O
NOVELTY_CLAIM: Constructing a formal lattice from the symbolic node ontology
  and computing its lattice-theoretic properties is new
POTENTIAL_PRIOR_ART: Concept lattices (formal concept analysis); type
  hierarchies in ontology engineering
DISTINCTION: The lattice here is derived from the empirical partition of
  imaginal symbols, not from a designed ontology; its lattice properties
  are structural findings about the imaginal taxonomy
TEST: Build L_O from the 14-type partition; compute all meets and joins;
  verify lattice axioms; compute depth and width
STATUS: NOVEL_CANDIDATE


NB-N063
ID: NB-N063
SOURCE: Black Books observation
OBSERVATION: Some visions have explicit spatial structure (above/below,
  left/right, center/periphery)
NEW_OPERATION: Extracting SPATIAL_RELATION_SET: all explicit spatial
  relations between symbols in a vision; representing each vision as a
  SPATIAL_GRAPH G_v = (N_v, E_spatial) where edge labels ∈
  { ABOVE, BELOW, LEFT_OF, RIGHT_OF, CONTAINS, SURROUNDS, FACES }
NEW_RELATION: SPATIAL_CONSISTENCY(G_v): testing whether the spatial relations
  in a vision are globally consistent (no contradictions under transitivity
  of above/below/left/right)
NOVELTY_CLAIM: Extracting formal spatial graphs from visionary imagery and
  testing global spatial consistency is new
POTENTIAL_PRIOR_ART: Qualitative spatial reasoning; spatial ontologies
DISTINCTION: Spatial consistency in imaginal visions is not guaranteed;
  detecting inconsistency is a novel formal test with hermeneutic implications
TEST: Extract spatial relations from one extended vision; build G_v;
  test consistency; hypothesis: some visions contain spatial inconsistencies
  that are themselves symbolically meaningful
STATUS: NOVEL_CANDIDATE


NB-N064
ID: NB-N064
SOURCE: Model construction, signal processing
OBSERVATION: Symbol activity over time is a binary signal (active / inactive)
NEW_OPERATION: Computing the POWER_SPECTRAL_DENSITY of the symbol activity
  signal for each n: PSD(n, f) = |∫ I_{n active}(t) e^{-2πift} dt|²
  using the DFT approximation over the discrete temporal grid
NEW_RELATION: DOMINANT_FREQUENCY(n) = argmax_f PSD(n, f); SPECTRAL_BANDWIDTH(n)
  = width of the main frequency peak; comparing DOMINANT_FREQUENCY across symbols
NOVELTY_CLAIM: Computing power spectral densities of symbolic activity signals
  in the Black Books is new as an application of Fourier analysis to
  imaginal symbol timeseries
POTENTIAL_PRIOR_ART: Spectral analysis of binary timeseries; rhythm analysis
DISTINCTION: The signal here is derived from an imaginal text rather than
  a physical measurement; interpreting spectral peaks as symbolic rhythm
  is a novel formal claim about imaginal structure
TEST: Compute PSD for Philemon; identify any spectral peaks; compare to
  PSD of a randomly shuffled activity signal (null hypothesis)
FAILURE_CASE: All PSD values are flat (white noise): no spectral structure
  in symbol activity
STATUS: NOVEL_CANDIDATE


NB-N065
ID: NB-N065
SOURCE: Black Books observation
OBSERVATION: The text contains explicit comparisons between symbols
  ("this figure is like...")
NEW_OPERATION: Extracting all EXPLICIT_SIMILE_PAIRS: (n, m) where the text
  explicitly compares n to m; building SIMILE_GRAPH G_sim = (N, E_sim)
  where (n, m) ∈ E_sim iff n is explicitly compared to m
NEW_RELATION: SIMILE_DISTANCE(n, m) = shortest path in G_sim; testing
  whether SIMILE_DISTANCE correlates with RESONANCE(n, m) — are symbols
  that are compared also symbols that co-occur?
NOVELTY_CLAIM: Extracting a formal simile graph from imaginal text and
  correlating its distance metric with formal co-occurrence resonance is new
POTENTIAL_PRIOR_ART: Metaphor and simile extraction in NLP; analogy detection
DISTINCTION: Similes in visionary text connect imaginal entities across
  ontological categories; the correlation between explicit comparison
  and temporal co-occurrence is a non-trivial structural hypothesis
TEST: Extract 20 explicit simile pairs; compute SIMILE_DISTANCE for 10 pairs;
  compute RESONANCE for same pairs; compute correlation; hypothesis: correlation > 0.4
STATUS: NOVEL_CANDIDATE


NB-N066
ID: NB-N066
SOURCE: Model construction, complexity theory
OBSERVATION: The symbolic automaton defined by F: N × X → N has computational
  properties
NEW_OPERATION: Computing the STATE_COMPLEXITY of the symbolic automaton:
  the minimum number of states required by a deterministic finite automaton
  recognizing L(A); comparing to |N| to determine if the symbol set is
  overcomplete relative to the language generated
NEW_RELATION: STATE_COMPRESSION_RATIO = STATE_COMPLEXITY / |N|; a ratio < 1
  indicates that the symbolic vocabulary N contains redundant states
  (some symbols are behaviorally equivalent)
NOVELTY_CLAIM: Computing state complexity and compression ratio for the
  symbolic automaton of the Black Books is new
POTENTIAL_PRIOR_ART: Automaton minimization (Myhill-Nerode); state complexity
  in formal language theory
DISTINCTION: Behavioral equivalence of imaginal symbols (two symbols with
  identical transition behavior) is a novel formal equivalence relation
  not present in hermeneutic or symbolic analysis
TEST: Apply Myhill-Nerode minimization to the symbol automaton; compute
  minimum states; compute ratio; hypothesis: ratio < 0.8 (some symbol
  redundancy exists)
STATUS: NOVEL_CANDIDATE


NB-N067
ID: NB-N067
SOURCE: Black Books observation
OBSERVATION: The text describes transformations that are explicitly reversible
  ("it became X again")
NEW_OPERATION: Identifying REVERSIBLE_TRANSFORMATION_PAIRS: (R_i, R_j) where
  R_i(n) = m and R_j(m) = n for the same n, m; building the REVERSIBILITY_GRAPH
  G_rev where edges connect rule pairs that are mutual inverses
NEW_RELATION: REVERSIBILITY_FRACTION = |REVERSIBLE_PAIRS| / |R|²;
  testing whether reversible transformations are more common than expected
  by chance
NOVELTY_CLAIM: Formally identifying and counting reversible symbolic
  transformation pairs in the Black Books is new
POTENTIAL_PRIOR_ART: Reversible computation; inverse functions in algebra
DISTINCTION: Symbolic reversibility in an imaginal text is an empirical
  observation about narrative structure, not a mathematical axiom;
  computing its frequency and distribution is a novel formal operation
TEST: Identify all candidate reversible pairs; verify by textual evidence;
  compute fraction; hypothesis: fraction > 0.1 (non-trivial reversibility)
STATUS: NOVEL_CANDIDATE


NB-N068
ID: NB-N068
SOURCE: Model construction, dimensional analysis
OBSERVATION: The formal objects in S have different dimensionalities
NEW_OPERATION: Defining DIMENSIONAL_SIGNATURE(O) for each formal object O
  in the model: a vector (d_N, d_E, d_T, d_R, d_I) recording the dimension
  (cardinality or functional dimension) of each component; verifying
  dimensional consistency of all operators
NEW_RELATION: DIMENSIONAL_MISMATCH: an operator that takes inputs of
  incompatible dimensional signatures; systematically checking all defined
  operators for dimensional consistency
NOVELTY_CLAIM: Performing dimensional analysis on the formal operators of
  the symbolic state system to detect type mismatches is new as an internal
  consistency check for the model
POTENTIAL_PRIOR_ART: Dimensional analysis in physics; type checking in
  programming languages
DISTINCTION: The "dimensions" here are formal model dimensions (node count,
  edge count, temporal range), not physical units; applying dimensional
  analysis as a formal consistency check on a symbolic theory is novel
TEST: Compute dimensional signature for RESONANCE, DRIFT, INVERSION;
  verify input/output signatures are consistent; report any mismatches
STATUS: NOVEL_CANDIDATE


NB-N069
ID: NB-N069
SOURCE: Black Books observation
OBSERVATION: Some symbols are described using negation ("it was not X but Y")
NEW_OPERATION: Extracting NEGATION_PAIRS: (n, m) where the text explicitly
  negates n in asserting m; building NEGATION_GRAPH G_neg = (N, E_neg);
  computing NEGATION_DEGREE(n) = number of times n is explicitly negated
NEW_RELATION: NEGATION_ATTRACTOR: a symbol that frequently appears as the
  "Y" in "not X but Y" constructions; high NEGATION_ATTRACTOR_SCORE indicates
  a symbol that defines itself against other symbols
NOVELTY_CLAIM: Formalizing negation as an edge relation in the imaginal
  symbol graph and computing negation-based structural roles is new
POTENTIAL_PRIOR_ART: Negation in logic; contrastive analysis in linguistics
DISTINCTION: Negation in visionary discourse ("this is not the sun but the
  dark sun") is imaginal opposition through negation — distinct from
  logical negation or ordinary contrastive reference
TEST: Extract 15 negation pairs; build G_neg; compute NEGATION_DEGREE;
  identify top-negated and top-asserted symbols
STATUS: NOVEL_CANDIDATE


NB-N070
ID: NB-N070
SOURCE: Model construction
OBSERVATION: The formal model S can be extended with a probability measure
NEW_OPERATION: Defining a PROBABILISTIC_SYMBOLIC_SYSTEM S_P = (S, P) where
  P is a probability measure over the transformation rules R:
  P(R_i) = (number of observed applications of R_i) / (total observed rule applications)
NEW_RELATION: EXPECTED_TRANSFORMATION(n) = Σ_i P(R_i) · R_i(n) (as a
  probability distribution over next states from n); computing NEXT_STATE_ENTROPY
  H_next(n) = H(EXPECTED_TRANSFORMATION(n))
NOVELTY_CLAIM: Defining a probabilistic extension of the symbolic state
  system and computing next-state entropy for each symbol is new
POTENTIAL_PRIOR_ART: Probabilistic finite automata; Markov decision processes
DISTINCTION: The probability measure is derived from observed rule frequencies
  in the text, not from a designed stochastic process; this makes it an
  empirical probabilistic model of the imaginal dynamics
TEST: Compute P(R_i) from observed rule applications; compute NEXT_STATE_ENTROPY
  for major symbols; hypothesis: attractors have lower NEXT_STATE_ENTROPY
  than peripheral symbols (their future state is more determined)
STATUS: NOVEL_CANDIDATE


NB-N071
ID: NB-N071
SOURCE: Black Books observation
OBSERVATION: The text contains explicit assertions about cause and effect
  in the imaginal domain ("because X, therefore Y")
NEW_OPERATION: Extracting CAUSAL_CLAIM_SET: all explicit causal assertions
  in the text; building CAUSAL_GRAPH G_cause = (N, E_cause) where
  (a, b, CAUSES) ∈ E_cause for each extracted causal claim
NEW_RELATION: Testing whether G_cause is a DAG (no causal cycles) or
  contains cycles (circular causation); computing CAUSAL_DEPTH(n) =
  longest causal chain originating from n
NOVELTY_CLAIM: Extracting a formal causal graph from an imaginal text and
  testing it for acyclicity is new
POTENTIAL_PRIOR_ART: Causal graph extraction; causal Bayesian networks
DISTINCTION: Causal claims in visionary text may be circular or paradoxical;
  detecting causal cycles is specifically meaningful in this domain
TEST: Extract 20 causal claims; build G_cause; test for cycles; compute
  CAUSAL_DEPTH; hypothesis: G_cause contains at least one cycle
STATUS: NOVEL_CANDIDATE


NB-N072
ID: NB-N072
SOURCE: Model construction, information theory
OBSERVATION: Different sections of the Black Books have different symbol
  densities (symbols per page)
NEW_OPERATION: Computing SYMBOL_DENSITY(k, j) = number of distinct symbols
  on page j of notebook k; computing DENSITY_GRADIENT = dD/dt (rate of
  change of symbol density over T)
NEW_RELATION: DENSITY_PEAK_SET: the set of (k,j) positions with locally
  maximum SYMBOL_DENSITY; testing whether density peaks coincide with
  known narrative climaxes
NOVELTY_CLAIM: Computing symbol density gradients and correlating density
  peaks with narrative structure in the Black Books is new
POTENTIAL_PRIOR_ART: Lexical density in computational stylistics; passage
  complexity metrics
DISTINCTION: Density here counts imaginal symbols (distinct entity types),
  not word types; the gradient measures symbolic acceleration, not lexical
  richness — a different construct
TEST: Compute SYMBOL_DENSITY for each notebook; identify top-5 density peaks;
  verify correspondence with known extended vision sequences
STATUS: NOVEL_CANDIDATE


NB-N073
ID: NB-N073
SOURCE: Black Books observation
OBSERVATION: Some figures address the author directly and some speak
  only among themselves
NEW_OPERATION: Defining ADDRESSIVITY_TYPE(n) for each figure n ∈ N_FIGURE:
  { AUTHOR_DIRECTED, SELF_DIRECTED, OTHER_FIGURE_DIRECTED, UNADDRESSED };
  computing ADDRESSIVITY_DISTRIBUTION over N_FIGURE
NEW_RELATION: ADDRESSIVITY_CENTRALITY: figures with high AUTHOR_DIRECTED
  fraction are structurally more "present" to the author; testing whether
  ADDRESSIVITY_CENTRALITY correlates with graph degree centrality
NOVELTY_CLAIM: Formalizing addressivity type of imaginal figures and
  testing its correlation with graph centrality is new
POTENTIAL_PRIOR_ART: Discourse addressivity analysis; conversation structure
DISTINCTION: Addressivity in visionary dialogues determines the ontological
  status of the figure relative to the author — a dimension not captured
  by standard dialogue analysis
TEST: Classify addressivity for 20 figures; compute distribution; correlate
  AUTHOR_DIRECTED fraction with degree centrality; hypothesis: r > 0.5
STATUS: NOVEL_CANDIDATE


NB-N074
ID: NB-N074
SOURCE: Model construction, algebraic graph theory
OBSERVATION: The symbol graph G has an automorphism group
NEW_OPERATION: Computing AUT(G) = the automorphism group of the symbol graph
  (permutations of N that preserve the edge structure E); computing |AUT(G)|
  and the orbit structure of N under AUT(G)
NEW_RELATION: SYMBOLIC_SYMMETRY: nodes in the same orbit under AUT(G) are
  structurally equivalent (they have identical graph neighborhoods up to
  relabeling); SYMMETRY_ORBITS partition N into equivalence classes
NOVELTY_CLAIM: Computing the automorphism group and orbit structure of the
  Black Books symbol graph is new as a formal symmetry analysis
POTENTIAL_PRIOR_ART: Graph automorphism; symmetry in network analysis
DISTINCTION: Structural equivalence of imaginal symbols (same orbit) means
  they play identical structural roles in the symbolic network — a stronger
  claim than semantic similarity
TEST: Compute AUT(G) for a 20-node subgraph; identify orbits; hypothesis:
  most nodes are in singleton orbits (low symmetry), with a few exceptions
STATUS: NOVEL_CANDIDATE


NB-N075
ID: NB-N075
SOURCE: Black Books observation
OBSERVATION: Some symbolic events are described as happening "for the first
  time" by the author
NEW_OPERATION: Extracting FIRST_TIME_MARKERS: explicit textual assertions
  of novelty ("for the first time I saw..."); computing FIRST_TIME_DENSITY
  per notebook; testing whether first-time events are uniformly distributed
  or concentrated in early notebooks
NEW_RELATION: NOVELTY_DECAY_FUNCTION: modeling the rate of first-time
  events as a decreasing function of t; fitting an exponential decay model
  P(novel event at t) = λe^{-λt}
NOVELTY_CLAIM: Modeling the rate of symbolic novelty as a formal decay
  process and fitting a parametric model is new
POTENTIAL_PRIOR_ART: Innovation diffusion models; novelty curves in creativity
  research
DISTINCTION: The decay of novel symbolic events in a single author's visionary
  record is an empirical temporal process; fitting a parametric model to it
  is a formal operation not present in existing scholarship
TEST: Count first-time markers per notebook; fit exponential decay model;
  test goodness of fit; report λ estimate and confidence interval
STATUS: NOVEL_CANDIDATE


NB-N076
ID: NB-N076
SOURCE: Model construction, fixpoint theory
OBSERVATION: Some symbolic states recur without transformation (stable symbols)
NEW_OPERATION: Defining FIXPOINT(n, R_i) = TRUE iff R_i(n) = n (the
  transformation rule maps n to itself); computing FIXPOINT_SET(R_i) =
  { n : R_i(n) = n } for each rule
NEW_RELATION: GLOBAL_FIXPOINT: a symbol n is a GLOBAL_FIXPOINT iff
  R_i(n) = n for all R_i ∈ R; testing whether the Black Books contain
  any global fixpoints (symbols invariant under all transformations)
NOVELTY_CLAIM: Identifying global fixpoints of the symbolic transformation
  system in the Black Books is new
POTENTIAL_PRIOR_ART: Fixed point theorems; invariant sets in dynamical systems
DISTINCTION: A global fixpoint in the imaginal system is a symbol that
  nothing transforms — an absolute invariant; testing for its existence
  is a formal claim about the limits of symbolic transformation
TEST: Check FIXPOINT condition for major symbols against all extracted rules;
  hypothesis: no global fixpoints exist (all symbols are transformable)
FAILURE_CASE: At least one global fixpoint found: an absolutely stable symbol
  exists — a strong structural claim
STATUS: NOVEL_CANDIDATE


NB-N077
ID: NB-N077
SOURCE: Black Books observation
OBSERVATION: The text contains explicit counting (the author counts figures,
  objects, events)
NEW_OPERATION: Extracting COUNT_STATEMENTS: all textual assertions of the
  form "there were N of X"; building COUNT_DISTRIBUTION over numerical
  values N; testing whether specific numbers (3, 4, 7, 12) are
  overrepresented relative to a uniform or Benford distribution
NEW_RELATION: COUNT_SIGNIFICANCE(k): the p-value of observing count k
  with frequency f under a null Benford distribution; identifying
  statistically significant overrepresented counts
NOVELTY_CLAIM: Testing the distribution of explicit counts in the Black Books
  against Benford's Law and testing for numerologically significant overrepresentation
  is new as a formal statistical operation
POTENTIAL_PRIOR_ART: Benford's Law applications; numerical symbolism studies
DISTINCTION: Benford's Law describes naturally occurring number distributions;
  deviation from it in the Black Books counts would indicate symbolic selection
  of specific numbers — a formal testable hypothesis
TEST: Extract all count statements; compute frequency distribution; apply
  Benford test; compute p-values for 3, 4, 7, 12
STATUS: NOVEL_CANDIDATE


NB-N078
ID: NB-N078
SOURCE: Model construction
OBSERVATION: The formal system S can be compared to similar systems
  defined for other texts
NEW_OPERATION: Defining INTER_TEXT_MORPHISM Φ: S_A → S_B between the
  symbolic systems of two texts; Φ is a structure-preserving map such that
  if (a, b, l) ∈ E_A then (Φ(a), Φ(b), l) ∈ E_B (graph homomorphism)
NEW_RELATION: MORPHISM_DENSITY(Φ) = |{ edges preserved by Φ }| / |E_A|;
  a high-density morphism indicates the two symbolic systems are structurally
  similar; an ISOMORPHISM is a bijective morphism with density 1
NOVELTY_CLAIM: Defining inter-text morphisms between formal symbolic systems
  and computing morphism density as a structural similarity measure is new
POTENTIAL_PRIOR_ART: Graph homomorphism; comparative literature (informal)
DISTINCTION: Structural similarity between symbolic systems is usually
  argued qualitatively in comparative mythology; the morphism density
  measure makes this precise and falsifiable
TEST: Build S for a comparison text (e.g., Dante's Commedia); compute
  best morphism Φ from S_BlackBooks to S_Dante; compute density
STATUS: NOVEL_CANDIDATE


NB-N079
ID: NB-N079
SOURCE: Black Books observation
OBSERVATION: Some symbols are presented as carrying messages or content
  from one symbolic domain to another
NEW_OPERATION: Defining MESSAGE_CARRIER(n) = TRUE if n is explicitly described
  as conveying content from one symbolic region to another; extracting
  MESSAGE_CONTENT_TYPE for each carrier: { WARNING, REVELATION, COMMAND,
  QUESTION, GIFT, PROHIBITION }; computing carrier frequency by content type
NEW_RELATION: CONTENT_ROUTING_GRAPH: directed graph where message carriers
  are edges connecting source and target symbolic regions
NOVELTY_CLAIM: Formalizing symbolic message-carrying as a typed routing
  function and building the resulting content routing graph is new
POTENTIAL_PRIOR_ART: Message passing in agent systems; semiotics of transmission
DISTINCTION: Message carriers in imaginal sequences are symbols that
  themselves have agency and content; the formal routing graph captures
  the information-transfer structure of the imaginal world
TEST: Identify 10 message-carrying events; classify content types; build
  routing graph; identify hub regions (most messages received or sent)
STATUS: NOVEL_CANDIDATE


NB-N080
ID: NB-N080
SOURCE: Model construction, ergodic theory
OBSERVATION: The symbolic dynamics under R define a discrete dynamical system
NEW_OPERATION: Testing ERGODICITY of the symbolic dynamics: whether the
  time-average of any observable f(n) over a long trajectory equals the
  space-average (1/|N|) Σ_n f(n); computing ERGODIC_DEVIATION(f) =
  |time_average(f) - space_average(f)|
NEW_RELATION: ERGODIC_OBSERVABLES: functions f for which ERGODIC_DEVIATION
  ≈ 0; NON_ERGODIC_OBSERVABLES: functions f for which ERGODIC_DEVIATION
  is significantly nonzero
NOVELTY_CLAIM: Testing ergodicity of the symbolic dynamics of the Black Books
  is new as a formal dynamical systems property of this material
POTENTIAL_PRIOR_ART: Ergodic theory; time-average vs ensemble-average analysis
DISTINCTION: Ergodicity failure means the symbolic trajectory does not
  explore all symbolic states equally; it is confined to a subset —
  a formal claim about the accessibility structure of the imaginal system
TEST: Define f = SYMBOL_ENTROPY contribution; compute time and space averages;
  test ergodic deviation significance
FAILURE_CASE: Trivial ergodicity (only one symbol type): space-average
  trivially equals time-average; test requires multiple symbol types
STATUS: NOVEL_CANDIDATE


NB-N081
ID: NB-N081
SOURCE: Black Books observation
OBSERVATION: Some visions are described as having a clear beginning, middle,
  and end; others lack explicit closure
NEW_OPERATION: Annotating each vision sequence V_i with:
  HAS_BEGINNING(V_i) ∈ {TRUE, FALSE}
  HAS_MIDDLE(V_i) ∈ {TRUE, FALSE}
  HAS_END(V_i) ∈ {TRUE, FALSE}
  Computing the NARRATIVE_COMPLETENESS_SCORE(V_i) = sum of three booleans (0–3)
NEW_RELATION: COMPLETENESS_DISTRIBUTION: the distribution of scores across
  all vision sequences; testing whether completeness correlates with temporal
  position (later visions more complete than earlier)
NOVELTY_CLAIM: Applying a three-part narrative completeness metric to
  individual vision sequences in the Black Books and testing its temporal
  trend is new
POTENTIAL_PRIOR_ART: Narrative structure theory (Aristotle's three parts);
  completeness metrics in story analysis
DISTINCTION: Applying a formal binary three-part completeness metric to
  visionary sequences rather than conventional narratives, and testing its
  temporal distribution, is the novel operation
TEST: Annotate 20 vision sequences; compute distribution; run regression
  of completeness score on temporal position; hypothesis: no significant trend
  (completeness does not increase over time)
STATUS: NOVEL_CANDIDATE


NB-N082
ID: NB-N082
SOURCE: Model construction, graph coloring
OBSERVATION: The symbol graph G = (N, E) can be colored with the node
  type partition as a starting point
NEW_OPERATION: Defining the TYPED_COLORING: assign each n ∈ N the color
  of its primary type in the ontology partition; testing whether the typed
  coloring is a proper coloring (no two adjacent nodes share the same type)
NEW_RELATION: TYPED_COLORING_VIOLATIONS = |{ (a,b,l) ∈ E : type(a) = type(b) }|;
  the fraction of edges connecting nodes of the same type
NOVELTY_CLAIM: Testing whether the symbolic node ontology partition constitutes
  a proper graph coloring of the Black Books symbol graph is new
POTENTIAL_PRIOR_ART: Graph coloring; typed ontology graphs
DISTINCTION: If the typed coloring is proper, it means the ontology partition
  correctly separates the symbolic domain into non-adjacent types — a structural
  confirmation of the ontology design
TEST: Apply typed coloring; count violations; hypothesis: typed coloring
  has > 0 violations (some cross-type edges exist within the same type pair)
STATUS: NOVEL_CANDIDATE


NB-N083
ID: NB-N083
SOURCE: Black Books observation
OBSERVATION: Some symbolic events are described as occurring in the author's
  body (somatic experiences coinciding with visions)
NEW_OPERATION: Extracting SOMATIC_EVENTS: textual assertions of bodily
  sensation accompanying symbolic events; building SOMATIC_CO_OCCURRENCE(n) =
  fraction of n's appearances that coincide with somatic events; identifying
  SOMATIC_LINKED_SYMBOLS
NEW_RELATION: SOMATIC_COUPLING_COEFFICIENT: correlation between somatic
  event frequency and symbolic entropy H(t) in the same temporal window
NOVELTY_CLAIM: Formally extracting somatic co-occurrence data from the
  Black Books and correlating it with the symbolic entropy model is new
POTENTIAL_PRIOR_ART: Embodied cognition studies; psychosomatic research
DISTINCTION: Somatic events in visionary journals are first-person reports
  of bodily accompaniments to imaginal experience; their formal relationship
  to symbolic complexity has not been quantified
TEST: Identify 15 somatic events; compute SOMATIC_CO_OCCURRENCE for top-10
  symbols; compute correlation with H(t); hypothesis: correlation > 0.3
STATUS: NOVEL_CANDIDATE


NB-N084
ID: NB-N084
SOURCE: Model construction
OBSERVATION: The transformation rules R can be composed to generate
  multi-step transformation chains
NEW_OPERATION: Defining the TRANSFORMATION_CHAIN_SET TC(n, k) =
  { (R_{i1}, R_{i2}, ..., R_{ik}) : the chain maps n to some m in k steps };
  computing TC_COUNT(n, k) = |TC(n, k)| as a function of n and k
NEW_RELATION: TRANSFORMATION_COMPLEXITY(n) = Σ_k k · TC_COUNT(n, k) / Z
  (expected chain length weighted by chain count); symbols with high
  TRANSFORMATION_COMPLEXITY have richer multi-step dynamics
NOVELTY_CLAIM: Computing transformation chain counts and complexity scores
  for imaginal symbols is new
POTENTIAL_PRIOR_ART: Path enumeration in graphs; reaction pathway analysis
DISTINCTION: Multi-step transformation complexity is a richer measure than
  simple RECURSION_DEPTH; it counts all paths, not just the deepest
TEST: Compute TC_COUNT for n_Philemon for k = 1, 2, 3; compare to a
  background symbol; hypothesis: major figures have higher TRANSFORMATION_COMPLEXITY
STATUS: NOVEL_CANDIDATE


NB-N085
ID: NB-N085
SOURCE: Black Books observation
OBSERVATION: Some figures are described as aging or changing in apparent age
NEW_OPERATION: Defining AGE_STATE(n, t) ∈ { YOUNG, MIDDLE, OLD, AGELESS, UNKNOWN }
  for each figure n at time t; computing AGE_TRAJECTORY(n) = sequence of
  AGE_STATE over n's active span; computing AGE_REVERSAL_COUNT(n) = number
  of times AGE_STATE decreases (older → younger)
NEW_RELATION: AGE_REVERSAL_CORRELATION: testing whether AGE_REVERSAL events
  coincide with TRANSFORMATION events in the symbol graph
NOVELTY_CLAIM: Formally tracking age state trajectories of imaginal figures
  and testing their correlation with symbolic transformation events is new
POTENTIAL_PRIOR_ART: Character age tracking in narrative analysis
DISTINCTION: Age reversal of imaginal figures is a specific symbolic
  phenomenon (the puer-senex dynamic) that has been studied qualitatively
  but never formalized as a trajectory analysis
TEST: Annotate age states for figures with documented age references;
  compute AGE_REVERSAL_COUNT; test coincidence with TRANSFORMS edges
STATUS: NOVEL_CANDIDATE


NB-N086
ID: NB-N086
SOURCE: Model construction, information compression
OBSERVATION: The symbol graph G has a minimum description length
NEW_OPERATION: Computing the MDL_DESCRIPTION_LENGTH of G: the minimum
  number of bits required to encode G using a two-part code (model + data);
  comparing MDL under different graph models (random, scale-free, stochastic
  block model)
NEW_RELATION: MDL_BEST_MODEL: the graph model class that achieves minimum
  MDL for G; this is the most compact description of the symbol network structure
NOVELTY_CLAIM: Applying minimum description length model selection to the
  Black Books symbol graph to identify its most compact structural description is new
POTENTIAL_PRIOR_ART: MDL in machine learning; graph compression
DISTINCTION: MDL model selection for the imaginal symbol graph determines
  which structural theory (random, scale-free, community-structured) provides
  the most efficient description of the symbolic system
TEST: Compute MDL for three graph models; identify best model; hypothesis:
  stochastic block model achieves lower MDL than random graph model
STATUS: NOVEL_CANDIDATE


NB-N087
ID: NB-N087
SOURCE: Black Books observation
OBSERVATION: The Black Books record dates of composition for some entries
NEW_OPERATION: Aligning the temporal coordinate T with the Julian calendar
  for all dateable entries; computing CALENDAR_ALIGNED_T(n) for each symbol
  n with dateable first appearance; building SEASONAL_ACTIVITY(n) =
  distribution of n's appearances over calendar seasons (spring/summer/fall/winter)
NEW_RELATION: SEASONAL_BIAS(n) = KL-divergence between n's seasonal
  distribution and a uniform seasonal distribution; symbols with high
  SEASONAL_BIAS are seasonally concentrated
NOVELTY_CLAIM: Aligning symbolic activity with calendar seasonality and
  testing for seasonal bias is new
POTENTIAL_PRIOR_ART: Seasonal patterns in diary studies; chronobiological
  analysis of subjective reports
DISTINCTION: Seasonal bias of imaginal symbols is a specific hypothesis
  about whether symbolic activity follows natural rhythms; it is testable
  and falsifiable given the dated entries
TEST: Compute SEASONAL_ACTIVITY for 10 major symbols; identify top-3 by
  SEASONAL_BIAS; hypothesis: at least 2 symbols show significant seasonal bias
STATUS: NOVEL_CANDIDATE


NB-N088
ID: NB-N088
SOURCE: Model construction, type theory
OBSERVATION: The symbols in N can be given dependent types based on their
  relations to other symbols
NEW_OPERATION: Defining DEPENDENT_TYPE(n) = { type annotation that depends
  on the relational context of n }; specifically, n : TRANSFORMED_BY(m)
  if there exists a TRANSFORMS edge from m to n; n : CO_OCCURS_WITH(m)
  if RESONANCE(n,m) > threshold
NEW_RELATION: TYPE_INHABITATION: the set of symbols that inhabit a given
  dependent type; TYPE_POPULATION(τ) = |{ n : n : τ }| for each type τ
NOVELTY_CLAIM: Applying dependent type theory to classify imaginal symbols
  by their relational context is new
POTENTIAL_PRIOR_ART: Dependent types in programming language theory (Coq,
  Agda, Lean); contextual ontologies
DISTINCTION: Dependent types for imaginal entities define context-sensitive
  classifications: the "type" of a symbol changes depending on what
  it is related to — a dynamic typing scheme for symbolic entities
TEST: Define 5 dependent types; compute TYPE_POPULATION for each; verify
  that dependent types provide finer classification than the static ontology
STATUS: NOVEL_CANDIDATE


NB-N089
ID: NB-N089
SOURCE: Black Books observation
OBSERVATION: Certain symbolic events are described as surprising or unexpected
  by the author
NEW_OPERATION: Extracting SURPRISE_MARKERS: textual assertions of unexpectedness
  ("I did not expect...", "suddenly..."); computing SURPRISE_DENSITY per
  notebook; computing SURPRISE_INFORMATION(event) = -log P(event) under
  the Markov model (the information-theoretic surprise of the event)
NEW_RELATION: SURPRISE_CALIBRATION: correlation between SURPRISE_MARKERS
  (subjective surprise) and SURPRISE_INFORMATION (model-predicted surprise);
  measuring whether the author's stated surprise aligns with model predictions
NOVELTY_CLAIM: Computing the calibration between subjective and information-
  theoretic surprise in the Black Books is new
POTENTIAL_PRIOR_ART: Calibration studies in probability judgment; surprise theory
DISTINCTION: Comparing the author's first-person surprise markers to a
  formal model's predicted surprise provides a novel test of whether
  the imaginal model captures the subjective phenomenology
TEST: Extract 10 surprise markers; compute SURPRISE_INFORMATION for each event;
  compute calibration correlation; hypothesis: positive but < 1 correlation
STATUS: NOVEL_CANDIDATE


NB-N090
ID: NB-N090
SOURCE: Model construction, network resilience
OBSERVATION: The symbol graph G has a connectivity structure that can be
  tested for resilience
NEW_OPERATION: Performing ROBUSTNESS_ANALYSIS on G: iteratively removing
  nodes in order of decreasing centrality (targeted attack) or randomly
  (random failure); measuring how the GIANT_COMPONENT_SIZE changes with
  each removal; computing ROBUSTNESS_COEFFICIENT R = (1/|N|) Σ_f(Q)
NEW_RELATION: TARGETED_VS_RANDOM_RATIO: ratio of nodes removed before
  giant component collapses under targeted attack vs random removal;
  high ratio indicates high robustness to random failure but vulnerability
  to targeted attack (characteristic of scale-free networks)
NOVELTY_CLAIM: Performing robustness analysis on the Black Books symbol
  graph to test resilience to targeted and random removal is new
POTENTIAL_PRIOR_ART: Network robustness analysis; percolation theory
DISTINCTION: Robustness of an imaginal symbol network measures how many
  symbols can be "removed" before the network loses global connectivity —
  a formal test of the structural resilience of the symbolic system
TEST: Perform both removal strategies on G; plot giant component size vs
  fraction removed; compute R for both; hypothesis: targeted attack is
  significantly more destructive than random removal
STATUS: NOVEL_CANDIDATE


NB-N091
ID: NB-N091
SOURCE: Black Books observation
OBSERVATION: The author records physical activities (walking, sitting,
  writing) in proximity to symbolic events
NEW_OPERATION: Extracting PHYSICAL_ACTIVITY_LOG: all textual references to
  physical actions by the author; computing ACTIVITY_SYMBOL_PROXIMITY(a, n) =
  frequency of physical activity a coinciding with symbol n's appearance
NEW_RELATION: ACTIVITY_PREFERENCE(n) = the physical activity with highest
  ACTIVITY_SYMBOL_PROXIMITY for symbol n; testing whether different symbols
  have different activity preferences
NOVELTY_CLAIM: Computing the co-occurrence of physical activities with
  symbolic events in the Black Books as a formal proximity metric is new
POTENTIAL_PRIOR_ART: Embodied cognition research; diary studies of physical
  context and mental states
DISTINCTION: Physical activity as a context variable for imaginal symbol
  occurrence is a novel formal operationalization of the body-psyche
  relationship in this specific material
TEST: Extract 20 activity references; compute ACTIVITY_SYMBOL_PROXIMITY
  matrix; identify top activity-symbol pairs
STATUS: NOVEL_CANDIDATE


NB-N092
ID: NB-N092
SOURCE: Model construction, graph product theory
OBSERVATION: The symbol graph G and the temporal graph T_G can be combined
NEW_OPERATION: Computing the TENSOR_PRODUCT G ⊗ T_G = the graph where
  nodes are pairs (n, t) and edges connect (n, t) to (m, t') if
  (n,m) ∈ E and (t,t') ∈ E_T (consecutive time points); this creates a
  space-time symbol graph
NEW_RELATION: SPACE_TIME_PATH(n, t₁, m, t₂): a path in G ⊗ T_G from
  (n, t₁) to (m, t₂); the existence of such a path certifies that m can
  be reached from n via the symbol graph within the time interval [t₁, t₂]
NOVELTY_CLAIM: Constructing the tensor product of the symbol graph with the
  temporal graph to build a space-time symbol graph is new
POTENTIAL_PRIOR_ART: Space-time graphs in physics; temporal network analysis
DISTINCTION: The tensor product construction captures both symbolic and
  temporal reachability simultaneously; a path in G ⊗ T_G is a causal
  symbolic sequence, not merely co-occurrence
TEST: Build G ⊗ T_G for a subset; find shortest space-time paths between
  major symbol pairs; compare to purely spatial shortest paths
STATUS: NOVEL_CANDIDATE


NB-N093
ID: NB-N093
SOURCE: Black Books observation
OBSERVATION: Some symbolic sequences end in explicit resolution statements
NEW_OPERATION: Extracting RESOLUTION_EVENTS: textual statements that explicitly
  close a symbolic sequence ("and thus it was resolved"); classifying by
  RESOLUTION_TYPE = { INTEGRATION, DISSOLUTION, TRANSFORMATION, TRANSCENDENCE,
  ABANDONMENT }; computing RESOLUTION_TYPE_DISTRIBUTION
NEW_RELATION: RESOLUTION_PREDICTORS: testing which symbol graph properties
  (centrality, entropy, recursion depth) predict resolution type via
  multinomial logistic regression
NOVELTY_CLAIM: Classifying symbolic resolution events into a formal taxonomy
  and testing graph-structural predictors of resolution type is new
POTENTIAL_PRIOR_ART: Resolution analysis in narrative theory; outcome
  prediction in process research
DISTINCTION: Resolution in imaginal sequences is a substantive symbolic
  event with multiple possible types; predicting resolution type from
  formal graph properties is a novel cross-domain predictive model
TEST: Extract 15 resolution events; classify types; build predictive model
  from graph features; test accuracy via leave-one-out cross-validation
STATUS: NOVEL_CANDIDATE


NB-N094
ID: NB-N094
SOURCE: Model construction, formal grammar
OBSERVATION: Symbolic sequences have syntactic structure analogous to
  formal grammars
NEW_OPERATION: Inducing a CONTEXT_FREE_GRAMMAR G_CF from the observed
  symbol sequences: using the inside-outside algorithm or PCFG induction
  to learn production rules over the symbol alphabet N; computing
  GRAMMAR_COVERAGE = fraction of observed sequences generated by G_CF
NEW_RELATION: GRAMMAR_COMPLEXITY = number of production rules in the
  minimal grammar; testing whether G_CF is more compact than a flat
  (unstructured) grammar over the same sequences
NOVELTY_CLAIM: Inducing a context-free grammar from imaginal symbol sequences
  in the Black Books is new as a formal grammatical analysis
POTENTIAL_PRIOR_ART: Grammar induction; computational linguistics
DISTINCTION: The "sentences" here are sequences of imaginal symbols;
  a grammar over imaginal sequences captures their hierarchical compositional
  structure — a level of analysis not present in hermeneutic treatments
TEST: Apply PCFG induction to 20 symbol sequences; compute coverage;
  compare grammar complexity to sequence complexity; hypothesis: compact
  grammar exists with coverage > 0.7
STATUS: NOVEL_CANDIDATE


NB-N095
ID: NB-N095
SOURCE: Black Books observation
OBSERVATION: Colors and their transitions in the text follow observable patterns
NEW_OPERATION: Building the COLOR_TRANSITION_MATRIX: C_T[c1, c2] = number
  of times color c1 is textually followed by color c2 within a window of
  w textual units; computing the STATIONARY_DISTRIBUTION of C_T (treating
  it as a Markov chain)
NEW_RELATION: CHROMATIC_STATIONARY_DISTRIBUTION: the long-run fraction of
  time each color is "active" under the Markov chain; comparing to the
  empirical color frequency distribution
NOVELTY_CLAIM: Computing the Markov stationary distribution of color
  transitions in the Black Books and comparing to empirical frequencies is new
POTENTIAL_PRIOR_ART: Markov chains for color sequences; chromatic analysis
DISTINCTION: The comparison between stationary and empirical distributions
  tests whether the color transition structure is consistent with the
  observed color frequencies — a formal internal consistency test
TEST: Build C_T from 30 color transitions; compute stationary distribution;
  compare to empirical frequencies; test via chi-squared
STATUS: NOVEL_CANDIDATE


NB-N096
ID: NB-N096
SOURCE: Model construction, linear algebra
OBSERVATION: The transformation rules R can be represented as matrices
  over N if N is given a basis
NEW_OPERATION: Representing each R_i as a matrix M_i ∈ {0,1}^{|N|×|N|}
  where M_i[a,b] = 1 iff R_i(a) = b; computing the JOINT_TRANSFORMATION_MATRIX
  M = Σ_i P(R_i) · M_i (probabilistic combination under rule frequencies)
NEW_RELATION: DOMINANT_EIGENVALUE of M; the dominant eigenvector identifies
  the INVARIANT_DISTRIBUTION over N under the mixed transformation dynamics
NOVELTY_CLAIM: Computing the dominant eigenvector of the probabilistic
  transformation matrix for the Black Books symbol system is new
POTENTIAL_PRIOR_ART: Markov chain matrix analysis; probabilistic transition
  matrices
DISTINCTION: The matrix M is derived from empirically observed rule
  applications in a visionary text; its dominant eigenvector identifies
  the symbolic "attractor distribution" of the imaginal dynamics
TEST: Construct M from 10 rules; compute dominant eigenvector; verify that
  top-weighted symbols correspond to major symbolic figures in the text
STATUS: NOVEL_CANDIDATE


NB-N097
ID: NB-N097
SOURCE: Black Books observation
OBSERVATION: Some entries in the Black Books are unusually short (fragments,
  one-line notes)
NEW_OPERATION: Segmenting the text into ENTRY_LENGTH_CLASSES: SHORT (< 5 lines),
  MEDIUM (5–20 lines), LONG (> 20 lines); computing SYMBOL_RICHNESS per class
  = mean distinct symbol count per entry; testing whether SYMBOL_RICHNESS
  differs across length classes
NEW_RELATION: DENSITY_PER_LENGTH: SYMBOL_RICHNESS / ENTRY_LENGTH; testing
  whether longer entries are symbolically denser or sparser than short entries
NOVELTY_CLAIM: Testing the relationship between entry length and symbol
  density in the Black Books as a formal statistical hypothesis is new
POTENTIAL_PRIOR_ART: Lexical richness vs text length; Herdan's law
DISTINCTION: Symbol richness here counts distinct imaginal entities, not
  word types; the density-per-length relationship tests a specific hypothesis
  about the compression of symbolic content in different entry formats
TEST: Classify 30 entries by length; compute SYMBOL_RICHNESS per class;
  run one-way ANOVA; hypothesis: long entries have lower DENSITY_PER_LENGTH
STATUS: NOVEL_CANDIDATE


NB-N098
ID: NB-N098
SOURCE: Model construction, sheaf theory
OBSERVATION: The symbol graph G and its restriction to subsets define a
  presheaf structure
NEW_OPERATION: Defining the PRESHEAF F over the poset of open subsets of G
  (under the subset inclusion ordering): F(U) = the restriction of G to
  nodes U and edges within U; defining restriction maps ρ_{UV}: F(V) → F(U)
  for U ⊆ V as the graph restriction map
NEW_RELATION: Testing whether F is a SHEAF: whether local data on overlapping
  subsets glues consistently to global data (gluing condition)
NOVELTY_CLAIM: Defining a sheaf structure over the Black Books symbol graph
  and testing the sheaf condition is new
POTENTIAL_PRIOR_ART: Sheaf theory in algebraic geometry; cellular sheaves
  in applied topology
DISTINCTION: If the symbol graph satisfies the sheaf condition, local
  symbolic sub-systems are globally consistent; violation of the sheaf
  condition would indicate irreducible global symbolic structure not
  recoverable from local information
TEST: Verify restriction maps for 3 pairs of overlapping subsets; test
  gluing condition; hypothesis: sheaf condition holds (global symbol
  structure is locally determined)
STATUS: NOVEL_CANDIDATE


NB-N099
ID: NB-N099
SOURCE: Black Books observation
OBSERVATION: The author uses specific verb types (perception verbs, cognition
  verbs, action verbs) when describing symbolic events
NEW_OPERATION: Extracting VERB_CLASS for each symbolic event description:
  { PERCEPTION (saw, heard, felt), COGNITION (understood, realized, knew),
  ACTION (said, did, moved), AFFECTIVE (felt, feared, longed) };
  computing VERB_CLASS_DISTRIBUTION per symbol type
NEW_RELATION: SYMBOL_VERB_AFFINITY(n, v) = P(verb class v | symbol n is active);
  identifying which symbols are primarily perceived vs understood vs acted upon
NOVELTY_CLAIM: Computing verb-class affinities for imaginal symbols in the
  Black Books and testing for systematic verb-symbol associations is new
POTENTIAL_PRIOR_ART: Verb argument structure analysis; selectional preferences
  in NLP
DISTINCTION: Verb-class affinity for imaginal entities measures how each
  symbol is cognitively processed (seen vs understood vs acted upon) —
  a phenomenological formal property of the symbolic descriptions
TEST: Extract verb class for 50 symbol-event pairs; compute affinities;
  hypothesis: FIGURE symbols have higher ACTION verb affinity than PLACE symbols
STATUS: NOVEL_CANDIDATE


NB-N100
ID: NB-N100
SOURCE: Model construction, coalgebra theory
OBSERVATION: The symbol system S has both static (algebraic) and dynamic
  (coalgebraic) aspects
NEW_OPERATION: Defining the COALGEBRA STRUCTURE of S: a coalgebra
  (N, δ) where δ: N → P(N) (the powerset functor) maps each symbol to
  its set of possible successor states under R; the coalgebra models the
  non-deterministic transitions of the symbol system
NEW_RELATION: BISIMULATION: two symbols n, m ∈ N are BISIMILAR if there
  exists a bisimulation relation B such that nBm; bisimilar symbols have
  identical behavioral futures and cannot be distinguished by any observable
NOVELTY_CLAIM: Applying coalgebraic bisimulation to the Black Books symbol
  system to identify behaviorally indistinguishable symbolic entities is new
POTENTIAL_PRIOR_ART: Coalgebra and bisimulation in process algebra (CCS,
  CSP); behavioral equivalence in formal methods
DISTINCTION: Bisimulation between imaginal symbols identifies symbols whose
  entire future symbolic behavior is identical — a stronger equivalence
  than graph automorphism (which is purely structural)
TEST: Define the coalgebra (N, δ) from extracted transformation rules;
  compute bisimulation equivalence classes; hypothesis: bisimulation classes
  are smaller than automorphism orbits
STATUS: NOVEL_CANDIDATE
