(define-module tsm.tuple
  (extend util.match)
  (use srfi-1)
  (use srfi-19)
  (export make-tuple
          tuple-expired? tuple-match?
          value-of))
(select-module tsm.tuple)

(define-class <tuple> ()
  ((value :accessor value-of :init-keyword :value)
   (expiration-time :accessor expiration-time-of)))

(define-method initialize ((self <tuple>) args)
  (next-method)
  (let-keywords* args ((expiration-time #f))
    (let ((expire (and expiration-time (current-time))))
      (set! (expiration-time-of self)
            (and expire
                 (add-duration expire
                               (apply make-time time-duration
                                      (if (pair? expiration-time)
                                        (reverse expiration-time)
                                        (list expiration-time 0)))))))))

(define (make-tuple value . args)
  (apply make <tuple> :value value args))

(define (tuple-expired? tuple)
  (and (expiration-time-of tuple)
       (time<? (expiration-time-of tuple)
               (current-time))))

(define-macro (tuple-match? tuple . patterns)
  `(match (value-of ,tuple)
     ,@(map (lambda (pat)
              (list (car pat) #t))
            patterns)
     ,@(if (find (lambda (pattern)
                   (symbol? (car pattern)))
                 patterns)
         '()
         '((_ #f)))))

(provide "tsm/tuple")
