#!/usr/bin/env gosh

(define-module nqueens-answerer-test
  (use test.unit)
  (extend nqueens.answerer))
(select-module nqueens-answerer-test)

(define-assertion (assert-available-hands excepted generator queens n m . args)
  (let ((hands '()))
    (assert-equal (not (null? excepted))
                  (apply generator queens n m
                         (append args (list
                                       (lambda (hand)
                                         (push! hands hand))))))
    (assert-lset-equal excepted hands)))

(define-assertion (assert-answerer excepted answerer . args)
  (assert-lset-equal excepted
                     (let loop ((result (answerer))
                                (hands '()))
                       (if result
                         (loop (answerer) (cons result hands))
                         hands))))

(define-test-case "n-Queens answerer test"
  ("available-hands-in-column test"
   (assert-available-hands '((0 2 #f))
                           available-hands-in-column '(0 #f #f) 3 3 1)
   (assert-available-hands '((0 #f 1))
                           available-hands-in-column '(0 #f #f) 3 3 2)
   (assert-available-hands '((0 #f 1) (2 #f 1))
                           available-hands-in-column '(#f #f 1) 3 3 0)
   (assert-available-hands '()
                           available-hands-in-column '(#f #f 1) 3 3 1)
   (assert-available-hands '((0 #f #f) (1 #f #f) (2 #f #f))
                           available-hands-in-column '(#f #f #f) 3 3 0)
   (assert-available-hands '((#f 0 #f) (#f 1 #f) (#f 2 #f))
                           available-hands-in-column '(#f #f #f) 3 3 1)
   (assert-available-hands '((#f #f 0) (#f #f 1) (#f #f 2))
                           available-hands-in-column '(#f #f #f) 3 3 2))
  ("available-hands test"
   (assert-available-hands '((0 #f 1) (0 2 #f))
                           terminated-hands '(0 #f #f) 3 3)
   (assert-available-hands '((0 #f 1) (2 #f 1))
                           terminated-hands '(#f #f 1) 3 3)
   (assert-available-hands '((0 2 #f) (0 #f 1)
                             (1 #f 0) (1 #f 2)
                             (2 0 #f) (2 #f 1)
                             (#f 0 2) (#f 1 #f) (#f 2 0))
                           terminated-hands '(#f #f #f) 3 3))
  ("make-answerer test"
   (assert-answerer '((0 2 #f) (0 #f 1)
                      (1 #f 0) (1 #f 2)
                      (2 0 #f) (2 #f 1)
                      (#f 0 2) (#f 1 #f) (#f 2 0))
                    (make-answerer '(#f #f #f) 3 3))
   (assert-answerer '((0) (1) (2))
                    (make-answerer '(#f) 1 3))
   (assert-answerer '((0 #f #f)
                      (#f 0 #f)
                      (#f #f 0))
                    (make-answerer '(#f #f #f) 3 1))
   (assert-answerer '((0 #f 1) (0 2 #f))
                    (make-answerer '(0 #f #f) 3 3))))

