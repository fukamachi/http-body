# HTTP-Body

[![Build Status](https://travis-ci.org/fukamachi/http-body.svg?branch=master)](https://travis-ci.org/fukamachi/http-body)

HTTP-Body parses HTTP POST data and returns POST parameters. It supports application/x-www-form-urlencoded, application/json, and multipart/form-data.

## Usage

`http-body` package exports only a function `parse`, which takes exact 2 arguments -- a string of Content-Type and a stream of HTTP POST data.

```common-lisp
(http-body:parse "application/x-www-form-urlencoded"
                 body-stream)
;=> (("name" . "Eitaro"))
;   T
```

It returns parsed parameters in an association list.

If the Content-Type of first argument isn't supported, it returns `NIL`.

```common-lisp
(http-body:parse "text/plain" body-stream)
;=> NIL
;   NIL
```

## Installation

```common-lisp
(ql:quickload :http-body)
```

## Author

* Eitaro Fukamachi

## Copyright

Copyright (c) 2014 Eitaro Fukamachi

## License

Licensed under the BSD 2-Clause License.
