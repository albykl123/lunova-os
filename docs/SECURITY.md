# Lunova OS Security Architecture & Policies

Security, reliability, and privacy are primary engineering requirements in Lunova OS.

---

## 1. Core Security Principles

### Credential Safety
- **No Hardcoded Passwords:** There are no baked-in credentials or default passwords in installed installations.
- **Live Session Isolation:** The live user (`live`) is strictly restricted to disposable RAM sessions. Calamares enforces the creation of a dedicated user with a strong password before system installation.
- **Root Account Protections:** The root account is locked by default with an invalid password hash (`*`). System administration is managed via `sudo` with proper user group authentication.

### Cryptographic Repository Verification
- All package installations, dependencies, and system updates use Debian's official GPG signed repositories (`Debian Archive Automatic Signing Key`).
- Package integrity and checksums are verified before installation.
- In `lunova-update`, all updates are routed through `pkexec` and standard APT policy without bypassing cryptographic verification.

### PolicyKit (Polkit) Authorization
- System-changing actions (installing software, disk partitioning, poweroff/reboot when other users are connected, editing system files) require PolicyKit authorization with explicit authentication prompts.

### Privacy & AI Assistant Boundaries
- The Lunova Assistant application stores credentials locally in user configuration directories (`~/.config/lunova/`) with restricted permissions (`0600`).
- No telemetry, analytics, or background data collection is bundled.
- System modifying commands suggested by the AI assistant are **never** executed automatically. They require explicit user review and confirmation via an interactive approval modal.

---

## 2. Reporting Security Vulnerabilities

To report a vulnerability in Lunova OS components, please open an advisory or contact security@lunova-os.org. For vulnerabilities in upstream Debian packages, reports should be directed to the Debian Security Team (security@debian.org).
