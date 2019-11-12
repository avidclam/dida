<?xml version="1.0" encoding="utf-8"?>
<!-- Created by Leo: http://leoeditor.com/leo_toc.html -->
<leo_file xmlns:leo="http://leoeditor.com/namespaces/leo-python-editor/1.1" >
<leo_header file_format="2"/>
<globals/>
<preferences/>
<find_panel_settings/>
<vnodes>
<v t="avidclam.20191107104201.2"><vh>@settings</vh>
<v t="avidclam.20191107232933.1"><vh>@string medium-font-size = 9pt</vh></v>
<v t="avidclam.20191107232835.1"><vh>@string small-font-size = 8pt</vh></v>
<v t="avidclam.20191107232544.1"><vh>@string font-size = 9pt </vh></v>
<v t="avidclam.20191107104237.1"><vh>@bool rst3_call_docutils = False</vh></v>
<v t="avidclam.20191107111310.1"><vh>@string rst3_write_intermediate_extension = .rst</vh></v>
</v>
<v t="avidclam.20191107150325.1"><vh>Фрагменты</vh>
<v t="avidclam.20191107160728.1"><vh>Создать проект на GitHub</vh></v>
<v t="avidclam.20191107162101.1"><vh>Настроить .gitignore</vh></v>
<v t="avidclam.20191107150449.1"><vh>Создать среду python</vh></v>
<v t="avidclam.20191107154943.1"><vh>conf.py</vh></v>
</v>
<v t="avidclam.20191107122350.1"><vh>dida</vh>
<v t="avidclam.20191107113327.1"><vh>@rst index</vh>
<v t="avidclam.20191111122556.1"><vh>@rst-no-head intro</vh></v>
<v t="avidclam.20191111122650.1"><vh>@rst-no-head toctree</vh></v>
<v t="avidclam.20191111122732.1"><vh>@rst-no-head &lt;index-entries&gt;</vh></v>
<v t="avidclam.20191111122801.1"><vh>@rst-no-head footer</vh></v>
</v>
<v t="avidclam.20191107105031.1"><vh>@rst this-site</vh>
<v t="avidclam.20191107135638.1"><vh>Требуется</vh></v>
<v t="avidclam.20191107105156.1"><vh>Технологии</vh></v>
<v t="avidclam.20191107145156.1"><vh>Действия</vh>
<v t="avidclam.20191107160728.1"></v>
<v t="avidclam.20191107162101.1"></v>
<v t="avidclam.20191107150449.1"></v>
<v t="avidclam.20191107163123.1"><vh>Настроить sphinx</vh></v>
<v t="avidclam.20191107233624.1"><vh>Выбрать редактор</vh></v>
<v t="avidclam.20191108133333.1"><vh>Настроить livereload</vh></v>
<v t="avidclam.20191108140816.1"><vh>Настроить Read the Docs</vh></v>
</v>
<v t="avidclam.20191107160103.1"><vh>Файлы</vh>
<v t="avidclam.20191107171459.1"><vh>conf.py</vh></v>
<v t="avidclam.20191108140008.1"><vh>livereload</vh></v>
</v>
</v>
<v t="avidclam.20191108073206.1"><vh>@rst leo</vh></v>
<v t="avidclam.20191112105836.1"><vh>@rst Linux</vh>
<v t="avidclam.20191112105856.1"><vh>Bash</vh>
<v t="avidclam.20191112105906.1"><vh>Работа с фоновыми процессами</vh></v>
</v>
</v>
<v t="avidclam.20191108144631.1"><vh>@rst useful-url</vh>
<v t="avidclam.20191108144810.1"><vh>reStructuredText</vh></v>
</v>
<v t="avidclam.20191111073339.1"><vh>@rst autosphinx</vh></v>
</v>
</vnodes>
<tnodes>
<t tx="avidclam.20191107104201.2"></t>
<t tx="avidclam.20191107104237.1"></t>
<t tx="avidclam.20191107105031.1">Этот сайт
=========

</t>
<t tx="avidclam.20191107105156.1">- Python + Sphinx + sphinx-rtd-theme
- Редактор leo
- livereload
- git, GitHub, Read the Docs
</t>
<t tx="avidclam.20191107111310.1"></t>
<t tx="avidclam.20191107113327.1"></t>
<t tx="avidclam.20191107122350.1">@language python
"""
Auto-fills index entries into index.rst file 
by rewriting '@rst-no-head &lt;index-entries&gt;' node.
Finally, executes 'rst3' command.
"""

target_ending = '&lt;index-entries&gt;'
idx_node = p.firstChild()  # assumes index node is the first one
idx_subnodes = idx_node.children()
idx_entries_node = None
for subnode in idx_subnodes:
    if subnode.h.endswith(target_ending):
        idx_entries_node = subnode
        break
