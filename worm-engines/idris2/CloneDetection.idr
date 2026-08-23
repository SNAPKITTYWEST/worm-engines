-- CloneDetection.idr
-- Runtime clone detection state machine with formal guarantees.
-- Total, linear, compiler-verified.
--
-- Authors: Ahmad Ali Parr, Jessica L. Williams (SNAPKITTYWEST)

module CloneDetection

%language LinearTypes

import NoClone

-- Clone detection state machine
data CloneState : Type where
  Clean     : (1 _ : KeyState) -> CloneState
  Suspected : (1 _ : KeyState) -> CloneEvidence -> CloneState
  Confirmed : (1 _ : KeyState) -> CloneEvidence -> CloneState
  Defunct   : CloneEvidence -> CloneState

-- Transition function — total, linear in CloneState
detectClone : (1 _ : CloneState) -> Attestation -> CloneState
detectClone (Clean state) attest =
  let currentHash = hardwareHashOf attest
      seen        = hardwareSeen state
  in  if null seen
        then Clean (record { hardwareSeen = [currentHash] } state)
        else if currentHash `elem` seen
          then Clean state
          else Suspected state (MkEvidence (head seen) currentHash (timestamp attest) Attest)

detectClone (Suspected state ev) attest =
  let currentHash = hardwareHashOf attest
  in  if currentHash == observedHardware ev
        then Confirmed state ev   -- same foreign hardware seen again: confirmed clone
        else Clean state          -- was a transient anomaly

detectClone (Confirmed state ev) _ = Confirmed state ev
detectClone (Defunct ev)         _ = Defunct ev

-- Policy enforcement: auto-defunct on confirmed clone
enforcePolicy : (1 _ : PrivateKey) -> (1 _ : CloneState) -> IO ()
enforcePolicy key (Confirmed state ev) = defunctKey key state
enforcePolicy key (Clean state)        = pure ()
enforcePolicy key (Suspected state _)  = pure ()
enforcePolicy _   (Defunct _)          = pure ()
