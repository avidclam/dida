.. rst3: filename: desktop

Рабочее место на Linux
======================

Обычное дело - работать на разных дистрибутивах на десктопе и на сервере,
но тут решено дать шанс релизу CentOS 8.1.1911 в качестве единой платформы.

Установка
++++++++++++++++++

На подготовленую виртуалку (4 CPU, 6G RAM, 2x24G HDD) ставим CentOS 8.1 в конфигурации Workstation. Особенности:

* Во время первой загрузки с iso в параметры ядра добавляем ``net.ifnames=0`` и убираем ``quiet``.
* Принимаем дефолтное разбиение первого диска, второй диск в процессе установки не трогаем.
* Проверяя разбиение, можно поменять предложенное имя LWM Volume Group на ``vg0``.
* Пользователя не создаем.

После перезагрузки::
    
    vi /etc/default/grub  # удаляем rhgb quiet в GRUB_CMDLINE_LINUX, оставляем net.ifnames=0
    grub2-mkconfig -o /boot/efi/EFI/centos/grub.cfg
    systemctl stop libvirtd
    systemctl disable libvirtd
    reboot

Организуем место для /home на втором диске, выделим 8G::
    
    wipefs --all /dev/vdb
    pvcreate /dev/vdb
    vgcreate vg1 /dev/vdb
    lvcreate -n home -L 8G vg1
    mkfs.xfs /dev/mapper/vg1-home
    mount /dev/mapper/vg1-home /home
    #
    vi /etc/fstab
    #dev/mapper/vg1-home    /home                   xfs     defaults        0 2

Теперь можно создать пользователя с помощью useradd.

Настройка
++++++++++++++++++

После первого входа в GNOME:

* User Automatic Login --- On
* Automatic Screen Lock --- Off

Firefox: настраиваем домашнюю страницу, поиск, запрос паролей и т.п.

Затем можно зайти на RealVNC, скачать realvnc-vnc-server и установить его с помощью dnf.
При запуске он запросит root пароль, после чего будет показывать ошибку "VNC Server is not licenced". Нужно найти и нажать кнопку Resolve, задать имя-пароль пользователя realvnc, задать пароль для сервера, подтвердить все root-паролем и все, можно соединяться через VNC.

Можно поменять разрешение виртуальной машины на нестандартное, например, 1280x720.

Flatpak и Podman
+++++++++++++++++

Установка дополнительного софта возможна через flatpak. Для его активации нужно зайти на страницу https://flatpak.org/setup/CentOS/, скачать Flathub repository file, установить его, и можно пользоваться менеджером Software для установки.

Запуск докеровских контейнеров работает через podman, причем под обычным пользователем (имеется в виду версия Centos 8.1, с учетом ограничений `Shortcomings of Rootless Podman <https://github.com/containers/libpod/blob/master/rootless.md>`_).

Для установки podman достаточно::
    
    # dnf install podman
    # echo "user.max_user_namespaces=28633" > /etc/sysctl.d/userns.conf
    # sysctl -p /etc/sysctl.d/userns.conf

Расширение home
+++++++++++++++++++++++++

Во время установки под ``/home`` было выделено 8G, но очень скоро выяснилось, что этого мало. Проверим::
    
    df -h /home

Место на диске оставлялось про запас, в чем можно убедиться::
    
    vgs
    vgdisplay vg1

Не мудрствуя, отдадим все место на диске под home, сразу с расширением файловой системы::
    
    lvextend -r -l +100%FREE /dev/mapper/vg1-home

