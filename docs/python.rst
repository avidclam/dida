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

    @pytest.fixture()
    def data_x_a():
        return {'x': 1, 'a': 'one'}

Теперь тестовая функция может принимать ``data_x_a``.

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

