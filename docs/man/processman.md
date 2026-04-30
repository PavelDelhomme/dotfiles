# PROCESSMAN(1) - Gestionnaire de Processus

## NOM

processman - Gestionnaire interactif de processus (recherche, inspection, kill, restart, signaux)

## SYNOPSIS

**processman** [*command*]

## DESCRIPTION

PROCESSMAN permet de gérer facilement les processus locaux:
- recherche par motif
- inspection détaillée d'un PID
- arrêt gracieux (`TERM`) ou forcé (`KILL`)
- pause/reprise (`STOP`/`CONT`)
- redémarrage d'un processus
- affichage de l'arbre des processus

Sans argument, il lance un menu interactif.

## OPTIONS

**command** peut être :
- **list** | **ls** - Liste les processus (tri CPU)
- **search** | **find** *pattern* - Recherche des processus
- **info** | **inspect** *pid* - Affiche les détails d'un PID
- **kill** *pid|pattern* - Envoie SIGTERM
- **force-kill** | **kill9** *pid|pattern* - Envoie SIGKILL
- **stop** *pid* - Envoie SIGSTOP
- **continue** | **cont** | **resume** *pid* - Envoie SIGCONT
- **signal** *SIGNAL* *pid* - Envoie un signal personnalisé
- **restart** *pid|pattern* - Relance un ou plusieurs processus
- **tree** - Affiche l'arbre des processus
- **help** - Affiche l'aide

## EXEMPLES

Lancer le menu interactif :
```
$ processman
```

Rechercher un processus :
```
$ processman search node
```

Voir les détails d'un PID :
```
$ processman info 1234
```

Terminer un processus :
```
$ processman kill 1234
```

Forcer la terminaison :
```
$ processman force-kill 1234
```

Relancer un processus :
```
$ processman restart 1234
```

## VOIR AUSSI

- **manman**(1) - Manager of Managers
- **ps**(1) - Affichage des processus
- **kill**(1) - Envoi de signaux
- **pstree**(1) - Arbre des processus
- **top**(1) - Monitoring des processus

## AUTEUR

Paul Delhomme - Systeme de dotfiles personnalise

