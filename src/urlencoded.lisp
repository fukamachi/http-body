(in-package :cl-user)
(defpackage http-body.urlencoded
  (:use :cl)
  (:import-from :quri
                :url-decode-params)
  (:export :urlencoded-parse))
(in-package :http-body.urlencoded)

;; TODO: parse as streaming
(defun urlencoded-parse (content-type content-length stream)
  (declare (ignore content-type))
  (url-decode-params
   (if (typep stream 'flex:vector-stream)
       (coerce (flex::vector-stream-vector stream) '(simple-array (unsigned-byte 8) (*)))
       (let ((buffer (make-array content-length :element-type '(unsigned-byte 8))))
         (read-sequence buffer stream)
         buffer))
   :lenient t))
