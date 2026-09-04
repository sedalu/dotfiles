# Databases

Applies when the repo owns a relational schema.
A non-relational store has no standard here yet;
write one when there is a repo to derive it from.

A rule below that names a server-side feature — schemas, roles, stored functions, native enums —
binds where the engine has that feature and is silent where it does not.
Postgres is the default engine; an embedded one such as SQLite has none of them.
What holds on every engine is where SQL lives, how it is organized, and how it is gated.

## Query access

- No raw SQL strings in application code — anywhere, tests included.
  Every query lives in a `.sql` file.
  The only out-of-band SQL is session commands and migration DDL.
- sqlc compiles those files wherever it targets the language.
  Where it does not, the `.sql` file is still the source of the query:
  generate from it with whatever that language offers, or load it by name at run time.
  What is never acceptable is a copy of the statement living in the code.
- Query files are organized per consuming component, one file per binary's needs,
  never one catch-all file.
- The pipeline runs `sqlc diff` as the drift gate and `sqlc vet` as the query linter.
  Drift is a push-blocking failure, not a regeneration prompt.
  Where nothing is generated there is no drift to gate, but the queries are still linted.
- Writes go through stored functions, and application code never holds DML on committed tables.
  On an engine without them, a write is a named query in a `.sql` file like any other.

## Schema

- Never validate with a pattern `CHECK` constraint,
  for the same reason regular expressions are not used for validation in code.
- A closed set is constrained by the schema:
  a native enum where the engine has one,
  a lookup table and a foreign key where it does not.
- Roles are named `<context>_<purpose>`;
  functions are named `<schema>.<verb>_<noun>`.

## Migrations

Migrations are forward-only, named `NNN_name.sql`, and gap-free.
Each context owns its own migrations and its own version table.
The runner is picked per engine, and tern is the choice on Postgres.
