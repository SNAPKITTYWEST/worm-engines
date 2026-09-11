NB-N101
ID: NB-N101
SOURCE: Black Books observation
OBSERVATION: The text contains descriptions of light and darkness as
  symbolic attributes of figures and scenes
NEW_OPERATION: Defining LUMINOSITY_STATE(n, t) ∈ { LUMINOUS, DARK, SHADOWED,
  IRIDESCENT, OPAQUE, UNDEFINED } for each symbol n at each appearance t;
  computing LUMINOSITY_TRAJECTORY(n) = sequence of states over active span;
  computing LUMINOSITY_TRANSITION_MATRIX across all symbols
NEW_RELATION: LUMINOSITY_CORRELATION(n, m): Pearson correlation between the
  luminosity timeseries of n and m; identifying luminosity-coupled symbol pairs
NOVELTY_CLAIM: Building a formal luminosity state model and transition matrix
  for the Black Books symbolic system is new
POTENTIAL_PRIOR_ART: Chiaroscuro analysis in art history; light symbolism
  in literary studies
DISTINCTION: Luminosity here is a formal state assigned to imaginal entities
  at specific temporal positions, not a general thematic analysis; the
  transition matrix provides a dynamic model of symbolic light-change
TEST: Annotate luminosity for 20 symbols across appearances; compute
  transition matrix; identify dominant luminosity transitions
STATUS: NOVEL_CANDIDATE


NB-N102
ID: NB-N102
SOURCE: Model construction, random walk theory
OBSERVATION: A random walk on the symbol graph defines a stochastic exploration
  of the imaginal system
NEW_OPERATION: Defining RANDOM_WALK(G, n_0, k): starting at node n_0,
  taking k steps by following edges chosen uniformly at random; computing
  COVER_TIME(G) = expected number of steps to visit all nodes; computing
  HITTING_TIME(n_0, n_target) = expected steps to reach n_target from n_0
NEW_RELATION: SYMBOLIC_ACCESSIBILITY(n) = 1 / HITTING_TIME(any_start, n)
  averaged over all starting nodes; high accessibility means the symbol is
  reachable quickly from anywhere in the graph
NOVELTY_CLAIM: Computing random walk cover times and hitting times on the
  Black Books symbol graph is new
POTENTIAL_PRIOR_ART: Random walk analysis; cover time bounds in graph theory
DISTINCTION: Hitting time as symbolic accessibility measures how "central"
  a symbol is not in terms of direct connections but in terms of reachability
  under random traversal — a distinct centrality concept
TEST: Compute HITTING_TIME for 5 pairs of symbols; compute SYMBOLIC_ACCESSIBILITY
  for top-5 symbols; compare to betweenness centrality ranking
STATUS: NOVEL_CANDIDATE


NB-N103
ID: NB-N103
SOURCE: Black Books observation
OBSERVATION: Some symbolic figures change their scale (described as very
  large or very small at different appearances)
NEW_OPERATION: Defining SCALE_STATE(n, t) ∈ { COSMIC, LARGE, HUMAN_SCALE,
  SMALL, MICROSCOPIC, UNDEFINED } at each appearance; computing
  SCALE_RANGE(n) = max(SCALE_STATE) - min(SCALE_STATE) over all appearances;
  identifying SCALE_VARIABLE_SYMBOLS with SCALE_RANGE > 1
NEW_RELATION: SCALE_TRANSFORMATION_CO_OCCURRENCE: testing whether scale
  changes coincide with TRANSFORMS edges in E; testing whether scale
  contraction precedes or follows symbolic transformation
NOVELTY_CLAIM: Formally tracking scale states of imaginal figures and testing
  their correlation with transformation events is new
POTENTIAL_PRIOR_ART: Scale in phenomenology; size symbolism in myth studies
DISTINCTION: Scale variability of imaginal figures is a formal property with
  potential predictive relationship to transformation; this formal tracking
  is distinct from qualitative symbolic interpretation of size
TEST: Annotate scale for figures with documented scale change; compute
  SCALE_RANGE; test temporal relationship to TRANSFORMS edges
STATUS: NOVEL_CANDIDATE


NB-N104
ID: NB-N104
SOURCE: Model construction, graph decomposition
OBSERVATION: The symbol graph G may have a tree decomposition with bounded
  treewidth
NEW_OPERATION: Computing the TREEWIDTH tw(G) of the symbol graph; constructing
  a tree decomposition of minimum width; the treewidth bounds the complexity
  of many graph algorithms on G
NEW_RELATION: TREEWIDTH_IMPLICATIONS: if tw(G) is small (≤ 3), many NP-hard
  graph problems become polynomial on G; listing which formal operations
  on the symbol system become tractable given bounded treewidth
NOVELTY_CLAIM: Computing the treewidth of the Black Books symbol graph and
  analyzing its algorithmic implications for formal symbolic computation is new
POTENTIAL_PRIOR_ART: Treewidth in parameterized complexity; tree decompositions
DISTINCTION: Treewidth of the imaginal symbol graph has direct implications
  for what formal analyses are computationally feasible on large symbol sets;
  this is a practical complexity-theoretic contribution
TEST: Compute treewidth of a 30-node subgraph; report whether tw ≤ 3;
  list algorithms that become tractable at this treewidth
STATUS: NOVEL_CANDIDATE


NB-N105
ID: NB-N105
SOURCE: Black Books observation
OBSERVATION: Some visions are described as having a quality of overwhelming
  intensity or numinosity
NEW_OPERATION: Extracting NUMINOSITY_MARKERS: textual intensity indicators
  (superlatives, exclamations, explicit intensity assertions); computing
  NUMINOSITY_SCORE(V_i) for each vision sequence using a weighted count
  of numinosity markers; computing NUMINOSITY_DISTRIBUTION over all visions
NEW_RELATION: NUMINOSITY_SYMBOL_CORRELATION(n): correlation between
  NUMINOSITY_SCORE of the containing vision and the presence of symbol n;
  identifying symbols that are structurally associated with intense visions
NOVELTY_CLAIM: Constructing a formal numinosity score for vision sequences
  and correlating it with symbol presence is new
POTENTIAL_PRIOR_ART: Sentiment analysis; intensity scoring in text analysis
DISTINCTION: Numinosity is a specific phenomenological category (Rudolf Otto's
  tremendum et fascinans) applied to visionary experience; its formal
  quantification and correlation with symbol presence is novel
