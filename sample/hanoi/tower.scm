#!/usr/bin/env gosh

(use gauche.interactive)
(use math.mt-random)
(use util.match)
(use tsm.proxy)

(define *server* "localhost")
(define *port* 8011)

(define (tower-main args
                    cannot-pop-handler pop-handelr
                    push-handler name-handler
                    start-handler finish-handler
                    exit-handler)
  (let-optionals* (cdr args) ((server *server*))
    (let ((tuple-space (tuple-space-connect #`"dsmp://,|server|:,|*port*|"))
          (tower (make-tower)))
      (define (next-command)
        (print (disks-of tower))
        (match (tuple-space-take tuple-space
                                 `((:tower-do ,(id-of tower) _ ...)))
          ((_ _ 'pop)
           (cond ((null? (disks-of tower))
                  (cannot-pop-handler tower tuple-space)
                  #t)
                 (else
                  (let ((disk (pop! (disks-of tower))))
                    (pop-handler tower tuple-space disk)
                    (tuple-space-write tuple-space
                                       (list :tower (id-of tower) disk)
                                       60)
                    #f))))
          ((_ _ 'push disk)
           (push! (disks-of tower) disk)
           (push-handler tower tuple-space disk)
           #f)
          ((_ _ 'start hight)
           (start-handler tower tuple-space hight)
           #f)
          ((_ _ 'finish)
           (finish-handler tower tuple-space)
           #t)
          ((_ _ 'name name)
           (set! (name-of tower) name)
           (name-handler tower tuple-space name)
           #f)
          (no-match
           (print "no match: " no-match)
           #f)))

      (define (alive?)
        (not (null? (tuple-space-read-all tuple-space
                                          `((:tower ,(id-of tower) #f))))))
      
      (let loop ((finished? #t))
        (if finished?
          (begin
            (display "start?: ")
            (flush)
            (cond ((eof-object? (read-line))
                   (exit-handler tower tuple-space))
                  (else
                   (set! (disks-of tower) '())
;;                    (unless (alive?)
;;                      (tuple-space-write tuple-space
;;                                         (list :tower (id-of tower) #f)
;;                                         60))

                   (tuple-space-write tuple-space
                                      (list :tower (id-of tower) #f))
                   (loop (next-command)))))
          (loop (next-command)))))))

(define mt-random (make <mersenne-twister> :seed (sys-time)))
(define-method random ()
  (mt-random-real mt-random))
(define-method random ((max <integer>))
  (mt-random-integer mt-random max))

(define-class <tower> ()
  ((id :accessor id-of :init-form (random))
   (name :accessor name-of :init-form "")
   (disks :accessor disks-of :init-form '())))

(define (make-tower)
  (make <tower>))

