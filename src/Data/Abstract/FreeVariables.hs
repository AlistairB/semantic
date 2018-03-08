{-# LANGUAGE DefaultSignatures, UndecidableInstances #-}
module Data.Abstract.FreeVariables where

import Prologue
import Data.Term

-- | The type of variable names.
data Name = Name ByteString | Qualified ByteString Name
  deriving (Eq, Ord, Show)

name :: ByteString -> Name
name = Name

qualifiedName :: [ByteString] -> Name
qualifiedName [] = Name "THIS IS BROKEN"
qualifiedName [x] = Name x
qualifiedName (x:xs) = Qualified x (qualifiedName xs)

friendlyName :: Name -> ByteString
friendlyName (Name a) = a
friendlyName (Qualified a b) = a <> "." <> friendlyName b

instance Semigroup Name where
  (<>) (Name a) n = Qualified a n
  (<>) (Qualified a rest) n = Qualified a (rest <> n)


-- | Types which can contain unbound variables.
class FreeVariables term where
  -- | The set of free variables in the given value.
  freeVariables :: term -> Set Name


-- | A lifting of 'FreeVariables' to type constructors of kind @* -> *@.
--
--   'Foldable' types requiring no additional semantics to the set of free variables (e.g. types which do not bind any variables) can use (and even derive, with @-XDeriveAnyClass@) the default implementation.
class FreeVariables1 syntax where
  -- | Lift a function mapping each element to its set of free variables through a containing structure, collecting the results into a single set.
  liftFreeVariables :: (a -> Set Name) -> syntax a -> Set Name
  default liftFreeVariables :: (Foldable syntax) => (a -> Set Name) -> syntax a -> Set Name
  liftFreeVariables = foldMap

-- | Lift the 'freeVariables' method through a containing structure.
freeVariables1 :: (FreeVariables1 t, FreeVariables a) => t a -> Set Name
freeVariables1 = liftFreeVariables freeVariables

freeVariable :: FreeVariables term => term -> Name
freeVariable term = let [n] = toList (freeVariables term) in n

-- TODO: Need a dedicated concept of qualified names outside of freevariables (a
-- Set) b/c you can have something like `a.a.b.a`
-- qualifiedName :: FreeVariables term => term -> Name
-- qualifiedName term = let names = toList (freeVariables term) in B.intercalate "." names

instance (FreeVariables1 syntax, Functor syntax) => FreeVariables (Term syntax ann) where
  freeVariables = cata (liftFreeVariables id)

instance (FreeVariables1 syntax) => FreeVariables1 (TermF syntax ann) where
  liftFreeVariables f (In _ s) = liftFreeVariables f s

instance (Apply FreeVariables1 fs) => FreeVariables1 (Union fs) where
  liftFreeVariables f = apply (Proxy :: Proxy FreeVariables1) (liftFreeVariables f)

instance FreeVariables1 []