TEST: Score 20 visions; compute NUMINOSITY_SYMBOL_CORRELATION for major
  symbols; hypothesis: specific figure-type symbols have higher numinosity
  correlation than object-type symbols
STATUS: NOVEL_CANDIDATE


NB-N106
ID: NB-N106
SOURCE: Model construction, tropical geometry
OBSERVATION: The symbol graph with edge weights can be analyzed under
  tropical arithmetic
NEW_OPERATION: Defining TROPICAL_ADJACENCY_MATRIX A_trop over the
  (min, +) semiring: A_trop[i,j] = -log RESONANCE(i,j) (or ∞ if no edge);
  computing tropical matrix powers A_trop^k which give shortest-path
  distances in k steps under the tropical metric
NEW_RELATION: TROPICAL_DISTANCE(n, m) = minimum cost path between n and m
  under the tropical metric; identifying TROPICAL_GEODESICS (minimum cost paths)
NOVELTY_CLAIM: Applying tropical geometry to compute optimal symbolic
  transition paths in the Black Books resonance graph is new
POTENTIAL_PRIOR_ART: Tropical mathematics; min-plus algebra in network theory
DISTINCTION: The tropical metric over resonance values defines a specific
  notion of symbolic distance: the minimum total temporal co-absence along
  a path; this is a different metric than graph distance
TEST: Compute tropical distance matrix for 10 symbols; compare to standard
  shortest-path distances; identify pairs where tropical and graph distances diverge
STATUS: NOVEL_CANDIDATE


NB-N107
ID: NB-N107
SOURCE: Black Books observation
OBSERVATION: Some symbolic figures have explicit roles described in the text
  (guide, adversary, messenger, teacher, trickster)
NEW_OPERATION: Classifying each n ∈ N_FIGURE with a ROLE_VECTOR over
  ROLE_TYPES = { GUIDE, ADVERSARY, MESSENGER, TEACHER, TRICKSTER, WITNESS,
  INITIATOR, HELPER, THRESHOLD_GUARDIAN }; computing ROLE_DISTRIBUTION
  over all figures
NEW_RELATION: ROLE_TRANSITION(n): sequence of role assignments of n over
  time; computing ROLE_STABILITY(n) = fraction of appearances where role
  is unchanged; identifying ROLE_CHANGERS vs ROLE_STABLE figures
NOVELTY_CLAIM: Formally classifying imaginal figures by a typed role vocabulary
  and computing role stability as a temporal metric is new
POTENTIAL_PRIOR_ART: Actant theory (Greimas); character role analysis in
  narrative theory
DISTINCTION: Role classification here is applied to imaginal (non-fictional)
  figures in visionary dialogues; role transitions are temporal events
  in the formal model T, not merely narrative observations
TEST: Classify roles for 15 figures; compute ROLE_STABILITY; identify figures
  with highest and lowest stability; hypothesis: named figures have higher
  stability than unnamed figures
STATUS: NOVEL_CANDIDATE


NB-N108
ID: NB-N108
SOURCE: Model construction, persistent homology
OBSERVATION: The symbol graph changes over time as symbols enter and leave
NEW_OPERATION: Computing PERSISTENT_HOMOLOGY of the filtration G(t_1) ⊆
  G(t_2) ⊆ ... ⊆ G(t_k) where G(t) is the active symbol graph at time t;
  tracking when topological features (connected components, cycles) are
  born and die across the filtration
NEW_RELATION: PERSISTENCE_DIAGRAM: plotting (birth_time, death_time) pairs
  for all topological features; PERSISTENCE(feature) = death_time - birth_time;
  long-lived features are structurally robust symbolic cycles or components
NOVELTY_CLAIM: Computing the persistent homology of the temporal filtration
  of the Black Books symbol graph is new
POTENTIAL_PRIOR_ART: Persistent homology in TDA; filtration homology
DISTINCTION: The filtration is driven by the temporal entry and exit of
  imaginal symbols, not by a geometric scale parameter; the persistence
  diagram tracks which symbolic cycles survive across time
TEST: Build filtration from temporal data; compute persistence diagram;
  identify features with persistence > 2 notebooks; hypothesis: at least
  one long-lived H_1 feature (symbolic cycle) exists
STATUS: NOVEL_CANDIDATE


NB-N109
ID: NB-N109
SOURCE: Black Books observation
OBSERVATION: Some symbols are associated with specific body parts or
  anatomical regions in the descriptions
NEW_OPERATION: Extracting ANATOMICAL_ASSOCIATIONS: (n, body_region) pairs
  where symbol n is explicitly linked to a body region; building
  ANATOMICAL_MAP(n) = distribution over body regions for symbol n;
  computing ANATOMICAL_SPECIFICITY(n) = entropy of ANATOMICAL_MAP(n)
NEW_RELATION: Low ANATOMICAL_SPECIFICITY = symbol consistently associated
  with one body region; high specificity = distributed across regions;
  testing whether anatomical specificity correlates with symbol type
NOVELTY_CLAIM: Formally mapping imaginal symbols to anatomical locations
  and computing specificity as an entropy measure is new
POTENTIAL_PRIOR_ART: Embodied symbolism; somatic markers in Jungian theory
DISTINCTION: The anatomical map is derived from explicit textual associations,
  not from theoretical projections; its entropy-based specificity measure
  is a formal data-driven property of the source material
TEST: Extract anatomical associations for 15 symbols; compute ANATOMICAL_MAP;
  compute ANATOMICAL_SPECIFICITY; test correlation with symbol type
STATUS: NOVEL_CANDIDATE


NB-N110
ID: NB-N110
SOURCE: Model construction, game theory
OBSERVATION: The dialogues between the author and imaginal figures can be
  modeled as a two-player interaction
NEW_OPERATION: Modeling each dialogue session D_i as a NORMAL_FORM_GAME:
  PLAYERS = { AUTHOR, FIGURE }; STRATEGIES for each player = possible
  speech acts from SPEECH_ACT_TYPE; PAYOFF defined by whether the dialogue
  reaches RESOLUTION (payoff 1) or INTERRUPTION (payoff 0)
NEW_RELATION: NASH_EQUILIBRIUM of the dialogue game: strategy profiles
  from which neither player benefits by deviating; testing whether observed
  dialogue patterns correspond to Nash equilibria
NOVELTY_CLAIM: Modeling Black Books dialogues as normal-form games and
  computing Nash equilibria is new
POTENTIAL_PRIOR_ART: Game-theoretic models of conversation; dialogue games
  in argumentation theory
