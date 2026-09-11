NB-N030
ID: NB-N030
SOURCE: Model construction, network science
OBSERVATION: The symbol graph G = (N, E) may exhibit small-world properties
NEW_OPERATION: Computing CLUSTERING_COEFFICIENT(n) = (triangles through n) /
  (possible triangles through n); computing AVERAGE_PATH_LENGTH = mean
  shortest path between all pairs in N
NEW_RELATION: SMALL_WORLD_INDEX = (C / C_random) / (L / L_random) where
  C = mean clustering coefficient, L = mean path length, subscript random
  = values for an Erdos-Renyi random graph with same |N|, |E|
NOVELTY_CLAIM: Testing small-world topology in the Black Books symbol graph
  is new as a formal structural claim about this material
POTENTIAL_PRIOR_ART: Small-world network analysis is standard; application
  to imaginal symbol graphs is proposed novel
DISTINCTION: Small-world structure in imaginal symbol networks would imply
  that any symbol is reachable from any other through few transformations —
  a substantive claim about the Black Books symbolic system
TEST: Compute SMALL_WORLD_INDEX; hypothesis: SMALL_WORLD_INDEX > 1
  (more clustered than random, shorter paths than lattice)
FAILURE_CASE: SMALL_WORLD_INDEX ≤ 1: the symbol graph is not small-world;
  this is a falsifiable prediction
STATUS: NOVEL_CANDIDATE


NB-N031
ID: NB-N031
SOURCE: Model construction, degree distribution
OBSERVATION: The symbol graph G has a degree sequence
NEW_OPERATION: Computing the DEGREE_DISTRIBUTION P(k) = fraction of nodes
  with degree k; fitting P(k) to power law, exponential, and Poisson models;
  performing goodness-of-fit tests (Kolmogorov-Smirnov) for each model
NEW_RELATION: If P(k) ~ k^{-γ}, the graph is scale-free; if P(k) ~ e^{-λk},
  the graph has an exponential degree distribution; the best-fit model
  is a structural property of the imaginal system
NOVELTY_CLAIM: Testing the degree distribution of the Black Books symbol graph
  for scale-free or exponential structure is new
POTENTIAL_PRIOR_ART: Degree distribution analysis is standard in network science
DISTINCTION: Scale-free degree distribution in an imaginal symbol network
  would imply the existence of symbolic "hubs" — a claim testable against
  the specific text
TEST: Compute degree sequence; fit three models; report best fit and γ estimate
FAILURE_CASE: If degree distribution does not distinguish from random,
  no preferential attachment or hub structure is present
STATUS: NOVEL_CANDIDATE


NB-N032
ID: NB-N032
SOURCE: Model construction, temporal graph theory
OBSERVATION: Symbols appear and disappear over time, making the symbol graph
  a temporal network
NEW_OPERATION: Defining the TEMPORAL_GRAPH G(t) = (N(t), E(t)) where
  N(t) = { n ∈ N : T_first(n) ≤ t ≤ T_last(n) } and
  E(t) = { (a,b,l) ∈ E : both a and b are in N(t) }
NEW_RELATION: TEMPORAL_DIAMETER(t) = diameter of G(t); tracking how
  diameter changes over T_total as symbols enter and exit the active set
NOVELTY_CLAIM: Analyzing the temporal evolution of the diameter of the
  Black Books symbol graph is new
POTENTIAL_PRIOR_ART: Temporal network analysis; dynamic graph theory
DISTINCTION: The growth and contraction pattern of G(t) reflects the
  narrative structure of the Black Books in a formally computable way
TEST: Compute TEMPORAL_DIAMETER at 10 equally-spaced time points; plot
  trajectory; identify peaks (maximum symbolic complexity) and troughs
FAILURE_CASE: If diameter is constant, the symbolic network has no
  temporal structural variation
STATUS: NOVEL_CANDIDATE


NB-N033
ID: NB-N033
SOURCE: Black Books observation
OBSERVATION: Some symbols appear only in proximity to other specific symbols
NEW_OPERATION: Defining CONDITIONAL_OCCURRENCE(a, b) = P(a active at t |
  b active at t) / P(a active at t); measuring how much the presence of b
  predicts the presence of a
NEW_RELATION: DEPENDENCY_MATRIX D[a,b] = CONDITIONAL_OCCURRENCE(a, b)
  for all pairs; D is not symmetric in general; MUTUAL_DEPENDENCY(a,b)
  = min(D[a,b], D[b,a])
NOVELTY_CLAIM: Computing the conditional occurrence matrix of symbolic
  co-activity in the Black Books is new
POTENTIAL_PRIOR_ART: Conditional probability analysis; association rule mining
DISTINCTION: The "support" for each symbol is its temporal span, not
  discrete transactions; this is a continuous-time conditional occurrence model
TEST: Identify a known symbol pair with documented co-occurrence; verify
  D[a,b] is high; verify an independent symbol pair has D[a,b] ≈ 1
