(define-module tsm.proxy
  (use srfi-19)
  (use tsm.tuple)
  (use dsm.client)
  (export tuple-space-connect
          tuple-space-write
          tuple-space-take tuple-space-read tuple-space-read-all))
(select-module tsm.proxy)

(define-class <tuple-space-proxy> ()
  ((server :accessor server-of)
   (minimum-update-nanosecond :accessor minimum-update-nanosecond-of
                              :init-keyword :minimum-update-nanosecond
                              :init-value 5000000)))

(define-method initialize ((self <tuple-space-proxy>) args)
  (next-method)
  (let-keywords* args ((uri #f))
    (set! (server-of self) (dsm-connect-server uri))))

(define (tuple-space-connect uri . args)
  (apply make <tuple-space-proxy> :uri uri args))

(define-method tuple-space-write ((self <tuple-space-proxy>) lst . args)
  (apply ((server-of self) "/write") lst args))

(define (command-with-timeout proxy mount-point pattern timeout callback)
  (let ((retry #f)
        (server (server-of proxy))
        (expiration-time (and timeout (current-time))))
    (if expiration-time
      (set-time-nanosecond! expiration-time timeout))
    (call/cc
     (lambda (cont)
       (set! retry cont)))
    (let ((result ((server mount-point) pattern)))
      (if result
        result
        (if (and expiration-time
                 (time<? expiration-time (current-time)))
          (error "tuple doesn't found.")
          (begin
            (sys-nanosleep (minimum-update-nanosecond-of proxy))
            (retry)))))))

(define-macro (define-tuple-space-getter name)
  `(define-method ,(string->symbol #`"tuple-space-,|name|")
       ((self <tuple-space-proxy>) pattern . args)
     (let-keywords* args ((timeout #f)
                          (callback #f))
       (command-with-timeout self ,#`"/,|name|"
                             pattern timeout callback))))

(define-tuple-space-getter "take")
(define-tuple-space-getter "read")
(define-tuple-space-getter "read-all")

(provide "tsm/proxy")


