#!/usr/bin/env gosh

(use nqueens.player)

(define *tuple-space-host* "localhost")
(define *tuple-space-port* 5959)

(define *xml-rpc-host* "192.168.0.17")
(define *xml-rpc-port* 80)
(define *xml-rpc-path* "/nqueen.php")

(define (main args)
  (nqueens-play "Gauche n-Queens player"
                (format #f "http://~a:~a~a"
                        *xml-rpc-host* *xml-rpc-port* *xml-rpc-path*)
                (format #f "dsmp://~a:~a"
                        *tuple-space-host* *tuple-space-port*)))
