#!/usr/bin/env gosh

(use test.unit)

(define-module test-tuple-space
  (extend tsm.tuple-space)
  (use srfi-1)
  (use test.unit))
(select-module test-tuple-space)

(let ((space #f))
  (define-test-case "tuple space test"
    (setup
     (lambda ()
       (set! space (make-tuple-space "dsmp://localhost"))))
    ("take test"
     (assert-each (lambda (item)
                    (ts-write space item)
                    (assert-equal item (ts-take space (list item)))
                    (assert-false (ts-take space (list item))))
                  '(1 (1 2) #(1 2) "str" sym)
                  :apply-if-can #f))
    ("read test"
     (assert-each (lambda (item)
                    (ts-write space item)
                    (assert-equal item (ts-read space (list item)))
                    (assert-equal item (ts-read space (list item))))
                  '(1 (1 2) #(1 2) "str" sym)
                  :apply-if-can #f))
    ("read-all test"
     (define items '())
     (define patterns '())
     (assert-each (lambda (item)
                    (ts-write space item)
                    (push! items item)
                    (push! patterns (if (symbol? item)
                                      `',item
                                      item))
                    (assert-lset-equal items
                                       (ts-read-all space patterns)))
                  '(1 (1 2) #(1 2) "str" sym)
                  :apply-if-can #f)
     (assert-lset-equal items (ts-read-all space '(_))))
    ("update-tuple-space! test"
     (define tuples '(1 (1 2) #(1 2) "str" sym))
     (define lazy-space #f)
     (define quick-space #f)
     (define (init-space space)
       (for-each (lambda (tuple)
                   (ts-write space tuple 0))
                 tuples))
     
     (set! lazy-space (make-tuple-space "dsmp://localhost"
                                        :minimum-update-nanosecond 5000000))
     (init-space lazy-space)
     (update-tuple-space! lazy-space)
     (assert-true (not (null? (ts-read-all lazy-space '(_)))))
     (sys-nanosleep (minimum-update-nanosecond-of lazy-space))
     (assert-true (not (null? (ts-read-all lazy-space '(_)))))
     (update-tuple-space! lazy-space)
     (assert-null (ts-read-all lazy-space '(_)))

     (set! quick-space (make-tuple-space "dsmp://localhost"
                                         :minimum-update-nanosecond 0))
     (init-space quick-space)
     (assert-true (not (null? (ts-read-all quick-space '(_)))))
     (update-tuple-space! quick-space)
     (assert-null (ts-read-all quick-space '(_))))))

