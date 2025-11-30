#!/bin/bash

# =============================================================================
# Gentoo Linux Installation Script
# =============================================================================
# Sistema operativo : Gentoo Linux (OpenRC)
# Architettura      : amd64
# Boot mode         : UEFI
# Init system       : OpenRC
# Lingua            : Italiano (it_IT.UTF-8)
# Fuso orario       : Europe/Rome
# Partizionamento   : Personalizzabile dall'utente (EFI + Swap + Root)
# Disco             : Scelto dall'utente (es. /dev/nvme0n1, /dev/sda)
# Conferma distruzione disco: singola lettera "S" (maiuscola)
#
# ATTENZIONE: Questo script cancella COMPLETAMENTE tutti i dati sul disco selezionato.
#             Non è possibile alcun recupero dopo l'avvio del partizionamento.
#
# Testato sulla Gentoo Minimal Installation CD (live environment)
# =============================================================================

set -e

function messaggio {
    echo -e "\n=== $1 ==="
}

# ────────────────────────────── SELEZIONE DISCO ──────────────────────────────
messaggio "Selezione del disco di installazione"
read -p "Inserisci il dispositivo disco (es. /dev/nvme0n1, /dev/sda): " DISK

if [ ! -b "$DISK" ]; then
    echo "ERRORE: $DISK non esiste o non è un dispositivo a blocchi valido."
    exit 1
fi

echo -e "\n!!! ATTENZIONE !!!"
echo "   Tutti i dati presenti su $DISK saranno cancellati in modo irreversibile."
read -p "   Digita la lettera S (maiuscola) per confermare e proseguire: " CONFERMA
if [ "$CONFERMA" != "S" ]; then
    echo "Operazione annullata dall'utente."
    exit 0
fi

# Prefisso partizioni
if [[ $DISK == *nvme* ]]; then
    PART_PREFIX="${DISK}p"
else
    PART_PREFIX="$DISK"
fi

# ────────────────────────────── DIMENSIONI PARTIZIONI ──────────────────────────────
messaggio "Configurazione dimensioni partizioni"
read -p "Dimensione partizione EFI (es. 512M, 1G) [default: 1G]: " EFI_SIZE
EFI_SIZE=${EFI_SIZE:-1G}

read -p "Dimensione partizione swap (es. 8G, 16G) [default: 8G]: " SWAP_SIZE
SWAP_SIZE=${SWAP_SIZE:-8G}

# ────────────────────────────── CREDENZIALI UTENTE ──────────────────────────────
messaggio "Impostazione credenziali"
read -p "Password per l'utente root: " -s ROOT_PASSWORD; echo
read -p "Nome utente da creare: " USER_NAME
read -p "Password per l'utente $USER_NAME: " -s USER_PASSWORD; echo

# ────────────────────────────── AMBIENTE LIVE ──────────────────────────────
messaggio "Configurazione ambiente live"
loadkeys it
export LANG=it_IT.UTF-8

# ────────────────────────────── CONNESSIONE DI RETE ──────────────────────────────
messaggio "Configurazione rete"
echo "Avvio client DHCP..."
dhcpcd -q -w

messaggio "Verifica connessione internet"
for i in {1..10}; do
    if ping -c 1 -W 3 8.8.8.8 &>/dev/null || ping -c 1 -W 3 1.1.1.1 &>/dev/null; then
        echo "Connessione internet stabilita."
        break
    else
        echo "Tentativo $i/10 fallito, nuovo tentativo tra 3 secondi..."
        sleep 3
    fi
done

if ! ping -c 1 -W 3 8.8.8.8 &>/dev/null; then
    echo "Connessione non rilevata automaticamente."
    echo "Configura manualmente se necessario (es. iwctl, nmtui, dhcpcd enp0s3...)"
    read -p "Premi INVIO quando hai internet funzionante..."
fi

# ────────────────────────────── PARTIZIONAMENTO CON PARTED (AFFIDABILE) ──────────────────────────────
messaggio "Partizionamento del disco $DISK con parted"

parted -s "$DISK" mklabel gpt

# Partizione EFI
parted -s "$DISK" mkpart primary fat32 1MiB "$EFI_SIZE"
parted -s "$DISK" set 1 esp on

# Partizione swap
END_EFI=$(parted -s "$DISK" unit MiB print | grep '^ 1 ' | awk '{print $3}' | sed 's/MiB//')
parted -s "$DISK" mkpart primary linux-swap "${END_EFI}MiB" "$((END_EFI + $(echo $SWAP_SIZE | sed 's/G//')) )GiB"

# Partizione root (tutto il resto)
parted -s "$DISK" mkpart primary ext4 "$((END_EFI + $(echo $SWAP_SIZE | sed 's/G//')) )GiB" 100%

# Attesa e rilettura partizioni
sleep 3
partprobe "$DISK" 2>/dev/null || true
blockdev --rereadpt "$DISK" 2>/dev/null || true
sleep 2

# Verifica esistenza partizioni
if [ ! -b "${PART_PREFIX}1" ] || [ ! -b "${PART_PREFIX}2" ] || [ ! -b "${PART_PREFIX}3" ]; then
    echo "ERRORE: Una o più partizioni non sono state create correttamente."
    ls -l /dev/${PART_PREFIX}* 2>/dev/null || echo "Nessuna partizione trovata"
    exit 1
fi

echo "Partizionamento completato con successo:"
echo "   EFI  → ${PART_PREFIX}1  ($EFI_SIZE)"
echo "   Swap → ${PART_PREFIX}2  ($SWAP_SIZE)"
echo "   Root → ${PART_PREFIX}3  (resto del disco)"

