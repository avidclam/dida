.. rst3: filename: redhat

Red Hat Linux
=============

Установка
++++++++++++++++++



Failed to set MokListRT
***********************

Знакомство с Red Hat Linux начинается с сообщения::
    
    Failed to set MokListRT: Invalid Parameter
    Something has gone seriously wrong: import_mok_state() failed:
    Invalid Parameter

Вроде бы виноваты пакеты ``shim-x64`` и ``mokutil``
и поэтому предлагается их не обновлять во избежание проблем::

   echo "exclude=shim-x64,mokutil" >> /etc/yum.conf

Прекрасное решение для работающей системы, которой пока нет. Ставим 7.6.

Параметры
******************

Устанавливаем с учетом Installation Guide, в частности, Recommended Partitioning Scheme,
а также по мотивам https://habr.com/ru/post/469097/.

Выделено два диска по 24Gb, один из них подключен на этапе установки, другой подключим после.

Разбивка диска::
    
    swap	2Gb (см. ниже)
    /boot	1Gb (не lvm, ext4)
    /boot/efi   200M (не lvm, vfat)
    /		10Gb (lvm, ext4)
    /var	4Gb (lvm, ext4)
    /home   1Gb (lvm, ext4)
    остальное место остается в запасе

Место под swap выделено из соображений стандартности и как запас.
Есть мнение, что в виртуалках swap не нужен, а, например, руководство по Elasticsearch явно рекомендует не использовать swap.
Установка автоматически создает swap, но его можно отключить, для этого закомментировать соответствующую строчку в /etc/fstab, а в консоли набрать::
    
    lsblk
    swapoff /dev/vda3
    free -h

Можно отключить еще и на уровне ядра::
    
    echo "vm.swappiness=0" >> /etc/sysctl.conf
    reboot

Остальное стандартно: часовой пояс Московский, сеть настраивается, пользователь не создается, 
после каждого большого этапа делается shapshot виртуального диска.

Регистрация
**********************

RHEL --- продукт коммерческий и хотя он доступен для разработчиков, использование требует управления подписками.

Сначала нужно зарегистрировать систему::
    
    subscription-manager register

В качестве username --- короткое имя пользователя, **не email**.

Затем нужно присоединить (attach) подписку к зарегистрированной системе::
    
    subscription manager attach

Неплохо зайти на Customer Portal посмотреть, как зарегистрировалась система: https://access.redhat.com/management/systems

Обновление промежуточное
***********************************************

После регистрации и оформления подписки можно обновиться.
Сначала обновляется текущая система в рамках 7.6, с учетом "исключенных" пакетов::
    
    yum clean all
    echo "exclude=shim-x64,mokutil" >> /etc/yum.conf
    yum --releasever=7.6 update

Подробности обновления в рамках минорной версии см. https://access.redhat.com/solutions/238533

Далее нужно обновиться до 7.6 EUS::
    
    subscription-manager repos --disable rhel-7-server-rpms --enable rhel-7-server-eus-rpms
    subscription-manager repos --enable rhel-7-server-extras-rpms
    subscription-manager repos --disable rhel-7-server-optional-rpms --enable rhel-7-server-eus-optional-rpms
    subscription-manager repos --disable rhel-7-server-supplementary-rpms --enable rhel-7-server-eus-supplementary-rpms
    subscription-manager release --set 7.6
    yum update
    reboot

Делаем копию копию /boot/efi/EFI в директорию /boot/efi/EFI76, пригодится.

Leapp
*****

Обновление на версию 8 начинается с утилиты Leapp. Сначала::
    
    yum install leapp
    
Далее нужно скачать файл ``leapp-data6.tar.gz`` из статьи 
https://access.redhat.com/articles/3664871 и распаковать его в нужное место::
    
    tar -xzf leapp-data6.tar.gz -C /etc/leapp/files && rm leapp-data6.tar.gz

