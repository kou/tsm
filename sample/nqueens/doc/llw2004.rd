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
  # src = system-architecture.png
  # keep_scale = true
  # relative_height = 70

= なんだけど

  * これはどうでもよくて．．．

= 真の目標

  * 継続をわかった((*気*))にさせる

= 例

  * イベントドリブン(('rightarrow:'))プルイベント

  * イベントドリブン
    * イベントが発生すると通知
  * プルイベント
    * イベントを自分で発生

= 定義

  (define finish #f)
  (define back #f)

= 条件分岐

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

= 継続

  (call/cc
    (lambda (cont)
      (set! back cont)
      #f))
  ;; -> #f

= 起動

  (if finish
    (finish #f)
    #f)
  ;; -> #f
  (back 'go-back)

= 継続

  (call/cc
    (lambda (cont)
      (set! back cont)
      #f))
  ;; -> go-back

= let/cc

  (call/cc
    (lambda (cont)
      ...))

  (let/cc cont
     ...)

= イベントドリブン

  (for-each (lambda (x)
              (print x))
            '(1 2 3))
  ;; 1
  ;; 2
  ;; 3

= プルイベント使用法

  (define pull (make-pull))
  (pull)
  ;; -> 1
  (pull)
  ;; -> 2
  (pull)
  ;; -> 3

= プルイベント

  (define (make-pull)
    (define return #f)
    (define (next)
      ...returnで値を返す...)
    (lambda ()
      (let/cc cont
        (set! return cont)
        (next))))

= next

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

= 復習

  (let/cc 継続
    ...
    継続を起動した時は
    ここは評価されない)

= 例

  (let/cc cont
    (set! finish cont)
    (back 'go-back))

= 継続

  (call/cc
    (lambda (cont)
      (set! back cont)
      #f))
  ;; -> go-back

= 起動

  (if finish
    (finish #f)
    #f)
  ;; ???
  (back 'go-back)

= 例

  (let/cc cont
    (set! finish cont)
    (back 'go-back))
  ;; -> #f

= まとめ

継続ってどうなってるの？
