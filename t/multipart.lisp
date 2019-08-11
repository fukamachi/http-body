(in-package :cl-user)
(defpackage http-body-test.multipart
  (:use :cl
        :http-body.multipart
        :assoc-utils
        :prove))
(in-package :http-body-test.multipart)

(plan 7)

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
Content-Type: text/plain

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


------------0xKhTmLbOuNdArY
Content-Disposition: form-data; name=\"json\"
Content-Type: application/json

{\"id\": \"nitro_idiot\"}
------------0xKhTmLbOuNdArY--"
                           (format nil "~C~C" #\Return #\Newline)))

(defun data-stream ()
  (flex:make-in-memory-input-stream (trivial-utf-8:string-to-utf-8-bytes *data*)))

(ok (alistp
     (multipart-parse "multipart/form-data; boundary=----------0xKhTmLbOuNdArY"
                      (length *data*)
                      (data-stream)))
    "association-list-p")

(let ((value (multipart-parse "multipart/form-data; boundary=----------0xKhTmLbOuNdArY"
                              (length *data*)
                              (data-stream))))
  (subtest "text1"
    (let ((text1 (aget value "text1")))
      (is text1 "Ratione accusamus aspernatur aliquam")))
  (subtest "text2"
    (let ((text2 (aget value "text2")))
      (is text2 "")))
  (subtest "select"
    (let ((select (remove-if-not (lambda (key) (equal key "select"))
                                 value
                                 :key #'car)))
      (is (length select) 2)
      (is (cdr (first select)) "A")
      (is (cdr (second select)) "B")))
  (subtest "textarea"
    (let ((textarea (aget value "textarea")))
      (is-type textarea 'string)
      (is (ppcre:regex-replace-all (format nil "~C" #\Return) textarea "")
          "Voluptatem cumque voluptate sit recusandae at. Et quas facere rerum unde esse. Sit est et voluptatem. Vel temporibus velit neque odio non.

Molestias rerum ut sapiente facere repellendus illo. Eum nulla quis aut. Quidem voluptas vitae ipsam officia voluptatibus eveniet. Aspernatur cupiditate ratione aliquam quidem corrupti. Eos sunt rerum non optio culpa.")))
  (subtest "upload"
    (let ((upload (aget value "upload")))
      (is-type upload 'cons)
      (is-type (first upload) 'stream)))
  (subtest "json"
    (let ((json (aget value "json")))
      (is json '(("id" . "nitro_idiot"))))))

(finalize)
