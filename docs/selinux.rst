.. rst3: filename: selinux

Ниже конспект документации RHEL8 --- *Using SELinux*.

Введение в SELinux
+++++++++++++++++++++++++++

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

