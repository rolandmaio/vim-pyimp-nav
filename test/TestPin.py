import os
import sys
import unittest
import tempfile

class Vim:

    expr2attr = {
        "expand('<cWORD>')": "cWORD",
        "expand('<cword>')": "cword",
        "getline('.')": "cline",
        "expand('%:p')": "pkgpath"
    }

    def __init__(self):
        self.isMock = True
        self.mockImport("", "", "", "")

    def mockImport(self, cWORD, cword, cline, pkgpath):
        self.cWORD = cWORD
        self.cword = cword
        self.cline = cline
        self.pkgpath = pkgpath

    def eval(self, expr):
        return getattr(self, Vim.expr2attr[expr])

    def command(self, cmd):
        pass

class TestPin(unittest.TestCase):

    vim = Vim()

    @classmethod
    def modifyPath(cls):
        """ Append the directory containing pin.py to sys.path. """
        abspath = os.path.abspath(__file__)
        testdir, tail = os.path.split(abspath)
        basedir, tail = os.path.split(testdir)
        sys.path.append(os.path.join(basedir, "ftplugin", "python"))

    @classmethod
    def setUpClass(cls):
        # Set up vim module for test imports
        sys.modules['vim'] = TestPin.vim

        # import PIN
        TestPin.modifyPath()
        with tempfile.TemporaryFile(mode="w") as tmp:
            stdout = sys.stdout
            sys.stdout = tmp
            from pin import Pin
            global Pin
            sys.stdout = stdout

    @classmethod
    def tearDownClass(cls):
        sys.modules['vim'] = None

    def test_import_statement_keywords(self):
        """
        Verify that Pin.navigate raises a ValueError whenever an import
        statement keyword is the cword (in such a case cword == cWORD).
        """
        for keyword in ["import", "from", "as"]:
            TestPin.vim.mockImport(keyword, keyword, "", "")
            with self.assertRaises(ValueError) as cm:
                Pin().navigate()


if __name__ == "__main__":
    unittest.main()
