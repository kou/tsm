#!/usr/bin/env gosh

(use tsm.proxy)

(define *server* "localhost")
(define *port* 2929)

(define (main args)
  (let ((tuple-space (tuple-space-connect #`"dsmp://,|*server*|:,|*port*|")))
    (tuple-space-write tuple-space '(1 2 3) 1)
    (print (tuple-space-take tuple-space '((1 _ _))))
    (tuple-space-write tuple-space '(1 2 3) 1)
    (print (tuple-space-read tuple-space '((1 _ _))))
    (print (tuple-space-read tuple-space '((1 _ _))))
    (tuple-space-write tuple-space '(1 2 3) 1)
    (tuple-space-write tuple-space '(1 2 3) 1)
    (print (tuple-space-read tuple-space '((1 _ _))))
    (print (tuple-space-read-all tuple-space '((1 _ _))))
    ))