Потом запустить этап оценки обновляемости::
    
    leapp preupgrade

почитать отчет /var/log/leapp/leapp-report.txt и настроить согласно рекомендациям как минимум то, 
что отмечено как inhibitor. В данном случае надо установить "PermitRootLogin yes" в sshd_config,
что пока не требуется (sshd еще не настраивали), но позволяет пройти дальше с обновлением.

Notes:
    Причина рекомендации --- изменилось поведение по умолчанию в RHEL8. 
    Если параметр PermitRootLogin явно не установлен, вход с паролем запрещается.


Наконец, идет непосредственно этап обновления::
    
    leapp upgrade

После ряда обновлений leapp говорит, что необходимо перегрузиться для продолжения.
После перезагрузки предлагается стартовать RHEL8 initramfs, который все обновит и снова перезагрузится.
После второй перезагрузки нас ждет приз: "Failed to set MokListRT".

Починка
**************

Не очень понятно, как чинить новый EFI, поэтому просто заменим shim на старый.
Для этого подключим установочный диск 7.6 и при загрузке выберем Troubleshooting -> Rescue. Далее

::
    
    cd /mnt/sysimage/boot/efi
    cp -a EFI EFI81
    cp EFI76/BOOT/BOOT* EFI/BOOT
    cp EFI76/redhat/shim* EFI/redhat
    shutdown now

Отключаем установочный диск, перегружаемся, и все вроде работает.

Проверка
****************

Надо убедиться, что у нас действительно версия 8.1::
    
    cat /etc/redhat-release

И соответствующее ядро::
    
    uname -r
    
И подписка соответствует::
    
    subscription-manager list --installed
    
Отменяем привязку к версии::
    
    subscription-manager release --unset

И включаем SELinux::
    
    setenforce 1

Курс администратора
+++++++++++++++++++++++++++++++++++++

Ниже заметки слушателя курса RHCSA на Udemy https://www.udemy.com/course/rhcsa-practice-exam-questions-ex200-redhat-release-7/.
На всякий случай, страница экзамена: https://www.redhat.com/en/services/training/ex200-red-hat-certified-system-administrator-rhcsa-exam.

Заметки касаются только части вопросов, имеющих отношение к развертыванию одиночной системы RHEL/CentOS в Интернете.
Не отражены разделы курса, посвященные таким "корпоративным" темам, как централизованная авторизация пользователей, локальные репозитории и др.
Также опущены простые задания, такие как использование ``scp``, например.

Отличия RHEL8 от RHEL7
*******************************

* От единого репозитория к двум: BaseOS и AppStream. Добавилась концепция "модулей" (логически связанный набор пакетов).
* YUM обновлен до версии 4 (DNF), поддерживающей модули.
* Устарел ntp daemon, поддерживается только chronyd для синхронизации времени.
* Средство настройки сети --- Network Manager. Скрипты ipup/ipdown зависят от nmcli.
* Добавлена поддержка Stratis как среддства storage management.
* Вместо authconfig --- authselect.

Замечания по установке
******************************************

При установке на VM нужно корректно подобрать виртуальное "железо".

* HDD: (IDE or SATA disk type, not SCSI)

Если хочется иметь "старые" названия сетевых интерфейсов (eth0, eth1), то можно до первой загрузки с DVD добавить ``net.ifnames=0`` [1]_ в параметры ядра соответствующей записи grub.

Тип установки можно выбрать любой, но не "Server with GUI".

.. [1] См. https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/7/html/networking_guide/sec-understanding_the_device_renaming_procedure

Задания
**************



Переустановить забытый пароль
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

В меню GRUB надо нажать "e" (edit) и в строчку ядра (начинается с linux) дописать ``rd.break`` в конце, после чего нажать Ctrl+x для продолжения загрузки.
В режиме rescue перемонтировать корневую директорию для чтения-записи, переустановить пароль и указать SELinux на необходимость переразметки::
    
    mount -o remount,rw /sysroot
    chroot /sysroot
    passwd
    touch /.autorelabel
    exit
    mount -o remount,ro /sysroot
    reboot

