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

  # image
  # src = system-architecture.eps
  # keep_scale = true
  # relative_height = 70

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

= 適用

  (手続きとか 引数...)

  (+ 1 2)
  ;; -> 3

= 定義

  (define finish #f)
  (define back #f)

= 条件分岐

  (if 条件式 真の場合 偽の場合)
  
  (if #t 1 2)
  ;; -> 1

= 手続き

  (lambda () #f)
  ;; -> 手続き

  ((lambda (x) (+ 10 x))
   20)
  ;; -> 30

= 代入

  (set! back 100)
  back
  ;; -> 100

= 継続の例

  (call/cc
    (lambda (継続)
      (print 1)
      (継続 返す値)
      ここには来ない))
  ;; 1
  ;; -> 返す値

= let/cc

  (call/cc
    (lambda (cont)
      ...))

  (let/cc cont
     ...)

= 継続の例

  (let/cc 継続
    (print 1)
    (継続 返す値)
    ここには来ない)
  ;; 1
  ;; -> 返す値

= 継続の代入

  (let/cc cont
    (set! back cont)
    #f)
  ;; -> #f

= 起動

  (if finish
    (finish #f)
    #f)
  ;; -> #f
  (back 'go-back)

= 継続

  (let/cc cont
    (set! back cont)
    #f)
  ;; -> go-back

= 本題

  * イベントドリブン(('rightarrow:'))プルイベント

  # image
  # src = event.eps
  # keep_scale = true
  # relative_width = 90

= イベントドリブン

  (for-each (lambda (x)
              (print x))
            '(1 2 3))
  ;; 1
  ;; 2
  ;; 3

= プルイベント

  (define pull (make-pull))
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

= 復習

  (let/cc 継続
    継続を代入

    一度だけ評価されるコード
    初期化コードとか)

= 復習例

  (let/cc cont
    (set! finish cont)
    (back 'go-back))

= 継続

  (let/cc cont
    (set! back cont)
    #f)
  ;; -> go-back

= 起動

  (if finish
    (finish #f)
    #f)
  ;; ???
  (back 'go-back)

= 復習例

  (let/cc cont
    (set! finish cont)
    (back 'go-back))
  ;; -> #f

= 続きまして

  (pull-next-language)
  ;; -> Ruby
