#!/usr/bin/env gosh

(use tsm.proxy)

(define *server* "localhost")
(define *port* 2929)

(define (main args)
  (let ((tuple-space (tuple-space-connect #`"dsmp://,|*server*|:,|*port*|")))
    (do ()
        (#f)
      (print (tuple-space-take tuple-space '(_))))))
