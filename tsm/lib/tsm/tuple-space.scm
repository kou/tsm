(define-module tsm.tuple-space
  (use srfi-1)
  (use srfi-11)
  (use gauche.parameter)
  (use tsm.tuple)
  (use dsm.server)
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
   (tuples :accessor tuples-of :init-form '())))

(define (make-tuple-space uri . keywords)
  (let ((server (apply make-dsm-server uri keywords))
        (space (make <tuple-space>)))
    (set! (server-of space) server)
    (add-mount-point! server "/write"
                      (cut ts-write space <> <...>))
    (add-mount-point! server "/take"
                      (cut ts-take space <> <...>))
    (add-mount-point! server "/read"
                      (cut ts-read space <> <...>))
    (add-mount-point! server "/read-all"
                      (cut ts-read-all space <> <...>))
    space))

(define (tuple-space-start! space)
  (dsm-server-start! (server-of space)
                     (lambda (server)
                       (update-tuple-space! space))))
(define (tuple-space-join! space)
  (dsm-server-join! (server-of space)))
(define (tuple-space-stop! space)
  (dsm-server-stop! (server-of space)))

(define (update-tuple-space! space)
  (set! (tuples-of space)
        (remove tuple-expired? (tuples-of space))))


(use gauche.interactive)
(define (ts-write space lst . args)
  (p "write" lst)
  (let-optionals* args ((sec #f))
    (push! (tuples-of space)
           (make-tuple lst :expiration-time sec))))


(define (ts-search space pattern need-more?)
  (p "search" pattern)
  (let ((matched? #f))
    (parameterize ((current-patterns pattern))
      (partition (lambda (tuple)
                   (if (and (not need-more?)
                            matched?)
                     #f
                     (parameterize ((current-tuple tuple))
                       (let ((result (current-tuple-match?)))
                         (if result (set! matched? #t))
                         result))))
                 (tuples-of space)))))

(define (ts-take space pattern . args)
  (let-keywords* args ((sec #f)
                       (proc #f))
    (let-values (((match-tuples not-match-tuples)
                  (ts-search space pattern #f)))
      (cond ((null? match-tuples) #f)
            (else
             (set! (tuples-of space)
                   (append (cdr match-tuples) not-match-tuples))
             (value-of (car match-tuples)))))))

(define (ts-read space pattern . args)
  (let-keywords* args ((sec #f)
                       (proc #f))
    (let-values (((match-tuples not-match-tuples)
                  (ts-search space pattern #f)))
      (cond ((null? match-tuples) #f)
            (else
             (value-of (car match-tuples)))))))

(define (ts-read-all space pattern . args)
  (let-keywords* args ((sec #f)
                       (proc #f))
    (let-values (((match-tuples not-match-tuples)
                  (ts-search space pattern #t)))
      (map value-of match-tuples))))

(provide "tsm/tuple-space")