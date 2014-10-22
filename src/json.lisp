(in-package :cl-user)
(defpackage http-body.json
  (:use :cl)
  (:import-from :st-json
                :read-json
                :jso-alist)
  (:import-from :trivial-gray-streams
                :fundamental-character-input-stream)
  (:import-from :trivial-utf-8
                :utf-8-bytes-to-string)
  (:export :json-parse))
(in-package :http-body.json)

(defun json-parse (content-type stream)
  (declare (ignore content-type))
  ;; Using st-json because it takes a stream and returns an association-list.
  (st-json::jso-alist
   (car
    (st-json:read-json
     (if (typep stream 'trivial-gray-streams:fundamental-character-input-stream)
         stream
         (flex:make-flexi-stream stream))))))
