(define-module nqueens.client
  (use srfi-1)
  (use srfi-11)
  (use srfi-13)
  (use util.list)
  (use gauche.sequence)
  (use xsm.xml-rpc.client)
  (use nqueens.common)
  (export nqueens-play))
(select-module nqueens.client)

(define get hash-table-get)

(define *available-time* 10)

(define-class <nqueens-client> ()
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

(define-method initialize ((self <nqueens-client>) args)
  (next-method)
  (set! (xml-rpc-client-of self)
        (make-xml-rpc-client (xml-rpc-uri-of self)))
  (set! (tuple-space-of self)
        (tuple-space-connect (tuple-space-uri-of self)))
  (regist! self))

(define (nqueens-play name uri)
  (let ((client (make <nqueens-client> :name name :uri uri)))
    (ensure-regist! client)
    (wait-play client)
    (update-field-info! client)
    (let play-loop ((playing? #t))
      (when playing?
        (let loop ((rest-time *available-time*)
                   (rest-players-number (length (players-of client)))
                   (available-queens-list '()))
          (or (and (< rest-time *available-time*)
                   (let ((queens
                          (or (find-best-next-queens client
                                                     available-queens-list
                                                     rest-players-number)
                              (and (< rest-time 3)
                                   (find-next-queens client
                                                     available-queens-list
                                                     rest-players-number)))))
                     (and queens (put-queen client queens))))
              (begin
                (when (and (<= rest-time 1)
                           (null? available-queens-list))
                  (print "give up")
                  '(give-up client))
                (sys-sleep 1)
                (update-field-info! client)
                (if (member (id-of client) (players-of client))
                  (loop (get (call-player-status client) 'play_time)
                        (length (get (call-status client) 'players))
                        (collect-available-queens client))
                  (print "lost..."))))))
      (update-field-info! client)
      (play-loop (and (in-play? client)
                      (member (id-of client) (players-of client)))))))

(define (ensure-regist! client)
  (until (regist! client)
    (sys-sleep 1)))

(define (wait-play client)
  (do ((mode (current-mode client)))
      ((not (in-play-mode? mode))
       (let ((status (call-status client)))
         (set! (players-of client) (get status 'players))))
    (print
     (cond ((in-standby-mode? mode) "in standby mode...")
           ((in-accepting-mode? mode) "in accepting mode...")
           ((in-play-mode? mode) "in play mode...")
           (else "??? mode...")))
    (sys-sleep 1)))

(define (give-up client)
  (call-give-up client))

(define (put-queen client queens)
  (let-values (((x y) (next-queen-position (queens-of client) queens)))
    (if (and x y)
      (let ((result (call-put-queen client x y)))
        (let ((success? (get result 'result)))
          (unless success?
            (print (get result 'reason)))
          success?))
      (begin
        (print #`"can't put queen: ,(queens-of client),, ,|queens|")
        (print "give up????")
        #f))))

(define (update-field-info! client)
  (let ((field-info (call-field-info client)))
    (set! (width-of client) (get field-info 'width))
    (set! (height-of client) (get field-info 'height))
    (set! (queens-of client) (parse-field-info (get field-info 'data))))
  (put-current-queens client))

(define (put-current-queens client)
  (tuple-space-write (tuple-space-of client)
                     `(:current ,(queens-of client))
                     `(,(* 2 *available-time*) 0)))

(define (collect-available-queens client)
  (map cadr (tuple-space-read-all (tuple-space-of client)
                                  `((:result
                                     (queens->pattern (queens-of client)))))))

(define (find-best-next-queens client queens-list rest-players-number)
  (find (lambda (queens)
          (= 1 (queens-difference-score (queens-of client) queens)))
        queens-list))

(define (find-next-queens client queens-list rest-players-number)
  (or (find (lambda (queens)
              (< 0
                 (queens-difference-score (queens-of client) queens)
                 rest-players-number))
            queens-list)
      (and (not (null? queens-list))
           (car queens-list))))

(define (regist! client)
  (let ((result (call-regist client)))
    (if (get result 'result)
      (begin
        (set! (id-of self) (get result 'player_id))
        (set! (ticket-of self) (get result 'ticket))
        (set! (start-time-of self) (+ (sys-time) (get result 'play_start))))
      (print (get result 'reason)))
    (get result 'result)))

(define (current-mode client)
  (get (call-status client) 'mode))

(define (in-standby-mode? mode)
  (= 0 mode))

(define (in-accepting-mode? mode)
  (= 1 mode))

(define (in-play-mode? mode)
  (= 2 mode))

(define (in-standby? client)
  (= 0 (current-mode client)))

(define (in-accepting? client)
  (= 1 (current-mode client)))

(define (in-play? client)
  (= 2 (current-mode client)))

(define-method call ((self <nqueens-client>) name . args)
  (apply call (xml-rpc-client-of self) name args))

(define (call-llw client name alist)
  (let ((method-name #`"LLW2004NQ.,|name|"))
    (if (null? alist)
      (call client method-name)
      (call client method-name (alist->hash-table alist 'eq?)))))

(define (call-regist client)
  (call-llw client "regist" `((name ,(name-of client)))))

(define (call-status client)
  (call-llw client "status" '()))

(define (call-player-status client)
  (call-llw client "playerStatus" `((player_id ,(id-of client)))))

(define (call-field-info client)
  (call-llw client "fieldInfo" '()))

(define (call-put-queen client x y)
  (call-llw client "putQueen" `((player_id ,(id-of client))
                                (ticket ,(ticket-of client))
                                (x ,x)
                                (y ,y))))

(define (call-give-up client)
  (call-llw client "giveUp" `((player_id ,(id-of client))
                              (ticket ,(ticket-of client)))))

(define (call-log client . index)
  (call-llw client "log"
            (if (null? index)
              '()
              `((index ,(car index))))))


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

(define (queens->pattern queens)
  (map (lambda (queen)
         (or queen '_))
       queens))

(provide "nqueens/client")
