#!/usr/bin/env gosh

(use tsm.proxy)
(use util.match)

(define *server* "localhost")
(define *port* 8011)

(define (tower-listener-main args actions-handler)
  (let-optionals* (cdr args) ((server *server*))
    (let ((tuple-space (tuple-space-connect #`"dsmp://,|server|:,|*port*|")))
      (actions-handler args tuple-space))))
