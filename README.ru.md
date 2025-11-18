## nice installer

>Этот проект был сделан в качестве тестового задания для собеседования.

### Возможности

- Массовая установка предустановленных пакетов
- Проверка прав администратора
- Обработчик ошибок
- Логирование операций
- Поддержка основных менеджеров пакетов

### Поддерживаемые менеджеры пакетов
- **APT** - Debian, Ubuntu, Linux Mint
- **DNF** - Fedora, RHEL 8+
- **YUM** - CentOS, RHEL 7
- **Zypper** - openSUSE
- **Pacman** - Arch Linux, Manjaro

### Установка и использование

1. Клонируйте репозиторий:
```bash
git clone https://github.com/gamr416/nice_installer.git
cd nice_installer
```
2. Сделайте скрипт исполняемым
```bash
chmod +x install.sh
```
3. Настройте нужные пакеты в файле config.txt (по одному пакету на строку)
4. Запустите скрипт
```bash
sudo ./install.sh
```