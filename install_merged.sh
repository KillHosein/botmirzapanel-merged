#!/bin/bash

# echo ""
# echo "███╗   ███╗██╗██████╗ ███████╗ █████╗  ██████╗  █████╗ ███╗   ██╗███████╗██╗   "
# echo "████╗ ████║██║██╔══██╗╚══███╔╝██╔══██╗ ██╔══██╗██╔══██╗████╗  ██║██╔════╝██║   "
# echo "██╔████╔██║██║██████╔╝  ███╔╝ ███████║ ██████╔╝███████║██╔██╗ ██║█████╗  ██║   "
# echo "██║╚██╔╝██║██║██╔══██╗ ███╔╝  ██╔══██║ ██╔═══╝ ██╔══██║██║╚██╗██║██╔══╝  ██║   "
# echo "██║ ╚═╝ ██║██║██║  ██║███████╗██║  ██║ ██║     ██║  ██║██║ ╚████║███████╗█████╗"
# echo "╚═╝     ╚═╝╚═╝╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝ ╚═╝     ╚═╝  ╚═╝╚═╝  ╚═══╝╚══════╝╚════╝"
# echo ""

# Checking Root Access
if [[ $EUID -ne 0 ]]; then
    echo -e "\033[31m[ERROR]\033[0m Please run this script as \033[1mroot\033[0m."
    exit 1
fi

# Check SSL certificate status and days remaining
check_ssl_status() {
    # First get domain from config file
    if [ -f "/var/www/html/mirzabotconfig/config.php" ]; then
        domain=$(grep '^\$domainhosts' "/var/www/html/mirzabotconfig/config.php" | cut -d"'" -f2 | cut -d'/' -f1)

        if [ -n "$domain" ] && [ -f "/etc/letsencrypt/live/$domain/cert.pem" ]; then
            expiry_date=$(openssl x509 -enddate -noout -in "/etc/letsencrypt/live/$domain/cert.pem" | cut -d= -f2)
            current_date=$(date +%s)
            expiry_timestamp=$(date -d "$expiry_date" +%s)
            days_remaining=$(( ($expiry_timestamp - $current_date) / 86400 ))
            if [ $days_remaining -gt 0 ]; then
                echo -e "\033[32m✅ SSL Certificate: $days_remaining days remaining (Domain: $domain)\033[0m"
            else
                echo -e "\033[31m❌ SSL Certificate: Expired (Domain: $domain)\033[0m"
            fi
        else
            echo -e "\033[33m⚠️ SSL Certificate: Not found for domain $domain\033[0m"
        fi
    else
        echo -e "\033[33m⚠️ Cannot check SSL: Config file not found\033[0m"
    fi
}

# Check bot installation status
check_bot_status() {
    if [ -f "/var/www/html/mirzabotconfig/config.php" ]; then
        echo -e "\033[32m✅ Bot is installed\033[0m"
        check_ssl_status
    else
        echo -e "\033[31m❌ Bot is not installed\033[0m"
    fi
}

# Display Logo
function show_logo() {
    clear
    echo -e "\033[1;34m"
    echo "================================================================================="
    echo "  __  __ _____ _____   ______           _____        _   _ ______ _       "
    echo " |  \/  |_   _|  __ \ |___  /   /\     |  __ \ /\   | \ | |  ____| |      "
    echo " | \  / | | | | |__) |   / /   /  \    | |__) /  \  |  \| | |__  | |      "
    echo " | |\/| | | | |  _  /   / /   / /\ \   |  ___/ /\ \ | . \ |  __| | |      "
    echo " | |  | |_| |_| | \ \  / /__ / ____ \  | |  / ____ \| |\  | |____| |____  "
    echo " | |_|  |_|_____|_|  \_\/_____/_/    \_\ |_| /_/    \_\_| \_|______|______| "
    echo "================================================================================="
    echo -e "\033[0m"
    echo ""
    echo -e "\033[1;36mVersion:\033[0m \033[33m5.1.5 (Merged Pro Version)\033[0m"
    echo -e "\033[1;36mTelegram Channel:\033[0m \033[34mhttps://t.me/mirzapanel\033[0m"
    echo -e "\033[1;36mTelegram Group:  \033[0m \033[34mhttps://t.me/mirzapanelgroup\033[0m"
    echo -e "\033[1;36m⭐️Buy Pro Version⭐️: \033[0m \033[34mhttps://t.me/mirzaperimium\033[0m"
    echo ""
    echo -e "\033[1;36mInstallation Status:\033[0m"
    check_bot_status
    echo ""
}

# Display Menu
function show_menu() {
    show_logo
    echo -e "\033[1;36m1)\033[0m Install Mirza Bot (Merged Pro Version)"
    echo -e "\033[1;36m2)\033[0m Update Mirza Bot"
    echo -e "\033[1;36m3)\033[0m Remove Mirza Bot"
    echo -e "\033[1;36m4)\033[0m Export Database"
    echo -e "\033[1;36m5)\033[0m Import Database"
    echo -e "\033[1;36m6)\033[0m Configure Automated Backup"
    echo -e "\033[1;36m7)\033[0m Renew SSL Certificates"
    echo -e "\033[1;36m8)\033[0m Change Domain"
    echo -e "\033[1;36m9)\033[0m Additional Bot Management"
    echo -e "\033[1;36m10)\033[0m Exit"
    echo ""
    read -p "Select an option [1-10]: " option
    case $option in
        1) install_bot ;;
        2) update_bot ;;
        3) remove_bot ;;
        4) export_database ;;
        5) import_database ;;
        6) auto_backup ;;
        7) renew_ssl ;;
        8) change_domain ;;
        9) manage_additional_bots ;;
        10)
            echo -e "\033[32mExiting...\033[0m"
            exit 0
            ;;
        *)
            echo -e "\033[31mInvalid option. Please try again.\033[0m"
            show_menu
            ;;
    esac
}

