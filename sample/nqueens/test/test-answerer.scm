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

(define-assertion (assert-nqueens-answerer excepted answerer . args)
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
   (assert-available-hands '((0 2 #f) (0 #f 1)
                             (1 #f 0) (1 #f 2)
                             (2 0 #f) (2 #f 1))
                           available-hands-in-column '(#f #f #f) 3 3 0))
  ("available-hands test"
   (assert-available-hands '((0 #f 1) (0 2 #f))
                           available-hands '(0 #f #f) 3 3)
   (assert-available-hands '((0 #f 1) (2 #f 1))
                           available-hands '(#f #f 1) 3 3)
   (assert-available-hands '((0 2 #f) (0 #f 1)
                             (1 #f 0) (1 #f 2)
                             (2 0 #f) (2 #f 1)
                             (#f 0 2) (#f 1 #f) (#f 2 0))
                           available-hands '(#f #f #f) 3 3))
  ("nqueens-answerer test"
   (assert-nqueens-answerer '((0 2 #f) (0 #f 1)
                              (1 #f 0) (1 #f 2)
                              (2 0 #f) (2 #f 1)
                              (#f 0 2) (#f 1 #f) (#f 2 0))
                            (nqueens-answerer 3 3))
   (assert-nqueens-answerer '((0) (1) (2))
                            (nqueens-answerer 1 3))
   (assert-nqueens-answerer '((0 #f #f)
                              (#f 0 #f)
                              (#f #f 0))
                            (nqueens-answerer 3 1))
   (assert-nqueens-answerer '((0 #f 1) (0 2 #f))
                            (nqueens-answerer 3 3 '(0 #f #f)))))

