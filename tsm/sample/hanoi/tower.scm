#!/usr/bin/env gosh

(use gauche.interactive)
(use dsm.server)
(use tsm.proxy)

(define *server* "localhost")
(define *port* 8011)

(define (main args)
  (let-optionals* (cdr args) ((server *server*))
    (let ((tuple-space (tuple-space-connect #`"dsmp://,|server|:,|*port*|"))
          (tower (make-tower)))
      (tuple-space-write tuple-space (list :tower (uri-of tower)) 60)
      (start-tower! tower))))

(define (make-tower)
  (let ((server (make-dsm-server "dsmp://localhost"))
        (stack '()))
    (add-mount-point! server "pop"
                      (lambda ()
                        (print #`"pop!!: ,(car stack)")
                        (pop! stack)))
    (add-mount-point! server "push"
                      (lambda (weight)
                        (print #`"push!!: ,|weight|")
                        (push! stack weight)))
    (add-mount-point! server "finish"
                      (lambda ()
                        (print #`"finish!!!: ,|stack|")
                        (dsm-server-stop! server)))
    server))

(define (start-tower! tower)
  (dsm-server-start! tower)
  (dsm-server-join! tower))
