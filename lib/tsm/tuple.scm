(define-module tsm.tuple
  (extend util.match)
  (use srfi-1)
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
    (set! (expiration-time-of self)
          (if expiration-time
            (+ (sys-time) expiration-time)
            #f))))

(define (make-tuple value . args)
  (apply make <tuple> :value value args))

(define (tuple-expired? tuple)
  (and (expiration-time-of tuple)
       (< (expiration-time-of tuple)
          (sys-time))))

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
