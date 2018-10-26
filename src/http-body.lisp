(in-package :cl-user)
(defpackage http-body
  (:use :cl)
  (:export :parse))
(in-package :http-body)

(defparameter *content-type-map*
  '(("application/json" . http-body.json:json-parse)
    ("application/x-www-form-urlencoded" . http-body.urlencoded:urlencoded-parse)
    ("multipart/form-data" . http-body.multipart:multipart-parse)))

(defun parse (content-type content-length stream)
  (loop for (type . fn) in *content-type-map*
        when (and (<= (length type) (length content-type))
                  (string-equal content-type type :end1 (length type)))
          do (return-from parse (values (funcall fn content-type content-length stream) t)))
  (values nil nil))
