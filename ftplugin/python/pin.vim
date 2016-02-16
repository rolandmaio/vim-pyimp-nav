" Vim File Type Plugin for navigating Python module imports.
" Last Change: February 13, 2016
" Maintainer: Roland Maio <rolandmaio38@gmail.com>

if !has("python")
    echo "This Vim instance does not support Python 2."
    echo "Aborting loading Python Import Navigation plugin."
    finish
endif

if exists("g:loaded_pin")
    finish
endif
let g:loaded_pin = 1

if !exists(":PINGo")
    command -nargs=0 PINGo :call <SID>openFile()
else
    echo "PINGo command is already mapped."
    echo "Aborting loading Python Import Navigation plugin."
    finish
endif

let s:save_cpo = &cpo
set cpo&vim


function s:openFile()
python << EOF

import sys
import ast
import vim
import os.path
import pkgutil

try:

    cWORD = vim.eval("expand('<cWORD>')")
    cword = vim.eval("expand('<cword>')")
    cline = vim.eval("getline('.')")

    if cWORD in ["import", "from", "as"]:
        raise ValueError(
            "The current word is an import statement keyword: "
            "'import', 'from', 'as'."
        )

    # Parse the current line into an abstract syntax tree. This should
    # fail if the current line is not syntactically correct Python 2.
    try:
        lineTree = ast.parse(cline)
    except SyntaxError as se:
        print se
        raise ImportError(
            "Import navigation failed. There is a syntax error on the "
            "cursor's line.\n\n"
            "Note: PIN only considers the current line of source code the "
            "cursor is on.\n"
            "Is this line a syntactically correct import statement?"
        )
    except TypeError as te:
        print te
        raise ImportError(
            "Import navigation failed. There are null bytes on the cursor's "
            "line.\n\n"
            "Note: PIN only considers the current line of source code the "
            "cursor is on.\n"
        )

    # Extract the subtree rooted at the Import or ImportFrom node
    # associated to the lexeme given by cword.
    # If there is no import statement in lineTree raise a ValueError
    def checkNames(tree):
        for node in ast.walk(tree):
            if isinstance(node, ast.alias) and\
               (node.name == cword or\
                node.asname == cword or\
                node.name == cWORD):
                return True
        return False

    def extractImportTree(tree):
        """
        Return the subtree rooted at the import statement containing
        the descendant cword.
        """
        if len(tree.body) == 1:
            node = tree.body[0]
            if isinstance(node, ast.Import) or\
               isinstance(node, ast.ImportFrom):
                return node
        for node in ast.walk(tree):
            if isinstance(node, ast.Import) and checkNames(node):
                return node
            if isinstance(node, ast.ImportFrom) and\
               (checkNames(node) or cWORD == node.module):
                return node
        raise ValueError("The current word is not part of an import statement")

    importTree = extractImportTree(lineTree)

    # Extract the module that contains cword; this may be cword itself.
    def extractModule(tree):
        """ Return the module name containing cword """
        if isinstance(tree, ast.Import):
            return extractModuleFromImport(tree)
        else:
            return extractModuleFromImportFrom(tree)

    def extractModuleFromImport(tree):
        """ Return the name of the module containing cword.

        tree must be an ast.Import node. It is therefore the case
        that for one of tree's ast.alias nodes:
            1) cword and cWORD are equal to the asname of the alias
                OR
            2) cWORD is equal to the name of the alias and cword is
               equal to one of the dot delimited name components
        """
        if not isinstance(tree, ast.Import):
            raise TypeError("Did not receive an ast.Import node.")
        for node in tree.names:
            if cword == node.asname:
                return node.name
            if cWORD in [node.name, node.asname]:
                return node.name
        raise ValueError(
            "ast.Import node tree does not contain a descendant "
            "with the current word under the cursor."
        )

    def extractModuleFromImportFrom(tree):
        """ Return the name of the module containing cword.

        tree must be an ast.ImportFrom node. Therefore either:
            1) cWORD is equal to the tree's module attribute and cword
               is equal to one of the dot delimited components of module
                OR
            2) cword and cWORD are equal to the name or asname of one of
               the ast.alias child nodes of tree
        """
        if not isinstance(tree, ast.ImportFrom):
            raise TypeError("Did not receive an ast.ImportFrom node.")
        if tree.module is None:
            packagePath = os.path.dirname(vim.eval("expand('%:p')"))
            sys.path.append(packagePath)
            module = os.path.basename(packagePath)
            tree.module = module
            global cWORD
            if cWORD == '.':
                cWORD = module
        if cWORD == tree.module:
            return cWORD
        for node in tree.names:
            if cword in [node.name, node.asname]:
                if pkgutil.get_loader(node.name) is not None:
                    return node.name
                else:
                    return tree.module
        raise ValueError(
            "ast.ImportFrom node tree does not contain a descendant "
            "with the current word under the cursor."
        )

    module = extractModule(importTree)
    package = pkgutil.get_loader(module)

    if os.path.isdir(package.filename):
        if os.path.isfile(os.path.join(package.filename, "__init__.py")):
            filename = os.path.join(package.filename, "__init__.py")
        else:
            raise ValueError("Unable to locate the module's file")
    else:
        filename = package.filename

    vim.command("tabnew {file}".format(file=filename))

except ImportError as ie:
    print ie
except ValueError as ve:
    print ve
except TypeError as te:
    print te

EOF
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
