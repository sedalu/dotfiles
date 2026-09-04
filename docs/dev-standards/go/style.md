# Go style

- Composite literals are multi-line, one field per line, trailing commas — table-test cases included.

  ```go
  cases := []struct {
      name     string
      currency string
  }{
      {name: "usd", currency: "USD"},
  }
  ```

- A blank line separates a declaration or assignment from a following control statement,
  except the idiomatic `x, err := f()` followed immediately by its `if err != nil`.
- A blank line precedes a `return` that follows other statements.
- Never type-assert without checking `ok`, and give the failure an explicit path.
- Never validate with a regular expression.
  Write explicit character and length checks, or use a real parser.
- Do not assert interface satisfaction with `var _ I = (*T)(nil)`;
  real use in a main package or a test proves it.
- Avoid shadowing `err`.
  An inner scope names its error after the operation:

  ```go
  tag, tagErr := parseTag(raw)
  if tagErr != nil {
      return fmt.Errorf("parse tag: %w", tagErr)
  }
  ```
