pragma Ada_2012;
pragma SPARK_Mode (On);

package body Invariants is

   --  All invariant functions are defined inline in the specification
   --  No implementation needed here (they are pure functions with Ghost contracts)

   --  The SPARK prover will verify these predicates automatically
   --  using the definitions in the .ads file.

end Invariants;
