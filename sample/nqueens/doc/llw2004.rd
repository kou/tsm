= n-Queens

: author
   須藤功平
: institution
   COZMIXNG
: theme
   cozmixng

= 方針

  * ひたすら手を計算

  * タプルスペースを使用
    * 相性問題
      * GaucheとFreeBSDとスレッド
    * せっかく作ったから
    * 作ろうと思っていたし

= イメージ

  # image
  # src = system-architecture.eps
  # keep_scale = true
  # relative_height = 90

= なんだけど

  * これはどうでもよくて．．．

= 真の目標

  * 継続をわかった((*気*))にさせる

= 例

  * イベントドリブン(('rightarrow:'))プルイベント

  # image
  # src = event.eps
  # keep_scale = true
  # relative_width = 90

= イベントドリブン例

  (for-each print '(1 2 3))
  ;; 1
  ;; 2
  ;; 3

= プルイベント例

  (pull)
  ;; -> 1
  (pull)
  ;; -> 2
  (pull)
  ;; -> 3

= 方針

  # image
  # src = event-driven-to-pull-event.eps
  # keep_scale = true
  # relative_width = 90

= (({make-pull}))

  (define (make-pull)
    (define return #f)
    (define (next)
      ...returnで値を返す...)
    (lambda ()
      (let/cc cont
        (set! return cont)
        (next))))

= (({next}))

  (define (next)
    (for-each
      (lambda (x)
        継続を保存しxを返す)
      '(1 2 3)))

= 継続を保存し(({x}))を返す

  * 次にプルされた時に継続を起動

      (define (make-pull)
        ...
        (lambda ()
          (let/cc cont
            (set! return cont)
            (next))))

  * (({next}))を書き換え

= (({next}))を書き換え

  (lambda (x)
    (let/cc do-next
      (set! next
        (lambda ()
          (do-next #f)))
      (return x)))

= 完成

  (define pull (make-pull))
  (pull)
  ;; -> 1
  (pull)
  ;; -> 2
  (pull)
  ;; -> 3

= 続きまして

  (pull-next-language)
  ;; -> Ruby
