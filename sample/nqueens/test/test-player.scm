#!/usr/bin/env gosh

(define-module nqueens-player-test
  (use test.unit)
  (extend nqueens.player))
(select-module nqueens-player-test)

(define-test-case "n-Queens player test"
  ("parse-field-info test"
   (assert-equal '(#f 1 #f) (parse-field-info "000\n010\n000\n"))
   (assert-equal '(#f 1 #f 2) (parse-field-info "0000\n0100\n0001\n"))
   (assert-equal '(0 #f #f 1) (parse-field-info "1000\n0001\n"))
   (assert-equal '() (parse-field-info ""))
   (assert-equal '() (parse-field-info "\n"))))
   
