-- |
-- Module      : Data.Monoid.Flux
-- Description : A Monoid for tracking changes
-- Copyright   : (c) Chris Penner  2018
-- License     : BSD-3-Clause
-- Stability   : stable
--
-- Flux is a monoid which detects the number of times a value changes across a sequence
--
-- > getFlux $ foldMap flux ["a", "b", "b", "a"]
-- > 2
-- > getFlux $ foldMap flux ["a", "b", "b", "a", "c", "c", "c"]
-- > 3
module Data.Monoid.Flux
  ( Flux (..),
    flux,
  )
where

-- | 'Flux' is a monoid which counts the number of times an element changes
-- (according to its Eq instance)
-- This is useful for gaining associativity (and its associated performance improvements)
-- for tasks where you'd otherwise use `group` or `groupBy`
--
-- It also allows usage of change-detection semantics in situations where a
-- Monoid is required; e.g. in a <https://hackage.haskell.org/package/fingertree/ FingerTree>
data Flux a = Flux
  -- We keep track of the last value we saw on the left and right sides of the accumulated
  -- sequence; `Nothing` is used in the identity case meaning no elements have yet
  -- been encountered
  { sides :: Maybe (a, a),
    -- We have a counter which increments each time we mappend another Flux who's
    -- left doesn't match our right or vice versa depending on which side it is mappended onto.
    getFlux :: Int
  }
  deriving (Show, Eq)

-- | Embed a single value into a Flux;
-- number of changes starts at 0.
flux :: a -> Flux a
flux a = Flux (Just (a, a)) 0

instance (Eq a) => Semigroup (Flux a) where
  Flux Nothing _ <> f = f
  f <> Flux Nothing _ = f
  Flux (Just (l, r)) n <> Flux (Just (l', r')) n'
    | r == l' = Flux (Just (l, r')) (n + n')
    | otherwise = Flux (Just (l, r')) (n + n' + 1)

instance (Eq a) => Monoid (Flux a) where
  mempty = Flux Nothing 0