if idx_entries_node is not None:
    content_nodes = idx_node.following_siblings()
    rst_names = [nd.h[5:] for nd in content_nodes if nd.h.startswith('@rst ')]
    idx_entries_node.b = '   ' + '\n   '.join(rst_names) + '\n'

c.executeMinibufferCommand('rst3')
</t>
<t tx="avidclam.20191107135638.1">- создавать заметки в текстовом редакторе
- генерировать на их основе статический сайт с нужной структурой, синтаксической разметкой кода и т.п.
- размещать созданный сайт на своем домене, не связываясь с хостинг-провайдерами</t>
<t tx="avidclam.20191107145156.1"></t>
<t tx="avidclam.20191107150325.1"></t>
<t tx="avidclam.20191107150449.1">::

    alias venv='source venv/bin/activate'
    python3 -m venv venv
    venv
    pip install -U pip</t>
<t tx="avidclam.20191107154943.1">.. literalinclude :: conf.py
   :language: python</t>
<t tx="avidclam.20191107160103.1"></t>
<t tx="avidclam.20191107160728.1">Если не настроен локальный git, то выполнить::

    git config --global user.name "Your Name"
    git config --global user.email "your.email@your-place.com"
    git config --global alias.hist "log --oneline --graph --decorate --all"

На GitHub нажать Create a new repository:

- выбрать Owner (себя или одну из созданных ранее Организаций), 
- задать Repository name и Description, 
- отметить "Initialize this repository with a README", 
- Add .gitignore: Python,
- задать лицензию, например, MIT

Далее на компе::

    cd ~/work
    git clone https://github.com/avidclam/dida.git  # см. repo url
    cd dida  # см. имя проекта
    git mv README.md README.rst  # если хочется
    vi README.rst  # ... и сделать описание в формате RST
    git add .
    git commit -m 'Local repo ready'
    git push</t>
<t tx="avidclam.20191107162101.1">В дополнение к .gitignore, который предлагает github, можно добавить::

    /sandbox/
    /log/
    *.orig
</t>
<t tx="avidclam.20191107163123.1">В директории проекта (например, ``~/work/dida``) выполнить::

    pip install sphinx
    pip install sphinx-rtd-theme
    mkdir docs
    cd docs
    sphinx-quickstart

На вопрос "Separate source and build directories (y/n) [n]:" ответить n
(не принципиально, но структура директорий будет немного отличаться).

Получившийся файл ``conf.py`` подправить по образцу, см. `Файлы`_.
</t>
<t tx="avidclam.20191107171459.1">.. code-block:: python

    project = 'Project Name'
    copyright = '2019, Project Author'
    author = 'Project Author'
    release = '0.1.0'
    master_doc = 'index'
    extensions = []
    templates_path = ['_templates']
    language = 'ru'
    exclude_patterns = ['_build']
    html_theme = 'sphinx_rtd_theme'
    html_static_path = ['_static']</t>
<t tx="avidclam.20191107232544.1">**Important**: This should be set by each user.</t>
<t tx="avidclam.20191107232835.1">A small font size used by default in the status area.</t>
<t tx="avidclam.20191107232933.1">A small font size used by default in the check boxes in the Find tab.</t>
<t tx="avidclam.20191107233624.1">Здесь используется :ref:`chapter_leo`, удачный инструмент редактирования документации.
</t>
<t tx="avidclam.20191108073206.1">.. _chapter_leo:

Редактор Leo
============

В проекте используется редактор `Leo Editor &lt;https://leoeditor.com&gt;`_. Это довольно специфическая среда редактирования/программирования, обладающая при всей непривычности несколькими привлекательными для данного проекта особенностями:

- Во-первых, Leo написан на python и инсталлируется привычной командой ``pip install leo``. 
- Во-вторых, вся текстовая часть сайта, с учетом структуры, сохраняется в едином файле (внешние ресурсы --- картинки, pdf-файлы и т.п. --- нужно держать отдельно). 
- В-третьих, единица редактирования --- не файл, а блок текста (outline). Структура контента хорошо видна, удобно редактировать мелкие фрагменты, а потом собирать из них сайт. Набор rst-файлов, готовых для обработки sphinx, генерируется одной командой. 
- И наконец, есть "клоны", т.е. синхронно обновляемые блоки, которые могут использоваться независимо. Изменение одного из клонов приводит к автоматическому обновлению соответствующих фрагментов других страниц сайта.

Для примера ниже приводится сриншот панели Outline на момент редактирования главы "Этот сайт".

.. figure:: _static/screenshots/leo.png
    :align: center

Примечательно следующее:

