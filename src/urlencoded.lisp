(in-package :cl-user)
(defpackage http-body.urlencoded
  (:use :cl)
  (:import-from :fast-http.byte-vector
                :digit-byte-char-p
                :digit-byte-char-to-integer)
  (:import-from :fast-io
                :fast-write-byte
                :make-output-buffer
                :finish-output-buffer)
  (:import-from :trivial-utf-8
                :utf-8-bytes-to-string)
  (:import-from :xsubseq
                :xsubseq
                :xnconcf
                :with-xsubseqs)
  (:import-from :cl-utilities
                :collecting
                :collect)
  (:export :urlencoded-parse))
(in-package :http-body.urlencoded)

(define-condition invalid-urlencoded (simple-error) ())

(defun url-decode (bytes)
  (declare (type (simple-array (unsigned-byte 8) (*)) bytes)
           (optimize (speed 3) (safety 2)))
  (collecting
    (let* ((p 0)
           (end (length bytes))
           (byte (aref bytes p))
           (parsing-name t)
           (current-parsing-name nil)
           (parsing-encoded-part nil)
           (buffer (make-output-buffer)))
      (flet ((collect-value ()
               (collect
                   (cons current-parsing-name
                         (utf-8-bytes-to-string (finish-output-buffer buffer))))
               (setq current-parsing-name nil)
               (setq parsing-name (not parsing-name))
               (setq buffer (make-output-buffer)))
             (collect-name ()
               (setq current-parsing-name
                     (utf-8-bytes-to-string (finish-output-buffer buffer)))
               (setq parsing-name nil)
               (setq buffer (make-output-buffer))))
        (macrolet ((goto (tag)
                     `(locally (declare (optimize (speed 3) (safety 0)))
                        (incf p)
                        (when (= p end)
                          (go exit))
                        (setq byte (aref bytes p))
                        (go ,tag))))
          (tagbody
           start
             (cond
               ((= byte #.(char-code #\=))
                (unless parsing-name
                  (error 'invalid-urlencoded))
                (collect-name))
               ((= byte #.(char-code #\&))
                (when parsing-name
                  (error 'invalid-urlencoded))
                (collect-value))
               ((= byte #.(char-code #\%))
                (goto parse-encoded-part))
               ((= byte #.(char-code #\+))
                (fast-write-byte #.(char-code #\Space) buffer))
               (T (fast-write-byte byte buffer)))
             (goto start)

           parse-encoded-part
             (setq parsing-encoded-part
                   (* 16 (cond
                           ((digit-byte-char-p byte)
                            (digit-byte-char-to-integer byte))
                           ((<= #.(char-code #\A) byte #.(char-code #\F))
                            (- byte #.(- (char-code #\A) 10)))
                           ((<= #.(char-code #\a) byte #.(char-code #\f))
                            (- byte #.(- (char-code #\a) 10)))
                           (T (error 'invalid-urlencoded)))))
             (goto parse-encoded-part-second)

           parse-encoded-part-second
             (fast-write-byte
              (+ parsing-encoded-part
                 (cond
                   ((digit-byte-char-p byte)
                    (digit-byte-char-to-integer byte))
                   ((<= #.(char-code #\A) byte #.(char-code #\F))
                    (- byte #.(- (char-code #\A) 10)))
                   ((<= #.(char-code #\a) byte #.(char-code #\f))
                    (- byte #.(- (char-code #\a) 10)))
                   (T (error 'invalid-urlencoded))))
              buffer)
             (setq parsing-encoded-part nil)
             (goto start)

           exit
             (when parsing-encoded-part ;; EOF
               (error 'invalid-urlencoded))
             (if parsing-name
                 (collect
                     (cons (utf-8-bytes-to-string (finish-output-buffer buffer)) nil))
                 (collect-value))))))))

;; TODO: parse as streaming
(defun urlencoded-parse (content-type stream)
  (declare (ignore content-type))
  (url-decode
   (with-xsubseqs (seq)
     (loop with buffer = (make-array 1024 :element-type '(unsigned-byte 8))
           for read-bytes = (read-sequence buffer stream)
           do (xnconcf seq (xsubseq buffer 0 read-bytes))
           while (= read-bytes 1024)))))