STATUS: NOVEL_CANDIDATE


NB-N034
ID: NB-N034
SOURCE: Model construction, algebraic topology
OBSERVATION: The label set L has 13 elements; the edge structure defines
  a multigraph with 13 edge types
NEW_OPERATION: Constructing the EDGE_TYPE_ALGEBRA: for each pair of labels
  l_1, l_2 ∈ L, defining the COMPOSITION l_1 * l_2 = the label of the
  edge (a, c, ?) that results when (a, b, l_1) and (b, c, l_2) are composed;
  testing whether this composition is well-defined and closed over L
NEW_RELATION: If the composition is closed, L forms a SEMIGROUP under *;
  if there is an identity, L forms a MONOID; if inverses exist, a GROUP
NOVELTY_CLAIM: Testing whether the edge label set of the Black Books symbol
  graph forms a semigroup under edge composition is new
POTENTIAL_PRIOR_ART: Category theory (morphism composition); relation algebra
DISTINCTION: The composition table of L is derived empirically from the
  text, not defined axiomatically; whether it satisfies algebraic laws is
  an empirical question about the source material
TEST: Build composition table for L; check closure, associativity, identity;
  classify the algebraic structure; hypothesis: L is at least a semigroup
FAILURE_CASE: Composition is not well-defined (contradictory compositions
  observed): L is not algebraically closed under composition
STATUS: NOVEL_CANDIDATE


NB-N035
ID: NB-N035
SOURCE: Black Books observation
OBSERVATION: Some symbols undergo transformation under specific conditions
  that are stated in the text as preconditions
NEW_OPERATION: Formalizing PRECONDITION(R_i) = the set of symbolic states
  that must be active for rule R_i to apply; defining PRECONDITION_GRAPH
  G_pre = (N, E_pre) where (a, b) ∈ E_pre iff a ∈ PRECONDITION(R_j) for
  some rule R_j that transforms b
NEW_RELATION: PRECONDITION_COUNT(n) = number of transformation rules for
  which n is a precondition; high PRECONDITION_COUNT identifies symbols
  that function as enabling conditions for other transformations
NOVELTY_CLAIM: Modeling symbolic transformation preconditions as a formal
  graph and computing enabling-condition centrality is new
POTENTIAL_PRIOR_ART: Petri nets; precondition-postcondition specification
DISTINCTION: Preconditions here are derived from the text, not imposed
  axiomatically; this is an empirical extraction from source material
TEST: Identify 3 rules with textual preconditions; build G_pre; compute
  PRECONDITION_COUNT; hypothesis: a small number of symbols have high count
STATUS: NOVEL_CANDIDATE


NB-N036
ID: NB-N036
SOURCE: Model construction, information geometry
OBSERVATION: The probability distributions p(n, t) over symbols at each
  time t form a statistical manifold
NEW_OPERATION: Defining the FISHER_INFORMATION_METRIC on the statistical
  manifold of symbol distributions: g_{ij}(t) = E[∂_i log p · ∂_j log p]
  where the parameters θ are the temporal coordinates of symbol activations
NEW_RELATION: GEODESIC_DISTANCE between two time points t_1, t_2 under the
  Fisher metric measures the information-geometric distance between the
  symbolic states at those times
NOVELTY_CLAIM: Applying information geometry to the temporal evolution of
  symbolic probability distributions in the Black Books is new
POTENTIAL_PRIOR_ART: Information geometry (Amari); statistical manifolds
DISTINCTION: The manifold here is parameterized by the temporal coordinates
  of an imaginal symbolic system, not by statistical model parameters
TEST: Compute Fisher metric at two time points (early and late notebooks);
  compare to Euclidean distance in parameter space; test for curvature
FAILURE_CASE: If the manifold is flat (zero curvature), information geometry
  adds no structure beyond standard distance metrics
STATUS: NOVEL_CANDIDATE


NB-N037
ID: NB-N037
SOURCE: Black Books observation
OBSERVATION: Some sequences of symbolic events exhibit periodicity
  (symbols that recur at approximately regular intervals)
NEW_OPERATION: Computing the AUTOCORRELATION FUNCTION ACF(n, τ) for each
  symbol n: ACF(n, τ) = correlation between the indicator function I_{n active}(t)
  and I_{n active}(t + τ) over all t
NEW_RELATION: DOMINANT_PERIOD(n) = argmax_τ ACF(n, τ) for τ > minimum_period;
  symbols with high ACF peaks are PERIODIC_SYMBOLS
NOVELTY_CLAIM: Computing the autocorrelation of symbol activity timeseries
  in the Black Books to identify periodic symbolic patterns is new
POTENTIAL_PRIOR_ART: Time series analysis; spectral analysis of binary sequences
DISTINCTION: The indicator function of symbol activity is derived from an
  imaginal text; periodicity here is a property of the imaginal structure,
  not of a physical or financial timeseries
