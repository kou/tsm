#!/usr/bin/env gosh

(use gauche.process)

(define *space* "bin/space.scm")
(define *questioner* "bin/questioner.scm")
(define *answerer* "bin/answerer.scm")

(define *answerer-number* 4)

(define *monitor-process-list*
  (cons *questioner* (make-list *answerer-number* *answerer*)))

(define (main args)
  (define tuple-space #f)
  
  (define (run-tuple-space)
    (set! tuple-space (run-process *space*))
    (print #`"run process: ,*space*")
    (process-wait tuple-space #t)
    (sys-sleep 1))

  (define (tuple-space-alive?)
    (process-wait tuple-space #t)
    (process-alive? tuple-space))
  
  (define (tuple-space-kill)
    (process-kill tuple-space))
  
  (dynamic-wind
      (lambda ()
        (run-tuple-space))
      (lambda ()
        (let loop ((processes (map (cut run-process <>)
                                   *monitor-process-list*)))
          (unless (tuple-space-alive?)
            (run-tuple-space))
          (sys-sleep 1)
          (loop (map (lambda (process command)
                       (process-wait process #t)
                       (if (process-alive? process)
                         process
                         (begin0
                             (run-process command)
                           (print #`"re-run process: ,|command|")
                           (sys-sleep 1))))
                     processes
                     *monitor-process-list*))))
      (lambda ()
        (if (tuple-space-alive?)
          (tuple-space-kill)))))
