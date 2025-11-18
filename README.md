## nice installer

>This project was made as a test task of an interview.

### Features

- Mass installation of predefined packages
- Administrator privileges check
- Error handler
- Operations logging
- Supports main package managers

### Supported package managers
- **APT** - Debian, Ubuntu, Linux Mint
- **DNF** - Fedora, RHEL 8+
- **YUM** - CentOS, RHEL 7
- **Zypper** - openSUSE
- **Pacman** - Arch Linux, Manjaro


### Installation and Usage

1. Clone the repository:
```bash
git clone https://github.com/gamr416/nice_installer.git
cd nice_installer
```
2. Make script executable
```bash
chmod +x install.sh
```
3. Configure your desired packages in config.txt (one package per line)
4. Run the script
```bash
sudo ./install.sh
```