(define-module nqueens.questioner
  (use srfi-1)
  (use srfi-11)
  (use srfi-27)
  (use gauche.sequence)
  (use tsm.proxy)
  (use nqueens.common)
  (export make-nqueens-questioner nqueens-questioner-write-question))
(select-module nqueens.questioner)

(define-class <nqueens-questioner> (<tuple-space-client>)
  ())

(define (make-nqueens-questioner uri)
  (make <nqueens-questioner> :uri uri))

(define (nqueens-questioner-write-question questioner)
  (let-values (((width height queens) (take-current-queens questioner)))
    (write-question questioner queens width height)
    (for-each-with-index
     (lambda (column queen)
       (unless queen
         (let ((new-queens (an-available-queens-in-column
                            queens column width height)))
           (if new-queens
             (write-question questioner new-queens width height)))))
     queens)))

(define (write-question questioner queens width height)
  (tuple-space-write (tuple-space-of questioner)
                     `(:question ,width ,height ,queens)
                     `(,(* 2 *available-second*) 0)))

(define (an-available-queens-in-column queens column width height)
  (let loop ((count 0))
    (if (< count height)
      (let ((row (random-integer height)))
        (if (cell-free? queens width height column row)
          (update-queens queens column row)
          (loop (+ count 1))))
      #f)))

(provide "nqueens/questioner")
