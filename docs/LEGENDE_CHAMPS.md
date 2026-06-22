# Légende des champs — format unique des étapes (tests + actions)

> **À utiliser partout** où une procédure est suivie pas à pas : [`TESTS.md`](TESTS.md), futurs guides « actions à mener », rapports d’intervention. Quand un autre document veut ajouter une étape, il **renvoie ici** au lieu de redéfinir les champs.

---

## 1. Bloc d’étape standard (à copier-coller)

```markdown
### Étape <ID> — <Titre court>

- **Commande** : `<commande exacte à exécuter>`
- **Attendu** : <comportement minimal observable>
- **[ ] Fait** *(coche quand exécuté)*
- **Sortie** :

\`\`\`
(coller ici un extrait pertinent — pas tout)
\`\`\`

- **Conforme** : *(O / N / NA — voir §3)*
- **Notes** : *(remarques utilisateur, lien vers une ligne `EXT-xxx` ou `TODOS.md`)*
- **Assistant (relecture)** : *(verdict externe — humain ou IA — après examen de la sortie ; vide jusqu’à validation)*
```

### Champs détaillés

| Champ | Qui remplit | Règle |
|--------|-------------|-------|
| **Étape** | rédacteur du guide | Identifiant **stable** (`A.1`, `B.1`, `G.7`, `EXT-014`…). Ne **jamais** renommer rétroactivement : on cite cet ID dans les `Notes`, les commits, les chats. |
| **Commande** | rédacteur | Copier-collable. Si plusieurs variantes existent → en lister une par bloc dédié. **Presse-papiers** : `make tests-copy STEP=<ID>` (bloc bash) ou `LINE=<n>` (une ligne) — voir [`TESTS.md`](TESTS.md) § « Comment utiliser ». |
| **Attendu** | rédacteur | **Critère minimal** observable (un mot-clé, un fichier, un exit code). Pas un roman. |
| **[ ] Fait** | toi | Coche **uniquement** quand la commande a été lancée. Une commande non lancée reste `[ ]`. |
| **Sortie** | toi | **Extrait pertinent** (max ~20 lignes). Tu peux résumer avec `… (n lignes coupées) …`. |
| **Conforme** | toi | `O` / `N` / `NA` — voir §3. |
| **Notes** | toi | Tout ce qui t’a sauté aux yeux, à creuser, à transformer en ligne `TODOS.md` ou `EXT-xxx`. |
| **Assistant (relecture)** | autre relecteur (humain / IA) | Verdict **après** examen de la sortie : confirme/dément le `Conforme`, ajoute une instruction de suite, demande une clarification. **Reste vide** tant qu’il n’y a pas eu de relecture. |

---

## 2. Variantes courtes

### 2.a — Étape **en ligne de tableau** (G : managers, H : variables d’env)

```markdown
| # | Manager | `[ ]` | Sortie (extrait) | Conforme | Notes | Assistant (relecture) |
|---|---------|-------|------------------|----------|-------|----------------------|
| G.1 | pathman | [ ] | | | | |
```

### 2.b — Étape **EXT-xxx** (demande adressée à l’assistant)

```markdown
| ID | Demande (précise) | Priorité | Traitée |
|----|-------------------|----------|---------|
| EXT-014 | Ajouter une étape dotcli pour `routeman` menu interactif | M | [ ] |
```

Une fois traitée par l’assistant : `[x]` + **nouvelle étape numérotée** ajoutée dans le bon bloc + lien commit en `Notes`.

---

## 3. Valeurs `Conforme` (O / N / NA)

| Valeur | Quand l’utiliser | Action ensuite |
|--------|------------------|----------------|
| **O** *(Oui)* | La sortie respecte l’**Attendu** (au moins le critère minimal). | Continue à l’étape suivante. |
| **N** *(Non)* | La sortie **contredit** l’Attendu (erreur, valeur fausse, exit ≠ 0 sans raison documentée). | Note la cause estimée ; ouvre une ligne dans [`ERRORS.md`](ERRORS.md) **ou** une `EXT-xxx`. Ne coche **pas** la suite tant que c’est non résolu si l’étape est bloquante. |
| **NA** *(Non applicable)* | Le critère ne **s’applique pas** dans ton contexte (ex. `docker version` exécuté **dans** un conteneur sans Docker, étape TUI sur un shell sans TTY, manager désactivé). | Indique la **raison** courte en `Notes`. Ne pas confondre avec `N`. |

> Règle d’or : `N` = « bug ou écart à investiguer ». `NA` = « pas le bon contexte, ce n’est pas un échec ».

---

## 4. Liens utilisateur ↔ documents

- Une étape **bloquante non résolue** → ligne dans [`ERRORS.md`](ERRORS.md) (Cause + Correctif) et référence dans `Notes`.
- Une **demande d’extension** → ligne `EXT-xxx` dans `TESTS.md` § 12 ou dans le guide concerné.
- Une **tâche à formaliser** dans la roadmap → ligne dans [`../TODOS.md`](../TODOS.md) (avec ID de l’étape dans la description).
- Un **incident général** récurrent → bloc daté dans `ERRORS.md`.

---

## 5. Convention de mise à jour

- Le **bloc d’étape** ci-dessus est **figé** : ne pas inventer de nouveaux champs ailleurs sans mettre à jour ce fichier.
- Quand tu ajoutes une **section** à un guide, copie le bloc tel quel (en remplaçant `ID` et `Titre`).
- Les autres documents (TESTS, futurs ACTIONS, etc.) doivent commencer par : `> **Format des étapes** : [`LEGENDE_CHAMPS.md`](LEGENDE_CHAMPS.md).`