TEST: Compute ACF for Philemon; test for significant peaks at any τ;
  hypothesis: at least one symbol has statistically significant periodicity
FAILURE_CASE: No symbol has ACF peak > significance threshold: no periodic
  symbolic structure is present
STATUS: NOVEL_CANDIDATE


NB-N038
ID: NB-N038
SOURCE: Model construction
OBSERVATION: The transformation rules R and the edge set E together define
  the full dynamics of the symbol system
NEW_OPERATION: Constructing the PHASE_PORTRAIT of S: for each symbol n,
  plotting (ENTROPY_CONTRIBUTION(n, t), CENTRALITY(n, t)) as a 2D trajectory
  over t; a "phase portrait" of the symbol in entropy-centrality space
NEW_RELATION: PHASE_TRAJECTORY(n) = the curve traced by n in (H, C) space;
  identifying fixed points (constant H and C), limit cycles, and transients
NOVELTY_CLAIM: Constructing phase portraits for imaginal symbols in
  entropy-centrality space is new as a visualization and analysis method
POTENTIAL_PRIOR_ART: Phase portraits in dynamical systems; attractor
  visualization
DISTINCTION: The "state space" is (entropy contribution, graph centrality),
  both derived from the formal model S; this is a derived state space
  specific to the symbolic system
TEST: Compute phase trajectory for n_Philemon; identify whether trajectory
  converges to a fixed point, cycles, or diverges
FAILURE_CASE: If all trajectories are identical, the phase portrait
  has no discriminative power
STATUS: NOVEL_CANDIDATE


NB-N039
ID: NB-N039
SOURCE: Black Books observation
OBSERVATION: The Black Books contain explicit statements of uncertainty
  or ambiguity by the author
NEW_OPERATION: Defining AUTHORIAL_UNCERTAINTY_NODES ⊂ N_TEXT: textual
  units where the author explicitly marks uncertainty, doubt, or
  incomprehension; computing UNCERTAINTY_DENSITY = |AUTHORIAL_UNCERTAINTY_NODES|
  / |N_TEXT|
NEW_RELATION: Testing whether AUTHORIAL_UNCERTAINTY_NODES cluster around
  specific symbolic events: UNCERTAINTY_PROXIMITY(n) = fraction of n's
  textual neighborhood that contains uncertainty markers
NOVELTY_CLAIM: Treating explicit authorial uncertainty markers as a formal
  subset of N and computing their structural relationship to symbolic events
  is new
POTENTIAL_PRIOR_ART: Hedge detection in NLP; epistemic marker analysis
DISTINCTION: The uncertainty here is not linguistic hedging in general
  discourse; it is authorial marking of imaginal incomprehension, a
  specific and unusual phenomenon
TEST: Identify 10 uncertainty markers in the text; compute UNCERTAINTY_PROXIMITY
  for major symbols; hypothesis: uncertainty markers cluster around
  transformation events rather than stable symbolic states
STATUS: NOVEL_CANDIDATE


NB-N040
ID: NB-N040
SOURCE: Model construction, category theory
OBSERVATION: The symbol system S = (N, E, T, R, I) has morphisms between
  its components
NEW_OPERATION: Defining a CATEGORY C_S where:
  OBJECTS = elements of N (symbolic nodes)
  MORPHISMS = elements of R (transformation rules) + elements of E (edges)
  COMPOSITION = rule composition ∘
  IDENTITY = identity transformation id_n for each n
NEW_RELATION: FUNCTOR F: C_S → C_T from the symbol category to the
  temporal category C_T (where objects are time points and morphisms are
  temporal intervals)
NOVELTY_CLAIM: Defining a category-theoretic structure over the Black Books
  symbol system and constructing functors into other categories is new
POTENTIAL_PRIOR_ART: Category theory applied to linguistics and semiotics
DISTINCTION: The category here is constructed from the empirical structure
  of an imaginal text, not from an abstract algebraic system; its
  category-theoretic properties are empirical questions
TEST: Verify composition law and identity for C_S; compute at least one
  functor F and verify functoriality; identify natural transformations
FAILURE_CASE: Composition is not associative → C_S is not a category but
  only a directed graph with labeled edges
STATUS: NOVEL_CANDIDATE


NB-N041
ID: NB-N041
SOURCE: Black Books observation
OBSERVATION: Certain symbols are explicitly associated with speech acts
  (commands, questions, declarations, laments)
NEW_OPERATION: Classifying N_TEXT by SPEECH_ACT_TYPE using Austin-Searle
  taxonomy (assertives, directives, commissives, expressives, declarations);
  computing SPEECH_ACT_DISTRIBUTION over the full text
NEW_RELATION: SPEECH_ACT_TRANSITION_MATRIX: M[i,j] = P(speech act j follows
  speech act i in the text); testing whether speech act transitions are
  Markovian (memoryless)
