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
    # Ordre: 11 (idéal) → 8 → 17. Jamais le java PATH (souvent 27).
    for cand in \
        /usr/lib/jvm/java-11-openjdk/bin/java \
        /usr/lib/jvm/java-8-openjdk/jre/bin/java \
        /usr/lib/jvm/java-8-openjdk/bin/java \
        /usr/lib/jvm/java-17-openjdk/bin/java; do
        if [ -x "$cand" ]; then
            printf '%s\n' "$cand"
            return 0
        fi
    done
    return 1
}

JAVA_BIN="$(pick_java)" || {
    echo "Aucun Java 8/11/17 trouvé (requis: java.applet.Applet)." >&2
    echo "  sudo pacman -S jdk11-openjdk" >&2
    echo "  Ne pas lancer avec /usr/bin/java (Java 27 casse CGoban)." >&2
    exit 1
}

exec "$JAVA_BIN" -jar "$JAR" "$@"
