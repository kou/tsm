#!/usr/bin/env gosh

(use test.unit)
(use nqueens.common)

(define-test-case "n-Queens common library test"
  ("column-has-queen? test"
   (assert-true (column-has-queen? '(0) 0))
   (assert-true (column-has-queen? '(0 #f) 0))
   (assert-true (column-has-queen? '(0 #f 1) 2))
   (assert-false (column-has-queen? '(#f) 0)))
  ("column-has-queen? test"
   (assert-true (row-has-queen? '(0) 0))
   (assert-true (row-has-queen? '(0 1 2 3 4) 4))
   (assert-false (row-has-queen? '(3) 0))
   (assert-false (row-has-queen? '(#f #f #f) 2)))
  ("cell-in-diagonal-line? test"
   (assert-true (cell-in-diagonal-line? '(0 #f) 0 1 1))
   (assert-true (cell-in-diagonal-line? '(2 #f) 0 1 1))
   (assert-true (cell-in-diagonal-line? '(#f #f 0) 2 1 1))
   (assert-true (cell-in-diagonal-line? '(#f #f 2) 2 1 1))
   (assert-true (cell-in-diagonal-line? '(#f #f 2) 2 1 3))
   (assert-false (cell-in-diagonal-line? '(0 #f) 1 1 1))
   (assert-false (cell-in-diagonal-line? '(1 #f) 0 1 1))
   (assert-false (cell-in-diagonal-line? '(#f #f 1) 2 1 1)))
  ("cell-free? test"
   (assert-true (cell-free? '(#f) 1 1 0 0))
   (assert-true (cell-free? '(#f) 1 5 0 0))
   (assert-false (cell-free? '(0 #f) 2 2 1 0))
   (assert-false (cell-free? '(0) 1 5 0 0))
   (assert-false (cell-free? '(0 #f) 2 5 1 1))
   (assert-true (cell-free? '(0 #f) 2 5 1 2))
   (assert-false (cell-free? '(0 #f 1) 3 3 1 2)))
  ("update-queens test"
   (assert-equal '(1) (update-queens '(#f) 0 1))
   (assert-equal '(1 2 3) (update-queens '(1 #f 3) 1 2))
   (assert-equal #(1 2 3) (update-queens #(1 #f 3) 1 2)))
  ("queens-difference-score test"
   (assert-equal 0 (queens-difference-score '() '()))
   (assert-equal 1 (queens-difference-score '(#f) '(1)))
   (assert-equal 0 (queens-difference-score '(#f) '(#f)))
   (assert-equal 1 (queens-difference-score '(#f 1) '(2 1)))
   (assert-equal 2 (queens-difference-score '(#f 1 #f) '(2 1 3)))
   (assert-equal 1 (queens-difference-score '(#f) '(1)))
   (assert-equal 0 (queens-difference-score '(#f) '(#f)))
   (assert-equal 0 (queens-difference-score '(1 3 5) '(1 3 5))))
  ("next-queen-position test"
   (assert-values-equal '(0 0)
                        (lambda () (next-queen-position '(#f) '(0))))
   (assert-values-equal '(1 3)
                        (lambda () (next-queen-position '(#f #f) '(#f 3))))
   (assert-values-equal '(0 1)
                        (lambda () (next-queen-position '(#f #f) '(1 3))))
   (assert-values-equal '(#f #f)
                        (lambda () (next-queen-position '(1 3) '(1 3))))))
