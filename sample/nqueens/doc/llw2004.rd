= n-Queens

: subtitle
   LLW 2004 「君ならどう書く」（Gauche）
: author
   須藤功平
: institution
   COZMIXNG
: theme
   cozmixng

= 方針

  * ひたすら手を計算

  * スレッドではなくタプルスペース

= システム構成

  # image
  # src = system-architecture.png
  # keep_scale = true
  # relative_height = 90

= なんだけど

  * これはどうでもよくて．．．

= 真の目標

  * 継続をわかった((*気*))にさせる

= 例

  * イベントドリブン(('&rightarrow;'))プルイベント

  # image
  # src = event.png
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

= 変換方法

  # image
  # src = event-driven-to-pull-event.png
  # keep_scale = true
  # relative_width = 90

= (({pull}))を作る

    (define pull (make-pull))
    (pull)
    (pull)
    ...

  * (({pull}))は手続き
  * オブジェクトを手続きで表現

= (({make-pull}))

  (define (make-pull)
    (lambda ()
      ...次の値を返す...))

= ちょっと待った

  * 継続の使用例でも．．．

= むむむ

  * 時間が．．．

= 継続の例

   (define cont #f)
   (let/cc 継続
     (set! cont 継続)
     10)
   ;; -> 10
   (cont 100)
   ;; -> (let/cc ...) -> 100
   (cont 50)
   ;; -> (let/cc ...) -> 50

= 大域脱出

  (for-each print '(1 2 3))
  ;; 1
  ;; 2
  ;; 3

* 2が来たら中止したい

= 脱出！

  (let/cc 継続
    (for-each (lambda (x)
                (if (= x 2)
                  (継続 x)
                  (print x)))
              '(1 2 3)))
  ;; 1
  ;; -> 2

= ちょっと複雑

   (define cont #f)
   (+ 1 (let/cc 継続
          (set! cont 継続)
          10))
   ;; -> 11
   (cont 100)
   ;; -> 101
   (cont 50)
   ;; -> 51

= 関数適用の順序

  (+ 1 2)

* (({1}))を評価 (('&rightarrow;')) 1
* (({2}))を評価 (('&rightarrow;')) 2
* (({+}))を評価 (('&rightarrow;')) 足す手続き
* (({(+ 1 2)}))を評価 (('&rightarrow;')) 3

= 今回の場合

   (+ 1 (let/cc ...))

* (({1}))を評価 (('&rightarrow;')) 1
* (({(let/cc ...)}))を評価 (('&rightarrow;')) (({XXX}))
  * この時点の継続を保存
* (({+}))を評価 (('&rightarrow;')) 足す手続き
* (({(+ 1 (let/cc ...))}))を評価 (('&rightarrow;')) ???

= では続きを

  (define (make-pull)
    (lambda ()
      ...次の値を返す...))

= むむむ

  * 時間が．．．

= 手続きの中身

  (define (make-pull)
    (define return #f)
    (define (next)
      ...returnで値を返す...)
    (lambda ()
      (let/cc 継続
        (set! return 継続)
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
          (let/cc 継続
            (set! return 継続)
            (next))))

  * (({next}))を書き換え

= (({next}))を書き換え

  (lambda (x)
    (let/cc do-next<-継続
      (set! next
        (lambda ()
          (do-next<-継続 #f)))
      (return x)))

= (({do-next}))

  # image
  # src = do-next.png
  # keep_scale = true
  # relative_width = 90

= 完成

  (define pull (make-pull))
  (pull)
  ;; -> 1
  (pull)
  ;; -> 2
  (pull)
  ;; -> 3

= 目標確認

  * 継続をわかった((*気*))にさせる

= 続きまして

  (pull-lightweight-language)
  ;; -> Python
