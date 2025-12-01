# GitHub Actions Workflows

Ce dossier contient les workflows GitHub Actions pour automatiser certaines tâches du projet.

## 📧 Notify on Push

Workflow qui envoie un email à chaque push sur n'importe quelle branche.

### Configuration

Pour activer ce workflow, vous devez configurer les secrets suivants dans GitHub :

1. Allez dans **Settings** → **Secrets and variables** → **Actions**
2. Ajoutez les secrets suivants :

#### Secrets requis :

- `SMTP_SERVER` : Adresse du serveur SMTP (ex: `smtp.gmail.com`, `smtp.office365.com`)
- `SMTP_PORT` : Port SMTP (ex: `587` pour TLS, `465` pour SSL)
- `SMTP_USERNAME` : Nom d'utilisateur SMTP (votre email)
- `SMTP_PASSWORD` : Mot de passe SMTP (ou mot de passe d'application)
- `EMAIL_TO` : Adresse email de destination (où recevoir les notifications)
- `EMAIL_FROM` : Adresse email expéditeur (doit correspondre à SMTP_USERNAME)

### Exemples de configuration SMTP

#### Gmail
```
SMTP_SERVER: smtp.gmail.com
SMTP_PORT: 587
SMTP_USERNAME: votre.email@gmail.com
SMTP_PASSWORD: [Mot de passe d'application Gmail]
EMAIL_FROM: votre.email@gmail.com
EMAIL_TO: destination@example.com
```

**Note pour Gmail** : Vous devez utiliser un [mot de passe d'application](https://support.google.com/accounts/answer/185833) au lieu de votre mot de passe normal.

#### Outlook/Office 365
```
SMTP_SERVER: smtp.office365.com
SMTP_PORT: 587
SMTP_USERNAME: votre.email@outlook.com
SMTP_PASSWORD: [Votre mot de passe]
EMAIL_FROM: votre.email@outlook.com
EMAIL_TO: destination@example.com
```

#### SendGrid (Alternative)
Si vous préférez utiliser SendGrid au lieu de SMTP direct, vous pouvez modifier le workflow pour utiliser l'API SendGrid.

### Contenu de l'email

L'email contient :
- 📦 Nom du repository
- 🌿 Branche concernée
- 👤 Auteur du commit
- 🔖 Hash du commit
- 💬 Message de commit
- 📝 Liste des fichiers modifiés
- 🔗 Liens vers le commit et la comparaison

### Déclenchement

Le workflow se déclenche automatiquement sur :
- ✅ Push sur n'importe quelle branche
- ✅ Déclenchement manuel via l'interface GitHub Actions

### Désactiver le workflow

Pour désactiver temporairement le workflow sans le supprimer :
1. Allez dans **Actions** → **Notify on Push**
2. Cliquez sur **...** → **Disable workflow**

Ou commentez le workflow dans le fichier `.github/workflows/notify-on-push.yml`.

