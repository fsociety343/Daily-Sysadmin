#!/bin/bash

#BACKUP_DIR="/hdd-storage-ext/vm-ext/dump/"
BACKUP_DIR="/hdd-storage-ext/vm-backup/dump" #sesuaikan dengan dir backup
DAYS_OLD=7

echo "Mencari file vzdump-qemu yang lebih dari $DAYS_OLD hari di $BACKUP_DIR..."

# Cari dan hapus file yang lebih tua dari 7 hari
find "$BACKUP_DIR" -type f -name "vzdump-qemu*" -mtime +$DAYS_OLD -print -exec rm -f {} \;

echo "Selesai menghapus file backup lama."