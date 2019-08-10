(in-package :cl-user)
(defpackage http-body-test.urlencoded
  (:use :cl
        :http-body.urlencoded
        :assoc-utils
        :prove))
(in-package :http-body-test.urlencoded)

(plan nil)

(defparameter *data*
  "text1=Ratione+accusamus+aspernatur+aliquam&text2=%C3%A5%C3%A4%C3%B6%C3%A5%C3%A4%C3%B6&select=A&select=B&textarea=Voluptatem+cumque+voluptate+sit+recusandae+at.+Et+quas+facere+rerum+unde+esse.+Sit+est+et+voluptatem.+Vel+temporibus+velit+neque+odio+non.%0D%0A%0D%0AMolestias+rerum+ut+sapiente+facere+repellendus+illo.+Eum+nulla+quis+aut.+Quidem+voluptas+vitae+ipsam+officia+voluptatibus+eveniet.+Aspernatur+cupiditate+ratione+aliquam+quidem+corrupti.+Eos+sunt+rerum+non+optio+culpa.&encoding=foo%3Dbar")

(ok (alistp
     (urlencoded-parse "application/x-www-form-urlencoded"
                       (length *data*)
                       (flex:make-in-memory-input-stream (trivial-utf-8:string-to-utf-8-bytes *data*))))
    "association-list-p")

(finalize)
