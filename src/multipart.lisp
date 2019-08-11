(in-package :cl-user)
(defpackage http-body.multipart
  (:use :cl)
  (:import-from :http-body.json
                :json-parse)
  (:import-from :http-body.urlencoded
                :urlencoded-parse)
  (:import-from :http-body.util
                :slurp-stream
                :starts-with)
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
                     (let ((content-type (gethash "content-type" headers)))
                       (collect (cons name
                                      (cond
                                        ((gethash "filename" field-meta)
                                         (list body field-meta headers))
                                        ((or
                                           ;; No Content-Type implies the body is a text data.
                                           (null content-type)
                                           ;; Convert the body into a text if the Content-Type is text.
                                           (starts-with "text/" content-type))
                                         (babel:octets-to-string (slurp-stream body)))
                                        ((starts-with "application/json" content-type)
                                         (json-parse content-type nil body))
                                        ((starts-with "application/x-www-form-urlencoded" content-type)
                                         (urlencoded-parse content-type nil body))
                                        (t (slurp-stream body))))))))))
      (if content-length
          (let ((buffer (make-array content-length :element-type '(unsigned-byte 8))))
            (read-sequence buffer stream)
            (funcall parser buffer))
          (loop with buffer = (make-array 1024 :element-type '(unsigned-byte 8))
                for read-bytes = (read-sequence buffer stream)
                do (funcall parser (subseq buffer 0 read-bytes))
                while (= read-bytes 1024))))))
