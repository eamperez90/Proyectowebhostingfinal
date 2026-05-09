#!/bin/bash
# ================================================================
#  setup_hosting.sh - Hosting Da Vinci GT
#  Universidad Da Vinci de Guatemala - Redes de Datos 1
#  Servidor: Ubuntu 24.04 LTS en Azure - IP: 4.205.13.148
#
#  Instala y configura:
#    - Apache2 (HTTP puerto 80)
#    - vsftpd  (FTP  puerto 21)
#    - BIND9   (DNS  puerto 53)
#    - OpenSSH (SSH  puerto 22)
#    - UFW     (firewall)
#    - 5 usuarios del hosting
#
#  NOTA: Para el cPanel web ejecuta install_cpanel.sh despues
#  Uso: sudo bash setup_hosting.sh
# ================================================================
set -e
GR='\033[0;32m'; BL='\033[0;34m'; YL='\033[1;33m'; NC='\033[0m'
log()  { echo -e "${GR}[OK]${NC} $1"; }
info() { echo -e "${BL}[..]${NC} $1"; }
warn() { echo -e "${YL}[!!]${NC} $1"; }
[ "$EUID" -ne 0 ] && echo "ERROR: sudo bash setup_hosting.sh" && exit 1

echo ""
echo "================================================================"
echo "  setup_hosting.sh - Da Vinci GT"
echo "  Ubuntu 24.04 LTS en Azure | IP: 4.205.13.148"
echo "================================================================"
echo ""

# ── 1. Instalar paquetes ─────────────────────────────────────────
info "Instalando paquetes del sistema..."
DEBIAN_FRONTEND=noninteractive apt-get update -qq 2>/dev/null
DEBIAN_FRONTEND=noninteractive apt-get install -y -qq \
    apache2 php libapache2-mod-php php-curl php-mbstring php-xml \
    vsftpd bind9 bind9utils openssh-server ufw curl 2>/dev/null
a2enmod php8.3  2>/dev/null || true
a2enmod rewrite 2>/dev/null || true
PHP_INI=$(find /etc/php -name "php.ini" -path "*/apache2/*" 2>/dev/null | head -1)
[ -f "$PHP_INI" ] && sed -i "s/upload_max_filesize = .*/upload_max_filesize = 64M/" "$PHP_INI"
[ -f "$PHP_INI" ] && sed -i "s/post_max_size = .*/post_max_size = 64M/" "$PHP_INI"
log "Paquetes instalados: Apache2, PHP, vsftpd, BIND9, SSH, UFW"

# ── 2. Usuarios del sistema ──────────────────────────────────────
info "Creando usuarios del hosting..."
for USR in eamperez gjuarez cpatricio fcalderon crodas; do
    id $USR &>/dev/null || useradd -m -s /bin/bash $USR
done
echo "eamperez:Emp@2024#Sec1"   | chpasswd
echo "gjuarez:Jua%2024#Net2"    | chpasswd
echo "cpatricio:Pat!2024#Sys3"  | chpasswd
echo "fcalderon:Cal*2024#Dev4"  | chpasswd
echo "crodas:Rod#2024@Tech5"    | chpasswd
log "Usuarios creados"

# ── 3. Directorios web ───────────────────────────────────────────
info "Creando estructura de directorios..."
for F in cloudnova infratech datasphere nexushost techide; do
    mkdir -p /var/www/$F/public_html /var/www/$F/logs
    chown -R www-data:www-data /var/www/$F/
    chmod -R 777 /var/www/$F/
done
chmod 1777 /tmp
usermod -d /var/www/cloudnova/public_html  eamperez  2>/dev/null || true
usermod -d /var/www/infratech/public_html  gjuarez   2>/dev/null || true
usermod -d /var/www/datasphere/public_html cpatricio 2>/dev/null || true
usermod -d /var/www/nexushost/public_html  fcalderon 2>/dev/null || true
usermod -d /var/www/techide/public_html    crodas    2>/dev/null || true
log "Directorios creados"

# ── 4. Apache base (sin sitios, los instala install_cpanel.sh) ───
info "Configurando Apache base..."
rm -f /var/www/html/index.html /var/www/html/index.php
cat > /etc/apache2/sites-available/000-default.conf << 'AEOF'
<VirtualHost *:80>
    ServerName 4.205.13.148
    DocumentRoot /var/www/html
    DirectoryIndex index.php index.html
    <Directory /var/www/html>
        Options FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>
</VirtualHost>
AEOF
a2ensite 000-default 2>/dev/null || true
systemctl restart apache2
log "Apache base configurado"

# ── 5. FTP vsftpd ────────────────────────────────────────────────
info "Configurando FTP..."
echo "bGlzdGVuPVlFUwpsaXN0ZW5faXB2Nj1OTwphbm9ueW1vdXNfZW5hYmxlPU5PCmxvY2FsX2VuYWJsZT1ZRVMKd3JpdGVfZW5hYmxlPVlFUwpsb2NhbF91bWFzaz0wMjIKY2hyb290X2xvY2FsX3VzZXI9WUVTCmFsbG93X3dyaXRlYWJsZV9jaHJvb3Q9WUVTCnVzZXJsaXN0X2VuYWJsZT1ZRVMKdXNlcmxpc3RfZmlsZT0vZXRjL3ZzZnRwZC51c2VybGlzdAp1c2VybGlzdF9kZW55PU5PCnBhc3ZfZW5hYmxlPVlFUwpwYXN2X21pbl9wb3J0PTQwMDAwCnBhc3ZfbWF4X3BvcnQ9NTAwMDAKcGFzdl9hZGRyZXNzPTQuMjA1LjEzLjE0OA==" | base64 -d > /etc/vsftpd.conf
for USR in eamperez gjuarez cpatricio fcalderon crodas; do
    grep -q "$USR" /etc/vsftpd.userlist 2>/dev/null || echo "$USR" >> /etc/vsftpd.userlist
