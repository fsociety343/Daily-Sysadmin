# Daily Sysadmin

Ini adalah Task harianku sebagai sysadmin 😀

## Cek kapasitas penggunaan disk terbanyak

```bash
find / -type f -exec du -h {} + 2>/dev/null | sort -rh | head -n 10
```

** untuk command ini akan menscann seluruh folder dan mencari file dengan kapasitas tertinggi

![image.png](Daily%20Sysadmin%201ff217acfeb9809da30dccf1c32557a1/image.png)

```bash
find . -type f -exec du -h {} + | sort -rh | head -n 10
```

** kalau untuk command ini di eksekusi didalam folder tertentu

![image.png](Daily%20Sysadmin%201ff217acfeb9809da30dccf1c32557a1/image%201.png)

## Cek Scan Backup All Time dengan Script bash

```bash
#!/bin/bash

echo "� Memulai scan sistem untuk file backup..."

# Ekstensi yang dicari ditulis langsung dalam perintah find
echo "� Scan direktori /backup..."
BACKUP_IN_BACKUP=$(find /backup -type f \( -iname "*.tar.gz" -o -iname "*.tar" -o -iname "*.sql.gz" -o -iname "*.zip" -o -iname "*.gz" -o -iname "*.bak" \) -print 2>/dev/null)

# Tambahan: scan global jika ingin menyeluruh (boleh diaktifkan)
# echo "� Scan seluruh sistem..."
# BACKUP_IN_ROOT=$(find / -type f \( -iname "*.tar.gz" -o -iname "*.tar" -o -iname "*.sql.gz" -o -iname "*.zip" -o -iname "*.gz" -o -iname "*.bak" \) -not -path "/proc/*" -not -path "/sys/*" -not -path "/dev/*" -not -path "/run/*" -not -path "/tmp/*"
-print 2>/dev/null)

# Gabung hasil pencarian
ALL_BACKUPS=$(echo "$BACKUP_IN_BACKUP" | sort -u)

if [ -z "$ALL_BACKUPS" ]; then
    echo "❌ Tidak ditemukan file backup di sistem ini."
    exit 1
fi

echo ""
echo "✅ Ditemukan file backup berikut:"
echo ""

echo "$ALL_BACKUPS" | while read -r FILE; do
    FILE_NAME=$(basename "$FILE")
    FILE_PATH=$(dirname "$FILE")
    FILE_SIZE=$(du -sh "$FILE" 2>/dev/null | cut -f1)
    FILE_DATE=$(stat -c %y "$FILE" 2>/dev/null | cut -d'.' -f1)
    PARENT_DIR=$(basename "$FILE_PATH")

    echo "� File: $FILE_NAME"
    echo "   � Lokasi: $FILE_PATH"
    echo "   � Dugaan user: $PARENT_DIR"
    echo "   � Tanggal: $FILE_DATE"
    echo "   � Ukuran: $FILE_SIZE"
    echo "-----------------------------"
done
```