NOVELTY_CLAIM: Applying formal speech act theory with a transition matrix
  model to the Black Books dialogue sequences is new
POTENTIAL_PRIOR_ART: Speech act theory (Austin, Searle); dialogue act modeling
DISTINCTION: Speech acts in the Black Books occur between an author and
  imaginal figures; the speech act structure of such dialogues is
  qualitatively different from standard discourse analysis
TEST: Classify speech acts in 50 dialogue turns; compute transition matrix;
  test Markov property; hypothesis: transition matrix is not uniform
STATUS: NOVEL_CANDIDATE


NB-N042
ID: NB-N042
SOURCE: Model construction, symbolic measure theory
OBSERVATION: The symbol graph can be equipped with a measure
NEW_OPERATION: Defining SYMBOL_MEASURE μ on the power set 2^N:
  μ(A) = Σ_{n ∈ A} T_span(n) / T_total (temporal persistence-weighted measure)
NEW_RELATION: MEASURE_PRESERVING_TRANSFORMATION: R_i is measure-preserving
  iff μ(R_i(A)) = μ(A) for all measurable sets A ⊂ N; testing which
  transformation rules preserve the measure
NOVELTY_CLAIM: Defining a temporal persistence measure on the symbol power
  set and testing transformation rules for measure-preservation is new
POTENTIAL_PRIOR_ART: Ergodic theory; measure-preserving transformations
DISTINCTION: The measure is derived from the temporal data of the source;
  whether transformations preserve it is an empirical question about the text
TEST: Compute μ for sample sets; test R_i for measure-preservation;
  hypothesis: at most a subset of rules are measure-preserving
FAILURE_CASE: All rules are measure-preserving: the dynamics are measure-
  preserving (an ergodic-like property of the symbolic system)
STATUS: NOVEL_CANDIDATE


NB-N043
ID: NB-N043
SOURCE: Black Books observation
OBSERVATION: Some symbolic sequences in the Black Books have the structure
  of formal proofs or derivations (one state follows necessarily from another)
NEW_OPERATION: Identifying DERIVATION_SEQUENCES: maximal subsequences
  S = n_1, n_2, ..., n_k where each n_{i+1} is explicitly presented as
  following from n_i by a stated rule or necessity; computing
  DERIVATION_LENGTH distribution
NEW_RELATION: FORMAL_VALIDITY(S) = TRUE if the sequence is self-consistent
  under the rules R; FORMAL_VALIDITY is a decidable property given R
NOVELTY_CLAIM: Identifying and testing formal derivation sequences in an
  imaginal visionary text for logical validity is new
POTENTIAL_PRIOR_ART: Proof theory; formal derivation in logic
DISTINCTION: The "derivations" here are imaginal, not logical; testing
  whether imaginal derivations satisfy formal validity criteria is a
  novel cross-domain application
TEST: Identify 3 candidate derivation sequences; check FORMAL_VALIDITY;
  hypothesis: at least one sequence is formally valid under R
STATUS: NOVEL_CANDIDATE


NB-N044
ID: NB-N044
SOURCE: Model construction
OBSERVATION: The SYMBOL_ATTRACTOR definition involves three independent criteria
NEW_OPERATION: Defining the ATTRACTOR_SCORE(n) = w_1 · (T_span/T_total) +
  w_2 · RECURSION_BASIN_SIZE(n)/|N| + w_3 · mean_m(RESONANCE(n,m))
  as a weighted linear combination of the three attractor criteria
NEW_RELATION: Optimizing weights w_1, w_2, w_3 to maximize separation
  between candidate attractors and non-attractors (if ground truth labels
  are available from expert annotation)
NOVELTY_CLAIM: Defining a composite attractor score with optimizable weights
  and applying it to rank symbolic nodes is new
POTENTIAL_PRIOR_ART: Composite scoring in network analysis; hub identification
DISTINCTION: The three-component attractor score is specific to the imaginal
  symbol model; weight optimization against expert labels is a novel
  validation method for this domain
TEST: Compute ATTRACTOR_SCORE for all n; rank nodes; compare top-ranked
  nodes to independently identified major symbols in the literature
STATUS: NOVEL_CANDIDATE


NB-N045
ID: NB-N045
SOURCE: Black Books structural observation
OBSERVATION: The text moves between narrative voice and direct speech
  at varying rates across the notebooks
NEW_OPERATION: Computing VOICE_RATIO(k) = (lines in direct speech in notebook k)
  / (total lines in notebook k) for each notebook k = 1,...,7;
  tracking VOICE_RATIO as a temporal series
NEW_RELATION: VOICE_RATIO_TREND: testing whether VOICE_RATIO increases,
  decreases, or fluctuates over the 7 notebooks; correlating with
  SYMBOL_ENTROPY at the notebook level
NOVELTY_CLAIM: Treating the ratio of direct speech to narrative as a
  formal temporal metric and correlating it with symbolic entropy is new
