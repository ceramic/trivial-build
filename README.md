# trivial-build

[![Build Status](https://travis-ci.org/ceramic/trivial-build.svg?branch=master)](https://travis-ci.org/ceramic/trivial-build)
[![Coverage Status](https://coveralls.io/repos/ceramic/trivial-build/badge.svg?branch=master&service=github)](https://coveralls.io/github/ceramic/trivial-build?branch=master)

Compile a system into an executable.

# Overview

trivial-build launches a new process of whichever implementation you're running,
loads a system, sets up an entrypoint, and dumps the executable. The Lisp
subprocess then dies, much like those deep-sea squids that die giving birth.

# Usage

```lisp
CL-USER> (build :system-name
                "(code-to-execute-on-startup)"
                #p"path/to/output.exe")
```

Example:

```lisp
CL-USER> (trivial-build:build :uiop
                              "(format t \"~A~%\" 1)"
                              #p"/home/eudoxia/binary")
Launch: "/usr/local/bin/sbcl"  --eval "(ql:quickload :UIOP)" --eval "(setf uiop:*image-entry-point* #'(lambda () (format t \"~A~%\" 1)))" --eval "(uiop:dump-image #P\"/home/eudoxia/binary\" :executable t
  #+sb-core-compression :compression #+sb-core-compression t)"

This is SBCL 1.2.9, an implementation of ANSI Common Lisp.
More information about SBCL is available at <http://www.sbcl.org/>.

SBCL is free software, provided as is, with absolutely no warranty.
It is mostly in the public domain; some portions are provided under
BSD-style licenses.  See the CREDITS and COPYING files in the
distribution for more information.
To load "uiop":
  Load 1 ASDF system:
    uiop
; Loading "uiop"

[undoing binding stack and other enclosing state... done]
[saving current Lisp image into /home/eudoxia/binary:
writing 5824 bytes from the read-only space at 0x20000000
writing 3168 bytes from the static space at 0x20100000
writing 56950784 bytes from the dynamic space at 0x1000000000
done]
#P"/home/eudoxia/binary"
```

And the output:

```
$[ eudoxia@laptop ] ~
$> ./binary
1
$[ eudoxia@laptop ] ~
$>
```

# License

Copyright (c) 2015 Fernando Borretti

Licensed under the MIT License.
