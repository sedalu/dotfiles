# Go API boundaries

- Third-party types never appear in exported signatures.
  Wrap them in owned types so the dependency stays confined.
- Internal values are typed values, never strings standing in for numbers.
  String encodings exist only at wire boundaries.
