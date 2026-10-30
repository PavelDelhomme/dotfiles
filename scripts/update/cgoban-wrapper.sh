#!/usr/bin/env bash
# Lance CGoban avec un JDK qui possède java.applet.Applet.
# Java 27 (défaut Arch) plante: NoClassDefFoundError: java/applet/Applet
set -euo pipefail

JAR="${CGOBAN_OPT_JAR:-/opt/cgoban.jar}"
if [ ! -f "$JAR" ]; then
    echo "CGoban absent: $JAR — lance: installman cgoban" >&2
    exit 1
fi

pick_java() {
    if [ -n "${CGOBAN_JAVA:-}" ] && [ -x "${CGOBAN_JAVA}" ]; then
        printf '%s\n' "$CGOBAN_JAVA"
        return 0
    fi
    local cand
    # Forcé: Java 21 (Applet OK sur Arch). Fallback 17/11/8. Jamais le java PATH (27).
    for cand in \
        /usr/lib/jvm/java-21-openjdk/bin/java \
        /usr/lib/jvm/java-17-openjdk/bin/java \
        /usr/lib/jvm/java-11-openjdk/bin/java \
        /usr/lib/jvm/java-8-openjdk/jre/bin/java \
        /usr/lib/jvm/java-8-openjdk/bin/java; do
        if [ -x "$cand" ]; then
            printf '%s\n' "$cand"
            return 0
        fi
    done
    return 1
}

JAVA_BIN="$(pick_java)" || {
    echo "Aucun Java 21/17/11/8 trouvé (requis: java.applet.Applet)." >&2
    echo "  sudo pacman -S jdk21-openjdk" >&2
    echo "  Ne pas lancer avec /usr/bin/java (Java 27 casse CGoban)." >&2
    exit 1
}

exec "$JAVA_BIN" -jar "$JAR" "$@"
