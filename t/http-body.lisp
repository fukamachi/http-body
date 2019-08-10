(in-package :cl-user)
(defpackage http-body-test
  (:use :cl
        :http-body
        :assoc-utils
        :prove))
(in-package :http-body-test)

(plan nil)

(is (parse "application/json"
           (length "{\"name\":\"Eitaro\"}")
           (flex:make-in-memory-input-stream (trivial-utf-8:string-to-utf-8-bytes "{\"name\":\"Eitaro\"}")))
    '(("name" . "Eitaro"))
    "application/json")

(is (parse "application/x-www-form-urlencoded"
           (length "name=Eitaro")
           (flex:make-in-memory-input-stream (trivial-utf-8:string-to-utf-8-bytes "name=Eitaro")))
    '(("name" . "Eitaro"))
    "application/x-www-form-urlencoded")

(let ((data (format nil "------------0xKhTmLbOuNdArY~C~CContent-Disposition: form-data; name=\"name\"~:*~:*~C~C~:*~:*~C~CEitaro~:*~:*~C~C------------0xKhTmLbOuNdArY--"
                    #\Return #\Newline)))
  (ok (alistp
       (parse "multipart/form-data; boundary=----------0xKhTmLbOuNdArY"
              (length data)
              (flex:make-in-memory-input-stream (trivial-utf-8:string-to-utf-8-bytes data))))
      "multipart/form-data"))

(is (parse "text/plain"
           3
           (flex:make-in-memory-input-stream (trivial-utf-8:string-to-utf-8-bytes "Foo")))
    nil)

(finalize)
