(define-module tsm.proxy
  (use srfi-19)
  (use tsm.tuple)
  (use dsm.client)
  (export tuple-space-connect tuple-space-shutdown!
          tuple-space-write
          tuple-space-take tuple-space-read tuple-space-read-all))
(select-module tsm.proxy)

(define-class <tuple-space-proxy> ()
  ((server :accessor server-of)
   (minimum-update-nanosecond :accessor minimum-update-nanosecond-of
                              :init-keyword :minimum-update-nanosecond
                              :init-value 500000000)))

(define-method initialize ((self <tuple-space-proxy>) args)
  (next-method)
  (set! (server-of self) (dsm-connect-server (get-keyword :uri args))))

(define (tuple-space-connect uri . args)
  (apply make <tuple-space-proxy> :uri uri args))

(define (tuple-space-shutdown! proxy)
  ((server-of proxy)))

(define-method tuple-space-write ((self <tuple-space-proxy>) value . args)
  (apply ((server-of self) "/write") value args))

(define unique-symbol (gensym))

(define (command-with-timeout proxy mount-point patterns timeout fallback)
  (let ((retry #f)
        (server (server-of proxy))
        (expiration-time (and timeout (current-time))))
    (if expiration-time
      (set-time-nanosecond! expiration-time timeout))
    (call/cc
     (lambda (cont)
       (set! retry cont)))
    (let ((result ((server mount-point) patterns)))
      (if result
        result
        (if (and expiration-time
                 (time<? expiration-time (current-time)))
          (if (eq? fallback unique-symbol)
            (error "tuple doesn't found.")
            fallback)
          (begin
            (sys-nanosleep (minimum-update-nanosecond-of proxy))
            (retry)))))))

(define-macro (define-tuple-space-getter name)
  `(define-method ,(string->symbol #`"tuple-space-,|name|")
       ((self <tuple-space-proxy>) patterns . args)
     (let-optionals* args ((timeout #f)
                           (fallback unique-symbol))
       (command-with-timeout self ,#`"/,|name|"
                             patterns timeout fallback))))

(define-tuple-space-getter "take")
(define-tuple-space-getter "read")

(define-method tuple-space-read-all ((self <tuple-space-proxy>) patterns)
  (((server-of self) "/read-all") patterns))

(provide "tsm/proxy")
