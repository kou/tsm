(define-module nqueens.player
  (use srfi-1)
  (use srfi-11)
  (use srfi-13)
  (use util.list)
  (use gauche.sequence)
  (use tsm.proxy)
  (use xsm.xml-rpc.client)
  (use nqueens.common)
  (export nqueens-play))
(select-module nqueens.player)

(define get hash-table-get)
(define exists? hash-table-exists?)

(define-class <nqueens-player> ()
  ((name :accessor name-of :init-keyword :name)
   (xml-rpc-uri :accessor xml-rpc-uri-of :init-keyword :xml-rpc-uri)
   (xml-rpc-client :accessor xml-rpc-client-of)
   (tuple-space-uri :accessor tuple-space-uri-of :init-keyword :tuple-space-uri)
   (tuple-space :accessor tuple-space-of)
   (ticket :accessor ticket-of)
   (id :accessor id-of :init-value #f)
   (start-time :accessor start-time-of)
   (players :accessor players-of)
   (width :accessor width-of)
   (height :accessor height-of)
   (queens :accessor queens-of)))

(define-method initialize ((self <nqueens-player>) args)
  (next-method)
  (set! (xml-rpc-client-of self)
        (make-xml-rpc-client (xml-rpc-uri-of self)))
  (set! (tuple-space-of self)
        (tuple-space-connect (tuple-space-uri-of self))))

(define (nqueens-play name xml-rpc-uri tuple-space-uri)
  (let ((player (make <nqueens-player>
                  :name name
                  :xml-rpc-uri xml-rpc-uri
                  :tuple-space-uri tuple-space-uri)))
    (ensure-regist! player)
    (wait-play player)
    (update-field-info! player)
    (player-play player)))

(define (player-play player)
  (let play-loop ()
    (define playing?
      (let* ((status (call-status player))
             (mode (get status 'mode)))
        (set! (players-of player) (get status 'players))
        (and (in-play-mode? mode)
             (member (id-of player) (players-of player)))))
    (when playing?
      (define available-queens-list (collect-available-queens player))
      (let loop ((available-queens-list available-queens-list)
                 (player-status (call-player-status player))
                 (mode (current-mode player)))
        (print-mode mode)
        (if (not (exists? player-status 'in_turn))
          (print "Uhmmm... in_turn not found")
          (begin
            (let ((in-turn? (get player-status 'in_turn))
                  (rest-time (get player-status 'play_time))
                  (rest-players-number (length (players-of player))))
              (print (list in-turn? rest-time
                           rest-players-number 'available-queens-list))
              (or (and in-turn?
                       (let ((queens
                              (or (find-best-next-queens player
                                                         available-queens-list
                                                         rest-players-number)
                                  (find-next-queens player
                                                    available-queens-list
                                                    rest-players-number))))
                         (print #`"found queens: ,queens")
                         (and queens
                              (put-queen player queens)
                              (or (sys-sleep (truncate (/ rest-time 2)))
                                  #t))))
                  (begin
                    (when (and in-turn?
                               (<= rest-time 1)
                               (null? available-queens-list))
                      (print "give up")
                      (give-up player))
                    (update-field-info! player)
                    (let* ((available-queens-list
                            (collect-available-queens player))
                           (player-status (call-player-status player))
                           (status (call-status player))
                           (mode (get status 'mode)))
                      (set! (players-of player) (get status 'players))
                      (print (list (id-of player) (players-of player)
                                   (member (id-of player) (players-of player))))
                      (print "---------------")
                      (print-mode mode)
                      (print (in-play-mode? mode))
                      (print "---------------")
                      (if (in-play-mode? mode)
                        (if (member (id-of player) (players-of player))
                          (loop available-queens-list
                                player-status
                                mode)
                          (print "lost..."))
                        (print "finished???")))))))))
      (update-field-info! player)
      (play-loop))))

(define (ensure-regist! player)
  (until (regist! player)
    (print "ensure-regist!...")
    (print-mode (current-mode player))
    (sys-sleep 1)))

(define (wait-play player)
  (do ((mode (current-mode player)))
      ((in-play-mode? mode)
       (let ((status (call-status player)))
         (set! (players-of player) (get status 'players))))
    (let ((players (get (call-status player) 'players)))
      (print-mode mode)
      (print (list (id-of player) players))
      (if (or (in-standby-mode? mode)
              (and (in-accepting-mode? mode)
                   (not (member (id-of player) players))))
        (ensure-regist! player))
      (sys-sleep 1))))

(define (print-mode mode)
  (print
   (cond ((in-standby-mode? mode) "in standby mode...")
         ((in-accepting-mode? mode) "in accepting mode...")
         ((in-play-mode? mode) "in play mode...")
         (else "??? mode..."))))

(define (give-up player)
  (call-give-up player))

(define (put-queen player queens)
  (let-values (((x y) (next-queen-position (queens-of player) queens)))
    (if (and x y)
      (let ((result (call-put-queen player x y)))
        (print #`"putting queen: ,x ,y")
        (let ((success? (get result 'result)))
          (if success?
            (print "success!!")
            (print #`"failed put queen: ,(get result 'reason)"))
          success?))
      (begin
        (print #`"can't put queen: ,(queens-of player),, ,|queens|")
        (print "give up????")
        #f))))

(define (update-field-info! player)
  (let ((field-info (call-field-info player)))
    (set! (width-of player) (get field-info 'width))
    (set! (height-of player) (get field-info 'height))
    (set! (queens-of player) (parse-field-info (get field-info 'data))))
  (print #`"writing queens: width=,(width-of player) height=,(height-of player) queens=,(queens-of player)")
  (write-current-queens player)
  (print "wrote queens"))

(define (write-current-queens player)
  (tuple-space-write (tuple-space-of player)
                     `(:current ,(width-of player)
                                ,(height-of player)
                                ,(queens-of player))
                     `(,(* 2 *available-second*) 0)))

(define (collect-available-queens player)
  (map cadddr (tuple-space-read-all (tuple-space-of player)
                                  `((:answer
                                     ,(width-of player)
                                     ,(height-of player)
                                     ,(queens->pattern (queens-of player)))))))

(define (find-best-next-queens player queens-list rest-players-number)
  (find (lambda (queens)
          (= 1 (queens-difference-score (queens-of player) queens)))
        queens-list))

(define (find-next-queens player queens-list rest-players-number)
  (or (find (lambda (queens)
              (< 0
                 (queens-difference-score (queens-of player) queens)
                 rest-players-number))
            queens-list)
      (find (lambda (queens)
              (not (zero?
                    (remainder
                     (queens-difference-score (queens-of player) queens)
                     rest-players-number))))
            queens-list)
      (and (not (null? queens-list))
           (car queens-list))))

(define (regist! player)
  (let ((result (call-regist player)))
    (if (get result 'result)
      (begin
        (print #`"registed!: id=,(get result 'player_id)")
        (set! (id-of player) (get result 'player_id))
        (set! (ticket-of player) (get result 'ticket))
        (set! (start-time-of player) (get result 'play_start))
        (print #`"waiting for starting...: ,(get result 'play_start) sec.")
        (sys-sleep (start-time-of player)))
      (print (get result 'reason)))
    (get result 'result)))

(define (current-mode player)
  (get (call-status player) 'mode))

(define (in-standby-mode? mode)
  (= 0 mode))

(define (in-accepting-mode? mode)
  (= 1 mode))

(define (in-play-mode? mode)
  (= 2 mode))

(define (in-standby? player)
  (= 0 (current-mode player)))

(define (in-accepting? player)
  (= 1 (current-mode player)))

(define (in-play? player)
  (= 2 (current-mode player)))

(define-method call ((self <nqueens-player>) name . args)
  (apply call (xml-rpc-client-of self) name args))

(define (call-llw player name alist)
  (let ((method-name #`"LLW2004NQ.,|name|"))
    (if (null? alist)
      (call player method-name)
      (call player method-name (alist->hash-table alist 'eq?)))))

(define (call-regist player)
  (call-llw player "regist" `((name . ,(name-of player)))))

(define (call-status player)
  (call-llw player "status" '()))

(define (call-player-status player)
  (call-llw player "playerStatus" `((player_id . ,(id-of player)))))

(define (call-field-info player)
  (call-llw player "fieldInfo" '()))

(define (call-put-queen player x y)
  (call-llw player "putQueen" `((player_id . ,(id-of player))
                                (ticket . ,(ticket-of player))
                                (x . ,x)
                                (y . ,y))))

(define (call-give-up player)
  (call-llw player "giveUp" `((player_id . ,(id-of player))
                              (ticket . ,(ticket-of player)))))

(define (call-log player . index)
  (call-llw player "log"
            (if (null? index)
              '()
              `((index . ,(car index))))))


(define (remove-empty-row rows)
  (fold-right (lambda (row prev)
                (if (string-null? row)
                  prev
                  (cons row prev)))
              '()
              rows))

(define (column-size rows)
  (if (pair? rows)
    (string-size (car rows))
    0))

(define (parse-field-info field-info-str)
  (let* ((rows (remove-empty-row (string-split field-info-str "\n")))
         (queens (make-list (column-size rows) #f)))
    (for-each-with-index (lambda (i row)
                           (let ((queen (string-index row #\1)))
                             (if queen
                               (set! (ref queens queen) i))))
                         rows)
    queens))

(provide "nqueens/player")
