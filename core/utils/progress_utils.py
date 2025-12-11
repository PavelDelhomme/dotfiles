#!/usr/bin/env python3
# =============================================================================
# PROGRESS_UTILS - Module de barre de progression réutilisable
# =============================================================================
# Description: Module Python pour afficher des barres de progression
# Author: Paul Delhomme
# Version: 1.0
# =============================================================================
"""
Module de barre de progression réutilisable

Usage: 
    from progress_utils import ProgressBar
    
    progress = ProgressBar(100, "Traitement")
    for i in range(100):
        progress.increment(successful=True)
    progress.finish()
"""

import sys
import time
from datetime import timedelta
from typing import Optional

class ProgressBar:
    """Classe pour afficher une barre de progression avec statistiques et temps."""
    
    def __init__(self, total: int, description: str = "Traitement"):
        """
        Initialise la barre de progression.
        
        Args:
            total: Nombre total d'éléments à traiter
            description: Description du traitement (optionnel)
        """
        self.total = total
        self.description = description
        self.start_time = time.time()
        self.completed = 0
        self.successful = 0
        self.failed = 0
        self.bar_length = 40
        self.last_print_time = time.time()
        self.print_interval = 0.3  # Afficher toutes les 0.3 secondes minimum
        
    def update(self, completed: int, successful: Optional[int] = None, failed: Optional[int] = None, force: bool = False):
        """
        Met à jour la barre de progression.
        
        Args:
            completed: Nombre d'éléments complétés
            successful: Nombre d'éléments réussis (optionnel, calculé automatiquement si None)
            failed: Nombre d'éléments échoués (optionnel, calculé automatiquement si None)
            force: Forcer l'affichage même si l'intervalle n'est pas atteint
        """
        self.completed = completed
        
        if successful is not None:
            self.successful = successful
        if failed is not None:
            self.failed = failed
        
        # Si successful et failed ne sont pas fournis, les calculer
        if successful is None and failed is None:
            # Par défaut, on considère que completed = successful
            self.successful = completed
            self.failed = 0
        
        # Afficher seulement si l'intervalle est atteint ou si on force
        current_time = time.time()
        if force or (current_time - self.last_print_time >= self.print_interval) or (completed == self.total):
            self._print_progress()
            self.last_print_time = current_time
    
    def increment(self, successful: bool = True, count: int = 1):
        """
        Incrémente la progression.
        
        Args:
            successful: True si réussi, False si échoué
            count: Nombre d'éléments à incrémenter (défaut: 1)
        """
        self.completed += count
        if successful:
            self.successful += count
        else:
            self.failed += count
        
        # Afficher seulement si l'intervalle est atteint
        current_time = time.time()
        if (current_time - self.last_print_time >= self.print_interval) or (self.completed == self.total):
            self._print_progress()
            self.last_print_time = current_time
    
    def _print_progress(self):
        """Affiche la barre de progression."""
        if self.total == 0:
            percentage = 0
        else:
            percentage = (self.completed / self.total) * 100
        
        # Créer la barre
        filled = int(self.bar_length * self.completed / self.total)
        if filled > self.bar_length:
            filled = self.bar_length
        bar = '█' * filled + '░' * (self.bar_length - filled)
        
        # Calculer le temps écoulé
        elapsed_time = time.time() - self.start_time
        elapsed_str = str(timedelta(seconds=int(elapsed_time)))
        
        # Estimation du temps restant
        if self.completed > 0:
            avg_time_per_item = elapsed_time / self.completed
            remaining = self.total - self.completed
            estimated_remaining = avg_time_per_item * remaining
            eta = str(timedelta(seconds=int(estimated_remaining)))
            time_info = f"⏱️  {elapsed_str} écoulé | ~{eta} restant"
        else:
            time_info = "⏱️  Calcul en cours..."
        
        # Statistiques
        stats = f"✅ {self.successful} | ❌ {self.failed}"
        
        # Afficher la barre de progression (retour chariot pour écraser la ligne précédente)
        sys.stdout.write(f"\r[{self.completed}/{self.total}] {percentage:.1f}% |{bar}| {stats} | {time_info}")
        sys.stdout.flush()
    
    def finish(self, show_summary: bool = True):
        """
        Termine la barre de progression.
        
        Args:
            show_summary: Afficher le résumé final (défaut: True)
        """
        # Afficher la progression finale
        self._print_progress()
        print()  # Nouvelle ligne après la barre de progression
        
        if show_summary:
            self._print_summary()
    
    def _print_summary(self):
        """Affiche le résumé final."""
        total_time = time.time() - self.start_time
        total_time_str = str(timedelta(seconds=int(total_time)))
        
        print(f"\n{'='*60}")
        print(f"📊 RÉSUMÉ - {self.description}")
        print(f"{'='*60}")
        print(f"⏱️  Temps total: {total_time_str}")
        
        if self.total > 0:
            success_percent = (self.successful / self.total) * 100
            failed_percent = (self.failed / self.total) * 100
            print(f"✅ Réussis: {self.successful} ({success_percent:.1f}%)")
            print(f"❌ Échoués: {self.failed} ({failed_percent:.1f}%)")
        else:
            print(f"✅ Réussis: {self.successful}")
            print(f"❌ Échoués: {self.failed}")
        
        print(f"{'='*60}")

