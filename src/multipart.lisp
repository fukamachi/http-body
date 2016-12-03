(in-package :cl-user)
(defpackage http-body.multipart
  (:use :cl)
  (:import-from :http-body.util
                :slurp-stream)
  (:import-from :fast-http
                :make-multipart-parser)
  (:import-from #:babel
                #:octets-to-string)
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
                     (collect (cons name
                                    (list (if (gethash "content-type" headers)
                                              ;; TODO: Convert the body into a text if the Content-Type is text.
                                              body
                                              ;; No Content-Type implies the body is a text data.
                                              (babel:octets-to-string (slurp-stream body)))
                                          field-meta headers)))))))
      (if content-length
          (let ((buffer (make-array content-length :element-type '(unsigned-byte 8))))
            (read-sequence buffer stream)
            (funcall parser buffer))
          (loop with buffer = (make-array 1024 :element-type '(unsigned-byte 8))
                for read-bytes = (read-sequence buffer stream)
                do (funcall parser (subseq buffer 0 read-bytes))
                while (= read-bytes 1024))))))
