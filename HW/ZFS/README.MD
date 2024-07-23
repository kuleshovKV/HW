ZFS


1.Определить алгоритм с наилучшим сжатием
Использовать в примере будем ВМ из Vagrantfile. В нес разворачивается машина с 8 дисками, ОС CentOS 7 и с установленными пакетами для работы с zfs 
- Создадим 4 пула по два диска в каждом 
[vagrant@exc4vm ~]$ lsblk

NAME   MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
sda      8:0    0   40G  0 disk 
└─sda1   8:1    0   40G  0 part /
sdb      8:16   0  512M  0 disk 
sdc      8:32   0  512M  0 disk 
sdd      8:48   0  512M  0 disk 
sde      8:64   0  512M  0 disk 
sdf      8:80   0  512M  0 disk 
sdg      8:96   0  512M  0 disk 
sdh      8:112  0  512M  0 disk 
sdi      8:128  0  512M  0 disk 

[root@exc4vm vagrant]# zpool create part1 mirror /dev/sdb /dev/sdc
[root@exc4vm vagrant]# zpool create part2 mirror /dev/sdd /dev/sde
[root@exc4vm vagrant]# zpool create part3 mirror /dev/sdf /dev/sdg
[root@exc4vm vagrant]# zpool create part4 mirror /dev/sdh /dev/sdi

Проверяем то, что создали
[root@exc4vm vagrant]# zpool status
  pool: part1
 state: ONLINE
  scan: none requested
config:
NAME        STATE     READ WRITE CKSUM
part1       ONLINE       0     0     0
  mirror-0  ONLINE       0     0     0
    sdb     ONLINE       0     0     0
    sdc     ONLINE       0     0     0

  

errors: No known data errors
pool: part2
state: ONLINE
scan: none requested
config:
NAME        STATE     READ WRITE CKSUM
part2       ONLINE       0     0     0
  mirror-0  ONLINE       0     0     0
    sdd     ONLINE       0     0     0
    sde     ONLINE       0     0     0

  

errors: No known data errors
pool: part3
state: ONLINE
scan: none requested
config:
NAME        STATE     READ WRITE CKSUM
part3       ONLINE       0     0     0
  mirror-0  ONLINE       0     0     0
    sdf     ONLINE       0     0     0
    sdg     ONLINE       0     0     0

  

errors: No known data errors
pool: part4
state: ONLINE
scan: none requested
config:
NAME        STATE     READ WRITE CKSUM
part4       ONLINE       0     0     0
  mirror-0  ONLINE       0     0     0
    sdh     ONLINE       0     0     0
    sdi     ONLINE       0     0     0

  

errors: No known data errors
Весь пул создался и работает без ошибок
Теперь добавим на каждый пул разные алгоритмы сжатия для определения наиболее оптимального
[root@exc4vm vagrant]# zfs set compression=lzjb part1
[root@exc4vm vagrant]# zfs set compression=lz4 part2
[root@exc4vm vagrant]# zfs set compression=gzip-9 part3
[root@exc4vm vagrant]# zfs set compression=zle part4
Скачаем на все имеющиеся пулы один и тот же файл. 
[root@exc4vm vagrant]# for i in {1..4}; do wget -P /part$i https://gutenberg.org/cache/epub/2600/pg2600.converter.log; done
--2024-07-18 03:40:44--  https://gutenberg.org/cache/epub/2600/pg2600.converter.log
Resolving gutenberg.org (gutenberg.org)... 152.19.134.47, 2610:28:3090:3000:0:bad:cafe:47
Connecting to gutenberg.org (gutenberg.org)|152.19.134.47|:443... connected.
HTTP request sent, awaiting response... 200 OK
Length: 40941287 (39M) [text/plain]
Saving to: ‘/part1/pg2600.converter.log’

100%[======================================>] 40,941,287  4.55MB/s   in 8.3s   

2024-07-18 03:40:53 (4.71 MB/s) - ‘/part1/pg2600.converter.log’ saved [40941287/40941287]

--2024-07-18 03:40:53--  https://gutenberg.org/cache/epub/2600/pg2600.converter.log
Resolving gutenberg.org (gutenberg.org)... 152.19.134.47, 2610:28:3090:3000:0:bad:cafe:47
Connecting to gutenberg.org (gutenberg.org)|152.19.134.47|:443... connected.
HTTP request sent, awaiting response... 200 OK
Length: 40941287 (39M) [text/plain]
Saving to: ‘/part2/pg2600.converter.log’

100%[======================================>] 40,941,287  1.77MB/s   in 19s    

2024-07-18 03:41:13 (2.07 MB/s) - ‘/part2/pg2600.converter.log’ saved [40941287/40941287]

