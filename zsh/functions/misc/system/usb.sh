# DESC: Teste la vraie capacité d'une clé USB en écrivant et vérifiant des données. ATTENTION: Efface toutes les données du périphérique!
# USAGE: test-usb-capacity <device>
# EXAMPLE: test-usb-capacity /dev/sdb
test-usb-capacity() {
    if [ $# -lt 1 ]; then
        echo "Usage: test-usb-capacity <device>"
        echo "Exemple: test-usb-capacity /dev/sdb"
        echo ""
        echo "⚠️  ATTENTION: Ceci va EFFACER toutes les données du périphérique!"
        return 1
    fi

    local device="$1"

    if [ ! -b "$device" ]; then
        echo "❌ Erreur: $device n'est pas un périphérique bloc valide"
        return 1
    fi

    echo "🔍 Test de capacité réelle pour: $device"
    echo ""

    # Afficher infos device
    echo "📊 Informations du périphérique:"
    sudo fdisk -l "$device" | grep "Disk $device"
    echo ""

    read -p "⚠️  Continuer? Toutes les données seront EFFACÉES! (tapez OUI): " confirm
    if [ "$confirm" != "OUI" ]; then
        echo "❌ Test annulé"
        return 1
    fi

    echo ""
    echo "🧪 Test en cours..."
    echo "1️⃣  Écriture de données aléatoires sur tout le périphérique..."

    # Utiliser f3write (à installer: sudo pacman -S f3)
    if command -v f3write >/dev/null 2>&1; then
        # Monter le périphérique
        local mount_point="/tmp/usb_test_$$"
        mkdir -p "$mount_point"
        sudo mount "${device}1" "$mount_point" 2>/dev/null || {
            echo "⚠️  Formatage nécessaire..."
            sudo mkfs.vfat -F 32 "${device}1"
            sudo mount "${device}1" "$mount_point"
        }

        echo "✍️  Écriture..."
        f3write "$mount_point"

        echo ""
        echo "2️⃣  Vérification des données écrites..."
        f3read "$mount_point"

        sudo umount "$mount_point"
        rmdir "$mount_point"
    else
        echo "❌ f3write/f3read non installé"
        echo "Installation: sudo pacman -S f3"
        echo ""
        echo "Alternative rapide avec dd (moins précis):"
        echo "  sudo dd if=/dev/zero of=$device bs=1M status=progress"
    fi

    echo ""
    echo "✅ Test terminé!"
}

# DESC: Vérifie rapidement la taille annoncée d'une clé USB et affiche les informations des partitions.
# USAGE: check-usb-size <device>
# EXAMPLE: check-usb-size /dev/sdb
check-usb-size() {
    if [ $# -lt 1 ]; then
        echo "Usage: check-usb-size /dev/sdX"
        return 1
    fi

    local device="$1"

    echo "📊 Taille annoncée:"
    sudo fdisk -l "$device" | grep "Disk $device"

    echo ""
    echo "📊 Partitions:"
    lsblk "$device"

    echo ""
    echo "💡 Pour un test complet: test-usb-capacity $device"
}
