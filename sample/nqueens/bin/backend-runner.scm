#!/usr/bin/env gosh

(use gauche.process)

(define *space* "bin/space.scm")
(define *questioner* "bin/questioner.scm")
(define *answer* "bin/answerer.scm")

(define *monitor-process-list* (list *questioner* *answer*))

(define (main args)
  (define tuple-space #f)
  
  (dynamic-wind
      (lambda ()
        (set! tuple-space (run-process *space*))
        (print #`"run process: ,*space*")
        (process-wait tuple-space #t)
        (sys-sleep 1))
      (lambda ()
        (if (process-alive? tuple-space)
          (let loop ((processes (map (cut run-process <>)
                                     *monitor-process-list*)))
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
                       *monitor-process-list*)))))
      (lambda ()
        (if (process-alive? tuple-space)
          (process-kill tuple-space)))))
