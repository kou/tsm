#!/usr/bin/env gosh

(use rfc.uri)
(use gauche.process)
(use test.unit)
(use tsm.proxy)

(define (connect-ts host port)
  (tuple-space-connect (uri-compose :scheme "dsmp"
                                    :host host
                                    :port port)))

(define (test-ts-run command host port)
  (let ((server (run-process command
                             #`"--host=,host"
                             #`"--port=,port")))
    (do ()
        ((with-error-handler
             (lambda (e) #f)
           (lambda ()
             (let ((ts (connect-ts host port)))
               (tuple-space-shutdown! ts))
             #t)))
      (sys-nanosleep 100000000)) ; wait for starting server
    server))

(define (test-ts-stop server)
  (process-kill server)
  (do ()
      ((not (process-alive? server)))
    (process-wait server #t)))


(let* ((ts-command "./test/tuple-space.scm")
       (ts-host "localhost")
       (ts-port 59876)
       (process #f)
       (space #f))
  (define-test-case "proxy test"
    (setup
     (lambda ()
       (set! process (test-ts-run ts-command ts-host ts-port))
       (set! space (connect-ts ts-host ts-port))))
    (teardown
     (lambda ()
       (test-ts-stop process)
       (tuple-space-shutdown! space)))
    ("take test"
     (assert-each (lambda (item)
                    (tuple-space-write space item)
                    (assert-equal item
                                  (tuple-space-take space (list item) 1000))
                    (assert-error (lambda ()
                                    (tuple-space-take space (list item) 1000)))
                    (assert-false (tuple-space-take space (list item)
                                                    1000 #f)))
                  '(1 (1 2) #(1 2) "str" sym)
                  :apply-if-can #f))
    ("read test"
     (assert-error (lambda ()
                     (tuple-space-read space '(_) 1000)))
     (assert-false (tuple-space-read space '(_) 1000 #f))
     (assert-each (lambda (item)
                    (tuple-space-write space item)
                    (assert-equal item (tuple-space-read space (list item)))
                    (assert-equal item (tuple-space-read space (list item))))
                  '(1 (1 2) #(1 2) "str" sym)
                  :apply-if-can #f))
    ("read-all test"
     (define items '())
     (define patterns '())
     (assert-null (tuple-space-read-all space '(_)))
     (assert-each (lambda (item)
                    (tuple-space-write space item)
                    (push! items item)
                    (push! patterns (if (symbol? item)
                                      `',item
                                      item))
                    (assert-lset-equal items
                                       (tuple-space-read-all space patterns)))
                  '(1 (1 2) #(1 2) "str" sym)
                  :apply-if-can #f)
     (assert-lset-equal items (tuple-space-read-all space '(_))))))
