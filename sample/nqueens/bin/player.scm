#!/usr/bin/env gosh

(use nqueens.player)

(define *tuple-space-host* "localhost")
(define *tuple-space-port* 5959)

(define *xml-rpc-host* "www.vdomains.org")
(define *xml-rpc-port* 80)
(define *xml-rpc-path* "/~koyama/llwnq/nqueen.php")

(define (main args)
  (nqueens-play #`"Gauche n-Queens player ,(cadr args)"
                (format #f "http://~a:~a~a"
                        *xml-rpc-host* *xml-rpc-port* *xml-rpc-path*)
                (format #f "dsmp://~a:~a"
                        *tuple-space-host* *tuple-space-port*)))
