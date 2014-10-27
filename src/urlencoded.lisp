(in-package :cl-user)
(defpackage http-body.urlencoded
  (:use :cl)
  (:import-from :quri
                :url-decode-params)
  (:import-from :xsubseq
                :xsubseq
                :xnconcf
                :with-xsubseqs)
  (:export :urlencoded-parse))
(in-package :http-body.urlencoded)

;; TODO: parse as streaming
(defun urlencoded-parse (content-type stream)
  (declare (ignore content-type))
  (url-decode-params
   (with-xsubseqs (seq)
     (loop with buffer = (make-array 1024 :element-type '(unsigned-byte 8))
           for read-bytes = (read-sequence buffer stream)
           do (xnconcf seq (xsubseq buffer 0 read-bytes))
           while (= read-bytes 1024)))))
