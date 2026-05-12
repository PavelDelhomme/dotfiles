# GitHub Actions — CI, secrets e-mail (OVH), roadmap

> **Hub** : [`../INDEX.md`](../INDEX.md) · **Tâches** : [`../../TODOS.md`](../../TODOS.md) · **Tests manuels** : [`../TESTS.md`](../TESTS.md) · **Incidents** : [`../ERRORS.md`](../ERRORS.md)

Ce guide répond à trois besoins :

1. **Corriger** un job « Send Email » qui casse avec `dawidd6/action-send-mail@v3`.
2. **Configurer** l’envoi automatique (ex. `dev@delhomme.ovh` → `dev@delhomme.ovh`) via des **secrets** GitHub (jamais de mot de passe en clair dans le dépôt).
3. **Tracer** ce qui reste à faire pour une CI **complète** (installation, configuration, `make test`, etc.) — à enchaîner **après** la passe manuelle [`TESTS.md`](../TESTS.md).

---

## 1. Erreurs observées (diagnostic)

### 1.a `Unexpected input(s) 'content_type'`

L’action **`dawidd6/action-send-mail@v3`** n’accepte **pas** le paramètre `content_type`. Les entrées valides sont notamment : `server_address`, `server_port`, `secure`, `username`, `password`, `subject`, `to`, `from`, `body`, `html_body`, `connection_url`, etc.

**Correctif** : supprimer toute ligne `content_type: …` du workflow.

### 1.b `Input required and not supplied: from`

Le champ **`from`** est obligatoire. Il est souvent branché sur `${{ secrets.EMAIL_FROM }}` — si le secret **n’existe pas** ou est **vide**, le job échoue.

**Correctif** :

- soit **créer** le secret `EMAIL_FROM` (et les autres SMTP, voir § 3) ;
- soit **rendre le job optionnel** avec une condition `if:` (voir § 2) pour que la CI reste verte sans e-mail.

---

## 2. Job e-mail optionnel (recommandé)

Évite d’échouer toute la pipeline quand les secrets ne sont pas encore posés :

```yaml
- name: Notification e-mail (si secrets SMTP configurés)
  if: ${{ secrets.EMAIL_FROM != '' && secrets.SMTP_SERVER != '' && secrets.SMTP_USERNAME != '' && secrets.SMTP_PASSWORD != '' && secrets.EMAIL_TO != '' }}
  uses: dawidd6/action-send-mail@v3
  with:
    server_address: ${{ secrets.SMTP_SERVER }}
    server_port: ${{ secrets.SMTP_PORT }}
    secure: true
    username: ${{ secrets.SMTP_USERNAME }}
    password: ${{ secrets.SMTP_PASSWORD }}
    subject: '[dotfiles] workflow ${{ github.workflow }} — ${{ job.status }}'
    to: ${{ secrets.EMAIL_TO }}
    from: ${{ secrets.EMAIL_FROM }}
    body: |
      Référentiel : ${{ github.repository }}
      Branche / ref : ${{ github.ref }}
      SHA : ${{ github.sha }}
      Run : ${{ github.server_url }}/${{ github.repository }}/actions/runs/${{ github.run_id }}
```

Notes :

- **`secure: true`** : adapté à un port **465** (SSL direct). Si tu utilises le port **587** (STARTTLS), teste `secure: false` ou consulte la doc de ton fournisseur / l’action.
- **`html_body`** existe si tu préfères du HTML ; inutile de passer par `content_type`.
- Ne mets **jamais** d’adresse ni de mot de passe en dur dans le YAML versionné : uniquement `${{ secrets.* }}`.

---

## 3. Secrets GitHub à créer (exemple OVH, même expéditeur et destinataire)

Dans le dépôt : **Settings → Secrets and variables → Actions → New repository secret**.

| Nom du secret | Rôle | Exemple typique (OVH) |
|---------------|------|-------------------------|
| `EMAIL_FROM` | Adresse **expéditeur** (obligatoire pour l’action) | `dev@delhomme.ovh` |
| `EMAIL_TO` | **Destinataire** | `dev@delhomme.ovh` (même adresse = OK pour tests) |
| `SMTP_SERVER` | Hôte SMTP | Souvent **`ssl0.ovh.net`** (SSL) — vérifier dans l’espace client OVH / la doc du type de compte (Perso / Pro). |
| `SMTP_PORT` | Port | **`465`** avec `secure: true`, ou **`587`** avec STARTTLS selon configuration. |
| `SMTP_USERNAME` | Identifiant SMTP | Généralement l’**adresse e-mail complète** `dev@delhomme.ovh`. |
| `SMTP_PASSWORD` | Mot de passe du compte ou **mot de passe d’application** | Celui défini dans le manager mail OVH. |

Sécurité :

- Les secrets sont **chiffrés** côté GitHub ; ils n’apparaissent pas dans les logs si tu ne les affiches pas (`echo "$SMTP_PASSWORD"` interdit).
- Active l’**authentification à deux facteurs** sur le compte GitHub et, côté mail, un **mot de passe d’application** si OVH le propose.

---

## 4. CI déjà dans le dépôt (première étape automatisée)

Le workflow **`.github/workflows/ci-checks.yml`** lance sur `ubuntu-latest` :

- installation de **zsh** (requis par `scripts/test/run_checks.sh` pour les adapters) ;
- **`make test-checks`** (syntaxe managers + adapters + scripts install + URLs).

C’est une **première brique** CI ; elle ne remplace pas `make test` Docker complet (trop lourd / besoin Docker-in-Docker pour une parité totale).

---

## 5. Roadmap CI « complète » (à planifier après `TESTS.md`)

Objectif : sur **GitHub-hosted runner**, enchaîner autant que possible de façon **déterministe** et **sans secret** inutile :

| Étape | Cible | Difficulté | Remarque |
|-------|--------|------------|----------|
| ✅ | `make test-checks` | faible | Déjà en `ci-checks.yml`. |
| ⏳ | `make test-dotfiles-good` | faible | Pure shell, pas de Docker. |
| ⏳ | `make build-dotcli` + `make test-dotcli` | moyenne | Nécessite compilateur C (`gcc`) sur le runner. |
| ⏳ | `make test` (Docker complet) | élevée | Nécessite service Docker ou workflow dédié ; durée longue ; variables `DOTFILES_TEST_*`. |
| ⏳ | Smoke « installation » (bootstrap / symlinks) | élevée | Définir un scénario non destructif + matrice OS. |

Le détail des priorités est dans [`../../TODOS.md`](../../TODOS.md) (**P8 — CI GitHub Actions**).

---

## 6. Références

- Action : [dawidd6/action-send-mail](https://github.com/dawidd6/action-send-mail) (liste des `with:` pour la v3).
- [`../ERRORS.md`](../ERRORS.md) — entrée **GitHub Actions / e-mail** si le problème revient après correctif.
