(define-module nqueens.common
  (use srfi-1)
  (use gauche.sequence)
  (export-all))
(select-module nqueens.common)

(unless (symbol-bound? 'let/cc)
  (define-syntax let/cc
    (syntax-rules ()
      ((_ var body ...)
       (call/cc
	(lambda (var)
	  body ...))))))

(define (column-has-queen? queens column)
  (number? (ref queens column)))

(define (row-has-queen? queens row)
  (any (lambda (queen)
         (and (number? queen)
              (= queen row)))
       queens))

(define (cell-in-diagonal-line? queens queen-column cell-column cell-row)
  (and (column-has-queen? queens queen-column)
       (let ((queen (ref queens queen-column))
             (step (- queen-column cell-column)))
         (or (= queen (+ cell-row step))
             (= queen (- cell-row step))))))
  
(define (cell-free? queens n m column row)
  (and (not (column-has-queen? queens column))
       (not (row-has-queen? queens row))
       (let loop ((i 0))
         (if (= i n)
           #t
           (if (cell-in-diagonal-line? queens i column row)
             #f
             (loop (+ i 1)))))))

(define (update-queens queens column row)
  (map-to-with-index (class-of queens)
                     (lambda (current-column queen)
                       (if (= column current-column)
                         row
                         queen))
                     queens))

(define (queens-difference-score old-queens new-queens)
  (apply + (map (lambda (old new)
		  (cond ((equal? old new) 0)
			((and new (not old)) 1)
			((and old (not new)) -1)
			(else 0)))
		old-queens
		new-queens)))

(provide "nqueens/common")
