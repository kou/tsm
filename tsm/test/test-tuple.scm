#!/usr/bin/env gosh

(define-module test.tsm-tuple
  (use test.unit)
  (extend tsm.tuple))
(select-module test.tsm-tuple)

(define-test-case "tuple test"
  ("match test"
   (assert-true (tsm-match? (make-tsm-tuple '(1))
                            ((1) #t)))
   (assert-true (tsm-match? (make-tsm-tuple '(1))
                            (((? number? x)))))
   (assert-false (tsm-match? (make-tsm-tuple '(1))
                             (((? string?)))))))
