#!/usr/bin/env gosh

(use tsm.tuple-space)

(define *port* 2929)

(define (main args)
  (let ((tuple-space (make-tuple-space #`"dsmp://:,|*port*|")))
    (tuple-space-start! tuple-space)
    (tuple-space-join! tuple-space)))
