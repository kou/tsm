#!/usr/bin/env gosh

(use tsm.proxy)
(use nqueens.common)

(define *tuple-space-server* "localhost")
(define *tuple-space-port* 5959)

(define (main args)
  (let ((tuple-space (tuple-space-connect (format #f
						  "dsmp://~a:~a"
						  *tuple-space-server*
						  *tuple-space-port*))))
    #f))
