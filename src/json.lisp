(in-package :cl-user)
(defpackage http-body.json
  (:use :cl)
  (:import-from :jsown
                :parse)
  (:import-from :trivial-utf-8
                :utf-8-bytes-to-string)
  (:export :json-parse))
(in-package :http-body.json)

(defun json-parse (content-type stream)
  (declare (ignore content-type))
  (let ((buffer (make-array 1024 :element-type '(unsigned-byte 8))))
    (cdr
     (jsown:parse
      (apply #'concatenate
             'string
             (loop for read-bytes = (read-sequence buffer stream)
                   collect (utf-8-bytes-to-string buffer :end read-bytes)
                   while (= read-bytes 1024)))))))
