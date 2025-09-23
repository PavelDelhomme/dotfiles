ports() {
  echo "📡 Ports en écoute actuellement :"
  echo
  sudo lsof -i -P -n | grep LISTEN | \
  awk '{printf "%-10s %-20s %-8s %-12s %s\n", $9, $1, $2, $3, $0}' | \
  sed 's/.*://g' | sort -n | \
  awk 'BEGIN{printf "%-10s %-20s %-8s %-12s %s\n", "PORT", "CMD", "PID", "USER", "LIGNE_COMPLETE"} {print}'
}

