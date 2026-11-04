# PHP refactoring overlay

List candidates with phpgraph `query_graph` when available, otherwise a search or static analysis.

- **Nested ternary** → successive `if`/`return`, `match (true)`, or a named private method.
- **Conditional array unions** → base array, then one `if` per optional key. Keep key order when the array is serialised.
- **Expression doing several things** → named variables or private methods.
- **Deep nesting** → guard clauses; drop the `else` after them.
- **Assignment in a condition** → assignment on its own line, then the test.
- **Long method** → private methods at one level of abstraction, named by intent.
- **Boolean flag parameter** → two methods or an enum; update the callers.
- **Array as a structure** between classes → `final readonly class`, converted at the boundary.
- **Missing types** → native types, then precise PHPDoc. A wider type than expected is reported, not hidden with `mixed`.
- **Open class** → `final` if nothing extends it, tests included; `readonly` if no property is written after construction.
- **`switch` mapping values** → `match`, with every case covered or the default kept.
