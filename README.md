# 🌐 Hosting Da Vinci GT

Proyecto Final — **Redes de Datos 1**  
Universidad Da Vinci de Guatemala

Servidor de hosting web completo sobre **Ubuntu 24.04 LTS en Microsoft Azure**, con servicios HTTP, FTP, DNS y SSH, y un cPanel personalizado desarrollado en PHP.

---

## 📋 Descripción

Sistema de hosting multi-usuario con 5 sitios web temáticos, administrados mediante un panel de control (cPanel) propio. El proyecto implementa los principales servicios de red vistos en el curso.

---

## 🖥️ Servidor

| Campo | Valor |
|---|---|
| Proveedor | Microsoft Azure |
| OS | Ubuntu 24.04 LTS |
| IP Pública | 4.205.13.148 |
| VM | MVHOSTINGUDV |
| Usuario admin | udvhost |

---

## 👥 Usuarios del Hosting

| Usuario | Sitio | Dominio |
|---|---|---|
| eamperez | CloudNova | cloudnova.local |
| gjuarez | InfraTech | infratech.local |
| cpatricio | DataSphere | datasphere.local |
| fcalderon | NexusHost | nexushost.local |
| crodas | TechIDE | techide.local |

---

## 🌍 URLs de Acceso

| URL | Sitio | Usuario |
|---|---|---|
| http://4.205.13.148 | cPanel | login |
| http://4.205.13.148/cloudnova/ | CloudNova | eamperez |
| http://4.205.13.148/infratech/ | InfraTech | gjuarez |
| http://4.205.13.148/datasphere/ | DataSphere | cpatricio |
| http://4.205.13.148/nexushost/ | NexusHost | fcalderon |
| http://4.205.13.148/techide/ | TechIDE | crodas |

---

## ⚙️ Servicios Configurados

| Servicio | Daemon | Puerto | Descripción |
|---|---|---|---|
| HTTP | Apache2 | 80/tcp | Servidor web principal |
| FTP | vsftpd | 21/tcp | Transferencia de archivos (PASV 40000-50000) |
| DNS | BIND9 | 53/udp | Zona hosting.local |
| SSH | OpenSSH | 22/tcp | Administración remota |
| Firewall | UFW | — | Puertos 22,80,21,53,40000-50000 |

---

## 📁 Estructura del Repositorio

```
hosting-davinci-gt/
├── README.md                      # Este archivo
├── scripts/
│   ├── setup_hosting.sh           # Instala servicios base (Apache, FTP, DNS, SSH)
│   └── install_cpanel.sh          # Instala cPanel + 5 sitios web
├── sites/
│   ├── cloudnova/index.html       # Sitio CloudNova (eamperez)
│   ├── infratech/index.html       # Sitio InfraTech (gjuarez)
│   ├── datasphere/index.html      # Sitio DataSphere (cpatricio)
│   ├── nexushost/index.html       # Sitio NexusHost (fcalderon)
│   └── techide/index.html         # Sitio TechIDE (crodas)
├── cpanel/
│   └── index.php                  # Panel de control cPanel
└── config/
    ├── apache/
    │   └── 000-cpanel.conf        # VirtualHost Apache
    ├── vsftpd/
    │   └── vsftpd.conf            # Configuracion FTP
    └── dns/
        └── db.hosting.local       # Zona DNS BIND9
```

---

## 🚀 Instalación

### Requisitos
- Ubuntu 24.04 LTS
- Acceso root o sudo
- Conexión a internet

### Paso 1 — Infraestructura base

```bash
sudo bash scripts/setup_hosting.sh
```

Instala y configura: Apache2, PHP, vsftpd, BIND9, OpenSSH, UFW y los 5 usuarios del hosting.

### Paso 2 — cPanel y sitios web

```bash
sudo bash scripts/install_cpanel.sh
```

Instala las 5 páginas HTML temáticas, configura Apache con symlinks y despliega el cPanel con Editor HTML.

---

## 🎛️ Funciones del cPanel

- **Dashboard** — Estado del hosting y accesos rápidos
- **Gestor de Archivos** — Subir, bajar, crear y eliminar archivos
- **Editor HTML** — Editor con vista previa en vivo del sitio
- **Mi Sitio** — Preview iframe + botón Abrir en Navegador
- **Mi Cuenta** — Datos FTP y dominio asignado
- **Servicios** — Estado de HTTP, FTP, DNS, SSH y tabla de sitios

---

## 🏗️ Arquitectura

```
Internet
    |
    v
[Azure VM - Ubuntu 24.04]
    |
    +-- Apache2 (puerto 80)
    |       |
    |       +-- /var/www/html/index.php        (cPanel)
    |       +-- /var/www/html/cloudnova  -->   symlink
    |       +-- /var/www/html/infratech  -->   symlink
    |       +-- /var/www/html/datasphere -->   symlink
    |       +-- /var/www/html/nexushost  -->   symlink
    |       +-- /var/www/html/techide    -->   symlink
    |
    +-- vsftpd  (puerto 21 + PASV 40000-50000)
    +-- BIND9   (puerto 53 - zona hosting.local)
    +-- OpenSSH (puerto 22)
    +-- UFW     (firewall)
```

---

## 📝 Notas Técnicas

- Los symlinks se usan en lugar de `mod_alias` porque el módulo no funciona correctamente en esta configuración de VM
- Todos los archivos de configuración se instalan desde base64 para evitar corrupción de caracteres especiales
- El cPanel es PHP puro sin frameworks externos
- El Editor HTML guarda directamente en `public_html/index.html` del usuario

---

## 👨‍💻 Autor

**Eddy Alexander Amperez Carranza**  
Carnet: eamperez  
Universidad Da Vinci de Guatemala  
Curso: Redes de Datos 1  
Año: 2026
