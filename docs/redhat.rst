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

Не очень понятно, как чинить новый EFI, поэтому просто заменим его на старый.
Для этого подключим установочный диск 7.6 и при загрузке выберем Troubleshooting -> Rescue.
Далее::
    
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

Тип установки можно выбрать любой, но не "Server with GUI".

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

