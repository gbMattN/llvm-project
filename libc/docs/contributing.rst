.. _contributing:

================================
Contributing to the libc Project
================================

LLVM-libc is being developed as part of the LLVM project so contributions
to the libc project should also follow the general LLVM
`contribution guidelines <https://llvm.org/docs/Contributing.html>`_. Below is
a list of open projects that one can start with:

#. **Beginner Bugs** - Help us tackle
   `good first issues <https://github.com/llvm/llvm-project/issues?q=is%3Aopen+is%3Aissue+label%3Alibc+label%3A%22good+first+issue%22>`__.
   These bugs have been tagged with the github labels "libc" and "good first
   issue" by the team as potentially easier places to get started.  Please do
   first check if the bug has an assignee; if so please find another unless
   there's been no movement on the issue from the assignee, in which place do
   ask if you can help take over.

#. **Cleanup code-style** - The libc project follows the general
   `LLVM style <https://llvm.org/docs/CodingStandards.html>`_ but differs in a
   few aspects: We use ``snake_case`` for non-constant variable and function
   names,``CamelCase`` for internal type names (those which are not defined in a
   public header), and ``CAPITALIZED_SNAKE_CASE`` for constants. When we started
   working on the project, we started using the general LLVM style for
   everything. However, for a short period, we switched to the style that is
   currently followed by the `LLD project <https://github.com/llvm/llvm-project/tree/main/lld>`_.
   But, considering that we implement a lot of functions and types whose names
   are prescribed by the standards, we have settled on the style described above.
   However, we have not switched over to this style in all parts of the ``libc``
   directory. So, a simple but mechanical project would be to move the parts
   following the old styles to the new style.

#. **Implement Linux syscall wrappers** - A large portion of the POSIX API can
   be implemented as syscall wrappers on Linux. A good number have already been
   implemented but many more are yet to be implemented. So, a project of medium
   complexity would be to implement syscall wrappers which have not yet been
   implemented.

#. **Update the clang-tidy lint rules and use them in the build and/or CI** -
   Currently, the :ref:`clang_tidy_checks` have gone stale and are mostly unused
   by the developers and on the CI builders. This project is about updating
   them and reintegrating them back with the build and running them on the
   CI builders.

#. **double and higher precision math functions** - These are under active
   development but you can take a shot at those not yet implemented. See
   :ref:`math` for more information.

#. **Contribute a new OS/Architecture port** - You can contribute a new
   operating system or target architecture port. See :ref:`porting` for more
   information.
