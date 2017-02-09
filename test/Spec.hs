module Main where

import Prologue
import qualified CorpusSpec
import qualified Data.Mergeable.Spec
import qualified Data.RandomWalkSimilarity.Spec
import qualified Diff.Spec
import qualified DiffSummarySpec
import qualified InterpreterSpec
import qualified PatchOutputSpec
import qualified RangeSpec
import qualified Source.Spec
import qualified TermSpec
import Test.Hspec

main :: IO ()
main = hspec . parallel $ do
  describe "Corpus" CorpusSpec.spec
  describe "Data.Mergeable" Data.Mergeable.Spec.spec
  describe "Data.RandomWalkSimilarity" Data.RandomWalkSimilarity.Spec.spec
  describe "Diff.Spec" Diff.Spec.spec
  describe "DiffSummary" DiffSummarySpec.spec
  describe "Interpreter" InterpreterSpec.spec
  describe "PatchOutput" PatchOutputSpec.spec
  describe "Range" RangeSpec.spec
  describe "Source" Source.Spec.spec
  describe "Term" TermSpec.spec