- под @settings можно переопределять системные параметры, даже такие "глобальные" как размер шрифта
- rst3_call_docutils = False говорит системе, что использется Sphinx а не docutils
- заметки под @rst this-site объединяются в единый файл this-site.rst, причем заголовки заметок становятся заголовками подразделов
- некоторые заметки, такие как "Настроить проект на GitHub" --- это клоны заметок, подготовленных во "Фрагментах"
- генерация rst-файлов происходит по команде ``rst3``, заданной в минибуфере</t>
<t tx="avidclam.20191108133333.1">Команда ``make html`` в директории ``docs`` запускает Sphinx для создания сайта из подготовленных rst-файлов. Пакет `livereload &lt;https://github.com/lepture/python-livereload&gt;`_ автоматически запускает sphinx при каждом изменении исходных файлов и обеспечивает локальный веб-доступ к созданному сайту.

После установки пакета командой ``pip install livereload`` нужно, как описано в Readme livereload, создать исполняемый скрипт (см. ниже), допустим, ``bin/livereload`` и запускать его командой::

    ./bin/livereload &gt; ./log/livereload.log &amp;2&gt;1 &amp;

Обновляемый сайт доступен по адресу http://localhost:5500/index.html

Можно воспользоваться скриптом :ref:`chapter_autosphinx`.
</t>
<t tx="avidclam.20191108140008.1">.. literalinclude :: ../bin/livereload
   :language: python</t>
<t tx="avidclam.20191108140816.1">Использование Read the Docs интуитивно. Основные действия по импорту проекта из GitHub проводятся на странице `списка проектов &lt;https://readthedocs.org/dashboard&gt;`_. Полезные возможности хорошо описаны в `документации &lt;https://docs.readthedocs.io/en/stable/&gt;`_:

- `Размещение на своём домене &lt;https://docs.readthedocs.io/en/stable/custom_domains.html&gt;`_
- `Привязка Google Analytics к сайту &lt;https://docs.readthedocs.io/en/stable/guides/google-analytics.html&gt;`_</t>
<t tx="avidclam.20191108144631.1">Полезные ссылки
===============

Ниже, без особой системы, даны ссылки на полезные ресурсы.</t>
<t tx="avidclam.20191108144810.1">- `Online Sphinx editor &lt;https://livesphinx.herokuapp.com&gt;`_</t>
<t tx="avidclam.20191111073339.1">.. _chapter_autosphinx:

autosphinx --- скрипт для livereload
====================================

Скрипт `livereload &lt;https://github.com/lepture/python-livereload&gt;`_
для запуска Sphinx и пересборки html-документации 
при изменении исходных rst-файлов, был доработан и назван ``autosphinx``.

Его можно запускать из директории проекта, папки docs или еще на один
уровень ниже, например, docs/source.

Ключ ``-l`` перенаправляет вывод в лог-файл log/autosphinx.log

Типичный запуск будет выглядеть примерно так::
    
    autosphinx -p 5501 -w -3 -l&amp;

Код скрипта ниже:

.. literalinclude :: ../bin/autosphinx
   :language: python</t>
<t tx="avidclam.20191111122556.1">.. meta::
   :keywords: linux, python, sphinx, reStructuredText

Записки самоучки
================

Некогда, буквально восприняв ``#learntocode``, я без особого труда прошел отличный вводный курс "`Программирование на Python &lt;https://stepik.org/course/67/promo&gt;`_" и решил, что так победим. Очень скоро однако выяснилось, что для мало-мальски полезного проекта требуются хотя бы базовые навыки в куче смежных технологий. 

Не то чтобы они были неподъемны. Проблема в том, что интуитивность --- не сильная сторона компьютерных технологий, и без постоянного использования полученные знания немедленно выветриваются из головы.

Чтобы не читать снова и снова одни и те же *Getting Started*, я стал записывать для себя (и тут же терять) краткие инструкции, а когда познакомился со Sphinx, решил оформлять новые заметки сразу в виде сайта и держать всё на `GitHub &lt;https://github.com/&gt;`_ и `Read the Docs &lt;https://readthedocs.org/&gt;`_, т.е. под рукой.</t>
<t tx="avidclam.20191111122650.1">.. toctree::
   :maxdepth: 1
   :caption: Содержание:</t>
<t tx="avidclam.20191111122732.1">   this-site
   leo
   Linux
   useful-url
   autosphinx
</t>
<t tx="avidclam.20191111122801.1">Указатели и поиск
=================

* :ref:`search`

Ключевые слова: Linux, Python, Sphinx, reStructuredText</t>
<t tx="avidclam.20191112105836.1">Linux
=====</t>
<t tx="avidclam.20191112105856.1"></t>
<t tx="avidclam.20191112105906.1">::
    
    autosphinx -l &amp;  # launch background job
    jobs  # list background jobs, add -l for PIDs
    fg %1  # put job #1 into foreground
    # Ctrl+Z: put foreground process on pause
    bg  # continue running process in the background
    kill -HUP %1  # send hangup to the process
    disown %1  # detach job from terminal</t>
</tnodes>
</leo_file>
