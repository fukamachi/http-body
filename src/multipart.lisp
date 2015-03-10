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

(defun multipart-parse (content-type content-length stream)
  (collecting
    (let ((parser (make-multipart-parser
                   content-type
                   (lambda (name headers field-meta body)
                     (collect (cons name (list body field-meta headers))))))
          (buffer (make-array content-length :element-type '(unsigned-byte 8))))
      (read-sequence buffer stream)
      (funcall parser buffer))))
