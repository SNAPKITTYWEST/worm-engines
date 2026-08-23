-- Bifrost_Integration.idr
-- Anchors clone evidence to the LOCKER WORM chain for immutable audit.
--
-- Authors: Ahmad Ali Parr, Jessica L. Williams (SNAPKITTYWEST)

module Bifrost_Integration

%language LinearTypes

import NoClone

-- Bifrost WORM receipt
record BifrostReceipt where
  constructor MkReceipt
  txHash      : Bytes
  blockHeight : Nat
  evidence    : CloneEvidence
  timestamp   : Integer

-- Anchor clone evidence to immutable WORM ledger.
-- Evidence is LINEAR — consumed on anchoring, cannot be double-anchored.
anchorEvidence : (1 _ : CloneEvidence) -> IO (Either String BifrostReceipt)
anchorEvidence ev = do
  let payload = encodeCloneEvidence ev
  txId    <- bifrost_submit "locker.clone_evidence" payload
  receipt <- bifrost_wait_finality txId
  pure $ Right receipt

-- Verify that anchored evidence is still on chain (tamper check)
verifyAnchored : BifrostReceipt -> IO Bool
verifyAnchored receipt = do
  onChain <- bifrost_fetch (txHash receipt)
  pure $ onChain == encodeCloneEvidence (evidence receipt)

-- Stubs (wired to actual WORM append path in production)
bifrost_submit : String -> Bytes -> IO Bytes
bifrost_submit _ payload = pure payload  -- stub

bifrost_wait_finality : Bytes -> IO BifrostReceipt
bifrost_wait_finality txId = pure (MkReceipt txId 0 (MkEvidence neutral neutral 0 Attest) 0)  -- stub

bifrost_fetch : Bytes -> IO Bytes
bifrost_fetch _ = pure neutral  -- stub
