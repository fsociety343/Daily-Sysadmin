## Membatasi Load CPU ketika backup berjalan sehingga tidak membebani CPU dan Memory

```bash
 PID USER      PR  NI    VIRT    RES    SHR S  %CPU  %MEM     TIME+ COMMAND
2234440 root      20   0    5200   1912   1352 R  60.0   0.0  15:50.28 gzip
    143 root       0 -20       0      0      0 I   6.7   0.0   0:15.28 kworker+
2243305 root      20   0       0      0      0 I   6.7   0.0   0:00.05 kworker+
      1 root      20   0  238744   9824   7272 S   0.0   0.1   3:41.46 systemd
      2 root      20   0       0      0      0 S   0.0   0.0   0:00.20 kthreadd
```

Periksa Aktifitas Cron

```bash
[root@cwp upt]# ls -lah /etc/cron.* /var/spool/cron/
-rw-r--r--. 1 root root    0 Apr  6  2024 /etc/cron.deny

/etc/cron.d:
total 60K
drwxr-xr-x.   2 root root 4.0K May 16 08:28 .
drwxr-xr-x. 100 root root  12K May 26 09:47 ..
-rw-r--r--.   1 root root  128 Apr  6  2024 0hourly
-rw-r--r--    1 root root   14 Feb  1  2013 csf-cron
-rw-------    1 root root   48 May 16 08:28 csf_update
-rw-r--r--    1 root root  581 Mar  2 12:16 home_user_backup
-rw-r--r--    1 root root   74 May 16 08:27 lfd-cron
-rw-r--r--    1 root root   76 May  5 03:35 maldet_pub
-rw-r--r--    1 root root  575 Mar  2 12:48 mysql_backup
-rw-r--r--    1 root root   90 Mar  2 19:22 sitepad
-rw-r--r--    1 root root   93 Mar  2 19:22 sitepad2
-rw-r--r--    1 root root  244 Mar  2 19:22 softaculous
-rw-r--r--    1 root root  122 Mar  2 19:22 softaculous2

/etc/cron.daily:
total 44K
drwxr-xr-x.   2 root root 4.0K May 16 08:27 .
drwxr-xr-x. 100 root root  12K May 26 09:47 ..
-rwx------    1 root root 3.3K Jul 26  2023 csget
-rwxr-xr-x.   1 root root  247 Feb 23 13:13 cwp
-rwxr-xr-x    1 root root   36 Feb 24 03:39 cwp_acme.sh
-rwxr-xr-x.   1 root root   88 Feb 23 14:39 cwp_bandwidth
-rwxr-xr-x.   1 root root  189 Jan  4  2018 logrotate
-rwxr-xr-x    1 root root 3.8K May  5 03:35 maldet
-rwxr-xr-x    1 root root 1.8K Jun 12  2022 rkhunter

/etc/cron.hourly:
total 20K
drwxr-xr-x.   2 root root 4.0K Feb 23 12:48 .
drwxr-xr-x. 100 root root  12K May 26 09:47 ..
-rwxr-xr-x.   1 root root  575 Apr  6  2024 0anacron

/etc/cron.monthly:
total 16K
drwxr-xr-x.   2 root root 4.0K Apr  8  2021 .
drwxr-xr-x. 100 root root  12K May 26 09:47 ..

/etc/cron.weekly:
total 16K
drwxr-xr-x.   2 root root 4.0K Apr  8  2021 .
drwxr-xr-x. 100 root root  12K May 26 09:47 ..

/var/spool/cron/:
total 16K
drwx------.  2 root   root   4.0K May 27 07:53 .
drwxr-xr-x. 14 root   root   4.0K May 15 09:29 ..
-rw-------   1 root   root   1.3K May 27 07:53 root
-rw-------   1 unisri unisri    1 May 14 09:01 unisri
```

Analisa :

Secara keseluruhan, log ini menunjukkan beberapa hal penting:

- Terdapat berbagai tugas cron yang dijalankan, baik oleh sistem maupun aplikasi pihak ketiga.
- Tugas-tugas tersebut memiliki jadwal eksekusi yang berbeda-beda: harian, mingguan, atau per jam.
- File `home_user_backup` di `/etc/cron.d` merupakan bagian krusial yang perlu dipantau.

Performa server yang melambat atau error dapat disebabkan oleh tugas-tugas cron ini (khususnya proses backup atau pemindaian malware seperti `maldet` dan `rkhunter`) yang berjalan bersamaan dengan waktu peak traffic server/webserver.

Kemudian lakukan pembatasan nice pada script crond tersebut di home_user_backup

```bash
[root@cwp upt]# cat /etc/cron.d/home_user_backup
# Backup Harian (07:00, 17:00, 23:00 WIB)
#0 7 * * * root /bin/bash /usr/local/bin/home_user_backup.sh daily
#0 17 * * * root /bin/bash /usr/local/bin/home_user_backup.sh daily
#0 23 * * * root /bin/bash /usr/local/bin/home_user_backup.sh daily

0 7 * * * root nice -n 19 ionice -c2 -n7 /bin/bash /usr/local/bin/home_user_backup.sh daily
0 17 * * * root nice -n 19 ionice -c2 -n7 /bin/bash /usr/local/bin/home_user_backup.sh daily
0 23 * * * root nice -n 19 ionice -c2 -n7 /bin/bash /usr/local/bin/home_user_backup.sh daily

# Backup Mingguan (Senin, Kamis, Sabtu pukul 02:00 dan 23:00 WIB)
#0 2 * * 1,4,6 root /bin/bash /usr/local/bin/home_user_backup.sh weekly
#0 23 * * 1,4,6 root /bin/bash /usr/local/bin/home_user_backup.sh weekly

0 2 * * 1,4,6 root nice -n 19 ionice -c2 -n7 /bin/bash /usr/local/bin/home_user_backup.sh weekly
0 23 * * 1,4,6 root nice -n 19 ionice -c2 -n7 /bin/bash /usr/local/bin/home_user_backup.sh weekly

# Backup Bulanan (Tanggal 1, 15, 28 pukul 02:00 WIB)
#0 2 1,15,28 * * root /bin/bash /usr/local/bin/home_user_backup.sh monthly

0 2 1,15,28 * * root nice -n 19 ionice -c2 -n7 /bin/bash /usr/local/bin/home_user_backup.sh monthly
```