POTENTIAL_PRIOR_ART: Narrative analysis; free indirect discourse studies
DISTINCTION: The correlation between direct-speech ratio and symbolic entropy
  is a specific formal hypothesis not present in existing scholarship
TEST: Compute VOICE_RATIO for each notebook; compute notebook-level H;
  compute Pearson correlation; hypothesis: VOICE_RATIO and H are positively
  correlated (more direct speech occurs during symbolic complexity peaks)
STATUS: NOVEL_CANDIDATE


NB-N046
ID: NB-N046
SOURCE: Model construction, combinatorics
OBSERVATION: The set of possible symbol graphs over a fixed N is finite
NEW_OPERATION: Computing the GRAPH_ENTROPY of the observed edge structure:
  H_G = -Σ_{(a,b,l)} p(a,b,l) log p(a,b,l) where p(a,b,l) is the
  normalized frequency of each labeled edge type
NEW_RELATION: GRAPH_ENTROPY vs MAXIMUM_GRAPH_ENTROPY = log(|N|² · |L|);
  the ratio GRAPH_ENTROPY / MAXIMUM_GRAPH_ENTROPY measures how far the
  edge structure is from maximum randomness
NOVELTY_CLAIM: Computing graph entropy of a labeled imaginal symbol graph
  and comparing to the maximum as a structural regularity measure is new
POTENTIAL_PRIOR_ART: Graph entropy measures exist in network science
DISTINCTION: The labeled multigraph entropy here uses the specific label
  set L derived from imaginal relations; the comparison to maximum entropy
  tests the degree of structural constraint in the imaginal system
TEST: Compute H_G; compute ratio; hypothesis: ratio < 0.5 (graph is
  significantly more structured than random)
STATUS: NOVEL_CANDIDATE


NB-N047
ID: NB-N047
SOURCE: Black Books observation
OBSERVATION: Some figures in the dialogues change their apparent stance
  or position across multiple appearances
NEW_OPERATION: Defining STANCE_VECTOR(n, t) = distribution over a set of
  STANCE_TYPES = { AFFIRMATIVE, NEGATIVE, QUESTIONING, COMMANDING,
  LAMENTING, PROPHESYING, SILENT } at time t for figure n;
  computing STANCE_DRIFT(n) = max_{t1,t2} |STANCE_VECTOR(n,t1) - STANCE_VECTOR(n,t2)|
NEW_RELATION: STANCE_DRIFT_CORRELATION: testing whether stance drift correlates
  with SYMBOL_DRIFT for the same figures
NOVELTY_CLAIM: Formalizing the stance of imaginal dialogue figures as a
  distribution and computing stance drift as a formal metric is new
POTENTIAL_PRIOR_ART: Stance detection in NLP; opinion mining
DISTINCTION: Stance here belongs to imaginal figures in visionary dialogues,
  not to real speakers; the formal drift measure over visionary dialogue
  is a novel application
TEST: Classify stances for Philemon across appearances; compute STANCE_DRIFT;
  compare to SYMBOL_DRIFT; hypothesis: stance drift and symbol drift are
  positively correlated
STATUS: NOVEL_CANDIDATE


NB-N048
ID: NB-N048
SOURCE: Model construction, symbolic dynamics
OBSERVATION: The sequence of active symbol sets over time defines a
  symbolic trajectory in the power set 2^N
NEW_OPERATION: Computing the LYAPUNOV_EXPONENT_ESTIMATE of the symbolic
  trajectory: measuring the rate of divergence of two initially similar
  symbolic states under the dynamics R
NEW_RELATION: SYMBOLIC_CHAOS_INDICATOR: if the Lyapunov exponent estimate
  is positive, the symbolic dynamics exhibit sensitive dependence on initial
  conditions; if zero or negative, the dynamics are stable
NOVELTY_CLAIM: Estimating Lyapunov exponents for an imaginal symbolic
  dynamical system derived from the Black Books is new
POTENTIAL_PRIOR_ART: Lyapunov exponents in dynamical systems theory
DISTINCTION: The state space is discrete (power set of N); Lyapunov estimation
  requires adaptation to discrete symbolic dynamics, which is a novel
  methodological challenge
TEST: Define a distance metric on 2^N; simulate the dynamics R from two
  nearby initial states; measure divergence rate; report estimate
FAILURE_CASE: Distance metric undefined or non-computable from the text data
STATUS: NOVEL_CANDIDATE


NB-N049
ID: NB-N049
SOURCE: Black Books observation
OBSERVATION: Animals appear as symbolic entities with varying attributes
  across different appearances
NEW_OPERATION: Building the ANIMAL_ATTRIBUTE_MATRIX: for each animal entity
  a ∈ N_ANIMAL and each attribute type (size, color, behavior, elemental
  association), recording the attested attribute values; computing
  ATTRIBUTE_CONSISTENCY(a) = fraction of appearances where attributes are stable
