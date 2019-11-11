.. rst3: filename: autosphinx

.. _chapter_autosphinx:

autosphinx --- скрипт для livereload
====================================

Скрипт `livereload <https://github.com/lepture/python-livereload>`_
для запуска Sphinx и пересборки html-документации 
при изменении исходных rst-файлов, был доработан и назван ``autosphinx``.

Его можно запускать из директории проекта, папки docs или еще на один
уровень ниже, например, docs/source.

Ключ ``-l`` перенаправляет вывод в лог-файл log/autosphinx.log

Типичный запуск будет выглядеть примерно так::
    
    autosphinx -p 5501 -w -3 -l&

Код скрипта ниже:

.. literalinclude :: ../bin/autosphinx
   :language: python

