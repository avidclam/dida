<?xml version="1.0" encoding="utf-8"?>
<!-- Created by Leo: http://leoeditor.com/leo_toc.html -->
<leo_file xmlns:leo="http://leoeditor.com/namespaces/leo-python-editor/1.1" >
<leo_header file_format="2"/>
<globals/>
<preferences/>
<find_panel_settings/>
<vnodes>
<v t="avidclam.20191107104201.2"><vh>@settings</vh>
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
<v t="avidclam.20191107113327.1"><vh>@rst index</vh></v>
<v t="avidclam.20191107105031.1"><vh>@rst this-site</vh>
<v t="avidclam.20191107135638.1"><vh>Требуется</vh></v>
<v t="avidclam.20191107105156.1"><vh>Технологии</vh></v>
<v t="avidclam.20191107145156.1"><vh>Действия</vh>
<v t="avidclam.20191107160728.1"></v>
<v t="avidclam.20191107162101.1"></v>
<v t="avidclam.20191107150449.1"></v>
<v t="avidclam.20191107163123.1"><vh>Настроить sphinx</vh></v>
</v>
<v t="avidclam.20191107160103.1"><vh>Файлы</vh>
<v t="avidclam.20191107154943.1"></v>
</v>
</v>
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
- git, GitHub, Read the Rocs
</t>
<t tx="avidclam.20191107111310.1"></t>
<t tx="avidclam.20191107113327.1">Записки самоучки
================

Некогда, буквально восприняв ``#learntocode``, я без особого труда прошел отличный вводный курс "`Программирование на Python &lt;https://stepik.org/course/67/promo&gt;`_" и решил, что так победим. Очень скоро однако выяснилось, что для мало-мальски полезного проекта требуются хотя бы базовые навыки в куче смежных технологий. 

Не то чтобы они были неподъемны. Проблема в том, что интуитивность --- не сильная сторона компьютерных технологий, и без постоянного использования полученные знания немедленно выветриваются из головы.

Чтобы не читать снова и снова одни и те же *Getting Started*, я стал записывать для себя (и тут же терять) краткие инструкции, а когда познакомился со Sphinx, решил оформлять новые заметки сразу в виде сайта и держать всё на `GitHub &lt;https://github.com/&gt;`_ и `Read the Docs &lt;https://readthedocs.org/&gt;`_, т.е. под рукой.

.. toctree::
   :maxdepth: 1
   :caption: Содержание:

   this-site

Указатели и поиск
=================

* :ref:`genindex`
* :ref:`search`

Ключевые слова: Linux, Python, Sphinx
</t>
<t tx="avidclam.20191107122350.1"></t>
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

На вопрос "Separate source and build directories (y/n) [n]:" ответить n.

Получившийся файл ``conf.py`` подправить по образцу, см. `Файлы`_.
</t>
</tnodes>
</leo_file>
