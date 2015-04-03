(in-package :cl-user)
(defpackage http-body.util
  (:use :cl)
  (:import-from :flexi-streams
                :vector-stream
                :vector-stream-vector)
  (:export :slurp-stream
           :detect-charset))
(in-package :http-body.util)

(defun slurp-stream (stream &optional content-length)
  (if (typep stream 'flex:vector-stream)
      (coerce (flex::vector-stream-vector stream) '(simple-array (unsigned-byte 8) (*)))
      (if content-length
          (let ((buffer (make-array content-length :element-type '(unsigned-byte 8))))
            (read-sequence buffer stream)
            buffer)
          (apply #'concatenate
                 '(simple-array (unsigned-byte 8) (*))
                 (loop with buffer = (make-array 1024 :element-type '(unsigned-byte 8))
                       for read-bytes = (read-sequence buffer stream)
                       collect (subseq buffer 0 read-bytes)
                       while (= read-bytes 1024))))))

(defun parse-content-type (content-type)
  (let ((types
          (nth-value 1
                     (ppcre:scan-to-strings "^\\s*?(\\w+)/(\\w+)(?:\\s*;\\s*charset=([A-Za-z0-9_-]+))?"
                                            content-type))))
    (when types
      (values (aref types 0)
              (aref types 1)
              (aref types 2)))))

(defun detect-charset (content-type)
  (multiple-value-bind (type subtype charset)
      (parse-content-type content-type)
    (declare (ignore type subtype))
    (cond
      ((null charset)
       babel:*default-character-encoding*)
      ((string-equal charset "utf-8")
       :utf-8)
      ((string-equal charset "euc-jp")
       :eucjp)
      ((string-equal charset "shift_jis")
       :cp932)
      (T (or (find charset (babel:list-character-encodings)
                   :test #'string-equal)
             babel:*default-character-encoding*)))))
