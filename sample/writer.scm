#!/usr/bin/env gosh

(use srfi-1)
(use tsm.proxy)

(define *server* "localhost")
(define *port* 2929)

(define (main args)
  (let ((tuple-space (tuple-space-connect #`"dsmp://,|*server*|:,|*port*|")))
    (for-each (lambda (i)
                (tuple-space-write tuple-space i '(1 0))
                (tuple-space-write tuple-space (list i)))
              (iota 10))))
