#!/usr/bin/env gosh

(use xsm.xml-rpc.client)

(define *xml-rpc-host* "www.vdomains.org")
(define *xml-rpc-port* 80)
(define *xml-rpc-path* "/~koyama/llwnq/nqueen.php")

(define get hash-table-get)

(define (main args)
  (let ((server (make-xml-rpc-client
                 (format #f "http://~a:~a~a"
                         *xml-rpc-host* *xml-rpc-port* *xml-rpc-path*))))
    (let loop ()
      (print "log...")
      (let log-loop ((count 0))
        (print count)
        (let ((logs (call server "LLW2004NQ.log" count)))
          (unless (null? logs)
            (for-each (lambda (log)
                        (print (list (get log 'player_id)
                                     (get log 'result)
                                     (get log 'x)
                                     (get log 'y))))
                      logs)
            (log-loop (+ count 1)))))
      (sys-sleep 1)
      (loop))))
