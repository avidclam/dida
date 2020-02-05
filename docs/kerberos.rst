.. rst3: filename: kerberos

Kerberos-авторизация
====================

Итак, есть машины ``kdc``, ``server`` и ``ws``. Домен ``mynet``, dns имеется. 

Требуется настроить так, чтобы с рабочей станции ws можно было через ssh войти на server, авторизовавшись через Kerberos, установленный на kdc. Чтобы приблизить задачу к реальности, добавим недефолтные настройки sshd.

Защищаем SSHD
+++++++++++++++++++++

Сервер KDC должен быть хорошо защищен. 
Для этого ставится минимальный Centos, sshd вешается на нестандартный порт и настраивается так, чтобы войти можно было только при наличии и ключа, и пароля.
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
    lsof -i  # if lsof is installed
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
Это не совсем то, что мы хотели. Нам надо было, чтобы пароль для входа был обязателен.
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
++++++++++++++++++++++++++

На машине ``kdc``::
    
    dnf install krb5-server
    vi /var/kerberos/krb5kdc/kdc.conf  # change realm
    vi /var/kerberos/krb5kdc/kadm5.acl  # change realm
    vi /etc/krb5.conf  # set up realm and kdc fqdn
    kdb5_util create -s -r MYNET  # master password here!

Кстати, для замены в vi можно использовать команды::

    :%s/EXAMPLE\.COM/MYNET/g
    :%s/example\.com/mynet/g

Запускаемся::
    
    systemctl enable krb5kdc
    systemctl enable kadmin
    systemctl start krb5kdc
    systemctl start kadmin
    firewall-cmd --add-service=kerberos --permanent
    firewall-cmd --add-service=kadmin --permanent
    firewall-cmd --add-service=kpasswd --permanent
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
+++++++++++++++++++++++++++++

На машине ``server``, куда мы должны будем заходить через ssh с авторизацией в Kerberos,
нужно создать пользователя, например, ``myuser`` и запретить соединения под root::
    
    useradd myuser
    passwd -l myuser  # krb5 password only
    dnf install krb5-workstation

Нужно скопировать файл /etc/krb5.conf на server и настроить sshd.
Файл /etc/ssh/sshd_config будет выглядеть примерно так::
    
    HostKey /etc/ssh/ssh_host_rsa_key
    HostKey /etc/ssh/ssh_host_ecdsa_key
    HostKey /etc/ssh/ssh_host_ed25519_key
    SyslogFacility AUTHPRIV
    PermitRootLogin no
    AuthorizedKeysFile      .ssh/authorized_keys
    PasswordAuthentication yes
    ChallengeResponseAuthentication no
    KerberosAuthentication yes
    KerberosOrLocalPasswd yes
    GSSAPIAuthentication no
    GSSAPICleanupCredentials no
    UsePAM yes
    X11Forwarding no

Перезапустим sshd::
    
    systemctl restart sshd
    
Теперь при входе по ssh пароли будут проверяться в kerberos. Конфигурировать рабочую станцию ws не потребовалось.

Кстати, после входа на server можно проверить работу сервиса смены пароля kerberos::
    
    kpasswd

Доменный вход
+++++++++++++++++++++++++

Для того, чтобы не просто проверять пароль через Kerberos, а иметь возможность, 
однажды авторизовавшись, входить без пароля, пока действует ticket, нужны другие настройки.

Сначала нужно внести ``server`` в KDC, запустив ``kadmin`` на машине server и задав следующие команды::
    
    addprinc -randkey host/server.mynet
    ktadd host/server.mynet

Затем установить SSSD::
    
    dnf install sssd

и настроить, создав файл /etc/sssd/sssd.conf::
    
    [sssd]
        services = nss, pam
        domains = MYNET
    
    [domain/MYNET]
        id_provider = files
        auth_provider = krb5
        krb5_realm = MYNET
        krb5_server = kdc.mynet
        krb5_validate = true

Файл /etc/ssh/sshd_config нужно поменять таким образом, чтобы работала не встроенная авторизация Kerberos, а внешняя::
    
    HostKey /etc/ssh/ssh_host_rsa_key
    HostKey /etc/ssh/ssh_host_ecdsa_key
    HostKey /etc/ssh/ssh_host_ed25519_key
    SyslogFacility AUTHPRIV
    PermitRootLogin no
    AuthorizedKeysFile      .ssh/authorized_keys
    PasswordAuthentication yes
    ChallengeResponseAuthentication no
    #KerberosAuthentication yes
    #KerberosOrLocalPasswd yes
    GSSAPIAuthentication yes
    GSSAPICleanupCredentials yes
    UsePAM yes
    X11Forwarding no

Далее::
    
    chmod 600 /etc/sssd/sssd.conf
    systemctl start sssd
    systemctl restart sshd

На рабочей станции ``ws`` необходимо также установить ``krb5-workstation``, скопировать содержимое /etc/krb5.conf и аналогично внести рабочую станцию в KDC с помощью kadmin.
Теперь вход по ssh нужно проводить в два этапа::
    
    kinit
    ssh server