# =============================================================================
# Fonction standalone pour compatibilité
# =============================================================================
def print_progress(completed: int, total: int, successful: int, failed: int, elapsed_time: float):
    """
    Affiche une barre de progression (fonction standalone pour compatibilité).
    
    Args:
        completed: Nombre d'éléments complétés
        total: Nombre total d'éléments
        successful: Nombre d'éléments réussis
        failed: Nombre d'éléments échoués
        elapsed_time: Temps écoulé en secondes
    """
    if total == 0:
        percentage = 0
    else:
        percentage = (completed / total) * 100
    
    bar_length = 40
    filled = int(bar_length * completed / total)
    if filled > bar_length:
        filled = bar_length
    bar = '█' * filled + '░' * (bar_length - filled)
    
    # Estimation du temps restant
    if completed > 0:
        avg_time_per_item = elapsed_time / completed
        remaining = total - completed
        estimated_remaining = avg_time_per_item * remaining
        eta = str(timedelta(seconds=int(estimated_remaining)))
        elapsed_str = str(timedelta(seconds=int(elapsed_time)))
        time_info = f"⏱️  {elapsed_str} écoulé | ~{eta} restant"
    else:
        time_info = "⏱️  Calcul en cours..."
    
    # Statistiques
    stats = f"✅ {successful} | ❌ {failed}"
    
    # Afficher la barre de progression
    sys.stdout.write(f"\r[{completed}/{total}] {percentage:.1f}% |{bar}| {stats} | {time_info}")
    sys.stdout.flush()

# =============================================================================
# Exemple d'utilisation
# =============================================================================
if __name__ == '__main__':
    # Exemple 1: Utilisation avec la classe ProgressBar
    print("Exemple 1: Utilisation avec ProgressBar")
    progress = ProgressBar(100, "Test de progression")
    
    for i in range(1, 101):
        time.sleep(0.05)  # Simuler un traitement
        success = (i % 2 == 0)
        progress.increment(successful=success)
    
    progress.finish()
    
    print("\n" + "="*60 + "\n")
    
    # Exemple 2: Utilisation avec la fonction standalone
    print("Exemple 2: Utilisation avec print_progress (standalone)")
    start_time = time.time()
    total = 50
    
    for i in range(1, 51):
        time.sleep(0.05)
        elapsed = time.time() - start_time
        successful = i // 2
        failed = i - successful
        print_progress(i, total, successful, failed, elapsed)
    
    print()  # Nouvelle ligne
    print(f"✅ Terminé en {timedelta(seconds=int(time.time() - start_time))}")