done
systemctl restart vsftpd
systemctl enable vsftpd 2>/dev/null
log "FTP vsftpd configurado en puerto 21"

# ── 6. DNS BIND9 ─────────────────────────────────────────────────
info "Configurando DNS BIND9..."
echo "em9uZSAiaG9zdGluZy5sb2NhbCIgewogICAgdHlwZSBtYXN0ZXI7CiAgICBmaWxlICIvZXRjL2JpbmQvem9uZXMvZGIuaG9zdGluZy5sb2NhbCI7Cn07" | base64 -d > /etc/bind/named.conf.local
mkdir -p /etc/bind/zones
echo "JFRUTCA2MDQ4MDAKQCAgIElOICBTT0EgbnMxLmhvc3RpbmcubG9jYWwuIGFkbWluLmhvc3RpbmcubG9jYWwuICgKICAgIDIwMjQwMTAxMDEgNjA0ODAwIDg2NDAwIDI0MTkyMDAgNjA0ODAwICkKQCAgICAgICAgICAgSU4gIE5TICBuczEuaG9zdGluZy5sb2NhbC4KbnMxICAgICAgICAgSU4gIEEgICA0LjIwNS4xMy4xNDgKY2xvdWRub3ZhICAgSU4gIEEgICA0LjIwNS4xMy4xNDgKaW5mcmF0ZWNoICAgSU4gIEEgICA0LjIwNS4xMy4xNDgKZGF0YXNwaGVyZSAgSU4gIEEgICA0LjIwNS4xMy4xNDgKbmV4dXNob3N0ICAgSU4gIEEgICA0LjIwNS4xMy4xNDgKdGVjaGlkZSAgICAgSU4gIEEgICA0LjIwNS4xMy4xNDg=" | base64 -d > /etc/bind/zones/db.hosting.local
chown -R bind:bind /etc/bind/zones 2>/dev/null || chown -R root:bind /etc/bind/zones 2>/dev/null || true
chmod 644 /etc/bind/zones/db.hosting.local
systemctl enable named --force 2>/dev/null || true
systemctl restart named 2>/dev/null || systemctl restart bind9 2>/dev/null || true
log "DNS BIND9 configurado (zona hosting.local)"

# ── 7. SSH ───────────────────────────────────────────────────────
info "Configurando SSH..."
sed -i "s/^#PermitRootLogin.*/PermitRootLogin no/" /etc/ssh/sshd_config
sed -i "s/^PasswordAuthentication no/PasswordAuthentication yes/" /etc/ssh/sshd_config
sed -i "s/^#PasswordAuthentication.*/PasswordAuthentication yes/" /etc/ssh/sshd_config
systemctl restart ssh
systemctl enable ssh 2>/dev/null
log "SSH configurado en puerto 22 (root deshabilitado)"

# ── 8. Firewall UFW ──────────────────────────────────────────────
info "Configurando firewall UFW..."
ufw --force reset    2>/dev/null
ufw default deny incoming  2>/dev/null
ufw default allow outgoing 2>/dev/null
ufw allow 22/tcp   comment "SSH"   2>/dev/null
ufw allow 80/tcp   comment "HTTP"  2>/dev/null
ufw allow 21/tcp   comment "FTP"   2>/dev/null
ufw allow 53       comment "DNS"   2>/dev/null
ufw allow 40000:50000/tcp comment "FTP Pasivo" 2>/dev/null
ufw --force enable 2>/dev/null
log "Firewall UFW activo (22,80,21,53,40000-50000)"

# ── 9. Habilitar servicios al inicio ─────────────────────────────
systemctl enable apache2 vsftpd ssh 2>/dev/null
log "Servicios habilitados al inicio"

# ── Resumen ──────────────────────────────────────────────────────
echo ""
echo "================================================================"
echo "  SETUP COMPLETADO"
echo ""
echo "  SERVICIOS ACTIVOS:"
echo "  HTTP   Apache2    puerto 80"
echo "  FTP    vsftpd     puerto 21  (pasivo 40000-50000)"
echo "  DNS    BIND9      puerto 53  (zona hosting.local)"
echo "  SSH    OpenSSH    puerto 22"
echo ""
echo "  USUARIOS:"
echo "  eamperez  / Emp@2024#Sec1  -> cloudnova.local"
echo "  gjuarez   / Jua%2024#Net2  -> infratech.local"
echo "  cpatricio / Pat!2024#Sys3  -> datasphere.local"
echo "  fcalderon / Cal*2024#Dev4  -> nexushost.local"
echo "  crodas    / Rod#2024@Tech5 -> techide.local"
echo ""
echo "  SIGUIENTE PASO:"
echo "  sudo bash install_cpanel.sh"
echo "================================================================"
