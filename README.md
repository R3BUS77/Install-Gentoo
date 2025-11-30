# Gentoo Installer Script 🚀

[![GitHub license](https://img.shields.io/github/license/Naereen/StrapDown.js.svg)](https://github.com/Naereen/StrapDown.js/blob/master/LICENSE)
[![GitHub stars](https://img.shields.io/github/stars/badges/shields.svg?style=social&label=Star&maxAge=2592000)](https://GitHub.com/Naereen/StrapDown.js/stargazers/)

Benvenuti nel **Gentoo Installer Script**! Questo tool open-source semplifica l'installazione di Gentoo Linux su hardware moderno, con un focus su facilità d'uso e personalizzazione.  
*Welcome to the **Gentoo Installer Script**! This open-source tool streamlines the installation of Gentoo Linux on modern hardware, emphasizing ease of use and customization.*

Ispirato al Gentoo Handbook ufficiale, automatizza i passaggi noiosi per farti partire in fretta.  
*Inspired by the official Gentoo Handbook, it automates the tedious steps to get you up and running quickly.*

Perfetto per appassionati di Linux che vogliono un'installazione pulita e performante! 💻✨  
*Ideal for Linux enthusiasts seeking a clean and high-performance setup! 💻✨*

## Funzionalità Principali  
## *Key Features*

- **Automazione Completa**: Partizionamento disco, download stage3, configurazione OpenRC, GRUB UEFI e altro – tutto in uno script! 🔧  
  *- **Full Automation**: Disk partitioning, stage3 download, OpenRC configuration, GRUB UEFI and more – all in one script! 🔧*

- **Personalizzazione Utente**: Richiede password root, nome utente e password per un setup sicuro e personalizzato. 🔒  
  *- **User Customization**: Prompts for root password, username, and password for a secure and personalized setup. 🔒*

- **Supporto Linguistico**: Tastiera e locale in italiano, fuso orario Europe/Rome. 🇮🇹  
  *- **Language Support**: Italian keyboard and locale, Europe/Rome timezone. 🇮🇹*

- **Layout Disco Ottimizzato**: EFI (1GB), Swap (8GB), Root (resto) su NVMe. 📊  
  *- **Optimized Disk Layout**: EFI (1GB), Swap (8GB), Root (remaining) on NVMe. 📊*

- **Verifica Integrità**: Download e verifica automatica del tarball stage3 per sicurezza. ✅  
  *- **Integrity Check**: Automatic download and verification of the stage3 tarball for security. ✅*

- **Strumenti Base Inclusi**: Kernel precompilato, firmware, logger, cron e NTP pronti all'uso. 🛠️  
  *- **Basic Tools Included**: Precompiled kernel, firmware, logger, cron, and NTP ready to use. 🛠️*

## Requisiti  
## *Requirements*

- Ambiente live Gentoo (es. ISO minimal bootata da USB/CD). 🖥️  
  *- Gentoo live environment (e.g., minimal ISO booted from USB/CD). 🖥️*

- Connessione internet (DHCP automatico; configura manualmente se necessario). 🌐  
  *- Internet connection (automatic DHCP; configure manually if needed). 🌐*

- Disco NVMe (/dev/nvme0n1) – **ATTENZIONE: Lo script cancellerà TUTTI i dati sul disco!** ⚠️  
  *- NVMe disk (/dev/nvme0n1) – **WARNING: The script will erase ALL data on the disk!** ⚠️*

- Esegui come root.  
  *- Run as root.*

## Utilizzo  
## *Usage*

1. Scarica o crea il file `install_gentoo.sh`. 📥  
   *1. Download or create the file `install_gentoo.sh`. 📥*

2. Rendilo eseguibile: `chmod +x install_gentoo.sh`. 🔑  
   *2. Make it executable: `chmod +x install_gentoo.sh`. 🔑*

3. Esegui: `./install_gentoo.sh`. ▶️  
   *3. Run: `./install_gentoo.sh`. ▶️*

4. Inserisci password root, nome utente e password utente quando richiesto. 📝  
   *4. Enter root password, username, and user password when prompted. 📝*

5. Lo script gestirà partizionamento, installazione e configurazione – poi riavvierà automaticamente. 🔄  
   *5. The script will handle partitioning, installation, and configuration – then reboot automatically. 🔄*

6. Dopo il reboot, rimuovi il media live e goditi Gentoo! 🎉  
   *6. After reboot, remove the live media and enjoy Gentoo! 🎉*

**Esempio di Output durante l'Esecuzione**  
***Sample Output During Execution:***

```
=== Richiesta informazioni utente ===  
Inserisci la password per root:
Inserisci il nome utente da creare: mio_utente
Inserisci la password per l'utente mio_utente:

=== *User Information Request* ===
*Enter the password for root:* 
*Enter the username to create: my_user*
*Enter the password for the user my_user:* 
```

## Layout del Disco  
## *Disk Layout*

- **EFI**: 1GB (/dev/nvme0n1p1, vfat) – Per il boot UEFI. 🥾  
  *- **EFI**: 1GB (/dev/nvme0n1p1, vfat) – For UEFI boot. 🥾*

- **Swap**: 8GB (/dev/nvme0n1p2, swap) – Per la gestione memoria. 💾  
  *- **Swap**: 8GB (/dev/nvme0n1p2, swap) – For memory management. 💾*

- **Root**: Spazio rimanente (/dev/nvme0n1p3, ext4) – Il cuore del sistema. 🏠  
  *- **Root**: Remaining space (/dev/nvme0n1p3, ext4) – The core of the system. 🏠*

## Risoluzione Problemi  
## *Troubleshooting*

- **Problemi di Rete?** Configura manualmente prima di eseguire (es. `dhcpcd eth0`). 📡  
  *- **Network Issues?** Configure manually before running (e.g., `dhcpcd eth0`). 📡*

- **Personalizzazioni?** Modifica lo script per dimensioni partizioni, profili o pacchetti extra. ✏️  
  *- **Customizations?** Edit the script for partition sizes, profiles, or extra packages. ✏️*

- **Errori?** Consulta il [Gentoo Handbook](https://wiki.gentoo.org/wiki/Handbook:AMD64) per passi manuali. 📖  
  *- **Errors?** Consult the [Gentoo Handbook](https://wiki.gentoo.org/wiki/Handbook:AMD64) for manual steps. 📖*

- Per issues, apri una Issue su GitHub! 🐛  
  *- For issues, open an Issue on GitHub! 🐛*

## Ispirazione  
## *Inspiration*

Basato sul [Gentoo Handbook AMD64](https://wiki.gentoo.org/wiki/Handbook:AMD64). Un grazie alla community Gentoo per le risorse eccellenti! 🙌  
*Based on the [Gentoo Handbook AMD64](https://wiki.gentoo.org/wiki/Handbook:AMD64). Thanks to the Gentoo community for the excellent resources! 🙌*

## Licenza  
## *License*

Questo progetto è sotto licenza MIT – vedi il file [LICENSE](LICENSE) per dettagli.  
*This project is under the MIT license – see the [LICENSE](LICENSE) file for details.*

**Contribuisci!** Forka, modifica e invia una Pull Request. Insieme rendiamo Gentoo più accessibile! 🤝  
***Contribute!** Fork, edit, and submit a Pull Request. Together, let's make Gentoo more accessible! 🤝*
