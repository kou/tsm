#!/usr/bin/env gosh

(use gauche.interactive)
(use tsm.tuple-space)

(define *port* 8011)

(define (main args)
  (let ((tuple-space (make-tuple-space #`"dsmp://:,|*port*|")))
    (tuple-space-start! tuple-space)
    (tuple-space-join! tuple-space)))