Включить SELinux
^^^^^^^^^^^^^^^^^^^^^^^^

Текущий режим можно узнать с помощью getenforce или sestatus, а установить --- в /etc/selinux/config::
    
    SELINUX=enforcing

Активируется при перезагрузке.

Перейти в графический режим
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

То, что когда-то настраивалось через runlevel (от 0 до 5) в /etc/inittab, в systemd настраивается через "target":
        
* poweroff.target
* rescue.target
* multi-user.target ("текстовой режим", runlevel 3)
* graphical.target ("графический режим", runlevel 5)
* reboot.target

Текущий target можно посмотреть командой ``systemctl get-default``.

Где есть get default, должен быть set default, и он есть::
    
    systemctl isolate graphical.target
    systemctl set-default graphical.target

Чтобы было куда переключаться, нужно установить нужные пакеты, например, так::
    
    dnf group list
    dnf groupinstall "Server with GUI"

Для информации, юниты systemd находятся в директории /usr/lib/systemd/system/ . 
Системные настройки, касающиеся юнитов --- в /etc/systemd/system/ .
Например, default.target --- это ссылка на /usr/lib/systemd/....

Настроить имя хоста и сеть
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Имя хоста настраивается, например, так::
    
    hostnamectl set-hostname system.example.com

Сеть настраивается с помощью Network Manager.
Команда ``nmcli`` без параметров выдает информацию о текущих настройках.
Команда ``ip addr`` показывает интерфейсы и соответствующие IP-адреса, ``ip route show`` --- настройку маршрутизации.

Следующие интуитивные команды настраивают и поднимают статическое IP-соединение::
    
    nmcli connection add con-name system type ethernet ifname eth0 ipv4.address 192.168.122.10/24 ipv4.gateway 192.168.122.1 ipv4.dns 192.168.122.254 ipv4.method manual 
    nmcli connection up system

Рестартовать Network Manager можно стандартно::
    
    systemctl restart NetworkManager

Посмотреть текущие установки можно в директории

::
    
    /etc/sysconfig/network-scripts

Замечания про модули и репозитории
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Некоторые полезные сведения о репозиториях, пакетах и управлении ими.

* Вместо yum -\> dnf
* Модульная структура пакетов

Модули и стримы можно просмотреть и установить независимо.

::
    
    dnf module list
    dnf module info python36
    dnf module info --profile python36:3.6
    dnf install @python36

* Как уже говорилось, в RHEL8 два репозитория --- BaseOS и AppStream.
* Их можно найти, например, на ISO-диске RHEL8 в директориях с соответствующими именами и скопировать локально.

После копирования создадим файл /etc/yum.repos.d/system.repo со следующим содержимым::
    
    [BaseOS]
    name = BaseOS
    baseurl = file:///root/BaseOS
    gpgcheck = 0
    enabled = 1
    [AppStream]
    name = AppStream
    baseurl = file:///root/AppStream
    gpgcheck = 0
    enabled = 1

Далее::
    
    dnf clean all
    
Проверка::
    
    dnf repolist
    dnf groups list

Запускать задания по расписанию
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Создадим пользователя::
    
    useradd -c "Regular User" -d /home/regular -m --user-group -u 5010 regular
    passwd regular
    su - regular

Рекомендация по выбору ID для RHEL8: *The recommended practice is to assign IDs starting at 5,000*, так что UID=5010 вполне соответствует.

Создадим скрипт, например, такой::
    
    su - regular
    mkdir bin
    mkdir log
    echo "#!/bin/bash" > bin/cronjob.sh
    echo "date >> /home/regular/log/cron.log" >> bin/cronjob.sh
    chmod u+x bin/cronjob.sh
    exit

Настроим cron

