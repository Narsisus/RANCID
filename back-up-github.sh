#!/bin/bash

# กำหนดตัวแปร
RANCID_PATH="/var/lib/rancid/devices/configs"
GITHUB_REPO="https://github.com/Narsisus/RANCID.git"
BACKUP_DIR="/tmp/rancid-backup"
DATE=$(date +%Y-%m-%d_%H-%M-%S)
BRANCH_NAME="rancid"  # เปลี่ยนเป็น rancid ตามที่คุณตั้งค่าไว้

# สร้างโฟลเดอร์ backup ชั่วคราว
mkdir -p $BACKUP_DIR

# คัดลอกไฟล์ config ไปยังโฟลเดอร์ backup
cp -r $RANCID_PATH/* $BACKUP_DIR/

# เริ่มต้น git repo และตั้งค่า
cd $BACKUP_DIR
if [ ! -d .git ]; then
    git init
    # ตั้งค่า user และ email
    git config user.name "RANCID Backup"
    git config user.email "your-email@example.com"
    git branch -M $BRANCH_NAME
    git remote add origin $GITHUB_REPO
fi

# เพิ่มไฟล์ทั้งหมดเข้า git
git add .

# ตรวจสอบว่ามีการเปลี่ยนแปลงหรือไม่
if git diff --staged --quiet; then
    echo "No changes detected"
    exit 0
fi

# commit การเปลี่ยนแปลง
git commit -m "Backup RANCID configs - $DATE"

# push ขึ้น GitHub ด้วย branch rancid
git push -u origin $BRANCH_NAME --force

# ลบโฟลเดอร์ backup ชั่วคราว
cd /tmp
rm -rf $BACKUP_DIR

echo "Backup completed successfully"
