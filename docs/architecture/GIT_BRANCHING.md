# Modèle de branches Git (dotfiles)

> **Statut** : convention adoptée **2026-06-16**. `main` reste la branche **production** sur GitHub (équivalent « prod ») ; pas de renommage immédiat pour éviter de casser les clones existants.

## Branches permanentes

| Branche | Rôle | Règle |
|---------|------|--------|
| **`main`** | Production stable | Merge depuis `preprod` uniquement après validation. Tag / release possible. |
| **`dev`** | Intégration continue | Branche principale de développement ; reçoit les merges de `feat/*`, `test/*`, `fix/*`. |
| **`preprod`** | Staging avant prod | Optionnelle tant que le flux n’est pas automatisé ; miroir de ce qui partira sur `main`. |

## Branches de travail (préfixes obligatoires)

| Préfixe | Quand l’ouvrir | Exemple |
|---------|----------------|---------|
| **`feat/`** | Développement d’une fonctionnalité en cours | `feat/manual-tests-g0` |
| **`test/`** | Feature **terminée** ; phase de tests unitaires / fonctionnels / E2E / manuels documentés | `test/manual-tests-g0` |
| **`fix/`** | Correctifs issus de la phase `test/` (régression, bug trouvé en QA) | `fix/displayman-ddc-timeout` |

### Flux recommandé

```text
feat/xxx  →  dev  →  test/xxx  →  fix/xxx (si besoin)  →  dev  →  preprod  →  main
```

1. Créer **`feat/nom-court`** depuis `dev`.
2. Développer, commit, push ; merge dans **`dev`** quand le lot est revu.
3. Ouvrir **`test/nom-court`** (depuis `dev` ou en renommant la branche) pour la passe tests complète (`docs/TESTS.md`, CI, E2E).
4. Si échec : **`fix/nom-court`** → merge **`dev`** → retour **`test/`**.
5. Quand **`test/`** est vert et documenté : merge **`dev`** → **`preprod`** → **`main`**.

## Règle : ne plus supprimer les branches

**À partir du 2026-06-16**, on **n’efface plus** les branches locales ou distantes après merge.

- Conserver l’historique et le nommage (`feat/`, `test/`, `fix/`) pour traçabilité.
- Marquer une branche comme **fusionnée** dans le message de merge ou un tag `merged/feat-xxx`.
- Nettoyage éventuel : **archiver** (tag, note dans `STATUS.md`) plutôt que `git branch -D` / `push --delete`.

Exception : branches jetables personnelles **non poussées** sur une machine de dev isolée.

## Personnalisation `gitman` (futur)

Le manager **`gitman`** du dépôt reste générique pour l’instant. Une couche **personnalisable** (profils utilisateur, hooks, conventions de nommage) est prévue : activation optionnelle via config locale (`pathman` / overrides), sans imposer le modèle ci-dessus aux contributeurs externes.

## Liens

- Journal : [`STATUS.md`](../../STATUS.md)
- Roadmap : [`TODOS.md`](../../TODOS.md) (P11, P12)
- Tests manuels : [`docs/TESTS.md`](../TESTS.md)
- Copie commandes : `make tests-copy STEP=G.0.b`
