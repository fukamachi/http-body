(in-package :cl-user)
(defpackage http-body-test
  (:use :cl
        :http-body
        :trivial-types
        :prove))
(in-package :http-body-test)

(plan nil)

(is (parse "application/json"
           (flex:make-in-memory-input-stream (trivial-utf-8:string-to-utf-8-bytes "{\"name\":\"Eitaro\"}")))
    '(("name" . "Eitaro"))
    "application/json")

(is (parse "application/x-www-form-urlencoded"
           (flex:make-in-memory-input-stream (trivial-utf-8:string-to-utf-8-bytes "name=Eitaro")))
    '(("name" . "Eitaro"))
    "application/x-www-form-urlencoded")

(ok (association-list-p
     (parse "multipart/form-data; boundary=----------0xKhTmLbOuNdArY"
            (flex:make-in-memory-input-stream
             (trivial-utf-8:string-to-utf-8-bytes
              (format nil "------------0xKhTmLbOuNdArY~C~CContent-Disposition: form-data; name=\"name\"~:*~:*~C~C~:*~:*~C~CEitaro~:*~:*~C~C------------0xKhTmLbOuNdArY--"
                      #\Return #\Newline)))))
    "multipart/form-data")

(is (parse "text/plain"
           (flex:make-in-memory-input-stream (trivial-utf-8:string-to-utf-8-bytes "Foo")))
    nil)

(finalize)
