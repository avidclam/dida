.. rst3: filename: selinux

SELinux
=======

Ниже конспект документации RHEL8 --- *Using SELinux*.

Введение
++++++++++++++++

SELinux реализует MAC (Mandatory Access Control).
Задача --- иметь возможность настроить политики вида "*субъекту* (не) разрешено над *объектом* *действие*", например, "веб-сервер не может читать файлы в домашних директориях пользователей".
 
С каждым процессом или системным ресурсом ассоциирован *SELinux context* a.k.a. *label*.
Контексты используются в *правилах*, которые определяют, как процессам разрешено взаимодействовать друг с другом и с ресурсами. Правила объединяются в *политики* SELinux, которые, кстати, применяются **после** традиционных политик доступа. Действие разрешается только тогда, когда существует политика, явно его разрешающая.

Контекст состоит из user, role, type и security level. 
Политики чаще опираются на type, а не на контекст целиком.
Название типа заканчивается на **_t**. Пример::
    
    httpd_t  # Web server
    http_port_t  # Web server port
    httpd_sys_content  # Web server content in /var/www/html/
    tmp_t  # content of /tmp and /var/tmp

Контексту httpd_t разрешен ряд действий с контекстом httpd_sys_content. Например, таких::
    
    allow httpd_t httpd_sys_content_t:dir { getattr ioctl lock open read search };
    allow httpd_t httpd_sys_content_t:file { getattr ioctl lock map open read };
    
В этом можно убедиться::
    
    dnf install setools-console
    sesearch --allow | grep httpd_t | grep http_sys_content_t

Режимы
++++++++++++

В SELinux три режима: ``enforcing`` "вкл", ``permissive`` "понарошку": пишет в журнал, но не блокирует, ``disabled`` "выкл".

Текущий режим отображается командой ``getenforce``. Статус --- ``sestatus``.

Переключение в Permissive: ``setenforce 0``, постоянное::
    
    # in /etc/selinux/config:
    SELINUX=permissive
    SELINUXTYPE=targeted
    #
    reboot

Переключение в Enabled: ``setenforce 1``, постоянное::
    
    fixfiles -F onboot  # создаст /.autorelabel для переразметки файлов, созданных без меток SELinux
    # in /etc/selinux/config:
    SELINUX=enforcing
    SELINUXTYPE=targeted
    #
    reboot

Возникающие при включении SELinux ошибки можно отследить в audit log утилитой ``ausearch``.
Также полезен пакет setroubleshoot-server.

Пример
++++++++++++

Требуется настроить работу Apache httpd на порту 3131 и предоставить досуп к /var/test_www.

Note:
    
    Потребуется пакет policycoreutils-python-utils

Проверяем, на каких портах SELinux ожидает встретить httpd, добавляем нужный нестандартный порт, а затем применяем контекст стандартной директории /var/www к нестандартной /var/test_www::
    
    semanage port -l | grep http
    semanage port -a -t http_port_t -p tcp 3131
    #
    matchpathcon /var/www/html
    semanage fcontext -a -e /var/www /var/test_www
    restorecon -Rv /var/

Изменить контекст можно также командой ``chcon``. 
Однако результат не сохранится, если будет запушен relabel системы или команда restorecon.

Посмотреть, из-за чего в приложениях возникают проблемы SELinux, можно командой ``sealert -l "*"``

Посмотреть контекст SELinux для процессов и директорий можно командами::
    
    ps -eZ
    ls -ldZ

Booleans
++++++++

Важную роль в настройке SELinux играют переменные-выключатели --- "booleans", принимающие значение 0 или 1.

Список всех переменных доступен по команде ``getsebool -a``. 

Установка переменной проводится командой ``setsebool``. Например::
    
    setsebool -P samba_export_all_rw 1

