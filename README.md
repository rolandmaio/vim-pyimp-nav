# PIN: Python Import Navigation

PIN is still under active development and not yet suitable for release, sorry! We hope that this
will change soon.

## Overview

PIN is a Vim plugin for navigating Python import statements.

Specifically, given an import statement in a Python file, PIN allows you to open the file that
provides the Python module being imported. This is done by examining the `__file__` attribute
of the imported module, consequently, the file may not be Python source code.

## Installation

PIN can be installed via [Pathogen][Pathogen]. Assuming [Pathogen][Pathogen] is installed and
that you are using a Linux box, run the following in a terminal.

    cd ~/.vim/bundle
    git clone https://github.com/rolandmaio/vim-pyimp-nav.git

Alternatively, PIN may be installed by placing a copy of `imp_nav.vim` in your Python ftplugin
directory.

[Pathogen]: https://github.com/tpope/vim-pathogen
