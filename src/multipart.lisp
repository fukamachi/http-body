(in-package :cl-user)
(defpackage http-body.multipart
  (:use :cl)
  (:import-from :fast-http
                :make-multipart-parser)
  (:import-from :cl-utilities
                :collecting
                :collect)
  (:export :multipart-parse))
(in-package :http-body.multipart)

(defun multipart-parse (content-type stream)
  (collecting
    (let ((parser (make-multipart-parser
                   content-type
                   (lambda (name headers field-meta body)
                     (collect (cons name (list body field-meta headers)))))))
      (loop with buffer = (make-array 1024 :element-type '(unsigned-byte 8))
            for read-bytes = (read-sequence buffer stream)
            do (funcall parser (if (= read-bytes 1024)
                                   buffer
                                   (subseq buffer 0 read-bytes)))
            while (= read-bytes 1024)))))
