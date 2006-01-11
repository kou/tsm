(define (make-pull generator . last-notifier)
  (define return #f)
  (define (next)
    (generator (lambda (result)
                 (let/cc do-next
                   (set! next
                         (lambda ()
                           (do-next #f)))
                   (return result)))))
  (lambda ()
    (let/cc cont
      (set! return cont)
      (next)
      (if (null? last-notifier)
        #f
        (last-notifier)))))

(define pull (make-pull (lambda (return)
                          (for-each return '(1 2 3)))))
(print (pull))
(print (pull))
(print (pull))
(print (pull))
