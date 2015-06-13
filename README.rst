Colorized output in GHCi
========================

This repository provides a Haskell module containing a colorizing
pretty-print function to be used as the interactive printer in a GHCi
session.

Installation
------------

1. Build & install the package using Cabal.
2. Install the file ``scripts/dot-ghci`` into ``~/.ghci``, or amend
   your existing file. Make sure to adjust the path to the files
   installed in the next step.
3. Copy ``scripts/ghci-{boot,onload}`` into ``~/.ghc``.

Background
----------

GHCi allows providing a custom pretty printer used to format output.
However, when a new module is loaded using `:load`, or a `:reload` is
issued, the custom pretty print function will go out of scope (since
the scope is reset upon (re-)load). To work around this issue, the
scripts provided here override these commands and make sure that the
pretty-printer is brought back in scope after a reload.

``ghci-boot`` contains everything that will survive a reload.
``ghci-onload`` imports the pretty-print function, and will be sourced
anew after a reload. It is also convenient to make additions here to
add imports which should always be active after a reload.