--2024-07-18 03:41:13--  https://gutenberg.org/cache/epub/2600/pg2600.converter.log
Resolving gutenberg.org (gutenberg.org)... 152.19.134.47, 2610:28:3090:3000:0:bad:cafe:47
Connecting to gutenberg.org (gutenberg.org)|152.19.134.47|:443... connected.
HTTP request sent, awaiting response... 200 OK
Length: 40941287 (39M) [text/plain]
Saving to: ‘/part3/pg2600.converter.log’

100%[======================================>] 40,941,287  2.51MB/s   in 17s    

2024-07-18 03:41:30 (2.34 MB/s) - ‘/part3/pg2600.converter.log’ saved [40941287/40941287]

--2024-07-18 03:41:30--  https://gutenberg.org/cache/epub/2600/pg2600.converter.log
Resolving gutenberg.org (gutenberg.org)... 152.19.134.47, 2610:28:3090:3000:0:bad:cafe:47
Connecting to gutenberg.org (gutenberg.org)|152.19.134.47|:443... connected.
HTTP request sent, awaiting response... 200 OK
Length: 40941287 (39M) [text/plain]
Saving to: ‘/part4/pg2600.converter.log’

100%[======================================>] 40,941,287  1.72MB/s   in 19s    

2024-07-18 03:41:51 (2.00 MB/s) - ‘/part4/pg2600.converter.log’ saved [40941287/40941287]
Сравним какое количество места занял на разных пулах, скаченный файл.
[root@exc4vm vagrant]# zfs list
NAME    USED  AVAIL     REFER  MOUNTPOINT
part1  21.6M   330M     21.6M  /part1
part2  17.7M   334M     17.6M  /part2
part3  10.8M   341M     10.7M  /part3
part4  39.2M   313M     39.1M  /part4
Как можно увидеть, меньше всего места файл занял на 3-м пуле, для которого установили алгоритм сжатия gzip-9.
Следующая команда покажет коэффициент сжатия
[root@exc4vm vagrant]# zfs get all | grep compressratio | grep -v ref
part1  compressratio         1.81x                  -
part2  compressratio         2.22x                  -
part3  compressratio         3.65x                  -
part4  compressratio         1.00x                  -
В этом выводе, также можем убедиться, что gzip-9 эффективнее остальных.



2. Определить настроки pool'а
Скачаем и распакуем архив
[root@exc4vm vagrant]# wget -O archive.tar.gz --no-check-certificate 'https://drive.google.com/u/0/uc?id=1KRBNW33QWqbvbVHa3hLJivOAt60yukkg&export=download'
...
[root@exc4vm vagrant]# tar -xzvf archive.tar.gz 
zpoolexport/
zpoolexport/filea
zpoolexport/fileb
Проверим возможность импорта пула
[root@exc4vm vagrant]# zpool import -d zpoolexport/
   pool: otus
     id: 6554193320433390805
  state: ONLINE
 action: The pool can be imported using its name or numeric identifier.
 config:

        otus                                 ONLINE
          mirror-0                           ONLINE
            /home/vagrant/zpoolexport/filea  ONLINE
            /home/vagrant/zpoolexport/fileb  ONLINE
Данный вывод говорит нам о том, что имя пула otus, тип mirror-0 и его состав
Импортируем этот пул с новым именем
[root@exc4vm vagrant]# zpool import -d zpoolexport/ otus newpart
Определить размер хранилища
[root@exc4vm ~]# zfs get available newpart
NAME     PROPERTY   VALUE  SOURCE
newpart  available  350M   -
Определить тип пула
[root@exc4vm ~]# zfs get readonly newpart
NAME     PROPERTY  VALUE   SOURCE
newpart  readonly  off     default
Определить значени recordsize
[root@exc4vm ~]# zfs get recordsize newpart
NAME     PROPERTY    VALUE    SOURCE
newpart  recordsize  128K     local
Определить тип сжатия
[vagrant@exc4vm ~]$ zfs get compression newpart
NAME     PROPERTY     VALUE     SOURCE
newpart  compression  zle       local
Определить контрольную сумму
[vagrant@exc4vm ~]$ zfs get checksum newpart
NAME     PROPERTY  VALUE      SOURCE
newpart  checksum  sha256     local


3. Найти сообщение
Скачаем файл, указанный в задании:
[root@zfs ~]# wget -O otus_task2.file --no-check-certificate
https://drive.usercontent.google.com/download?id=1wgxjih8YZ-cqLqaZVa0lA3h
3Y029c3oI&export=download
Восстановим файловую систему из снапшота:
zfs receive otus/test@today < otus_task2.file
Далее, ищем в каталоге /otus/test файл с именем “secret_message”:
[root@zfs ~]# find /otus/test -name "secret_message"
/otus/test/task1/file_mess/secret_message
Смотрим содержимое найденного файла:
[root@zfs ~]# cat /otus/test/task1/file_mess/secret_message
https://otus.ru/lessons/linux-hl/

