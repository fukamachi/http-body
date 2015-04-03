(in-package :cl-user)
(defpackage http-body.urlencoded
  (:use :cl)
  (:import-from :http-body.util
                :slurp-stream)
  (:import-from :quri
                :url-decode-params)
  (:export :urlencoded-parse))
(in-package :http-body.urlencoded)

(defun urlencoded-parse (content-type content-length stream)
  (declare (ignore content-type))
  (url-decode-params (slurp-stream stream content-length) :lenient t))
