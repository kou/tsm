(define-module tsm.common
  (use srfi-1)
  (export patterns->boolean-match-patterns))
(select-module tsm.common)

(define (all-match-pattern? pattern)
  (symbol? pattern))

(define (patterns->boolean-match-patterns patterns)
  (let* ((found-all-match-pattern? #f)
         (converted-patterns (fold (lambda (pattern prev)
                                     (if (all-match-pattern? pattern)
                                       (cond (found-all-match-pattern?
                                              prev)
                                             (else
                                              (set! found-all-match-pattern? #t)
                                              (cons (list pattern #t) prev)))
                                       (cons (list pattern #t) prev)))
                                   '()
                                   patterns)))
      (reverse (if found-all-match-pattern?
                 converted-patterns
                 (cons '(_ #f) converted-patterns)))))


(provide "tsm/common")


