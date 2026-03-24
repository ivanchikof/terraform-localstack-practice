#!/bin/bash
# ПЛАН B: Перенаправляємо весь вивід (stdout та stderr) у консоль та лог-файл
exec > >(tee /var/log/user-data.log | logger -t user-data -s 2>/dev/console) 2>&1
# Включаємо режим детального відображення кожної команди
set -x

# Робимо встановлення повністю автоматичним (без запитань)
export DEBIAN_FRONTEND=noninteractive
# Оновлюємо список пакетів та ставимо unzip і curl (вони потрібні для AWS CLI)
sudo apt-get update -y
sudo apt-get install -y unzip curl

# Завантажуємо та встановлюємо AWS CLI
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip -o awscliv2.zip
sudo ./aws/install --update

# Створюємо змінну для логів, щоб не писати довгий шлях щоразу
LOG_FILE="/tmp/server_setup.log"
echo "--STARTING--" | tee -a $LOG_FILE
echo "Project: $PROJECT_NAME" | tee -a $LOG_FILE
echo "Admin: $USER_OWNER" | tee -a $LOG_FILE


sudo apt-get update -y
sudo apt-get install -y nginx

# Перевірка (наш перший Shell logic)
if [ $? -eq 0 ]; then
    echo "$(date): Nginx встановлено успішно! для проекту $PROJECT_NAME!" | tee -a $LOG_FILE
    sudo systemctl start nginx
else
    echo "$(date): Помилка при встановленні!" | tee -a $LOG_FILE
    exit 1
fi

# НОВИЙ РЯДОК: Відправляємо результат у бакет (я взяв один з твоїх - finance)
aws s3 cp $LOG_FILE s3://corp-finance-data/setup_report.txt --endpoint-url http://172.17.0.1:4566
