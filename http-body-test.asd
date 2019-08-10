#|
  This file is a part of http-body project.
  Copyright (c) 2014 Eitaro Fukamachi
|#

(in-package :cl-user)
(defpackage http-body-test-asd
  (:use :cl :asdf))
(in-package :http-body-test-asd)

(defsystem http-body-test
  :author "Eitaro Fukamachi"
  :license "BSD 2-Clause"
  :depends-on (:http-body
               :cl-ppcre
               :trivial-utf-8
               :assoc-utils
               :flexi-streams
               :prove)
  :components ((:module "t"
                :components
                ((:test-file "http-body")
                 (:test-file "json")
                 (:test-file "multipart")
                 (:test-file "urlencoded"))))

  :defsystem-depends-on (:prove-asdf)
  :perform (test-op :after (op c)
                    (funcall (intern #.(string :run-test-system) :prove-asdf) c)
                    (asdf:clear-system c)))
