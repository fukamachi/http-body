(in-package :cl-user)
(defpackage http-body.json
  (:use :cl)
  (:import-from :st-json
                :read-json
                :jso-alist)
  (:import-from :trivial-gray-streams
                :fundamental-character-input-stream)
  (:export :json-parse))
(in-package :http-body.json)

(defun ensure-car (thing)
  (if (consp thing)
      (car thing)
      thing))

(defun json-parse (content-type stream)
  (declare (ignore content-type))
  ;; Using st-json because it takes a stream and returns an association-list.
  (st-json::jso-alist
   (ensure-car
    (st-json:read-json
     (if (typep stream 'trivial-gray-streams:fundamental-character-input-stream)
         stream
         (flex:make-flexi-stream stream))))))