::

    crontab -u regular -e
    # в редакторе добавим строчку
    */3 * * * * /home/regular/bin/cronjob.sh

Скрипт будет исполняться каждые 3 минуты.

Чтобы скрипт выполнялся, например, в 12:15 каждый понедельник, нужно было прописать строчку::
    
    15 12 * * 1 /home/regular/bin/cronjob.sh

Кстати, вполне приличное описание crontab есть в Википедии https://ru.wikipedia.org/wiki/Cron

::
    
    * * * * * выполняемая команда
    - - - - -
    | | | | |
    | | | | ----- день недели (0—7) (воскресенье = 0 или 7)
    | | | ------- месяц (1—12)
    | | --------- день (1—31)
    | ----------- час (0—23)
    ------------- минута (0—59)
    
Пользователю можно дать права самостоятельно настраивать свои задания. 
Для этого требуется внести пользователя в файл /etc/cron.allow

::
    
    echo "regular" >> /etc/cron.allow
    

Удаляются задания с помощью ``crontab -r``.

Для разового запуска задания по расписанию используем atd. 
Он не установлен по умолчанию. Поэтому::
    
    dnf install at
    systemctl start atd
    systemctl status atd

Для конфигурирования задания нужно войти в командную оболочку ``at``
с указанием необходимомо времени выполнения задания. Например::
    
    at 4 PM + 2 days # или
    at now + 30 min

В оболочке нужно набрать команду и нажать Ctrl+D для выхода.

Проверить, что есть задание по расписанию, можно командой ``atq``.

Замечания про grub2
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Много где, например, здесь --- https://wiki.centos.org/HowTos/Grub2 --- написано, что если мы хотим изменить параметры ядра при запуске (kernelopts), то нужно отредактировать файл ``/etc/default/grub`` и запустить

::
    
    grub2-mkconfig -o /boot/efi/EFI/redhat/grub.cfg

Оказывается, так может не работать, и вот почему. 

Параметры, заданные в GRUB_CMDLINE_LINUX файла /etc/default/grub, переносятся скриптом grub2-mkconfig в переменную окружения kernelopts. См.::
    
    grub2-editenv - list

Параметры старта каждого пункта меню GRUB, 
в соответствии с https://systemd.io/BOOT_LOADER_SPECIFICATION/,
описываются в .conf файлах, расположенных в директории ``/boot/loader/entries/``.
Обычно в них присутствует строчка

::
    
    options $kernelopts $tuned_params

Однако ``options`` могут задаваться и непосредственно в conf-файле. В таком случае заданные где-то еще kernelopts никак не используются, 
и для изменения параметров запуска ядра нужно редактировать 
непосредственно conf-файл в директории ``/boot/loader/entries``.

Диски и разделы
^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Последовательность при работе со стандартными разделами диска: fdisk, mkfs, mount.

Для LVM::
    
    fdisk
    pvcreate  # Physical Volume
    pvs
    vgcreate  -s 16M  # Volume Group with custom PE size
    vgs
    lvcreate  # Logical Volume
    lvs
    mkfs
    mount
    vgextend  # Extend VG
    lvextend  # Extend LV

У команды ``lvcreate`` опция ``-ll`` предлагает интересные возможности, например::
    
    lvcreate -n lvname -l 20 vsname  # size = 20 PEs
    lvcreate -n lvname -l 100%FREE vsname  # size = все свободное пространство
    lvcreate -n lvname -l 60%VG vsname  # size = 60% размера VG

Полезные утилиты:

* ``lsblk`` --- list block devices
* ``blkid`` --- locate/print block device attributes
* ``partprobe`` --- inform the OS of partition table changes
* ``cat /proc/partitions`` --- verify change
* ``mkswap`` и ``swapon`` для создания и активации swap
* ``fsadm`` --- utility to resize or check filesystem on a device

Разное
^^^^^^^^^^^^

Посмотреть источники синхронизации времени chronyd можно командой::
    
    chronyc sources -v

