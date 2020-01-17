.. rst3: filename: linux

Linux, разное
=============

Магия чисел
+++++++++++++++++++++



Виртуальные машины
***********************************

Полезна единая система номеров для виртуальных машин.

Например, используется сеть 192.168.68/24, IP-адреса виртуальных машин начинаются с 81, а имя хоста первой виртуалки: ``uno``. 

.. table:: Пример настройки параметров первой виртуальной машины:
   :widths: auto

   =================  ================================  ==========
   Название VM                      uno81               или vm81uno, например
   MAC-адрес                         0A:C0:A8:44:51:01  (т.е. 10:192:168:68:81:1)
   IP-адрес                            192.168.68.81
   Порт VNC-консоли             5981
   =================  ================================  ==========

Соображения по MAC-адресу:
    
    Чтобы MAC-адрес распознался как Locally Administered MAC Аddress, он должен начинаться с x2, x6, xA или xE. Далее октеты могут быть любыми. Удобно, чтобы они соответствовали IP-адресу. В последнем октете ставится единица, если сеть строится по правилу "один интерфейс --- один адрес", либо используются разные цифры для более хитрых настроек.

Нестандарт
********************

Время от времени появляется желание использовать недефолтные UID для пользователей и нестандартные номера портов сетевых служб (например, из соображений безопасности). 
По прошествии времени вся нумерация, естественно, забывается, и вспомнить, на какой порт был в итоге повешен sshd, бывает затруднительно.

Простой выход из положения --- считать UID административного пользователя (не root) магическим числом, базой нумерации. 

Пример: на группе машин административный пользователь ``resurepus`` имеет UID=23400.
Тогда если забылась вся нумерация, достаточно команды ``id``, чтобы вспомнить, что sshd располагается на порту 23422, служебный веб-сервер --- на 23480, и т.п.

Что происходит?
++++++++++++++++++++++++++++



Что это за устройство?
****************************************

Хотим, например, узнать параметры аппаратного сетевого интерфейса eth0. А вот::
    
    for f in $(find /sys/devices -name eth0); do udevadm info $f; done

Watch
*****

Довольно тривиальная команда, но почему-то все время забывается.
Допустим, нужно, запустив процесс, последить, какие файлы он добавляет в директорию.

Здесь нам поможет::

    watch tree <directory>

Bash
++++



Работа с фоновыми процессами
*****************************************************

::
    
    autosphinx -l &  # launch background job
    jobs  # list background jobs, add -l for PIDs
    fg %1  # put job #1 into foreground
    # Ctrl+Z: put foreground process on pause
    bg  # continue running process in the background
    kill -HUP %1  # send hangup to the process
    disown %1  # detach job from terminal

Kerberos-авторизация
+++++++++++++++++++++++++++++++

Есть машины kdc, server и ws. Домен mynet, dns имеется. 

Требуется настроить так, чтобы с рабочей станции ws можно было через ssh войти на server, авторизовавшись через Kerberos, установленный на kdc. Чтобы приблизить задачу к реальности, добавим недефолтные настройки sshd.

Защищаем SSHD
*********************

Сервер KDC должен быть хорошо защищен. 
Для этого ставится минимальный Centos, sshd вешается на нестандартный порт и настраивается так, чтобы войти можно было только при наличии и ключа шифрования, и пароля.
Оставим вход под root (решение, несомненно, спорное) -- по умолчанию он разрешен, только добавим требование публичного ключа.

Нестандартный порт недостаточно прописать в /etc/ssh/sshd_config в строчке Port. 
Нужно настроить firewall.

Для этого создадим и добавим в конфигурацию новый файл описания сервиса ssh для firewalld::
    
    cd /usr/lib/firewalld/services
    cp ssh.xml ssh-custom.xml
    vi ssh-custom.xml  # Change port
    firewall-cmd --permanent --remove-service='ssh'
    firewall-cmd --permanent --add-service='ssh-custom'

Не забудем про selinux::
    
    dnf provides /usr/sbin/semanage
    dnf install policycoreutils-python-utils
    semanage port -a -t ssh_port_t -p tcp 23422 

Заодно посмотрим, что пропускает firewalld, и уберем лишнее::
    
    firewall-cmd --list-services
    firewall-cmd --permanent --remove-service='cockpit'
    firewall-cmd --permanent --remove-service='dhcpv6-client'

Перезапустим сервисы, проверим::
    
    systemctl restart sshd
    lsof -i  # if installed
    firewall-cmd --reload
    firewall-cmd --list-services  # shoud be ssh-custom only

и c рабочей станции::
    
    ssh -p 23422 root@kdc

Логин по паролю должен пройти без проблем.
Начнем разбираться с сертификатами. На рабочей станции::
    
    ssh-keygen -t rsa
    ssh-copy-id -i ~/.ssh/id_rsa.pub -p 23422 root@kdc
    ssh -p 23422 root@kdc
    restorecon -Rv ~/.ssh   # on kdc
    systemctl restart sshd

Теперь можно войти без пароля, если есть ключ, и с паролем, если ключа нет.
Это не совсем то, что мы хотели. Нам надо было, чтобы для входа ключ был обязателен.
Для этого необходимо в файл /etc/ssh/sshd_config добавить строчку::
    
    AuthenticationMethods "publickey,password"

Желательно вместо изначального файла /etc/ssh/sshd_config с комментариями и т.п. поставить файл с ясными и компактными настройками, например, такой::

    Protocol 2
    Port 23422
    ListenAddress 192.168.68.80
    HostKey /etc/ssh/ssh_host_rsa_key
    HostKey /etc/ssh/ssh_host_ecdsa_key
    HostKey /etc/ssh/ssh_host_ed25519_key
    SyslogFacility AUTHPRIV
    AuthenticationMethods "publickey,password"
    PermitRootLogin yes
    AuthorizedKeysFile      .ssh/authorized_keys
    PasswordAuthentication yes
    ChallengeResponseAuthentication no
    GSSAPIAuthentication no
    GSSAPICleanupCredentials no
    UsePAM yes
    X11Forwarding no
    PrintMotd no

Источники:

* https://wiki.centos.org/HowTos/Network/SecuringSSH
* https://man.openbsd.org/sshd_config.5

Настраиваем KDC
**************************

На машине kdc::
    
    dnf install krb5-server
    vi /var/kerberos/krb5kdc/kdc.conf  # change realm
    vi /var/kerberos/krb5kdc/kadm5.acl  # change realm
    vi /etc/krb5.conf  # change realm and kdc fqdn
    kdb5_util create -s -r MYNET  # master password here!
    
Note:
    
    Для замены в vi можно использовать команды::

    :%s/EXAMPLE\.COM/MYNET/g
    :%s/example\.com/mynet/g

Запускаемся::
    systemctl enable krb5kdc
    systemctl enable kadmin
    systemctl start krb5kdc
    systemctl start kadmin
    firewall-cmd --add-service=kerberos --permanent
    firewall-cmd --add-service=kadmin --permanent
    firewall-cmd --reload

Создаем принципалов с помощью утилиты ``kadmin.local``. Далее команды внутри утилиты::
    
    addprinc root/admin
    addprinc myuser
    addprinc -randkey host/kdc.mynet
    ktadd host/kdc.mynet
    quit

Источники:

* https://codingbee.net/rhce/rhce-kerberos
* https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/7/html/system-level_authentication_guide/configuring_a_kerberos_5_server

Настраиваем server
*****************************

На машине server, куда мы должны будем заходить через ssh с авторизацией в Kerberos::
    
    dnf install krb5-workstation

Нужно скопировать файл /etc/krb5.conf на server.