# ────────────────────────────── FORMATTAZIONE E MONTAGGIO ──────────────────────────────
messaggio "Formattazione delle partizioni"
mkfs.vfat -F 32 "${PART_PREFIX}1"
mkswap "${PART_PREFIX}2"
mkfs.ext4 -F "${PART_PREFIX}3"

messaggio "Attivazione swap"
swapon "${PART_PREFIX}2"

messaggio "Montaggio filesystem"
mkdir -p /mnt/gentoo
mount "${PART_PREFIX}3" /mnt/gentoo
mkdir -p /mnt/gentoo/efi
mount "${PART_PREFIX}1" /mnt/gentoo/efi

# ────────────────────────────── SINCRONIZZAZIONE ORA ──────────────────────────────
chronyd -q

# ────────────────────────────── DOWNLOAD STAGE3 ──────────────────────────────
messaggio "Download e verifica stage3 OpenRC"
cd /mnt/gentoo
wget -q https://distfiles.gentoo.org/releases/amd64/autobuilds/latest-stage3-amd64-openrc.txt
STAGE_FILE=$(grep -v '^#' latest-stage3-amd64-openrc.txt | head -1 | awk '{print $1}')
wget -c https://distfiles.gentoo.org/releases/amd64/autobuilds/"$STAGE_FILE"
wget -c https://distfiles.gentoo.org/releases/amd64/autobuilds/"$STAGE_FILE".DIGESTS.asc

# Verifica SHA512
grep -A1 SHA512 "$STAGE_FILE".DIGESTS.asc | grep -v '^--' | awk '{print $1 "  " basename}' | \
    sha512sum -c --quiet && echo "Verifica integrità stage3: OK"

messaggio "Estrazione stage3"
tar xpvf "$(basename "$STAGE_FILE")" --xattrs-include='*.*' --numeric-owner

# ────────────────────────────── PREPARAZIONE CHROOT ──────────────────────────────
cp --dereference /etc/resolv.conf /mnt/gentoo/etc/
mount --types proc /proc /mnt/gentoo/proc
mount --rbind /sys /mnt/gentoo/sys
mount --make-rslave /mnt/gentoo/sys
mount --rbind /dev /mnt/gentoo/dev
mount --make-rslave /mnt/gentoo/dev
mount --bind /run /mnt/gentoo/run
mount --make-slave /mnt/gentoo/run

# ────────────────────────────── CONFIGURAZIONE FINALE NEL CHROOT ──────────────────────────────
messaggio "Configurazione del sistema nel chroot"
chroot /mnt/gentoo /bin/bash <<CHROOT_EOF
source /etc/profile
export PS1="(chroot) \$PS1"

# fstab con UUID
blkid > /tmp/blkid_output
EFI_UUID=\$(grep ${PART_PREFIX}1 /tmp/blkid_output | grep -oP 'UUID="\K[^"]+')
SWAP_UUID=\$(grep ${PART_PREFIX}2 /tmp/blkid_output | grep -oP 'UUID="\K[^"]+')
ROOT_UUID=\$(grep ${PART_PREFIX}3 /tmp/blkid_output | grep -oP 'UUID="\K[^"]+')

cat > /etc/fstab <<FSTAB
UUID=\$EFI_UUID   /efi      vfat    defaults          0 2
UUID=\$SWAP_UUID  none      swap    sw                0 0
UUID=\$ROOT_UUID  /         ext4    noatime           0 1
FSTAB

echo 'USE="-systemd"' >> /etc/portage/make.conf
echo 'GENTOO_MIRRORS="https://distfiles.gentoo.org"' >> /etc/portage/make.conf

eselect profile set default/linux/amd64/23.0/desktop
emerge-webrsync
emerge --sync --quiet

echo "Europe/Rome" > /etc/timezone
ln -sf ../usr/share/zoneinfo/Europe/Rome /etc/localtime
echo "it_IT.UTF-8 UTF-8" >> /etc/locale.gen
locale-gen
eselect locale set it_IT.UTF-8
env-update && source /etc/profile

emerge --ask sys-kernel/gentoo-kernel-bin
emerge --ask sys-kernel/linux-firmware sys-firmware/intel-microcode sys-firmware/sof-firmware

echo 'GRUB_PLATFORMS="efi-64"' >> /etc/portage/make.conf
emerge --ask sys-boot/grub
grub-install --efi-directory=/efi
grub-mkconfig -o /boot/grub/grub.cfg

echo "root:$ROOT_PASSWORD" | chpasswd
useradd -m -G users,wheel,audio,video,usb "$USER_NAME"
echo "$USER_NAME:$USER_PASSWORD" | chpasswd

emerge --ask app-admin/sysklogd sys-process/cronie net-misc/chrony
rc-update add sysklogd default
rc-update add cronie default
rc-update add chronyd default

echo "Installazione Gentoo completata con successo!"
CHROOT_EOF

# ────────────────────────────── FINE E RIAVVIO ──────────────────────────────
messaggio "Smontaggio e riavvio del sistema"
cd /
umount -l /mnt/gentoo/dev{/shm,/pts,} 2>/dev/null || true
umount -R /mnt/gentoo
swapoff -a

echo
echo "======================================================================"
echo "Gentoo Linux installato con successo su $DISK"
echo "Rimuovi il supporto di installazione (USB/CD) prima del riavvio."
echo "======================================================================"
read -p "Premi INVIO per riavviare..."
reboot