# Install Function
function install_bot() {
    echo -e "\e[32mInstalling Mirza Bot (Merged Pro Version) ... \033[0m\n"

    # Install required packages
    sudo apt update
    sudo apt install -y git unzip curl apache2 mysql-server php8.2 php8.2-fpm php8.2-mysql libapache2-mod-php php-mbstring php-zip php-gd php-json php-curl

    # Configure Apache
    sudo a2enmod rewrite
    sudo systemctl restart apache2

    # Configure MySQL
    sudo mysql -e "CREATE DATABASE IF NOT EXISTS mirzabot;"
    sudo mysql -e "CREATE USER IF NOT EXISTS 'mirzabot'@'localhost' IDENTIFIED BY 'mirzabot123';"
    sudo mysql -e "GRANT ALL PRIVILEGES ON mirzabot.* TO 'mirzabot'@'localhost';"
    sudo mysql -e "FLUSH PRIVILEGES;"

    # Download and install bot
    cd /var/www/html/
    sudo rm -rf mirzabotconfig
    sudo git clone https://github.com/KillHosein/botmirzapanel-merged.git mirzabotconfig
    sudo chown -R www-data:www-data /var/www/html/mirzabotconfig/
    sudo chmod -R 755 /var/www/html/mirzabotconfig/

    echo -e "\e[32mBot installed successfully!\033[0m"
    echo -e "\e[33mPlease configure the bot by editing /var/www/html/mirzabotconfig/config.php\033[0m"
}

# Update Function
function update_bot() {
    echo -e "\e[32mUpdating Mirza Bot (Merged Pro Version) ... \033[0m\n"
    
    cd /var/www/html/mirzabotconfig/
    sudo git pull origin main
    sudo chown -R www-data:www-data /var/www/html/mirzabotconfig/
    sudo chmod -R 755 /var/www/html/mirzabotconfig/
    
    echo -e "\e[32mBot updated successfully!\033[0m"
}

# Remove Function
function remove_bot() {
    echo -e "\e[31mRemoving Mirza Bot ... \033[0m\n"
    
    sudo rm -rf /var/www/html/mirzabotconfig/
    sudo mysql -e "DROP DATABASE IF EXISTS mirzabot;"
    sudo mysql -e "DROP USER IF EXISTS 'mirzabot'@'localhost';"
    
    echo -e "\e[32mBot removed successfully!\033[0m"
}

# Export Database Function
function export_database() {
    echo -e "\e[32mExporting database ... \033[0m\n"
    
    mysqldump -u mirzabot -p mirzabot > /tmp/mirzabot_backup.sql
    echo -e "\e[32mDatabase exported to /tmp/mirzabot_backup.sql\033[0m"
}

# Import Database Function
function import_database() {
    echo -e "\e[32mImporting database ... \033[0m\n"
    
    if [ -f "/tmp/mirzabot_backup.sql" ]; then
        mysql -u mirzabot -p mirzabot < /tmp/mirzabot_backup.sql
        echo -e "\e[32mDatabase imported successfully!\033[0m"
    else
        echo -e "\e[31mBackup file not found!\033[0m"
    fi
}

# Auto Backup Function
function auto_backup() {
    echo -e "\e[32mConfiguring automated backup ... \033[0m\n"
    
    # Create backup script
    cat > /tmp/backup_script.sh << 'EOF'
#!/bin/bash
DATE=$(date +%Y%m%d_%H%M%S)
mysqldump -u mirzabot -p mirzabot > /tmp/mirzabot_backup_$DATE.sql
tar -czf /tmp/mirzabot_files_$DATE.tar.gz /var/www/html/mirzabotconfig/
EOF
    
    chmod +x /tmp/backup_script.sh
    echo -e "\e[32mBackup script created at /tmp/backup_script.sh\033[0m"
}

# Renew SSL Function
function renew_ssl() {
    echo -e "\e[32mRenewing SSL certificates ... \033[0m\n"
    
    sudo certbot renew
    sudo systemctl reload apache2
    
    echo -e "\e[32mSSL certificates renewed!\033[0m"
}

# Change Domain Function
function change_domain() {
    echo -e "\e[32mChanging domain ... \033[0m\n"
    
    read -p "Enter new domain: " new_domain
    sed -i "s/\$domainhosts = '.*';/\$domainhosts = 'https:\/\/$new_domain\/';/" /var/www/html/mirzabotconfig/config.php
    
    echo -e "\e[32mDomain changed to $new_domain\033[0m"
}

# Manage Additional Bots Function
function manage_additional_bots() {
    echo -e "\e[32mManaging additional bots ... \033[0m\n"
    
    echo "This feature is available in the merged pro version!"
    echo "You can manage multiple bots from the web panel."
}

# Main execution
show_menu
