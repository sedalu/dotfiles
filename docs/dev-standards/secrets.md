# Secrets

Secrets are managed by fnox.
Ciphertext is committed; private keys stay local.
No plaintext `.env` ever exists on disk.

## Rules

- **Every secret declares `if_missing = "error"`.**
  The default is `warn`, which logs and leaves the variable unset,
  so the process starts with the key simply absent —
  standing up an unauthenticated service instead of failing the deploy.

  ```toml
  [secrets.DATABASE_URL]
  if_missing = "error"
  ```

- **Inject per process** via `fnox exec --`.
  Never load secrets into a shell session.
- **Set values with `fnox set <KEY>`**, which prompts with hidden input,
  so nothing reaches shell history or `ps`.
- **Store every password, even one no script reads.**
  Secrets nothing automated consumes live in a non-default profile,
  so they are held without widening what a normal `fnox exec` resolves.
- **Never route a password prompt through an agent.**
  Hand the command to the person to run.

## Providers

The provider follows the trust boundary:
a machine-local keychain for secrets that never leave the machine,
age for anything committed or consumed by CI.

**Each repo gets its own CI key.**
A shared key lets any repo's runner decrypt every other repo's secrets.

## Handling

Gitignore key material — `*.age.txt`, `age.txt` — and every `.local.toml` overlay.

When a secrets file moves, update everything that names it by path.
An exclude list keyed on the old filename stops matching silently,
and starts sweeping the key into backups and archives.

Where a secret has an authoritative store outside the repo,
name that store as the source of truth and treat fnox as a downstream cache.
