#!/usr/bin/env gosh

(use file.util)

(define (main args)
  (load (build-path (sys-dirname (car args)) "tower"))
  (tower-main args
              cannot-pop-handler pop-handler
              push-handler name-handler
              start-handler finish-handler exit-handler))

(define actions #f)
(define sequence #f)

(define (write-tuple tuple-space tower . values)
  (print `(:tower-action ,(id-of tower) ,sequence ,@values))
  (tuple-space-write tuple-space
                     `(:tower-action ,(id-of tower) ,sequence ,@values))
  (inc! sequence)
  (sys-sleep 2))

(define (cannot-pop-handler tower tuple-space)
  (print "cannnot pop!!"))

(define (pop-handler tower tuple-space disk)
  (print "poped!!" disk)
  (write-tuple tuple-space tower `(pop ,disk)))

(define (push-handler tower tuple-space disk)
  (print "pushed!!" disk)
  (write-tuple tuple-space tower `(push ,disk)))

(define (start-handler tower tuple-space hight)
  (print "started!!")
  (print "hight: " hight)
  (set! sequence 0)
  (write-tuple tuple-space tower `(start ,hight)))

(define (finish-handler tower tuple-space)
  (print "finished!!")
  (write-tuple tuple-space tower '(finish))
  (set! sequence #f))

(define (name-handler tower tuple-space name)
  (print name)
  (write-tuple tuple-space tower `(name ,name)))

(define (exit-handler tower tuple-space)
  (print "Thank you"))
