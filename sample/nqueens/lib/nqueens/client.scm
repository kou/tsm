(define-module nqueens.client
  (use srfi-1)
  (use srfi-13)
  (use util.list)
  (use gauche.sequence)
  (use xsm.xml-rpc.client)
  (use nqueens.common)
  )
(select-module nqueens.client)

(define get hash-table-get)

(define-class <nqueens-client> ()
  ((name :accessor name-of :init-keyword :name)
   (uri :accessor uri-of :init-keyword :uri)
   (xml-rpc-client :accessor xml-rpc-client-of)
   (ticket :accessor ticket-of)
   (id :accessor id-of :init-value #f)
   (start-time :accessor start-time-of)))

(define-method initialize ((self <nqueens-client>) args)
  (next-method)
  (set! (xml-rpc-client-of self)
        (make-xml-rpc-client (uri-of self)))
  (regist! self))

(define (regist! client)
  (let ((result (call-regist client)))
    (if (get result 'result)
      (begin
        (set! (id-of self) (get result 'player_id))
        (set! (ticket-of self) (get result 'ticket))
        (set! (start-time-of self) (+ (sys-time) (get result 'play_start))))
      (print (get result 'reason)))))

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


(provide "nqueens/client")
