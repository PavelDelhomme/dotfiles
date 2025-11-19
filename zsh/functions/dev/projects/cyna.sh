#!/bin/zsh

run_cyna () {
  # 1) Le sous-dossier qui contient docker-compose.yml
  local proj_dir="$HOME/Documents/Dev/Travail/SupDeVinci/CYNA/cyna_backend/cyna_backend"
  
  # 2) On y va
  cd "$proj_dir" || { echo "❌ Impossible de trouver $proj_dir"; return 1; }
  
  # 3) On (re)démarre en arrière-plan
  echo "⚙️  docker compose up -d"
  docker compose up -d
  
  # 4) On attend un peu que le conteneur soit bien healthy
  echo "⏳ Attente 5s pour que tout soit prêt…"
  sleep 5
  
  # 5) On suit les logs du conteneur nommé cyna_backend
  echo "📖 Affichage des logs de 'cyna_backend'"
  docker logs -f cyna_backend
}

cyna_push_back () {
  docker build -t paveldelhomme/cyna_backend:latest ./cyna_backend
  docker push paveldelhomme/cyna_backend:latest
}

cyna_push_front() {
  docker build -t paveldelhomme/cyna_frontend:latest ./cyna_front/cyna_front
  docker push paveldelhomme/cyna_front:latest
}