NEW_RELATION: ATTRIBUTE_INCONSISTENCY_EVENT: an appearance of animal a where
  an attribute changes; computing INCONSISTENCY_RATE over all animal appearances
NOVELTY_CLAIM: Formally tracking attribute consistency of zoomorphic symbolic
  entities across appearances is new as a structured data extraction
POTENTIAL_PRIOR_ART: Entity attribute tracking in information extraction
DISTINCTION: The "attributes" of imaginal animals are symbolic properties
  that may change as part of the imaginal dynamics; attribute inconsistency
  is itself meaningful data, not annotation error
TEST: Apply to serpent figure; record all attribute appearances; compute
  ATTRIBUTE_CONSISTENCY; hypothesis: color and size show higher inconsistency
  than behavioral attributes
STATUS: NOVEL_CANDIDATE


NB-N050
ID: NB-N050
SOURCE: Model construction, spectral theory
OBSERVATION: The transformation graph G_R = (N, E_R) has a Laplacian matrix
NEW_OPERATION: Computing the LAPLACIAN L_R = D - A where D is the degree
  matrix and A is the adjacency matrix of G_R; computing the spectrum
  {λ_0 = 0 ≤ λ_1 ≤ ... ≤ λ_{|N|-1}} of L_R
NEW_RELATION: ALGEBRAIC_CONNECTIVITY = λ_1 (Fiedler value): measures how
  well-connected the transformation graph is; FIEDLER_VECTOR = eigenvector
  corresponding to λ_1 identifies the optimal cut of the transformation graph
NOVELTY_CLAIM: Computing the algebraic connectivity and Fiedler vector of
  the Black Books transformation graph is new
POTENTIAL_PRIOR_ART: Spectral graph theory; Fiedler value analysis
DISTINCTION: The Fiedler vector here partitions the symbol set into two
  groups that are most weakly connected by transformation rules; this
  partition is an empirical structural property of the imaginal system
TEST: Compute λ_1 and Fiedler vector; identify the two symbolic clusters
  defined by the Fiedler partition; verify they correspond to interpretable
  symbolic groupings
STATUS: NOVEL_CANDIDATE


NB-N051
ID: NB-N051
SOURCE: Black Books observation
OBSERVATION: Some symbolic events are described as simultaneous or synchronous
NEW_OPERATION: Defining SYNCHRONY_SET(t) = { (a,b) : both a and b are
  explicitly described as occurring simultaneously at time t }; computing
  SYNCHRONY_DENSITY = |SYNCHRONY_SET| / (|N| choose 2)
NEW_RELATION: SYNCHRONY_GRAPH G_sync = (N, SYNCHRONY_SET); testing whether
  G_sync has community structure (synchrony clusters)
NOVELTY_CLAIM: Extracting a synchrony graph from explicit simultaneity
  statements in an imaginal text and analyzing its community structure is new
POTENTIAL_PRIOR_ART: Synchrony analysis in neuroscience; co-occurrence networks
DISTINCTION: Synchrony here is textually explicit (stated as simultaneous),
  not inferred from statistical co-occurrence; this distinction matters
  for the formal model
TEST: Identify 10 synchrony events; build G_sync; apply community detection;
  hypothesis: synchrony communities differ from resonance communities
STATUS: NOVEL_CANDIDATE


NB-N052
ID: NB-N052
SOURCE: Model construction
OBSERVATION: The formal system S has multiple subsystems that can be projected
NEW_OPERATION: Defining PROJECTION π_k: S → S_k for each node type k, where
  S_k = (N_k, E_k, T_k, R_k, I_k) is the restriction of S to nodes of type k
  and edges between them
NEW_RELATION: INTER_PROJECTION_COUPLING: the number of edges crossing
  between projected subsystems S_k and S_j; measuring how coupled different
  node-type subsystems are
NOVELTY_CLAIM: Formally projecting the full symbol system S onto typed
  subsystems and measuring inter-subsystem coupling is new
POTENTIAL_PRIOR_ART: Subgraph projection; multilayer network analysis
DISTINCTION: The projection here follows the SYMBOLIC_NODE_ONTOLOGY
  partition; the coupling between, e.g., the FIGURE subsystem and the
  ELEMENT subsystem is a specific structural claim about the text
TEST: Compute S_FIGURE and S_ELEMENT; count cross-projection edges;
  hypothesis: FIGURE-ELEMENT coupling is higher than FIGURE-NUMBER coupling
STATUS: NOVEL_CANDIDATE


NB-N053
ID: NB-N053
SOURCE: Black Books observation
OBSERVATION: Certain symbolic sequences repeat across different notebooks
  with variations
NEW_OPERATION: Defining SEQUENCE_SIMILARITY(S_1, S_2) for two symbol
  sequences S_1 and S_2: using edit distance (Levenshtein) on the symbol
  alphabet, with symbol similarity defined by RESONANCE; computing all
  pairwise sequence similarities for sequences of length > k
