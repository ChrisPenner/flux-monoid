# flux-monoid

`Flux` is a monoid which counts the number of times an element changes
(according to its Eq instance) This is useful for gaining associativity (and
its associated performance improvements) for tasks where you'd otherwise use
`group` or `groupBy`

It also allows usage of change-detection semantics in situations where a Monoid
is required; e.g. in a [FingerTree](https://hackage.haskell.org/package/fingertree/)

```haskell
> getFlux $ foldMap flux ["a", "b", "b", "a"]
2
> getFlux $ foldMap flux ["a", "b", "b", "a", "c", "c", "c"]
3
```
