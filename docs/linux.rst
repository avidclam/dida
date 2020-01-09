.. rst3: filename: linux

Linux, разные мелочи
====================

Что происходит?
++++++++++++++++++++++++++++



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

