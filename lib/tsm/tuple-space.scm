(define-module tsm.tuple-space
  (extend tsm.tsm)
  (use srfi-1)
  (use srfi-11)
  (use srfi-19)
  (use gauche.parameter)
  (use dsm.server)
  (use tsm.common)
  (use tsm.tuple)
  (export make-tuple-space
          tuple-space-start! tuple-space-join! tuple-space-stop!))
(select-module tsm.tuple-space)

(define current-tuple (make-parameter #f))
(define current-patterns (make-parameter #f))
(define ts-module (current-module))

(define-macro (current-tuple-match?)
  '(eval '(eval `(tuple-match? ,(current-tuple) ,(current-patterns))
                ts-module)
         ts-module))

(define-class <tuple-space> ()
  ((server :accessor server-of)
   (tuples :accessor tuples-of :init-form '())
   (last-update-time :accessor last-update-time-of
                     :init-form (current-time))
   (minimum-update-nanosecond :accessor minimum-update-nanosecond-of
                              :init-keyword :minimum-update-nanosecond
                              :init-value 500000)))

(define (make-tuple-space uri . keywords)
  (let-keywords* keywords ((minimum-update-nanosecond #f))
    (let ((server (apply make-dsm-server uri keywords))
          (space (apply make <tuple-space>
                        (if minimum-update-nanosecond
                          `(:minimum-update-nanosecond
                            ,minimum-update-nanosecond)
                          '()))))
      (set! (server-of space) server)
      (add-mount-point! server "/write"
                        (cut ts-write space <> <...>))
      (add-mount-point! server "/take"
                        (cut ts-take space <> <...>))
      (add-mount-point! server "/read"
                        (cut ts-read space <> <...>))
      (add-mount-point! server "/read-all"
                        (cut ts-read-all space <> <...>))
      space)))

(define (tuple-space-start! space)
  (dsm-server-start! (server-of space)
                     (lambda (server)
                       (update-tuple-space! space))))
(define (tuple-space-join! space)
  (dsm-server-join! (server-of space)))
(define (tuple-space-stop! space)
  (dsm-server-stop! (server-of space)))

(define (update-tuple-space! space)
  (when (< (minimum-update-nanosecond-of space)
           (time-nanosecond
            (time-difference (current-time) (last-update-time-of space))))
    (set! (tuples-of space)
          (remove tuple-expired? (tuples-of space)))
    (set! (last-update-time-of space)
          (current-time))))

(define (ts-write space value . args)
  (let-optionals* args ((sec #f))
    (push! (tuples-of space)
           (make-tuple value :expiration-time sec))))


(define (ts-search space patterns need-more?)
  (let ((matched? #f))
    (parameterize ((current-patterns patterns))
      (partition (lambda (tuple)
                   (if (and (not need-more?)
                            matched?)
                     #f
                     (parameterize ((current-tuple tuple))
                       (let ((result (current-tuple-match?)))
                         (if result (set! matched? #t))
                         result))))
                 (tuples-of space)))))

(define (ts-take space patterns)
  (let-values (((match-tuples not-match-tuples)
                (ts-search space patterns #f)))
    (cond ((null? match-tuples) #f)
          (else
           (set! (tuples-of space)
                 (append (cdr match-tuples) not-match-tuples))
           (value-of (car match-tuples))))))

(define (ts-read space patterns)
  (let-values (((match-tuples not-match-tuples)
                (ts-search space patterns #f)))
    (cond ((null? match-tuples) #f)
          (else
           (value-of (car match-tuples))))))

(define (ts-read-all space patterns)
  (let-values (((match-tuples not-match-tuples)
                (ts-search space patterns #t)))
    (map value-of match-tuples)))

(provide "tsm/tuple-space")
