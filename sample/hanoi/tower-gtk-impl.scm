(use srfi-1)
(use util.queue)
(use gtk)

(define max-disk 6)
(define update-span 500)
(define disk-size #f)
(define sequence #f)
(define disks '())

(define (disk-width w)
  (/ w (- max-disk 1)))

(define (disk-hight h)
  (/ h (- max-disk 1)))

(define (center w)
  (/ w 2))

(define (disk-base-x w x)
  (- (center w)
     (* (+ x 1)
        (/ (disk-width w) 2))))

(define (disk-base-y h y)
  (- h (* y (disk-hight h))))

(define (pole-base-x w)
  (- (center w)
     (/ (disk-width w) 4)))

(define (pole drawable width hight fg bg)
  ;; clear
  (gdk-draw-rectangle drawable bg #t 0 0 width hight)
  ;; draw pole
  (gdk-draw-rectangle drawable fg #t
                      (pole-base-x width)
                      0
                      (/ (disk-width width) 2)
                      hight)
  ;; draw border line
  (let ((dw (disk-width width)))
    (let loop ((x dw))
      (when (< x width)
        (gdk-draw-line drawable fg x 0 x width)
        (loop (+ x dw))))))

(define (disk drawable width hight fg bg)
  (let loop ((ds disks))
    (unless (null? ds)
      (let ((x (car ds))
            (y (length ds)))
        (gdk-draw-rectangle drawable fg #t
                            (disk-base-x width x)
                            (disk-base-y hight y)
                            (* (disk-width width)
                               (+ x 1))
                            (disk-hight hight))
        (loop (cdr ds))))))

(define (tower-gtk-main args tuple-space)
  (let-optionals* (cdr args) ((server #f)
                              (width 600)
                              (hight 480))
    (let1 w (gtk-window-new GTK_WINDOW_TOPLEVEL)
      (g-signal-connect w "destroy" (lambda _ (gtk-main-quit)))
      (let* ((area (gtk-drawing-area-new))
             (drawable #f) ;; initialized by realize callback
             (fg-gc #f) ;; initialized by realize callback
             (bg-gc #f) ;; initialized by realize callback
             (width (x->integer width))
             (hight (x->integer hight))
             (finished? #f)
             (sequence 0)
             (tower-id '_)
             (actions (make-queue)))
        (define (next-action)
          (if finished?
            #f
            (begin
              (with-error-handler
                  (lambda (e) #f)
                (lambda ()
                  (match (tuple-space-take tuple-space
                                           `((:tower-action ,tower-id ,sequence
                                                            (_ ...)))
                                           :timeout 100000)
                    ((_ id seq action)
                     (print seq)
                     (inc! sequence)
                     (set! tower-id id)
                     action)
                    (not-match
                     (print "not match:" not-match)
                     #f)))))))
          
        (gtk-widget-set-size-request area width hight)
        (gtk-container-add w area)
        (g-signal-connect area "realize"
                          (lambda _
                            (set! drawable (ref area 'window))
                            (set! fg-gc (gdk-gc-new drawable))
                            (set! bg-gc (gdk-gc-new drawable))
                            (gdk-gc-set-foreground bg-gc
                                                   (ref (ref (ref area 'style)
                                                             'bg)
                                                        0))
                            ))
        (g-signal-connect area "expose_event"
                          (lambda (w event)
                            (pole drawable width hight fg-gc bg-gc))
                          (lambda (w event)
                            (disk drawable width hight fg-gc bg-gc)))
        (gtk-timeout-add update-span
                         (lambda ()
                           (unless finished?
                             (let ((action (next-action)))
                               (if action
                                 (enqueue! actions action))))
                           (when drawable
                             (pole drawable width hight fg-gc bg-gc))
                           (when drawable
                             (unless (queue-empty? actions)
                               (let ((action (dequeue! actions)))
                                 ;; (print action)
                                 (case (car action)
                                   ((start)
                                    (set! disks '())
                                    (set! disk-size (cadr action)))
                                   ((name)
                                    (print (cadr action)))
                                   ((push)
                                    (push! disks (cadr action)))
                                   ((pop)
                                    (pop! disks))
                                   ((finish)
                                    (set! sequence 0)
                                    (set! finished? #t)
                                    (set! tower-id '_))
                                   (else
                                    (print "????: " action)))))
                             (disk drawable width hight fg-gc bg-gc))
                           #t))
        (gtk-widget-show area)
        )
      (gtk-widget-show w)))
  (gtk-main)
  0)


;; (define actions '((start) (name "left")
;;                   (push 2) (push 1) (push 0)
;;                   (pop 0) (pop 1) (pop 2)
;;                   (finish)))

;; (define (main args)
;;   (gtk-init args)
;;   (tower-gtk-main args actions))
