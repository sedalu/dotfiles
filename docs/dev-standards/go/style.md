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
- Use `encoding/json/v2` and `encoding/json/jsontext`, never `encoding/json`.
- json/v2's tag options are `case`, `embed`, `omitzero`, `omitempty`, `string`, and `format`.
  `inline` and `unknown` are names from the v2 proposal that the released package never implemented,
  and an option it does not recognize is ignored rather than rejected,
  so `json:",inline"` reads as if it promotes a field's members while they stay nested.
  `embed` is what promotes them.
- A decoder reading a JSON `null` into a string yields `""` and no error.
  Where `null` is invalid, check the token's kind (`'"'`) rather than the decoded value.
- A `jsontext.Token` or `jsontext.Value` read from a decoder is valid only until the next read.
  Copy it — `String()`, `Clone()` — before reading on.
- Avoid shadowing `err`.
  An inner scope names its error after the operation:

  ```go
  tag, tagErr := parseTag(raw)
  if tagErr != nil {
      return fmt.Errorf("parse tag: %w", tagErr)
  }
  ```
