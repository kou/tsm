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
  (let-values (((width height first-queens)
                (read-current-queens nq-answerer)))
    (let ((answerer (make-answerer width height first-queens)))
      (let loop ((current-queens first-queens)
                 (answer (answerer)))
        (print answer)
        (when answer
          (write-answer nq-answerer width height answer)
          (let-values (((_ _ new-queens)
                        (read-current-queens nq-answerer
                                             0
                                             '(_ #f #f #f))))
            (if (or (not new-queens)
                    (equal? first-queens currnet-queens))
              (loop current-queens (answerer)))))))))

(define (write-answer nq-answerer width height queens)
  (tuple-space-write (tuple-space-of nq-answerer)
                     `(:answer ,width ,height ,queens)
                     `(,(* width *available-second*) 0)))

(define (make-answerer queens width height)
  (define return #f)

  (define (next)
    (terminated-hands queens width height
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


(define (available-hands-in-column queens width height column handler)
  (let loop ((row 0)
             (found-available-hand? #f))
    (if (= row height)
      found-available-hand?
      (loop (+ row 1)
            (if (cell-free? queens width height column row)
              (begin
                (handler (update-queens queens column row))
                #t)
              found-available-hand?)))))

(define (terminated-hands queens width height handler . args)
  (let-keywords* args ((column-cache-table (make-hash-table 'equal?))
                       (row-cache-table (make-hash-table 'equal?)))

    (define (row-handler new-queens)
      (when (and (not (hash-table-exists? row-cache-table new-queens))
                 (not (terminated-hands new-queens width height handler
                                        :column-cache-table column-cache-table
                                        :row-cache-table row-cache-table)))
        (hash-table-put! row-cache-table new-queens #t)
        (handler new-queens)))
    
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
                       queens width height column row-handler)
                      found-available-hand?))))))

    (search-if-no-cache)))

(provide "nqueens/answerer")
