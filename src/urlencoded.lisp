(in-package :cl-user)
(defpackage http-body.urlencoded
  (:use :cl)
  (:import-from :quri
                :url-decode-params)
  (:export :urlencoded-parse))
(in-package :http-body.urlencoded)

;; TODO: parse as streaming
(defun urlencoded-parse (content-type stream)
  (declare (ignore content-type))
  (url-decode-params
   (if (typep stream 'flex:vector-stream)
       (coerce (flex::vector-stream-vector stream) '(simple-array (unsigned-byte 8) (*)))
       (apply #'concatenate
              '(simple-array (unsigned-byte 8) (*))
              (loop with buffer = (make-array 1024 :element-type '(unsigned-byte 8))
                    for read-bytes = (read-sequence buffer stream)
                    collect (subseq buffer 0 read-bytes)
                    while (= read-bytes 1024))))))
