#!/usr/bin/env gosh

(use gauche.interactive)
(use srfi-1)
(use tsm.proxy)

(define *server* "localhost")
(define *port* 8011)

(define (main args)
  (let-optionals* (cdr args) ((server *server*))
    (let ((tuple-space (tuple-space-connect #`"dsmp://,|server|:,|*port*|")))
      (define (do-command tower-id command . args)
        (tuple-space-write tuple-space
                           `(:tower-do ,tower-id ,command ,@args)
                           60))
      (define (tower-id->command id)
        (lambda (command . args)
          (cond ((eq? 'id command)
                 id)
                ((eq? 'read command)
                 (caddr (tuple-space-take tuple-space
                                          `((:tower ,id _))
                                          ;; :timeout 6000000
                                          )))
                (else
                 (apply do-command id command args)))))

      (define (get-tower)
        (tuple-space-take tuple-space '((:tower _ #f))))

      (define (wait-all-read towers)
        (let loop ()
          (unless (every (lambda (tower)
                           (null? (tuple-space-read-all
                                   tuple-space
                                   `((:tower-do ,(tower 'id)
                                                _ ...)))))
                         towers)
            (loop))))
      
      (let loop ((towers '())
                 (hight #f))
        (cond ((not hight)
               (display "hight?: ")
               (flush)
               (let ((hight (read)))
                 (if (eof-object? hight)
                   (print "Thank you!")
                   (loop towers (x->number hight)))))
              ((= 3 (length towers))
               (let* ((left (tower-id->command (cadr (pop! towers))))
                      (center (tower-id->command (cadr (pop! towers))))
                      (right (tower-id->command (cadr (pop! towers)))))
                 (for-each (lambda (target)
                               (target 'start hight))
                           (list left center right))
                 (wait-all-read (list left center right))
                 (for-each (lambda (elem)
                             (let ((target (car elem))
                                   (name (cadr elem)))
                               (target 'name name)))
                           `((,left "left")
                             (,center "center")
                             (,right "right")))
                 (wait-all-read (list left center right))
                 (for-each (lambda (i)
                             (left 'push i)
                             (wait-all-read (list left)))
                           (reverse (iota hight)))
                 (wait-all-read (list left center right))
                 (solve left center right hight)
                 (wait-all-read (list left center right))
                 (for-each (lambda (target)
                             (target 'finish))
                           (list left center right))
                 (print "solved!!")
                 (loop '() #f)))
              (else
               (loop (cons (get-tower) towers)
                     hight)))))))


;;; left -> right
(define (solve left center right hight)
  (cond ((zero? hight)
         ;; (print "finished")
         #t)
        (else
         (solve left right center (- hight 1))
         (left 'pop)
         (let ((disk (left 'read)))
           (right 'push disk))
         (solve center left right (- hight 1)))))

