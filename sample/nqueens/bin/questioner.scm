#!/usr/bin/env gosh

(use nqueens.questioner)

(define *tuple-space-server* "localhost")
(define *tuple-space-port* 5959)

(define (main args)
  (let ((questioner (make-nqueens-questioner (format #f
                                                     "dsmp://~a:~a"
                                                     *tuple-space-server*
                                                     *tuple-space-port*))))
    (let loop ()
      (nqueens-questioner-write-question questioner)
      (loop))))
