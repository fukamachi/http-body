(in-package :cl-user)
(defpackage http-body-test.multipart
  (:use :cl
        :http-body.multipart
        :trivial-types
        :prove))
(in-package :http-body-test.multipart)

(plan nil)

(defparameter *data*
  (ppcre:regex-replace-all "\\n"
                           "------------0xKhTmLbOuNdArY
Content-Disposition: form-data; name=\"text1\"

Ratione accusamus aspernatur aliquam
------------0xKhTmLbOuNdArY
Content-Disposition: form-data; name=\"text2\"


------------0xKhTmLbOuNdArY
Content-Disposition: form-data; name=\"select\"

A
------------0xKhTmLbOuNdArY
Content-Disposition: form-data; name=\"select\"

B
------------0xKhTmLbOuNdArY
Content-Disposition: form-data; name=\"textarea\"

Voluptatem cumque voluptate sit recusandae at. Et quas facere rerum unde esse. Sit est et voluptatem. Vel temporibus velit neque odio non.

Molestias rerum ut sapiente facere repellendus illo. Eum nulla quis aut. Quidem voluptas vitae ipsam officia voluptatibus eveniet. Aspernatur cupiditate ratione aliquam quidem corrupti. Eos sunt rerum non optio culpa.
------------0xKhTmLbOuNdArY
Content-Disposition: form-data; name=\"upload\"; filename=\"hello.lisp\"
Content-Type: application/octet-stream

#!/usr/bin/env sbcl --script

(format t \"Hello, World!~%\")


------------0xKhTmLbOuNdArY
Content-Disposition: form-data; name=\"upload1\"; filename=\"\"


------------0xKhTmLbOuNdArY
Content-Disposition: form-data; name=\"upload2\"; filename=\"hello.lisp\"
Content-Type: application/octet-stream

#!/usr/bin/env sbcl --script

(defun fact (n)
  (if (zerop n)
      1
      (* n (fact (1- n)))))


------------0xKhTmLbOuNdArY
Content-Disposition: form-data; name=\"upload3\"; filename=\"blank.lisp\"
Content-Type: application/octet-stream


------------0xKhTmLbOuNdArY
Content-Disposition: form-data; name=\"upload4\"; filename=\"0\"


------------0xKhTmLbOuNdArY--"
                           (format nil "~C~C" #\Return #\Newline)))

(ok (association-list-p
     (multipart-parse "multipart/form-data; boundary=----------0xKhTmLbOuNdArY"
                      (length *data*)
                      (flex:make-in-memory-input-stream (trivial-utf-8:string-to-utf-8-bytes *data*))))
    "association-list-p")

(finalize)
