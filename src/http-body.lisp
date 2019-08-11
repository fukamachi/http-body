(in-package :cl-user)
(defpackage http-body
  (:use :cl)
  (:import-from :http-body.util
                :starts-with)
  (:export :parse))
(in-package :http-body)

(defparameter *content-type-map*
  '(("application/json" . http-body.json:json-parse)
    ("application/x-www-form-urlencoded" . http-body.urlencoded:urlencoded-parse)
    ("multipart/" . http-body.multipart:multipart-parse)))

(defun parse (content-type content-length stream)
  (loop for (type . fn) in *content-type-map*
        when (starts-with type content-type)
          do (let ((results (multiple-value-list
                              (funcall fn content-type content-length stream))))
                (return-from parse (apply #'values (first results) t (rest results)))))
  (values nil nil))