DISTINCTION: The players here are an empirical author and an imaginal figure;
  the payoff structure is derived from observed outcomes; testing Nash
  equilibria against observed dialogue strategies is a novel formal test
TEST: Model 5 dialogues as games; compute Nash equilibria; compare to
  observed strategies; hypothesis: observed strategies are within epsilon of
  a Nash equilibrium for at least 2 dialogues
STATUS: NOVEL_CANDIDATE


NB-N111
ID: NB-N111
SOURCE: Black Books observation
OBSERVATION: The text alternates between passages of high and low symbolic
  density creating a rhythm
NEW_OPERATION: Computing the SYMBOLIC_RHYTHM: the autocorrelation of the
  SYMBOL_DENSITY signal at lag distances 1, 2, 3, ... pages; identifying
  the DOMINANT_RHYTHM_PERIOD = the lag at which autocorrelation peaks
NEW_RELATION: RHYTHM_STABILITY across notebooks: testing whether the dominant
  rhythm period is constant or changes across the 7 notebooks; computing
  RHYTHM_PERIOD_VARIANCE
NOVELTY_CLAIM: Quantifying the symbolic rhythm of the Black Books as a
  formal autocorrelation structure and testing its stability across notebooks is new
POTENTIAL_PRIOR_ART: Rhythm analysis in poetry and prose; narrative pacing
DISTINCTION: The "rhythm" here is defined over symbolic density (count of
  active imaginal entities), not over linguistic prosody; the autocorrelation
  approach makes the period quantitative and testable
TEST: Compute SYMBOL_DENSITY per page; compute autocorrelation function;
  identify peak lag; compute across notebooks; test variance
STATUS: NOVEL_CANDIDATE


NB-N112
ID: NB-N112
SOURCE: Model construction, formal verification
OBSERVATION: The formal model S makes testable predictions about the
  Black Books that can be verified against the source
NEW_OPERATION: Defining the VERIFICATION_SUITE: a set of formal propositions
  P_1, P_2, ..., P_k derived from the model S, each with an explicit
  verification procedure against the primary source; computing
  VERIFICATION_RATE = |{ P_i verified }| / k
NEW_RELATION: FALSIFICATION_SET: { P_i : P_i is tested and fails };
  FALSIFICATION_RATE = |FALSIFICATION_SET| / k; a model with zero falsifications
  is unfalsifiable (not scientific); target: FALSIFICATION_RATE ∈ (0.05, 0.30)
NOVELTY_CLAIM: Constructing a formal verification suite for a symbolic
  model of the Black Books with explicit falsification criteria is new as a
  methodological contribution to the humanities
POTENTIAL_PRIOR_ART: Formal verification in software; hypothesis testing
DISTINCTION: Applying formal verification methodology to a model of an
  imaginal text — with explicit falsification criteria — is a novel
  methodological contribution that bridges formal methods and hermeneutics
TEST: Derive 20 formal propositions from S; verify each against source;
  compute VERIFICATION_RATE and FALSIFICATION_RATE; report findings
STATUS: NOVEL_CANDIDATE


NB-N113
ID: NB-N113
SOURCE: Black Books observation
OBSERVATION: Certain figures speak in verse or rhythmic patterns at specific
  moments
NEW_OPERATION: Detecting VERSE_PASSAGES: textual segments with regular
  meter, rhyme, or explicit poetic form; tagging the symbol n that is
  speaking or being described; computing VERSE_ASSOCIATION(n) = frequency
  of verse passages associated with n relative to n's total appearances
NEW_RELATION: VERSE_ATTRACTOR: a symbol with high VERSE_ASSOCIATION;
  testing whether verse passages cluster around symbolic transformation events
NOVELTY_CLAIM: Computing the verse-association score of imaginal symbols
  and testing whether verse marks symbolic transitions is new
POTENTIAL_PRIOR_ART: Verse-prose transitions in literary analysis;
  prosimetrum studies
DISTINCTION: The formal metric VERSE_ASSOCIATION quantifies how often each
  symbol appears in the context of verse — a testable structural claim
  about the relationship between poetic form and symbolic content
TEST: Identify 10 verse passages; compute VERSE_ASSOCIATION for present symbols;
  test whether verse coincides with TRANSFORMS edges
STATUS: NOVEL_CANDIDATE


NB-N114
ID: NB-N114
SOURCE: Model construction, quantum formalism
OBSERVATION: The symbol system can be given a quantum-inspired representation
NEW_OPERATION: Representing each symbol n as a quantum state |n⟩ in a
  Hilbert space H of dimension |N|; defining the SYMBOLIC_DENSITY_MATRIX
  ρ(t) = Σ_n p(n,t) |n⟩⟨n| (a diagonal density matrix from the classical
  probabilities); computing VON_NEUMANN_ENTROPY S(ρ) = -Tr(ρ log ρ)
NEW_RELATION: S(ρ) = H(t) for diagonal ρ; verifying that quantum formalism
  reduces to classical Shannon entropy for diagonal density matrices;
  testing whether off-diagonal terms arise if superposition states are included
NOVELTY_CLAIM: Representing the Black Books symbolic system as a quantum
  density matrix and computing von Neumann entropy is new; testing whether
  non-diagonal terms are meaningful for imaginal states is the novel hypothesis
POTENTIAL_PRIOR_ART: Quantum cognition models; quantum-like models in psychology
DISTINCTION: The quantum representation here is formal, not physical; it
  provides a potential extension to non-classical probability (superposition
  of symbolic states) — a hypothesis about the structure of imaginal experience
TEST: Compute ρ(t) as diagonal matrix; verify S(ρ) = H(t); propose a
  specific off-diagonal term and test whether it improves predictive power
STATUS: NOVEL_CANDIDATE


NB-N115
ID: NB-N115
SOURCE: Black Books observation
OBSERVATION: Some symbolic sequences are explicitly described as
  repetitions of earlier sequences with variations
NEW_OPERATION: Identifying VARIATION_PAIRS (V_i, V_j): sequences where V_j
  is explicitly presented as a variation of V_i; computing VARIATION_DISTANCE
  = SEQUENCE_SIMILARITY(V_i, V_j); building VARIATION_TREE = hierarchical
  tree of all variation relationships
NOVELTY_CLAIM: Building a formal variation tree of symbolic sequences in
  the Black Books and computing variation distances is new
NEW_RELATION: VARIATION_DEPTH(V_i) = depth of V_i in the variation tree;
  sequences with high depth have undergone multiple layers of variation
POTENTIAL_PRIOR_ART: Theme and variation analysis in musicology; intertextual
  analysis
