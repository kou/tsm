(use srfi-1)
(use gauche.sequence) ;; for ref of list, vector, ...

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

(define (available-hands-in-column queens n m column handler)
  (let loop ((row 0)
             (found-available-hand? #f))
    (if (= row m)
      found-available-hand?
      (loop (+ row 1)
            (if (cell-free? queens n m column row)
              (let ((new-queens (update-queens queens column row)))
                '(print (list queens n m column row
                             (cell-free? queens n m column row)
                             new-queens))
                (unless (available-hands new-queens n m handler)
                  (handler new-queens))
                #t)
              found-available-hand?)))))

(define (available-hands queens n m handler)
  (let loop ((column 0)
             (found-available-hand? #f))
    (if (= column n)
      found-available-hand?
      (loop (+ column 1)
            (if (column-has-queen? queens column)
              found-available-hand?
              (or (available-hands-in-column queens n m column handler)
                  found-available-hand?))))))

(define (nqueen-computer n m)
  (define (%available-hands queens handler)
    (available-hands queens n m handler))

  (define (next)
    (let/cc return
      (available-hands (make-list n #f) n m
                       (lambda (hand)
                         (let/cc cont
                           (let ((prev next))
                             (set! next
                                   (lambda ()
                                     (set! next prev)
                                     (cont 'next))))
                           (return hand))))
      (set! next (lambda () #f))
      #f))
  
  (lambda ()
    (next)))

(define (nqueen-print nqueen)
  (let loop ((result (nqueen)))
    (when result
      (if (every number? result)
        (print result))
      (loop (nqueen)))))
