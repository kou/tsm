#!/usr/bin/env gosh

(define-module nqueens-client-test
  (use test.unit)
  (extend nqueens.client))
(select-module nqueens-client-test)

(define-test-case "n-Queens client test"
  ("parse-field-info test"
   (assert-equal '(#f 1 #f) (parse-field-info "000\n010\n000\n"))
   (assert-equal '(#f 1 #f 2) (parse-field-info "0000\n0100\n0001\n"))
   (assert-equal '(0 #f #f 1) (parse-field-info "1000\n0001\n"))
   (assert-equal '() (parse-field-info ""))
   (assert-equal '() (parse-field-info "\n")))
  ("queens->pattern test"
   (assert-equal '() (queens->pattern '()))
   (assert-equal '(_ 1 _) (queens->pattern '(#f 1 #f)))
   (assert-equal '(_ 1 _ 2) (queens->pattern '(#f 1 #f 2)))
   (assert-equal '(0 _ _ 1) (queens->pattern '(0 #f #f 1)))))
   
