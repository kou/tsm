#!/usr/bin/env gosh

(use tsm.proxy)
(use nqueens.answerer)

(define *server* "localhost")
(define *port* 5959)

(define (main args)
  (let ((tuple-space (tuple-space-connect #`"dsmp://,|*server*|:,|*port*|")))
    #f))
