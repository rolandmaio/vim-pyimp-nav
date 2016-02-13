# PIN: Python Import Navigation

## Description.

PIN is a Vim plugin for navigating Python import statements.

Given an import statement in a Python file, PIN allows you to open the file that
provides the Python module being imported.

## Requirements

PIN requires that Vim be compiled with Python 2 support. PIN will check for this when it is loaded
and will abort loading if Python 2 is not available to it. However, while PIN uses Python 2, it
can navigate the import statements in Python 3 files.

## Installation

PIN can be installed via [Pathogen][Pathogen]. Assuming [Pathogen][Pathogen] is installed and
that you are using a Linux box, run the following in a terminal.

    cd ~/.vim/bundle
    git clone https://github.com/rolandmaio/vim-pyimp-nav.git

Alternatively, PIN may be installed by placing a copy of `pin.vim` in your Python ftplugin
directory.

## Usage

Once PIN is installed, simply position the cursor over the name of a module in an import statement
and execute the normal mode command `:PINGo` (do remap the command :D).

For example given the following:

```python
import foo as bar
from baz.bah import moo

spam = bar(ham)
```

If the cursor is over `foo` or `bar` then `:PINGo` will open the file for `foo` in another tab. 
If the cursor is over either `baz` or `bah`, `:PINGo` will open the file for `bah` in another tab
and if the cursor is over `moo`, it will open the file for `moo` if `moo` is a module, otherwise the file for `bah` from which `moo` is imported.

## Reporting Bugs

If PIN disappoints, then please report it and include the following information:
  1. The line of Python source code.
  2. The position of the cursor when `:PINGo` was executed.
  3. The path of the current working directory.
  4. The path of the target file.
  
[Pathogen]: https://github.com/tpope/vim-pathogen
