#!/usr/bin/env gosh

(use gtk)
(use file.util)

(define (main args)
  (gtk-init args)
  (load (build-path (sys-dirname (car args)) "tower-listener"))
  (load (build-path (sys-dirname (car args)) "tower-gtk-impl"))
  (tower-listener-main args tower-gtk-main))

(define (tower-gtk-main actions)
  (print actions)
  (gtk-main))
