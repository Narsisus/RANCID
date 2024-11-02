#!/bin/bash

# กำหนดตัวแปร
RANCID_PATH="/var/lib/rancid/devices/configs"
GITHUB_REPO="https://github.com/Narsisus/RANCID.git"
BACKUP_DIR="/tmp/rancid-backup"
DATE=$(date +%Y-%m-%d_%H-%M-%S)
BRANCH_NAME="rancid"

# Function สำหรับจัดการ error
handle_error() {
    echo "Error: $1"
    cd /tmp
    rm -rf $BACKUP_DIR
    exit 1
}

# สร้างโฟลเดอร์ backup ชั่วคราว
mkdir -p $BACKUP_DIR

# ถ้ามี git repo อยู่แล้ว ให้ clone มาก่อน
if [ -d "$BACKUP_DIR/.git" ]; then
    cd $BACKUP_DIR || handle_error "Cannot change to backup directory"
    # ตรวจสอบและแก้ไขปัญหา conflicts
    git fetch origin
    git reset --hard origin/$BRANCH_NAME
else
    # ถ้ายังไม่มี repo ให้ clone ใหม่
    git clone $GITHUB_REPO $BACKUP_DIR || handle_error "Failed to clone repository"
    cd $BACKUP_DIR || handle_error "Cannot change to backup directory"
    git checkout $BRANCH_NAME || git checkout -b $BRANCH_NAME
fi

# ตั้งค่า git config
git config user.name "RANCID"
git config user.email "65070181@kmitl.ac.th"

# คัดลอกไฟล์ config ใหม่
cp -r $RANCID_PATH/* $BACKUP_DIR/ || handle_error "Failed to copy config files"

# เพิ่มไฟล์ทั้งหมดเข้า git
git add .

# ตรวจสอบว่ามีการเปลี่ยนแปลงหรือไม่
if git diff --staged --quiet; then
    echo "No changes detected"
    cd /tmp
    rm -rf $BACKUP_DIR
    exit 0
fi

# commit การเปลี่ยนแปลง
git commit -m "Backup RANCID configs - $DATE"

# ลองทำ pull และ rebase ก่อน push
git pull --rebase origin $BRANCH_NAME || {
    # ถ้า pull --rebase ไม่สำเร็จ ให้ลอง merge
    git pull origin $BRANCH_NAME || handle_error "Failed to sync with remote"
}

# push ขึ้น GitHub
git push origin $BRANCH_NAME || handle_error "Failed to push changes"

# ลบโฟลเดอร์ backup ชั่วคราว
cd /tmp
rm -rf $BACKUP_DIR

echo "Backup completed successfully"
