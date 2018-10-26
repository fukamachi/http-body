(defpackage http-body.errors
  (:use :cl)
  (:export :http-body-error
           :http-body-parse-error))
(in-package :http-body.errors)

(define-condition http-body-error (error) ())

(define-condition http-body-parse-error (http-body-error)
  ((body :initarg :body)
   (format :initarg :format))
  (:report (lambda (condition stream)
             (with-slots (body format) condition
               (format stream "Invalid ~A format: ~S" format body)))))
