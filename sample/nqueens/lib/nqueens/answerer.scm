(define-module nqueens.answerer
  (use srfi-11)
  (use tsm.proxy)
  (use nqueens.common)
  (export make-nqueens-answerer nqueens-answerer-write-answers))
(select-module nqueens.answerer)

(define-class <nqueens-answerer> (<tuple-space-client>)
  ())

(define (make-nqueens-answerer uri)
  (make <nqueens-answerer> :uri uri))

(define (nqueens-answerer-write-answers nq-answerer)
  (let-values (((width height queens)
                (read-current-queens nq-answerer)))
    (let ((answerer (make-answerer width height queens)))
      (let loop ((current-queens queens)
                 (answer (answerer)))
        (when answer
          (answerer-write-answer nq-answerer width height answer)
          (let-values (((_ _ new-queens)
                        (read-current-queens answerer 0 '(_ #f #f #f))))
            (if (or (not new-queens)
                    (equal? new-queens current-queens))
              (loop current-queens (answerer)))))))))

(define (nqueens-answerer-write-answer nq-answerer queens)
  (tuple-space-write (tuple-space-of nq-answerer)
                     `(:answer ,width ,height ,queens)
                     `(,(* 100 *available-second*) 0)))

(define (make-answerer width height . queens)
  (define return #f)

  (define (next)
    (available-hands (get-optional queens (make-list width #f))
                     width
                     height
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


(define (available-hands-in-column queens width height column handler . args)
  (let-keywords* args ((column-cache-table (make-hash-table 'equal?))
                       (row-cache-table (make-hash-table 'equal?)))
    
    (define (call-handler-if-need new-queens)
      (when (and (not (hash-table-exists? row-cache-table new-queens))
                 (not (available-hands new-queens width height handler
                                       :column-cache-table column-cache-table
                                       :row-cache-table row-cache-table)))
        (hash-table-put! row-cache-table new-queens #t)
        (handler new-queens)))
    
    (let loop ((row 0)
               (found-available-hand? #f))
      (if (= row height)
        found-available-hand?
        (loop (+ row 1)
              (if (cell-free? queens width height column row)
                (let ((new-queens (update-queens queens column row)))
                  (call-handler-if-need new-queens)
                  #t)
                found-available-hand?))))))

(define (available-hands queens width height handler . args)
  (let-keywords* args ((column-cache-table (make-hash-table 'equal?))
                       (row-cache-table (make-hash-table 'equal?)))

    (define (search-if-no-cache)
      (let ((key (list queens width height)))
        (if (hash-table-exists? column-cache-table key)
          (hash-table-get column-cache-table key)
          (let ((found? (search)))
            (hash-table-put! column-cache-table key found?)
            found?))))
    
    (define (search)
      (let loop ((column 0)
                 (found-available-hand? #f))
        (if (= column width)
          found-available-hand?
          (loop (+ column 1)
                (if (column-has-queen? queens column)
                  found-available-hand?
                  (or (available-hands-in-column
                       queens width height column handler
                       :column-cache-table column-cache-table
                       :row-cache-table row-cache-table)
                      found-available-hand?))))))

    (search-if-no-cache)))

(provide "nqueens/answerer")
