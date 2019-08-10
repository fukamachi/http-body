#|
  This file is a part of http-body project.
  Copyright (c) 2014 Eitaro Fukamachi
|#

#|
  Author: Eitaro Fukamachi
|#

(in-package :cl-user)
(defpackage http-body-asd
  (:use :cl :asdf))
(in-package :http-body-asd)

(defsystem http-body
  :version "0.1"
  :author "Eitaro Fukamachi"
  :license "BSD 2-Clause"
  :depends-on (:fast-http
               :jonathan
               :trivial-gray-streams
               :quri
               :flexi-streams
               :babel
               :cl-ppcre
               :cl-utilities)
  :components ((:module "src"
                :components
                ((:file "http-body" :depends-on ("multipart" "json" "urlencoded" "util"))
                 (:file "multipart" :depends-on ("json" "urlencoded" "util"))
                 (:file "json" :depends-on ("util"))
                 (:file "urlencoded" :depends-on ("util"))
                 (:file "util"))))
  :description "HTTP POST data parser for Common Lisp"
  :long-description
  #.(with-open-file (stream (merge-pathnames
                             #p"README.markdown"
                             (or *load-pathname* *compile-file-pathname*))
                            :if-does-not-exist nil
                            :direction :input)
      (when stream
        (let ((seq (make-array (file-length stream)
                               :element-type 'character
                               :fill-pointer t)))
          (setf (fill-pointer seq) (read-sequence seq stream))
          seq)))
  :in-order-to ((test-op (test-op http-body-test))))
