(define-module nqueens.answerer
  (use nqueens.common)
  (export nqueen-answerer))
(select-module nqueens.answerer)

(define (available-hands-in-column queens n m column handler . args)
  (let-keywords* args ((column-cache-table (make-hash-table 'equal?))
                       (row-cache-table (make-hash-table 'equal?)))
    
    (define (call-handler-if-need new-queens)
      (when (and (not (hash-table-exists? row-cache-table new-queens))
                 (not (available-hands new-queens n m handler
                                       :column-cache-table column-cache-table
                                       :row-cache-table row-cache-table)))
        (hash-table-put! row-cache-table new-queens #t)
        (handler new-queens)))
    
    (let loop ((row 0)
               (found-available-hand? #f))
      (if (= row m)
        found-available-hand?
        (loop (+ row 1)
              (if (cell-free? queens n m column row)
                (let ((new-queens (update-queens queens column row)))
                  (call-handler-if-need new-queens)
                  #t)
                found-available-hand?))))))

(define (available-hands queens n m handler . args)
  (let-keywords* args ((column-cache-table (make-hash-table 'equal?))
                       (row-cache-table (make-hash-table 'equal?)))

    (define (search-if-no-cache)
      (let ((key (list queens n m)))
        (if (hash-table-exists? column-cache-table key)
          (hash-table-get column-cache-table key)
          (let ((found? (search)))
            (hash-table-put! column-cache-table key found?)
            found?))))
    
    (define (search)
      (let loop ((column 0)
                 (found-available-hand? #f))
        (if (= column n)
          found-available-hand?
          (loop (+ column 1)
                (if (column-has-queen? queens column)
                  found-available-hand?
                  (or (available-hands-in-column
                       queens n m column handler
                       :column-cache-table column-cache-table
                       :row-cache-table row-cache-table)
                      found-available-hand?))))))

    (search-if-no-cache)))

(define (nqueens-answerer n m . queens)
  (define return #f)

  (define (next)
    (available-hands (get-optional queens (make-list n #f))
                     n m
                     (lambda (hand)
                       (let/cc restart
                         (set! next
                               (lambda ()
                                 (restart 'do-next)))
                         (return hand))))
    (return #f))

  (lambda ()
    (let/cc cont
      (set! return cont)
      (next))))

(provide "nqueens/answerer")
