#!/usr/bin/env gosh

(use file.util)

(define (main args)
  (load (build-path (sys-dirname (car args)) "tower"))
  (tower-main args
              cannot-pop-handler pop-handler
              push-handler name-handler
              start-handler finish-handler exit-handler))

(define (cannot-pop-handler tower tuple-space)
  (print "cannnot pop!!"))

(define (pop-handler tower tuple-space disk)
  (print "poped!!")
  (print (disks-of tower)))

(define (push-handler tower tuple-space disk)
  (print "pushed!!")
  (print (disks-of tower)))

(define (start-handler tower tuple-space hight)
  (print "started!!")
  (print "hight: " hight))

(define (finish-handler tower tuple-space)
  (print "finished!!")
  (print (disks-of tower)))

(define (name-handler tower tuple-space name)
  (print name))

(define (exit-handler tower tuple-space)
  (print "Thank you"))