NEW_RELATION: NEAR_REPEAT_CLUSTERS: groups of sequences with
  SEQUENCE_SIMILARITY > threshold; identifying the "motif set" of
  near-repeated symbolic patterns
NOVELTY_CLAIM: Computing edit-distance-based similarity over imaginal
  symbol sequences using resonance-weighted substitution costs is new
POTENTIAL_PRIOR_ART: Sequence alignment (bioinformatics); motif discovery
DISTINCTION: Standard sequence alignment uses a fixed substitution matrix;
  here the substitution cost between two symbols is their resonance distance,
  derived from the text itself — a data-adaptive cost function
TEST: Apply to two notebooks; identify near-repeat clusters; verify that
  clustered sequences correspond to thematically related narrative sections
STATUS: NOVEL_CANDIDATE


NB-N054
ID: NB-N054
SOURCE: Model construction
OBSERVATION: The interruption set I defines incomplete processes
NEW_OPERATION: Defining COMPLETION_PROBABILITY(n) for each n ∈ I:
  P(n is eventually resolved) estimated from the base rate of resolution
  for symbols of the same type; computing the EXPECTED_RESOLUTION_TIME(n)
  = E[T_resolution - T_interruption] conditioned on eventual resolution
NEW_RELATION: INTERRUPTION_SURVIVAL_FUNCTION: S(τ) = P(interruption persists
  for > τ time units); fitting a survival model (exponential, Weibull) to
  the observed interruption durations
NOVELTY_CLAIM: Applying survival analysis to symbolic interruption durations
  in the Black Books is new
POTENTIAL_PRIOR_ART: Survival analysis in medicine, engineering; event history
  analysis in sociology
DISTINCTION: The "events" here are symbolic narrative interruptions; the
  survival function models the probability that an unresolved symbolic thread
  persists past a given duration — a novel application domain
TEST: Extract all interruption durations; fit exponential model; test
  goodness of fit; report hazard rate
STATUS: NOVEL_CANDIDATE


NB-N055
ID: NB-N055
SOURCE: Black Books observation
OBSERVATION: Geographic and architectural locations recur in the visions
NEW_OPERATION: Building the PLACE_GRAPH G_place = (N_PLACE, E_place) where
  (a, b) ∈ E_place if a and b are textually described as adjacent, nested,
  or connected; computing GRAPH_ISOMORPHISM tests between G_place and
  known historical or mythological architectural schemas
NEW_RELATION: PLACE_CENTRALITY(p) = betweenness centrality of place p in
  G_place; identifying "crossing places" (high betweenness) in the imaginal geography
NOVELTY_CLAIM: Building a formal graph of imaginal geography from the Black
  Books and testing it for isomorphism with historical schemas is new
POTENTIAL_PRIOR_ART: Literary geography; sacred architecture analysis
DISTINCTION: The test for graph isomorphism with external schemas is a
  precise formal test, not a qualitative comparison; a failed isomorphism
  is as informative as a successful one
