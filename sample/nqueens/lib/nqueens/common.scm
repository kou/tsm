(define-module nqueens.common
  (use srfi-1)
  (use util.match)
  (use gauche.sequence)
  (use tsm.proxy)
  (export-all))
(select-module nqueens.common)

(unless (symbol-bound? 'let/cc)
  (define-syntax let/cc
    (syntax-rules ()
      ((_ var body ...)
       (call/cc
	(lambda (var)
	  body ...))))))

(define *available-second* 10)

(define-class <tuple-space-client> ()
  ((uri :accessor uri-of :init-keyword :uri)
   (tuple-space :accessor tuple-space-of)))

(define-method initialize ((self <tuple-space-client>) args)
  (next-method)
  (set! (tuple-space-of self)
        (tuple-space-connect (uri-of self))))

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
  
(define (cell-free? queens width height column row)
  (and (not (column-has-queen? queens column))
       (not (row-has-queen? queens row))
       (let loop ((i 0))
         (or (= i width)
             (and (not (cell-in-diagonal-line? queens i column row))
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
			((and old(not (equal? old new)))
                         (errorf "??? bad compare: old<~s>, new<~s>"
                                 old new))
			(else 0)))
		old-queens
		new-queens)))

(define (next-queen-position old-queens new-queens)
  (apply values
         (let/cc return
           (for-each-with-index (lambda (i old new)
                                  (if (and (not old) new)
                                    (return (list i new))))
                                old-queens
                                new-queens)
           '(#f #f))))

(define (x-current-queens x tuple-space-client . args)
  (apply values
         (cdr (apply x
                     (tuple-space-of tuple-space-client)
                     '(:current _ _ _)
                     args))))

(define (take-current-queens tuple-space-client . args)
  (apply x-current-queens tuple-space-take tuple-space-client args))

(define (read-current-queens tuple-space-client . args)
  (apply x-current-queens tuple-space-read tuple-space-client args))

(define (queens->pattern queens)
  (map (lambda (queen)
         (or queen '_))
       queens))

(provide "nqueens/common")
