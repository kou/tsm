#!/usr/bin/env gosh

(use tsm.proxy)

(define *server* "localhost")
(define *port* 2929)

(define (main args)
  (let ((tuple-space (tuple-space-connect #`"dsmp://,|*server*|:,|*port*|")))
    (tuple-space-write tuple-space '(1 2 3) '(1 0))
    (print (tuple-space-take tuple-space '((1 _ _))))
    (tuple-space-write tuple-space '(1 2 3) '(1 0))
    (print (tuple-space-read tuple-space '((1 _ _))))
    (print (tuple-space-read tuple-space '((1 _ _))))
    (tuple-space-write tuple-space '(1 2 3) 10000000)
    (tuple-space-write tuple-space '(1 2 3) 10000000)
    (print (tuple-space-read tuple-space '((1 _ _))))
    (print (tuple-space-read-all tuple-space '((1 _ _))))
    
    (tuple-space-write tuple-space '(tag (1 2 3)))
    (print (cdr (tuple-space-take tuple-space
                                  '((taaaag ((? number?) ...))))))
    (print (tuple-space-take tuple-space
                             '(('taaaag ((? number?) ...)))
                             1000
                             #f))
    (tuple-space-write tuple-space '(tag (1 2 3)))
    (print (cdr (tuple-space-take tuple-space
                                  '(('tag ((? number?) ...))))))))
