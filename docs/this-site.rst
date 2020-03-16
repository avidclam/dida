.. rst3: filename: this-site

Этот сайт
=========

Требуется
++++++++++++++++++

- создавать заметки в текстовом редакторе
- генерировать на их основе статический сайт с нужной структурой, синтаксической разметкой кода и т.п.
- размещать созданный сайт на своем домене, не связываясь с хостинг-провайдерами

Технологии
++++++++++++++++++++

- Python + Sphinx + sphinx-rtd-theme
- Редактор leo
- livereload
- git, GitHub, Read the Docs

Действия
++++++++++++++++



Создать проект на GitHub
***************************************

Если не настроен локальный git, то выполнить::

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
    git push

Настроить .gitignore
*****************************

В дополнение к .gitignore, который предлагает github, можно добавить::

    /sandbox/
    /log/
    *.orig

Создать среду python
********************************

::

    alias venv='source venv/bin/activate'
    python3 -m venv venv
    venv
    pip install -U pip

Настроить sphinx
*************************

В директории проекта (например, ``~/work/dida``) выполнить::

    pip install sphinx
    pip install sphinx-rtd-theme
    mkdir docs
    cd docs
    sphinx-quickstart

На вопрос "Separate source and build directories (y/n) [n]:" ответить n
(не принципиально, но структура директорий будет немного отличаться).

Получившийся файл ``conf.py`` подправить по образцу, см. `Файлы`_.

Выбрать редактор
*******************************

Здесь используется :ref:`chapter_leo`, удачный инструмент редактирования документации.

Настроить livereload
*****************************

Команда ``make html`` в директории ``docs`` запускает Sphinx для создания сайта из подготовленных rst-файлов. Пакет `livereload <https://github.com/lepture/python-livereload>`_ автоматически запускает sphinx при каждом изменении исходных файлов и обеспечивает локальный веб-доступ к созданному сайту.

После установки пакета командой ``pip install livereload`` нужно, как описано в Readme livereload, создать исполняемый скрипт (см. ниже), допустим, ``bin/livereload`` и запускать его командой::

    ./bin/livereload > ./log/livereload.log &2>1 &

Обновляемый сайт доступен по адресу http://localhost:5500/index.html

Можно воспользоваться скриптом :ref:`chapter_autosphinx`.

Настроить Read the Docs
********************************

Использование Read the Docs интуитивно. Основные действия по импорту проекта из GitHub проводятся на странице `списка проектов <https://readthedocs.org/dashboard>`_. Полезные возможности хорошо описаны в `документации <https://docs.readthedocs.io/en/stable/>`_:

- `Размещение на своём домене <https://docs.readthedocs.io/en/stable/custom_domains.html>`_
- `Привязка Google Analytics к сайту <https://docs.readthedocs.io/en/stable/guides/google-analytics.html>`_

Файлы
++++++++++



conf.py
*******

.. code-block:: python

    project = 'Project Name'
    copyright = '2020, Project Author'
    author = 'Project Author'
    release = '0.1.0'
    master_doc = 'index'
    extensions = []
    templates_path = ['_templates']
    language = 'ru'
    exclude_patterns = ['_build']
    html_theme = 'sphinx_rtd_theme'
    html_static_path = ['_static']

livereload
**********

.. literalinclude :: ../bin/livereload
   :language: python

