#!/usr/bin/env gosh

(use nqueens.client)

(define *tuple-space-host* "localhost")
(define *tuple-space-port* 5959)

(define *xml-rpc-host* "localhost")
(define *xml-rpc-port* 8080)
(define *xml-rpc-path* "/RPC2")

(define (main args)
  (nqueens-play "Gauche n-Queens client"
                (format #f "http://~a:~a~a"
                        *xml-rpc-host* *xml-rpc--port* *xml-rpc-path*)
                (format #f "dsmp://~a:~a"
                        *tuple-space-host* *tuple-space-port*)))
