#!/usr/bin/env gosh

(use test.unit)
(use tsm.tuple)

(define-test-case "tuple test"
  ("match test"
   (assert-true (tuple-match? (make-tuple '(1))
                              ((1))))
   (assert-true (tuple-match? (make-tuple '(1))
                              ((1)
                               (_))))
   (assert-true (tuple-match? (make-tuple '(1))
                              (((? number?)))))
   (assert-true (tuple-match? (make-tuple '("str"))
                              (((? string?)))))
   (assert-false (tuple-match? (make-tuple '(1))
                               (((? string?)))))
   (assert-true (tuple-match? (make-tuple '(1))
                              (((? string?))
                               ((? number?))))))
  ("expiration test"
   (assert-true (tuple-expired? (make-tuple '() :expiration-time 0)))
   (let ((tuple (make-tuple '() :expiration-time 100000)))
     (assert-false (tuple-expired? tuple))
     (sys-nanosleep 100000)
     (assert-true (tuple-expired? tuple)))
   (let ((tuple (make-tuple '() :expiration-time '(0 1000000))))
     (assert-false (tuple-expired? tuple))
     (sys-nanosleep 1000000)
     (assert-true (tuple-expired? tuple)))
   (assert-false (tuple-expired? (make-tuple '())))))
