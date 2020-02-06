.. rst3: filename: python

Python
======

pytest
++++++



Fixtures
********

К слову об интуитивности ...

Допустим, нужно в тест-функции использовать какие-то данные, 
скажем, ``{'x': 1, 'a': 'one'}``.
Для этого в файле ``tests/conftest.py`` создается fixture:

.. code-block:: python

    data_x_a = {'x': 1, 'a': 'one'}
    
    @pytest.fixture(name='data_x_a')
    def data_x_a_fixture():
        return data_x_a

Теперь данные можно использовать в своих sandbox-скриптах,

.. code-block:: python

    from tests.conftest import data_x_a
    # some code

и тестовая функция может принимать ``data_x_a``:

.. code-block:: python

    def test_data(data_x_a):
        assert 'x' in data_x_a
        assert 'a' in data_x_a

В составе pytest есть и готовые к использованию fixtures, 
такие как `tmp_path <http://doc.pytest.org/en/latest/tmpdir.html>`_
(временная директория) или
`capsys <https://docs.pytest.org/en/latest/reference.html?highlight=capsys#capsys>`_
(перехват вывода в stdout/stderr).
Их не нужно явно импортировать.

Проверка исключений
*************************************

Протестировать на исключения можно с помощью
`pytest.raises <https://docs.pytest.org/en/latest/reference.html#pytest-raises>`_.

.. code-block:: python

    def test_exception(data_x_a):
        with pytest.raises(KeyError, match=r"nonexistent"):
            data_x_a['nonexistent']

Перехват stdout/stderr
******************************

.. code-block:: python

    def test_stdout(capsys):
        msg = 'Go capture stdout'
        print(msg)
        captured = capsys.readouterr()
        assert captured.out == msg + "\n"

Версии и публикация
++++++++++++++++++++++++++++++++++++

Версия --- это tag. Например, версия 1.0.15 --- это тэг v1.0.15

Для выпуска версии можно делать специальный коммит, куда войдут только изменения номера версии в __init__.py и/или setup.py и сразу помечать его, например::
    
    git tag -a v1.0.15 -m 'version 1.0.15'

Далее, как обычно, ``git push`` и не забыть все опубликовать::
    
    rm -rf dist
    python setup.py sdist bdist_wheel
    twine upload --repository-url https://test.pypi.org/legacy/ dist/*
    twine upload dist/*


Полезная статья на тему: `Build Your First Open Source Python Project <https://towardsdatascience.com/build-your-first-open-source-python-project-53471c9942a7>`_.

