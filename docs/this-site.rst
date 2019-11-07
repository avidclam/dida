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
- git, GitHub, Read the Rocs

Действия
++++++++++++++++



Создать проект на GitHub
***************************************

Если не настроен локальный git, то выполнить::

    git config --global user.name "Your Name"
    git config --global user.email "your.email@your-place.com"
    git config --global alias.hist "log --oneline --graph --decorate --all"

На GitHub:

- Create a new repository, 
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

На вопрос "Separate source and build directories (y/n) [n]:" ответить n.

Получившийся файл ``conf.py`` подправить так, чтобы получился примерно такой, как ниже в разделе `Файлы`_.

Файлы
++++++++++



conf.py
*******

.. literalinclude :: conf.py
   :language: python

