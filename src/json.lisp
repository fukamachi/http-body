(in-package :cl-user)
(defpackage http-body.json
  (:use :cl)
  (:import-from :http-body.util
                :slurp-stream
                :detect-charset)
  (:import-from :http-body.errors
                :http-body-parse-error)
  (:import-from :jonathan
                :parse)
  (:export :json-parse))
(in-package :http-body.json)

(defun json-parse (content-type content-length stream)
  (let* ((json (babel:octets-to-string (slurp-stream stream content-length)
                                   :encoding (detect-charset content-type :utf-8)))
         (data (handler-case (parse json :as :alist)
                 (error ()
                   (error 'http-body-parse-error
                          :format "json"
                          :body json)))))
    (unless (listp data)
      (error 'http-body-parse-error
             :format "json"
             :body json))
    data))