TEST: Build G_place for a subset of locations; compute betweenness centrality;
  test isomorphism with a known schema (e.g., Dante's cosmological structure)
FAILURE_CASE: Non-isomorphism: the imaginal geography does not match the
  external schema — a falsifiable structural claim
STATUS: NOVEL_CANDIDATE


NB-N056
ID: NB-N056
SOURCE: Model construction, information theory
OBSERVATION: The symbol graph E contains redundant information (multiple
  edge types can convey overlapping information)
NEW_OPERATION: Computing MUTUAL_INFORMATION I(L_1; L_2) between pairs of
  edge label types: I(l_1; l_2) = Σ P(a has edge l_1 AND l_2 to same b) ·
  log [P(l_1 AND l_2) / (P(l_1) · P(l_2))]
NEW_RELATION: LABEL_REDUNDANCY_MATRIX R_L[i,j] = I(L_i; L_j) / H(L_i);
  high redundancy means L_i and L_j carry similar information
NOVELTY_CLAIM: Computing mutual information between edge label types in the
  Black Books symbol graph to identify redundant relational categories is new
POTENTIAL_PRIOR_ART: Feature selection via mutual information; label dependency
  analysis
DISTINCTION: If TRANSFORMS and RESOLVES have high mutual information, they
  may be redundant categories; this is an empirical finding about the
  adequacy of the label set L
TEST: Compute R_L for all pairs of labels; identify maximally redundant pairs;
  hypothesis: at least two labels have mutual information > 0.5 H
STATUS: NOVEL_CANDIDATE


NB-N057
ID: NB-N057
SOURCE: Black Books observation
OBSERVATION: Some dialogue exchanges have the structure of philosophical
  questions and responses
NEW_OPERATION: Identifying APORIA_EVENTS: dialogue exchanges where a
  question is posed but explicitly left without answer in the text;
  computing APORIA_COUNT and APORIA_DENSITY; classifying aporiae by
  semantic field (ethical, metaphysical, cosmological, personal)
NEW_RELATION: APORIA_SYMBOL_PROXIMITY(n): how often symbol n appears in
  the textual neighborhood of aporia events; identifying symbols that
  are structurally associated with unresolved questioning
NOVELTY_CLAIM: Formally classifying aporia events in the Black Books and
  measuring their structural proximity to specific symbols is new
POTENTIAL_PRIOR_ART: Aporia in philosophy; rhetorical aporia analysis
DISTINCTION: Aporia here is an imaginal phenomenon (a visionary dialogue
  that breaks off without answer); its formal relationship to the symbol
  graph is a structural question not addressed in hermeneutic literature
TEST: Identify 5 aporia events; classify by field; compute APORIA_SYMBOL_PROXIMITY
  for major symbols; hypothesis: Philemon has high proximity to aporiae
STATUS: NOVEL_CANDIDATE


NB-N058
ID: NB-N058
SOURCE: Model construction, graph theory
OBSERVATION: The symbol graph G may contain specific subgraph patterns
NEW_OPERATION: Performing GRAPHLET_ANALYSIS: counting all connected
  non-isomorphic induced subgraphs of size 3 and 4 (graphlets);
  computing GRAPHLET_DEGREE_VECTOR(n) = vector of graphlet frequencies
  centered on node n
NEW_RELATION: GRAPHLET_SIMILARITY(n, m) = cosine similarity of their
  graphlet degree vectors; identifying nodes with similar local topology
NOVELTY_CLAIM: Applying graphlet analysis to the Black Books symbol graph
  to characterize local topological environments of symbols is new
POTENTIAL_PRIOR_ART: Graphlet analysis in protein interaction networks;
  network motif analysis
DISTINCTION: Graphlets characterize the local topology around each symbol
  beyond simple degree; this is a richer structural fingerprint for
  imaginal symbols
TEST: Compute graphlets for a 50-node subgraph; identify overrepresented
  graphlet types relative to random graph baseline
STATUS: NOVEL_CANDIDATE


NB-N059
ID: NB-N059
SOURCE: Black Books observation
OBSERVATION: Some symbols are associated with specific sensory modalities
  in the text (visual, auditory, tactile, olfactory descriptions)
NEW_OPERATION: Classifying each node n by SENSORY_MODALITY_VECTOR(n) =
  distribution over {VISUAL, AUDITORY, TACTILE, OLFACTORY, PROPRIOCEPTIVE}
  based on how n is described; computing SENSORY_DOMINANCE(n) = argmax
  of SENSORY_MODALITY_VECTOR
NEW_RELATION: SENSORY_GRAPH G_sense = (N, E_sense) where (a,b) ∈ E_sense
  iff a and b share the same SENSORY_DOMINANCE; testing whether the
  sensory graph has community structure
NOVELTY_CLAIM: Classifying imaginal symbols by sensory modality and building
  a sensory co-dominance graph is new
POTENTIAL_PRIOR_ART: Sensory analysis of literature; multimodal perception studies
DISTINCTION: Sensory modality here is assigned to imaginal entities, not
  to linguistic expressions; the sensory co-dominance graph is a novel
  organizational structure for the imaginal material
TEST: Classify 30 symbols by sensory dominance; build G_sense; test for
  community structure; hypothesis: VISUAL and AUDITORY form separate communities
STATUS: NOVEL_CANDIDATE


NB-N060
ID: NB-N060
SOURCE: Model construction, temporal resolution analysis
OBSERVATION: The temporal coordinate T has varying resolution across notebooks
  (some entries are dated precisely, others only approximately)
NEW_OPERATION: Defining TEMPORAL_RESOLUTION(k) = the granularity of dating
  in notebook k; building a RESOLUTION_WEIGHTED temporal model where
  operations on T are weighted by their temporal resolution
NEW_RELATION: RESOLUTION_BIAS_TEST: testing whether formal metrics computed
  from T (RESONANCE, DRIFT, entropy) are sensitive to temporal resolution;
  computing confidence intervals for metrics under resolution uncertainty
NOVELTY_CLAIM: Propagating temporal resolution uncertainty through the
  formal metrics of the symbol system is new as a metrological analysis
POTENTIAL_PRIOR_ART: Uncertainty propagation in measurement theory;
  sensitivity analysis
DISTINCTION: Temporal resolution uncertainty in manuscript analysis affects
  all time-indexed formal operations; making this uncertainty explicit
  and propagating it through the metrics is a novel methodological contribution
TEST: Compute RESONANCE(a,b) under three resolution assumptions; measure
  variance; hypothesis: metrics are robust to resolution uncertainty
  at the notebook level but sensitive at sub-page level
STATUS: NOVEL_CANDIDATE
