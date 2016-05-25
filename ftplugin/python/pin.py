import sys
import ast
import vim
import os.path
import pkgutil

class Pin:

    def __init__(self):
        self.cWORD = vim.eval("expand('<cWORD>')")
        self.cword = vim.eval("expand('<cword>')")
        self.cline = vim.eval("getline('.')")

        if self.cWORD in ["import", "from", "as"]:
            raise ValueError(
                "The current word is an import statement keyword: "
                "'import', 'from', 'as'."
            )

        # Parse the current line into an abstract syntax tree. This should
        # fail if the current line is not syntactically correct Python 2.
        try:
            self.lineTree = ast.parse(self.cline)
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

        importTree = self.extractImportTree(self.lineTree)
        module = self.extractModule(importTree)
        package = pkgutil.get_loader(module)

        if os.path.isdir(package.filename):
            if os.path.isfile(os.path.join(package.filename, "__init__.py")):
                filename = os.path.join(package.filename, "__init__.py")
            else:
                raise ValueError("Unable to locate the module's file")
        else:
            filename = package.filename

        vim.command("tabnew {file}".format(file=filename))


    def extractImportTree(self, tree):
        """
        Return the subtree rooted at the import statement containing
        the descendant cword.
        """
        # Extract the subtree rooted at the Import or ImportFrom node
        # associated to the lexeme given by cword.
        # If there is no import statement in lineTree raise a ValueError
        def checkNames(tree):
            for node in ast.walk(tree):
                if isinstance(node, ast.alias) and\
                   (node.name == self.cword or\
                    node.asname == self.cword or\
                    node.name == self.cWORD):
                    return True
            return False

        if len(tree.body) == 1:
            node = tree.body[0]
            if isinstance(node, ast.Import) or\
               isinstance(node, ast.ImportFrom):
                return node
        for node in ast.walk(tree):
            if isinstance(node, ast.Import) and checkNames(node):
                return node
            if isinstance(node, ast.ImportFrom) and\
               (checkNames(node) or self.cWORD == node.module):
                return node
        raise ValueError("The current word is not part of an import statement")

    # Extract the module that contains cword; this may be cword itself.
    def extractModule(self, tree):
        """ Return the module name containing cword """
        if isinstance(tree, ast.Import):
            return self.extractModuleFromImport(tree)
        else:
            return self.extractModuleFromImportFrom(tree)

    def extractModuleFromImport(self, tree):
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
            if self.cword == node.asname:
                return node.name
            if self.cWORD in [node.name, node.asname]:
                return node.name
        raise ValueError(
            "ast.Import node tree does not contain a descendant "
            "with the current word under the cursor."
        )

    def extractModuleFromImportFrom(self, tree):
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
            if self.cWORD == '.':
                self.cWORD = module
        if self.cWORD == tree.module:
            return self.cWORD
        for node in tree.names:
            if self.cword in [node.name, node.asname]:
                if pkgutil.get_loader(node.name) is not None:
                    return node.name
                else:
                    return tree.module
        raise ValueError(
            "ast.ImportFrom node tree does not contain a descendant "
            "with the current word under the cursor."
        )

try:
    Pin()
except ImportError as ie:
    print ie
except ValueError as ve:
    print ve
except TypeError as te:
    print te
