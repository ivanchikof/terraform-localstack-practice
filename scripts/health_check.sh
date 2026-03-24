#!/bin/bash

#1.Змінні (Variables) - де ми зберігаємо дані
SERVICE="nginx"

# 2. Команди перевірки
echo "Перевіряю статус служби: $SERVICE"

# 3. Логіка (If/Else) - прийняття рішень
if systemctl is-active --quite $SERVICE; then
  echo "Все супер! $SERVICE працює."

else
  echo "УВАГА! $SERVICE впав. Спроба перезапуску..."
  sudo systemctl start $SERVICE
fi
