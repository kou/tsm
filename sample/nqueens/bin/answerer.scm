#!/usr/bin/env gosh

(use nqueens.answerer)

(define *host* "localhost")
(define *port* 5959)

(define (main args)
  (nqueens-answerer-write-answers
   (make-nqueens-answerer #`"dsmp://,|*host*|:,|*port*|")))