DISTINCTION: Variation here is the author's explicit acknowledgment of
  repetition-with-change; the formal distance measure and variation tree
  structure makes this precise and computable
TEST: Identify 5 variation pairs; compute variation distances; build partial
  variation tree; report depth distribution
STATUS: NOVEL_CANDIDATE


NB-N116
ID: NB-N116
SOURCE: Model construction, order theory
OBSERVATION: The temporal function T induces a partial order on N
NEW_OPERATION: Completing the partial order T to a TOTAL_ORDER by applying
  a tiebreaking rule for symbols with identical T values; computing the
  ZETA_FUNCTION of the poset Z(s) = Σ_{n ≤ m in T-order} 1 / d(n,m)^s
  where d(n,m) is the temporal distance
NEW_RELATION: POSET_MOBIUS_FUNCTION μ(n, m) for pairs (n, m) with n ≤ m
  in the T-order; the Möbius function counts inclusion-exclusion contributions
  between temporal intervals
NOVELTY_CLAIM: Computing the Möbius function of the temporal poset of the
  Black Books symbol system is new
POTENTIAL_PRIOR_ART: Möbius functions on posets; zeta functions of posets
DISTINCTION: The Möbius function characterizes the combinatorial structure
  of temporal intervals in the symbol system; it is a precise algebraic
  invariant of the temporal ordering structure
TEST: Compute Möbius function for 10 symbol pairs in the T-order; verify
  standard identities (Σ μ(n,m) = [n=m]); test for any zero-patterns
STATUS: NOVEL_CANDIDATE


NB-N117
ID: NB-N117
SOURCE: Black Books observation
OBSERVATION: The text contains descriptions of threshold events — moments
  of crossing between symbolic states or domains
NEW_OPERATION: Identifying THRESHOLD_EVENTS: textual moments of explicit
  crossing, boundary-passage, or liminal transition; tagging each with
  SOURCE_DOMAIN and TARGET_DOMAIN; computing THRESHOLD_FREQUENCY per
  notebook and testing temporal distribution
NEW_RELATION: THRESHOLD_SYMBOL_CORRELATION(n): fraction of threshold events
  where symbol n is present as participant or witness; identifying THRESHOLD_GUARDIANS
  (symbols with highest threshold correlation)
NOVELTY_CLAIM: Formally extracting threshold events and computing their
  correlation with specific symbols is new
POTENTIAL_PRIOR_ART: Liminality theory (Turner); threshold concepts in
  cultural studies
DISTINCTION: Threshold events are formally defined by explicit textual
  markers of boundary crossing, not by theoretical projection of liminality;
  the correlation metric tests which symbols empirically cluster at thresholds
TEST: Identify 15 threshold events; compute THRESHOLD_SYMBOL_CORRELATION;
  identify top-5 threshold-associated symbols; compare to formal attractor ranking
STATUS: NOVEL_CANDIDATE


NB-N118
ID: NB-N118
SOURCE: Model construction, metric space theory
OBSERVATION: The set N can be given a metric structure via RESONANCE
NEW_OPERATION: Defining RESONANCE_DISTANCE(n, m) = 1 - RESONANCE(n, m)
  (converting similarity to distance); verifying METRIC_AXIOMS:
  (1) d(n,n) = 0; (2) d(n,m) = d(m,n); (3) d(n,m) ≤ d(n,k) + d(k,m)
NEW_RELATION: Testing whether RESONANCE_DISTANCE satisfies the triangle
  inequality (which is not guaranteed for arbitrary similarity measures);
  if it does, (N, RESONANCE_DISTANCE) is a metric space
NOVELTY_CLAIM: Verifying that the resonance-derived distance satisfies the
  metric axioms and characterizing the resulting metric space is new
POTENTIAL_PRIOR_ART: Metric embeddings; similarity-to-distance conversion
DISTINCTION: Metric verification is non-trivial for derived similarity
  measures; a confirmed metric space structure allows application of
  all metric-based analysis tools to the symbol system
TEST: Check all three metric axioms for RESONANCE_DISTANCE on a 20-symbol
  sample; report whether triangle inequality holds or fails; if fails,
  report the fraction of violating triples
STATUS: NOVEL_CANDIDATE


NB-N119
ID: NB-N119
SOURCE: Black Books observation
OBSERVATION: Some symbols appear in the text alongside explicit temporal
  markers (dawn, midday, midnight, seasons)
NEW_OPERATION: Computing TEMPORAL_MARKER_AFFINITY(n) = distribution of
  temporal markers co-occurring with n; identifying DAWN_SYMBOLS,
  MIDNIGHT_SYMBOLS, SEASONAL_SYMBOLS based on dominant temporal marker
NEW_RELATION: TEMPORAL_MARKER_TRANSITION: testing whether symbols shift
  their temporal marker affinity over the course of the notebooks (a
  symbol that appears at dawn in early notebooks but midnight in later ones)
NOVELTY_CLAIM: Computing temporal-marker affinity vectors for imaginal
  symbols and testing their temporal stability is new
POTENTIAL_PRIOR_ART: Chronotope analysis (Bakhtin); temporal setting in
  narrative studies
DISTINCTION: Temporal marker affinity is computed from explicit co-occurrence
  data, not from thematic interpretation; a formal shift in temporal marker
  affinity constitutes a SYMBOL_DRIFT in the temporal register
TEST: Compute temporal marker affinity for 10 symbols; identify dominant
  markers; test for affinity shifts across notebooks
STATUS: NOVEL_CANDIDATE


NB-N120
ID: NB-N120
SOURCE: Model construction, stochastic processes
OBSERVATION: The appearance of new symbols over time is a stochastic process
NEW_OPERATION: Modeling the arrival of new symbols as a POINT_PROCESS:
  let λ(t) = rate of new symbol arrivals at time t; fitting a non-homogeneous
  Poisson process (NHPP) with intensity λ(t) to the observed first-appearance
  times T_first(n) for all n ∈ N
NEW_RELATION: INTENSITY_FUNCTION λ(t): the fitted intensity may be decreasing
  (symbol vocabulary saturates), increasing (accelerating symbolic production),
  or non-monotone (episodic bursts); testing model fit via Kolmogorov-Smirnov
NOVELTY_CLAIM: Fitting a non-homogeneous Poisson process to the symbolic
  first-appearance process of the Black Books is new
