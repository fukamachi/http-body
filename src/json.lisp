(in-package :cl-user)
(defpackage http-body.json
  (:use :cl)
  (:import-from :http-body.util
                :slurp-stream
                :detect-charset)
  (:import-from :yason)
  (:export :json-parse))
(in-package :http-body.json)

(defun json-parse (content-type content-length stream)
  (let ((yason:*parse-object-as* :alist))
    (yason:parse
     (babel:octets-to-string (slurp-stream stream content-length)
                             :encoding (detect-charset content-type :utf-8)))))
