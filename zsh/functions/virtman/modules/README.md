# Modules VIRTMAN

Ce répertoire contient les modules du gestionnaire d'environnements virtuels VIRTMAN.

## Structure

```
modules/
├── docker/          # Gestion des conteneurs Docker
├── qemu/            # Gestion des VMs QEMU/KVM
├── libvirt/         # Gestion via libvirt/virsh
├── lxc/             # Gestion des conteneurs LXC
├── vagrant/         # Gestion des VMs Vagrant
├── overview.sh      # Vue d'ensemble de tous les environnements
└── search.sh        # Recherche d'environnements
```

## Modules disponibles

### docker/
Gestion complète des conteneurs Docker :
- Lister les conteneurs
- Créer et démarrer des conteneurs
- Gérer les images
- Gérer les volumes
- Gérer les réseaux

### qemu/
Gestion des machines virtuelles QEMU/KVM :
- Lister les VMs
- Créer des VMs
- Démarrer/Arrêter des VMs
- Gérer les disques
- Configuration réseau

### libvirt/
Gestion via libvirt/virsh :
- Lister les VMs
- Démarrer/Arrêter/Suspendre des VMs
- Accès console
- Gérer les réseaux libvirt

### lxc/
Gestion des conteneurs LXC :
- Lister les conteneurs
- Créer des conteneurs
- Démarrer/Arrêter des conteneurs
- Accès shell
- Gestion complète

### vagrant/
Gestion des VMs Vagrant :
- Lister les VMs
- Initialiser des projets
- Démarrer/Arrêter des VMs
- Provisionnement
- Accès SSH