POTENTIAL_PRIOR_ART: Point process modeling in event data; vocabulary growth
  models (Heaps' Law)
DISTINCTION: The process here models the arrival of imaginal symbols (not
  words); its intensity function characterizes the temporal structure of
  symbolic creativity in the Black Books
TEST: Extract all T_first values; fit NHPP; compute intensity function;
  test fit; hypothesis: λ(t) decreases monotonically (decelerating symbolic novelty)
STATUS: NOVEL_CANDIDATE


NB-N121
ID: NB-N121
SOURCE: Black Books observation
OBSERVATION: Some dialogue turns contain questions that are immediately
  answered within the same turn
NEW_OPERATION: Identifying SELF_ANSWERING_TURNS: dialogue turns where a
  question is posed and then answered without switching speaker; computing
  SELF_ANSWER_RATE per figure; computing SELF_ANSWER_SYMBOL_PROXIMITY(n)
  for each symbol n
NEW_RELATION: SELF_ANSWER_INTERPRETATION: high self-answer rate for a figure
  may indicate that the figure represents an integrated internal process
  (asks and answers itself); testing whether self-answering figures have
  higher ATTRACTOR_SCORE than non-self-answering figures
NOVELTY_CLAIM: Formalizing self-answering dialogue as a structural feature
  of imaginal figures and testing its correlation with attractor status is new
POTENTIAL_PRIOR_ART: Self-repair in conversation analysis; internal dialogue
  in psychology
DISTINCTION: Self-answering turns in visionary dialogue are phenomenologically
  distinct from conversational self-repair; their formal correlation with
  symbolic attractor status is a novel structural hypothesis
TEST: Identify all self-answering turns; compute SELF_ANSWER_RATE for 10 figures;
  rank by rate; compare to ATTRACTOR_SCORE ranking
STATUS: NOVEL_CANDIDATE


NB-N122
ID: NB-N122
SOURCE: Model construction, graph minor theory
OBSERVATION: The symbol graph G may contain specific graph minors
NEW_OPERATION: Testing whether G contains K_5 or K_{3,3} as minors
  (which would imply G is non-planar by Wagner's theorem); if G is planar,
  computing its PLANAR_EMBEDDING and FACE_COUNT via Euler's formula
NEW_RELATION: FACE_INTERPRETATION: if G is planar, each face of the planar
  embedding is a region of the "symbolic plane"; FACE_COUNT = |E| - |N| + 2
  (Euler formula for planar connected graphs)
NOVELTY_CLAIM: Testing planarity of the Black Books symbol graph and computing
  the planar face structure (if planar) or the non-planarity witnesses (if not) is new
POTENTIAL_PRIOR_ART: Planar graph theory; graph minor theory
DISTINCTION: Planarity of the imaginal symbol graph is a non-trivial structural
  property; a non-planar symbol graph requires higher-dimensional embedding,
  which may be symbolically meaningful
TEST: Apply linear-time planarity test to G; if non-planar, identify the
  K_5 or K_{3,3} minor; if planar, compute face structure
STATUS: NOVEL_CANDIDATE


NB-N123
ID: NB-N123
SOURCE: Black Books observation
OBSERVATION: Some passages describe recursive self-description (the author
  describes himself observing himself)
NEW_OPERATION: Identifying RECURSIVE_SELF_REFERENCE_EVENTS: passages where
  the narrative contains nested levels of self-observation; computing
  NESTING_DEPTH of each such passage (maximum number of recursive levels);
  computing SELF_REFERENCE_DEPTH_DISTRIBUTION
NEW_RELATION: SELF_REFERENCE_SYMBOL_SET: the symbols present at highest-
  depth self-reference events; testing whether these symbols have distinctive
  formal properties relative to the full symbol set
NOVELTY_CLAIM: Measuring nesting depth of recursive self-reference in the
  Black Books and correlating depth with symbol presence is new
POTENTIAL_PRIOR_ART: Metalepsis in narratology; self-reference in logic
DISTINCTION: Recursive self-reference in a visionary journal is a specific
  phenomenological event (consciousness observing its own observation);
  formal nesting depth measurement is a novel operation on this material
TEST: Identify 5 recursive passages; compute nesting depth; identify
  co-present symbols; test whether they have higher centrality than average
STATUS: NOVEL_CANDIDATE


NB-N124
ID: NB-N124
SOURCE: Model construction, extremal graph theory
OBSERVATION: The symbol graph G has a finite number of nodes and edges
NEW_OPERATION: Computing TURÁN_NUMBER ex(|N|, H) for forbidden subgraphs H
  of interest; comparing actual |E| to the Turán bound; testing whether
  the symbol graph is denser or sparser than Turán-theoretically expected
  for a graph avoiding specific subgraph types
NEW_RELATION: TURÁN_RATIO = |E| / ex(|N|, H); TURÁN_RATIO > 1 means H
  must appear as a subgraph; identifying which subgraphs H necessarily
  appear given the observed edge density
NOVELTY_CLAIM: Applying Turán-type analysis to the Black Books symbol graph
  to identify necessary structural subgraphs based on edge density is new
POTENTIAL_PRIOR_ART: Extremal graph theory; Turán numbers
DISTINCTION: The Turán analysis provides an unconditional structural guarantee:
  certain subgraphs must appear given the edge count, regardless of how
  the edges are arranged — a non-trivial formal claim about the symbol graph
TEST: Compute |N| and |E|; compute ex(|N|, K_3) and ex(|N|, K_4);
  determine which complete subgraphs must exist; report findings
STATUS: NOVEL_CANDIDATE


NB-N125
ID: NB-N125
SOURCE: Black Books observation
OBSERVATION: The text contains passages where two opposing symbolic forces
  are held in tension without resolution
NEW_OPERATION: Identifying TENSION_PASSAGES: segments where two opposing
  symbolic entities are simultaneously present without merging or resolving;
  computing TENSION_DURATION = T_resolution - T_onset for each tension passage;
  computing TENSION_DURATION_DISTRIBUTION
NEW_RELATION: TENSION_SYMBOL_PAIR_SET: all (n, m) pairs that co-appear in
  tension passages; testing whether TENSION pairs coincide with OPPOSES
  edges in E (are the formally opposed pairs also the tensely co-present ones?)
NOVELTY_CLAIM: Formally extracting tension passages, measuring their duration,
  and testing their alignment with the formal opposition structure is new
POTENTIAL_PRIOR_ART: Tension in narrative theory; dramatic irony analysis
DISTINCTION: Tension duration as a temporal metric in a visionary text
  measures how long the symbolic system sustains an unresolved opposition —
  a formal property with implications for the dynamics of R
TEST: Identify 10 tension passages; measure durations; extract tension pairs;
  test overlap with OPPOSES edges in E; hypothesis: > 60% overlap
STATUS: NOVEL_CANDIDATE


NB-N126
ID: NB-N126
SOURCE: Model construction, topological dynamics
OBSERVATION: The symbol system S evolves over time defining a discrete flow
NEW_OPERATION: Defining the SYMBOLIC_FLOW Φ: N × T → N as the function
  mapping each symbol and time to its transformed state; identifying PERIODIC_ORBITS
  of Φ: symbol sequences n, R_i(n), R_j(R_i(n)), ..., n (cycles in the transformation graph)
NEW_RELATION: ORBIT_PERIOD(n) = length of the shortest periodic orbit containing n;
  ORBIT_STABILITY: testing whether periodic orbits are stable under small perturbations
  of R (replacing one rule with a nearby rule)
NOVELTY_CLAIM: Computing periodic orbits and orbit stability of the symbolic
  flow derived from the Black Books transformation rules is new
POTENTIAL_PRIOR_ART: Topological dynamics; periodic orbit theory in dynamical systems
DISTINCTION: Periodic orbits in the symbolic flow correspond to recurring
  symbolic cycles in the imaginal system; their formal identification
  and stability analysis is a precise dynamical claim about the text
TEST: Identify all periodic orbits of length ≤ 4 in G_R; report orbit periods;
  test stability under a small perturbation of one rule
STATUS: NOVEL_CANDIDATE


NB-N127
ID: NB-N127
SOURCE: Black Books observation
OBSERVATION: Some figures are described as having been known to the author
  in previous encounters or previous books
NEW_OPERATION: Building ENCOUNTER_HISTORY(n) = ordered list of all appearances
  of figure n across notebooks with explicit reference to prior encounters;
  computing CONTINUITY_INDEX(n) = fraction of appearances that explicitly
  reference prior encounters (n "remembers" earlier meetings)
NEW_RELATION: CONTINUITY_VS_FRESHNESS: testing whether figures with high
  CONTINUITY_INDEX also have high SYMBOL_DRIFT (can a figure maintain
  identity continuity while undergoing semantic transformation?)
NOVELTY_CLAIM: Computing continuity index for imaginal figures and testing
  its relationship to symbolic drift is new
POTENTIAL_PRIOR_ART: Character continuity in narrative analysis; identity
  persistence in philosophy
DISTINCTION: Continuity and transformation are formally opposite tendencies;
  their quantitative relationship in specific imaginal figures is a
  novel formal question about the phenomenology of the Black Books
TEST: Compute CONTINUITY_INDEX and SYMBOL_DRIFT for 10 figures; plot;
  test for anti-correlation; hypothesis: weak negative correlation (r ≈ -0.3)
STATUS: NOVEL_CANDIDATE


NB-N128
ID: NB-N128
SOURCE: Model construction, algebraic K-theory inspired
OBSERVATION: The transformation rules R form a monoid; monoids have K-groups
NEW_OPERATION: Computing the GROTHENDIECK_GROUP K_0(M(R)) of the transformation
  monoid: the group completion of M(R) under formal inverses; computing
  whether K_0 is trivial (M(R) is already a group) or non-trivial
NEW_RELATION: NON_TRIVIAL_K_0 means the monoid has elements with no inverse —
  irreversible transformations; TRIVIAL_K_0 means all transformations are
  invertible (a group, not just a monoid)
NOVELTY_CLAIM: Computing the Grothendieck group of the symbolic transformation
  monoid of the Black Books is new
POTENTIAL_PRIOR_ART: Algebraic K-theory; Grothendieck groups
DISTINCTION: Whether the symbolic transformations form a group vs a proper
  monoid is an empirical question about the Black Books source material;
  its algebraic K-theoretic formulation makes this question precise
TEST: Check which transformation rules lack inverses; compute K_0;
  hypothesis: K_0 is non-trivial (some transformations are irreversible)
STATUS: NOVEL_CANDIDATE


NB-N129
ID: NB-N129
SOURCE: Black Books observation
OBSERVATION: The text describes encounters with figures from specific historical
  and mythological traditions
NEW_OPERATION: Identifying CULTURAL_SOURCE(n) for each figure n ∈ N_FIGURE:
  the cultural or textual tradition of origin (Gnostic, Alchemical, Biblical,
  Classical, Germanic, Original); computing CULTURAL_DIVERSITY_INDEX =
  Shannon entropy of CULTURAL_SOURCE distribution
NEW_RELATION: CROSS_CULTURAL_EDGES: edges in E between figures from different
  cultural sources; CROSS_CULTURAL_DENSITY = |CROSS_CULTURAL_EDGES| / |E|;
  testing whether cross-cultural symbol connections are more or less common
  than same-culture connections
NOVELTY_CLAIM: Computing cross-cultural edge density in the Black Books
  symbol graph and testing for cultural homophily or heterophily is new
POTENTIAL_PRIOR_ART: Cultural source analysis in comparative mythology;
  homophily in social networks
DISTINCTION: Cultural homophily/heterophily in an imaginal symbol network
  tests whether the author's imaginal system tends to connect figures from
  the same tradition or across traditions — a formal structural claim
TEST: Classify cultural source for 30 figures; compute CROSS_CULTURAL_DENSITY;
  compare to expected under random mixing; test homophily hypothesis
STATUS: NOVEL_CANDIDATE


NB-N130
ID: NB-N130
SOURCE: Model construction, formal concept analysis
OBSERVATION: Symbols share attributes that define formal concepts
NEW_OPERATION: Building the FORMAL_CONTEXT K = (N, A, I) where N = symbols,
  A = attributes (elemental associations, modal type, cultural source, etc.),
  and I ⊆ N × A is the incidence relation (n has attribute a);
  computing the CONCEPT_LATTICE L(K) using the standard FCA algorithm
NEW_RELATION: FORMAL_CONCEPTS of the Black Books symbol system: pairs (X, Y)
  where X ⊆ N is the extent (symbols with attributes Y) and Y ⊆ A is
  the intent (attributes of all symbols in X)
NOVELTY_CLAIM: Applying Formal Concept Analysis to the Black Books symbol
  system with the derived formal context is new
POTENTIAL_PRIOR_ART: Formal Concept Analysis (Wille); concept lattices
DISTINCTION: The formal context here is derived from the imaginal material;
  the resulting concept lattice is an empirical organization of symbols
  by shared properties, not a designed ontology
TEST: Build K for 20 symbols × 10 attributes; compute concept lattice;
  report number of concepts; identify most populated concepts
STATUS: NOVEL_CANDIDATE


NB-N131
ID: NB-N131
SOURCE: Black Books observation
OBSERVATION: Some transformation events are preceded by a period of inactivity
  or latency for the transforming symbol
NEW_OPERATION: Defining LATENCY_PERIOD(n, R_i) = T(R_i application) - T_last(n before R_i)
  (the gap between n's last appearance and the transformation event);
  computing LATENCY_DISTRIBUTION over all transformations; fitting a
  parametric model (exponential, power law)
NEW_RELATION: LATENCY_PREDICTOR: testing whether LATENCY_PERIOD predicts
  TRANSFORMATION_DEPTH (deeper transformations follow longer latency periods)
NOVELTY_CLAIM: Computing transformation latency periods and testing their
  relationship to transformation depth is new
POTENTIAL_PRIOR_ART: Incubation periods in creativity research; latency
  in stochastic processes
DISTINCTION: Transformation latency in imaginal sequences is a temporal
  property of the symbolic dynamics; its relationship to transformation
  depth tests whether "deeper" transformations require longer preparation
TEST: Identify 10 transformations with measurable latency; compute latency;
  test correlation with RECURSION_DEPTH(n); hypothesis: moderate positive correlation
STATUS: NOVEL_CANDIDATE


NB-N132
ID: NB-N132
SOURCE: Model construction, spectral theory of operators
OBSERVATION: The transformation rules R define linear operators on ℝ^|N|
NEW_OPERATION: For each rule R_i, the matrix M_i ∈ {0,1}^{|N|×|N|} is a
  linear operator; computing the SPECTRUM of M_i: { eigenvalues of M_i };
  computing SPECTRAL_RADIUS(M_i) = max |eigenvalue|
NEW_RELATION: SPECTRAL_GAP(M_i) = second-largest eigenvalue magnitude;
  a large spectral gap means the rule M_i rapidly converges to its dominant
  eigenvector (ergodic rule); a small gap means slow mixing
NOVELTY_CLAIM: Computing spectral radii and gaps of symbolic transformation
  matrices derived from the Black Books is new
POTENTIAL_PRIOR_ART: Spectral theory of Markov chains; matrix spectrum analysis
DISTINCTION: The spectral gap of a transformation rule matrix characterizes
  how quickly repeated application of that rule homogenizes the symbolic
  state — a formal mixing property of the imaginal dynamics
TEST: Compute spectrum for 3 transformation matrices; report spectral radius
  and gap; identify fastest-mixing and slowest-mixing rules
STATUS: NOVEL_CANDIDATE


NB-N133
ID: NB-N133
SOURCE: Black Books observation
OBSERVATION: The text contains dream-work operations described explicitly
  (condensation, displacement, secondary revision)
NEW_OPERATION: Identifying DREAM_WORK_OPERATIONS: textual evidence of
  condensation (multiple entities fused into one), displacement (energy
  shifted from primary to secondary symbol), secondary revision (narrative
  smoothing); building DW_OPERATION_SET with OPERATION_TYPE and
  PARTICIPANT_SYMBOLS
NEW_RELATION: CONDENSATION_GRAPH G_cond: nodes = symbols, edges = when two
  symbols are condensed into a third; CONDENSATION_PRODUCT(a, b) = the
  resulting fused symbol; computing CONDENSATION_DEGREE(n) = number of
  condensations in which n participates
NOVELTY_CLAIM: Extracting dream-work operations as formal graph operations
  and computing condensation degree is new
POTENTIAL_PRIOR_ART: Freudian dream-work theory; condensation in semiotics
DISTINCTION: Dream-work operations are here treated as formal graph operations
  (fusions, shifts) on the symbol graph, not as psychological mechanisms;
  the formal condensation graph is a novel structural object
TEST: Identify 5 condensation events; build G_cond; compute CONDENSATION_DEGREE;
  hypothesis: condensation products have higher subsequent centrality
STATUS: NOVEL_CANDIDATE


NB-N134
ID: NB-N134
SOURCE: Model construction, topological sort
OBSERVATION: The transformation graph G_R may contain cycles or be a DAG
NEW_OPERATION: If G_R is a DAG, computing a TOPOLOGICAL_SORT of the
  transformation graph; the topological order defines a "causal depth"
  for each symbol: symbols early in the order are "prior" and those late
  are "derivative"
NEW_RELATION: CAUSAL_DEPTH(n) = position of n in the topological order;
  symbols with low causal depth are foundational; symbols with high causal
  depth are derived from many prior transformations
NOVELTY_CLAIM: Computing topological sort and causal depth of the Black
  Books transformation graph is new
POTENTIAL_PRIOR_ART: Topological sort in algorithms; causal ordering in
  Bayesian networks
DISTINCTION: If G_R contains cycles (confirmed by NB-N011 SCC analysis),
  the topological sort applies only to the condensed DAG of SCCs;
  the causal depth then applies to symbolic clusters, not individual symbols
TEST: Test G_R for DAG property; if DAG, compute topological order; if cyclic,
  condense SCCs and apply to condensation DAG; report causal depth distribution
STATUS: NOVEL_CANDIDATE


NB-N135
ID: NB-N135
SOURCE: Black Books observation
OBSERVATION: Some entries in the Black Books are written in a distinctly
  different tone or register from surrounding entries
NEW_OPERATION: Defining REGISTER_VECTOR(entry) = distribution over
  REGISTER_TYPES = { PROPHETIC, ANALYTICAL, CONFESSIONAL, DESCRIPTIVE,
  DIALOGIC, POETIC }; computing REGISTER_ENTROPY per notebook;
  computing REGISTER_TRANSITION_MATRIX across consecutive entries
NEW_RELATION: REGISTER_SYMBOL_AFFINITY(n, r): frequency of register r
  co-occurring with symbol n; identifying which symbols are "register-specific"
NOVELTY_CLAIM: Formalizing register as a distributional property of entries
  and computing register-symbol affinities is new
POTENTIAL_PRIOR_ART: Register analysis in stylistics; genre classification
DISTINCTION: Register in the Black Books is a formal property of the
  authorial voice, not of the imaginal content; its correlation with
  symbol presence tests the relationship between symbolic and stylistic structure
TEST: Classify register for 20 entries; compute REGISTER_ENTROPY per notebook;
  compute REGISTER_SYMBOL_AFFINITY for major symbols
STATUS: NOVEL_CANDIDATE


NB-N136
ID: NB-N136
SOURCE: Model construction, combinatorial optimization
OBSERVATION: The symbol graph has a maximum weight independent set problem
NEW_OPERATION: Computing the MAXIMUM_INDEPENDENT_SET of G weighted by
  T_span(n) (symbol persistence): the largest set of mutually non-adjacent
  symbols that maximizes total persistence weight; computing
  INDEPENDENCE_NUMBER α(G)
NEW_RELATION: The maximum weighted independent set identifies the largest
  collection of temporally persistent symbols with no direct symbolic
  relationships — a "non-interacting core" of the imaginal system
NOVELTY_CLAIM: Computing the maximum weighted independent set of the Black
  Books symbol graph with persistence weights is new
POTENTIAL_PRIOR_ART: Maximum independent set algorithms; weighted clique/IS problems
DISTINCTION: The persistence-weighted independent set identifies which symbols
  are both long-lived and maximally isolated from each other — a formal
  characterization of the "background" of the symbolic system
TEST: Compute α(G) for a 30-node subgraph; identify the IS; verify that
  IS members have high T_span and no mutual edges; compare to random selection
STATUS: NOVEL_CANDIDATE


NB-N137
ID: NB-N137
SOURCE: Black Books observation
OBSERVATION: Some symbolic events are described as having moral or ethical
  valence (good/evil, light/dark in moral sense)
NEW_OPERATION: Assigning MORAL_VALENCE(n, t) ∈ { POSITIVE, NEGATIVE, AMBIGUOUS,
  BEYOND_MORAL, UNDEFINED } for each symbol at each appearance; computing
  MORAL_TRAJECTORY(n) = sequence of valuations over time; computing
  MORAL_REVERSAL_COUNT(n) = sign changes in valence
NEW_RELATION: MORAL_REVERSAL_CORRELATION: testing whether moral reversals
  coincide with TRANSFORMS or INVERSION events in the formal model
NOVELTY_CLAIM: Tracking moral valence trajectories of imaginal symbols
  and testing their correlation with formal transformation events is new
POTENTIAL_PRIOR_ART: Sentiment analysis; moral psychology research
DISTINCTION: Moral valence in visionary text can include BEYOND_MORAL (explicit
  transcendence of moral categories) as a distinct state — a category not
  present in standard sentiment analysis
TEST: Annotate moral valence for 15 symbols across appearances; compute
  MORAL_REVERSAL_COUNT; test coincidence with TRANSFORMS edges
STATUS: NOVEL_CANDIDATE


NB-N138
ID: NB-N138
SOURCE: Model construction, network motifs
OBSERVATION: The symbol graph may contain over-represented subgraph patterns
NEW_OPERATION: Computing NETWORK_MOTIF_PROFILE: count of all connected
  subgraphs of size 3 and 4 in G; comparing counts to expected counts in
  a random graph null model (same degree sequence); computing Z-SCORE for
  each motif type; identifying SIGNIFICANT_MOTIFS (|Z| > 2)
NEW_RELATION: MOTIF_SIGNATURE(G) = vector of normalized motif counts;
  comparing MOTIF_SIGNATURE of G to motif signatures of other symbolic
  or biological networks
NOVELTY_CLAIM: Computing the network motif profile of the Black Books symbol
  graph and comparing to other network types is new
POTENTIAL_PRIOR_ART: Network motif analysis (Milo et al.); motif profiles
  in biological and social networks
DISTINCTION: The motif profile characterizes the local structural "building
  blocks" of the imaginal network; comparing to other domains tests whether
  imaginal symbol networks share structural features with any known network class
TEST: Compute motif counts for all 13 size-3 directed motifs; compute Z-scores;
  report significant motifs; compare profile to social network benchmark
STATUS: NOVEL_CANDIDATE


NB-N139
ID: NB-N139
SOURCE: Black Books observation
OBSERVATION: The prologue and epilogue of Liber Novus have distinct symbolic
  properties relative to the main body
NEW_OPERATION: Defining TEXT_REGION ∈ { PROLOGUE, BOOK_1, BOOK_2,
  SCRUTINIES, EPILOGUE }; computing SYMBOL_DIVERSITY(region) = |N(region)|,
  SYMBOL_OVERLAP(r1, r2) = |N(r1) ∩ N(r2)| / |N(r1) ∪ N(r2)| (Jaccard similarity)
NEW_RELATION: REGION_SIMILARITY_MATRIX: |TEXT_REGIONS|² matrix of pairwise
  Jaccard similarities; identifying which regions share the most symbols
  and which are most distinct
NOVELTY_CLAIM: Computing a formal regional symbol similarity matrix for
  the structural sections of Liber Novus is new
POTENTIAL_PRIOR_ART: Document similarity; section-level text analysis
DISTINCTION: The regional Jaccard similarity measures structural symbolic
  overlap across textual sections — a formal test of whether the major
  divisions of Liber Novus constitute distinct symbolic worlds or a unified system
TEST: Compute N(region) for each of the 5 regions; compute Jaccard similarity
  matrix; identify most similar and most distinct region pairs
STATUS: NOVEL_CANDIDATE


NB-N140
ID: NB-N140
SOURCE: Model construction, extremal combinatorics
OBSERVATION: The formal system S = (N, E, T, R, I) has a size that bounds
  the complexity of all derived operations
NEW_OPERATION: Computing COMPLEXITY_BOUNDS for each formal operation defined
  in the model: TIME_COMPLEXITY and SPACE_COMPLEXITY as functions of |N|,
  |E|, |T|, |R|, |I|; identifying which operations are polynomial and
  which are NP-hard in the worst case
NEW_RELATION: TRACTABILITY_MAP: a classification of all formal operations
  by computational tractability; identifying which analyses require
  approximation algorithms or are only feasible on small subgraphs
NOVELTY_CLAIM: Producing a comprehensive computational complexity analysis
  of all formal operations defined in the symbolic state system is new
  as a metatheoretical contribution
POTENTIAL_PRIOR_ART: Complexity analysis of graph algorithms; computational
  social science feasibility analysis
DISTINCTION: The tractability map is specific to the model S and its
  derived operations; it provides practical guidance for which analyses
  are computationally feasible for a given size of Black Books symbol graph
TEST: Compute complexity bounds for RESONANCE (O(|N|²|T|)), ATTRACTOR_BASIN
  (O(|N||E|)), CHROMATIC_NUMBER (NP-hard in general); build tractability table
STATUS: NOVEL_CANDIDATE
