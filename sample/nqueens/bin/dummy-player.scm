#!/usr/bin/env gosh


(extend nqueens.common nqueens.player)
(use tsm.proxy)

(define *host* "localhost")
(define *port* 5959)

(define-class <dummy-player> ()
  ((queens :accessor queens-of :init-keyword :queens)))

(define (main args)
  (let* ((tuple-space (tuple-space-connect #`"dsmp://,|*host*|:,|*port*|"))
         (width 20)
         (height 18)
         (dummy-player (make <dummy-player> :queens (make-list width #f)))
         (player-number 4))
    (let loop ((current-queens (make-list width #f)))
      (tuple-space-write tuple-space
                         `(:current ,width ,height ,current-queens))
      (print (format #f
                     "writing tuple: <~s>"
                     `(:current ,width ,height ,current-queens)))
      (sys-sleep 1)
      (let ((queens-list
             (map cadddr
                  (tuple-space-read-all
                   tuple-space
                   `((:answer ,width ,height
                              ,(queens->pattern current-queens)))))))
        (print (list (find-best-next-queens dummy-player
                                            queens-list
                                            player-number)
                     (find-next-queens dummy-player
                                       queens-list
                                       player-number)
                     (queens-difference-score
                      (queens-of dummy-player)
                      (find-next-queens dummy-player
                                        queens-list
                                        player-number))
                     (length queens-list))))
      (loop current-queens))))
