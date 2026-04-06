(in-package #:aimario)

;;; Color palette - Classic NES
(defparameter *T*       '(0 0 0 0))         ; Transparent
(defparameter *BLK*     '(0 0 0 255))
(defparameter *WHT*     '(252 252 252 255))
(defparameter *RED*     '(200 36 0 255))
(defparameter *DRK-RED* '(136 20 0 255))
(defparameter *BRN*     '(136 76 0 255))
(defparameter *SKIN*    '(252 188 148 255))
(defparameter *GRN*     '(0 168 0 255))
(defparameter *DRK-GRN* '(0 120 0 255))
(defparameter *BLU*     '(32 56 236 255))
(defparameter *ORG*     '(228 92 16 255))
(defparameter *YLW*     '(248 184 0 255))
(defparameter *TAN*     '(228 148 88 255))
(defparameter *DRK-TAN* '(136 112 0 255))
(defparameter *PIPE-GRN* '(0 168 68 255))
(defparameter *PIPE-DRK* '(0 120 0 255))
(defparameter *PIPE-LIT* '(128 208 16 255))
(defparameter *GRY*     '(188 188 188 255))

;;; Sprite storage: hash table mapping name -> (list width height rgba-bytes)
(defvar *sprites* (make-hash-table :test 'equal))

(defun make-sprite-data (w h pixel-colors)
  "Create sprite data: (width height rgba-byte-array)."
  (list w h (make-rgba-bytes pixel-colors w h)))

(defun store-sprite (name w h pixel-colors)
  (setf (gethash name *sprites*) (make-sprite-data w h pixel-colors)))

(defun get-sprite (name)
  (gethash name *sprites*))

;;; Underground palette
(defparameter *ug-blu* '(32 56 236 255))
(defparameter *ug-drk* '(16 28 128 255))
(defparameter *ug-gnd* '(60 60 100 255))
(defparameter *ug-gnd-lit* '(80 80 140 255))

;;; Helper to create a solid 16x16 block with border
(defun make-solid-block (fill border)
  (let ((g (make-list 256 :initial-element fill)))
    (loop for y from 0 below 16 do
      (loop for x from 0 below 16 do
        (when (or (= x 0) (= x 15) (= y 0) (= y 15))
          (setf (nth (+ (* y 16) x) g) border))))
    g))

;;; Helper: set pixel in grid list
(defmacro sp (grid w y x color)
  `(setf (nth (+ (* ,y ,w) ,x) ,grid) ,color))

;;;------------------------------------------------------------
;;; Tile sprites
;;;------------------------------------------------------------
(defun generate-tiles ()
  ;; Ground
  (let ((o *ORG*) (b *BRN*))
    (store-sprite "ground" 16 16
      (list o o o o o o o o o o o o o o o o
            o b b b b b b b o b b b b b b b
            o b b b b b b b o b b b b b b b
            o b b b b b b b o b b b b b b b
            o b b b b b b b o b b b b b b b
            o b b b b b b b o b b b b b b b
            o b b b b b b b o b b b b b b b
            o b b b b b b b o b b b b b b b
            o o o o o o o o o o o o o o o o
            b b b o b b b b b b b o b b b b
            b b b o b b b b b b b o b b b b
            b b b o b b b b b b b o b b b b
            b b b o b b b b b b b o b b b b
            b b b o b b b b b b b o b b b b
            b b b o b b b b b b b o b b b b
            b b b o b b b b b b b o b b b b)))

  ;; Brick
  (let ((k *BLK*) (r *RED*) (d *DRK-RED*))
    (store-sprite "brick" 16 16
      (list k k k k k k k k k k k k k k k k
            k d r r r r r k k d r r r r r k
            k d r r r r r k k d r r r r r k
            k d r r r r r k k d r r r r r k
            k d r r r r r k k d r r r r r k
            k d r r r r r k k d r r r r r k
            k d r r r r r k k d r r r r r k
            k k k k k k k k k k k k k k k k
            k k k k k k k k k k k k k k k k
            r r r k k d r r r r r k k d r r
            r r r k k d r r r r r k k d r r
            r r r k k d r r r r r k k d r r
            r r r k k d r r r r r k k d r r
            r r r k k d r r r r r k k d r r
            r r r k k d r r r r r k k d r r
            k k k k k k k k k k k k k k k k)))

  ;; Question blocks (3 animation frames)
  (generate-question-block "question0" *YLW* *ORG*)
  (generate-question-block "question1" '(200 168 40 255) '(168 120 20 255))
  (generate-question-block "question2" '(160 128 20 255) '(120 80 10 255))

  ;; Used block
  (store-sprite "used_block" 16 16 (make-solid-block *DRK-TAN* *BLK*))

  ;; Hard block
  (store-sprite "hard_block" 16 16 (make-solid-block *GRY* *BLK*))

  ;; Pipe textures
  (generate-pipe-textures)

  ;; Underground tile variants
  (generate-underground-tiles)

  ;; Flagpole
  (generate-flagpole-sprites))

(defun generate-question-block (name main dark)
  (let ((g (make-solid-block main *BLK*))
        (w *WHT*))
    ;; ? mark
    (loop for x from 6 to 10 do (sp g 16 3 x w))
    (sp g 16 4 5 w) (sp g 16 4 11 w)
    (sp g 16 5 11 w) (sp g 16 6 10 w)
    (sp g 16 7 9 w) (sp g 16 8 8 w)
    (sp g 16 10 8 w) (sp g 16 11 8 w)
    ;; Shadow
    (loop for x from 1 to 14 do (sp g 16 14 x dark))
    (loop for y from 1 to 14 do (sp g 16 y 14 dark))
    (store-sprite name 16 16 g)))

(defun generate-pipe-textures ()
  (let ((k *BLK*) (g *PIPE-GRN*) (l *PIPE-LIT*) (d *PIPE-DRK*) (tr *T*))
    ;; Pipe top left
    (let ((px (make-list 256 :initial-element tr)))
      (loop for y from 0 below 16 do
        (loop for x from 0 below 16 do
          (sp px 16 y x (cond ((or (< y 2) (< x 2)) k)
                              ((< x 5) l)
                              (t g)))))
      (store-sprite "pipe_tl" 16 16 px))
    ;; Pipe top right
    (let ((px (make-list 256 :initial-element tr)))
      (loop for y from 0 below 16 do
        (loop for x from 0 below 16 do
          (sp px 16 y x (cond ((or (< y 2) (> x 13)) k)
                              ((> x 10) d)
                              (t g)))))
      (store-sprite "pipe_tr" 16 16 px))
    ;; Pipe body left
    (let ((px (make-list 256 :initial-element tr)))
      (loop for y from 0 below 16 do
        (loop for x from 0 below 16 do
          (sp px 16 y x (cond ((< x 4) k)
                              ((< x 7) l)
                              (t g)))))
      (store-sprite "pipe_bl" 16 16 px))
    ;; Pipe body right
    (let ((px (make-list 256 :initial-element tr)))
      (loop for y from 0 below 16 do
        (loop for x from 0 below 16 do
          (sp px 16 y x (cond ((> x 11) k)
                              ((> x 8) d)
                              (t g)))))
      (store-sprite "pipe_br" 16 16 px))))

(defun generate-underground-tiles ()
  ;; Underground ground tile (blue-tinted brick pattern)
  (let ((g (make-list 256 :initial-element *ug-gnd*)))
    (loop for y from 0 below 16 do
      (loop for x from 0 below 16 do
        (when (or (= y 0) (= y 8))
          (setf (nth (+ (* y 16) x) g) *ug-gnd-lit*))
        (when (or (and (< y 8) (or (= x 0) (= x 8)))
                  (and (>= y 8) (or (= x 4) (= x 12))))
          (setf (nth (+ (* y 16) x) g) *ug-gnd-lit*))))
    (store-sprite "ground_ug" 16 16 g))

  ;; Underground brick tile
  (let ((g (make-list 256 :initial-element *ug-blu*))
        (k *BLK*))
    (loop for y from 0 below 16 do
      (loop for x from 0 below 16 do
        (when (or (= x 0) (= x 15) (= y 0) (= y 7) (= y 8) (= y 15))
          (setf (nth (+ (* y 16) x) g) k))
        (when (or (= x 1)
                  (and (> y 8) (= x 5))
                  (and (> y 8) (= x 13))
                  (and (<= y 7) (= x 8)))
          (setf (nth (+ (* y 16) x) g) *ug-drk*))))
    (store-sprite "brick_ug" 16 16 g))

  ;; Underground hard block
  (store-sprite "hard_block_ug" 16 16 (make-solid-block *ug-drk* *BLK*)))

(defun generate-flagpole-sprites ()
  (let ((tr *T*) (g *GRY*) (gn *GRN*))
    ;; Flagpole
    (let ((px (make-list 256 :initial-element tr)))
      (loop for y from 0 below 16 do
        (loop for x from 7 to 8 do (sp px 16 y x g)))
      (store-sprite "flagpole" 16 16 px))
    ;; Flag top
    (let ((px (make-list 256 :initial-element tr)))
      (loop for y from 2 to 6 do
        (loop for x from 5 to 10 do (sp px 16 y x gn)))
      (loop for y from 7 below 16 do
        (sp px 16 y 7 g) (sp px 16 y 8 g))
      (store-sprite "flagtop" 16 16 px))
    ;; Flag
    (let ((px (make-list 256 :initial-element tr)))
      (loop for y from 0 below 14 do
        (let ((w (- 14 y)))
          (loop for x from 0 below (min w 16) do
            (sp px 16 y x gn))))
      (store-sprite "flag" 16 16 px))))

;;;------------------------------------------------------------
;;; Mario sprites
;;;------------------------------------------------------------
(defun generate-mario ()
  (let ((tr *T*) (r *RED*) (b *BRN*) (s *SKIN*) (k *BLK*) (bl *BLU*) (y *YLW*))
    ;; Small Mario standing
    (store-sprite "mario_small_stand" 16 16
      (list tr tr tr tr tr r  r  r  r  r  tr tr tr tr tr tr
            tr tr tr tr r  r  r  r  r  r  r  r  r  tr tr tr
            tr tr tr tr b  b  b  s  s  k  s  tr tr tr tr tr
            tr tr tr b  s  b  s  s  s  k  s  s  s  tr tr tr
            tr tr tr b  s  b  b  s  s  s  k  s  s  s  tr tr
            tr tr tr b  b  s  s  s  s  k  k  k  k  tr tr tr
            tr tr tr tr tr s  s  s  s  s  s  s  tr tr tr tr
            tr tr tr tr r  r  bl r  r  r  tr tr tr tr tr tr
            tr tr tr r  r  r  bl r  r  bl r  r  r  tr tr tr
            tr tr r  r  r  r  bl bl bl bl r  r  r  r  tr tr
            tr tr s  s  r  bl y  bl bl y  bl r  s  s  tr tr
            tr tr s  s  s  bl bl bl bl bl bl s  s  s  tr tr
            tr tr s  s  bl bl bl bl bl bl bl bl s  s  tr tr
            tr tr tr tr bl bl bl tr tr bl bl bl tr tr tr tr
            tr tr tr b  b  b  tr tr tr tr b  b  b  tr tr tr
            tr tr b  b  b  b  tr tr tr tr b  b  b  b  tr tr))

    ;; Small Mario walk1
    (store-sprite "mario_small_walk1" 16 16
      (list tr tr tr tr tr r  r  r  r  r  tr tr tr tr tr tr
            tr tr tr tr r  r  r  r  r  r  r  r  r  tr tr tr
            tr tr tr tr b  b  b  s  s  k  s  tr tr tr tr tr
            tr tr tr b  s  b  s  s  s  k  s  s  s  tr tr tr
            tr tr tr b  s  b  b  s  s  s  k  s  s  s  tr tr
            tr tr tr b  b  s  s  s  s  k  k  k  k  tr tr tr
            tr tr tr tr tr s  s  s  s  s  s  s  tr tr tr tr
            tr tr tr tr r  r  r  bl r  r  tr tr tr tr tr tr
            tr tr tr r  r  r  bl bl r  r  r  tr tr tr tr tr
            tr tr tr tr r  r  bl bl bl bl tr tr tr tr tr tr
            tr tr tr tr tr bl bl bl bl tr tr tr tr tr tr tr
            tr tr tr tr b  b  r  r  r  tr tr tr tr tr tr tr
            tr tr tr b  b  b  b  r  tr tr tr tr tr tr tr tr
            tr tr tr b  b  tr b  b  b  tr tr tr tr tr tr tr
            tr tr tr tr tr tr b  b  b  b  tr tr tr tr tr tr
            tr tr tr tr tr tr tr b  b  tr tr tr tr tr tr tr))

    ;; Small Mario walk2
    (store-sprite "mario_small_walk2" 16 16
      (list tr tr tr tr tr r  r  r  r  r  tr tr tr tr tr tr
            tr tr tr tr r  r  r  r  r  r  r  r  r  tr tr tr
            tr tr tr tr b  b  b  s  s  k  s  tr tr tr tr tr
            tr tr tr b  s  b  s  s  s  k  s  s  s  tr tr tr
            tr tr tr b  s  b  b  s  s  s  k  s  s  s  tr tr
            tr tr tr b  b  s  s  s  s  k  k  k  k  tr tr tr
            tr tr tr tr tr s  s  s  s  s  s  s  tr tr tr tr
            tr tr tr tr tr r  r  bl r  tr tr tr tr tr tr tr
            tr tr tr tr r  r  r  bl r  r  tr tr tr tr tr tr
            tr tr tr tr r  bl bl bl bl r  tr tr tr tr tr tr
            tr tr tr tr b  bl bl bl b  tr tr tr tr tr tr tr
            tr tr tr b  b  b  r  b  b  tr tr tr tr tr tr tr
            tr tr tr b  b  b  b  b  tr tr tr tr tr tr tr tr
            tr tr tr tr b  b  tr tr tr tr tr tr tr tr tr tr
            tr tr tr tr b  b  b  tr tr tr tr tr tr tr tr tr
            tr tr tr tr tr tr tr tr tr tr tr tr tr tr tr tr))

    ;; walk3 = walk1
    (setf (gethash "mario_small_walk3" *sprites*)
          (gethash "mario_small_walk1" *sprites*))

    ;; Small Mario jump
    (store-sprite "mario_small_jump" 16 16
      (list tr tr tr tr tr tr tr tr tr s  tr tr tr tr tr tr
            tr tr tr tr tr r  r  r  r  r  tr tr tr tr tr tr
            tr tr tr tr r  r  r  r  r  r  r  r  r  tr tr tr
            tr tr tr tr b  b  b  s  s  k  s  tr tr tr tr tr
            tr tr tr b  s  b  s  s  s  k  s  s  s  tr tr tr
            tr tr tr b  s  b  b  s  s  s  k  s  s  s  tr tr
            tr tr tr b  b  s  s  s  s  k  k  k  k  tr tr tr
            tr tr tr tr tr s  s  s  s  s  s  s  tr tr tr tr
            tr tr r  r  r  r  bl r  r  bl tr tr tr tr tr tr
            s  r  r  r  r  r  bl bl bl bl r  tr tr tr tr tr
            s  s  tr r  bl y  bl bl y  bl r  r  tr tr tr tr
            tr tr tr bl bl bl bl bl bl bl bl tr tr tr tr tr
            tr tr bl bl bl bl bl tr bl bl tr tr tr tr tr tr
            tr b  b  b  tr tr tr tr tr b  b  tr tr tr tr tr
            tr b  b  b  b  tr tr tr tr tr b  b  tr tr tr tr
            tr tr tr tr tr tr tr tr tr tr tr tr tr tr tr tr))

    ;; Death = jump
    (setf (gethash "mario_small_death" *sprites*)
          (gethash "mario_small_jump" *sprites*)))

  ;; Big Mario variants
  (generate-big-mario "mario_big_stand" nil 0)
  (generate-big-mario "mario_big_walk1" nil 1)
  (generate-big-mario "mario_big_walk2" nil 2)
  (setf (gethash "mario_big_walk3" *sprites*)
        (gethash "mario_big_walk1" *sprites*))
  (generate-big-mario "mario_big_jump" nil 3)
  (generate-big-mario-duck "mario_big_duck" nil)

  ;; Fire Mario variants
  (generate-big-mario "mario_fire_stand" t 0)
  (generate-big-mario "mario_fire_walk1" t 1)
  (generate-big-mario "mario_fire_walk2" t 2)
  (setf (gethash "mario_fire_walk3" *sprites*)
        (gethash "mario_fire_walk1" *sprites*))
  (generate-big-mario "mario_fire_jump" t 3)
  (generate-big-mario-duck "mario_fire_duck" t))

(defun generate-big-mario (name fire frame)
  (let* ((hat (if fire *WHT* *RED*))
         (overalls (if fire *BRN* *BLU*))
         (tr *T*) (b *BRN*) (s *SKIN*) (k *BLK*) (y *YLW*)
         (g (make-list (* 16 32) :initial-element tr)))
    (macrolet ((ss (gy gx c) `(sp g 16 ,gy ,gx ,c)))
      ;; Head
      (loop for x from 4 to 9 do (ss 1 x hat))
      (loop for x from 3 to 12 do (ss 2 x hat))
      (loop for x from 3 to 13 do (ss 3 x hat))
      ;; Face
      (loop for x from 3 to 5 do (ss 4 x b))
      (loop for x from 6 to 8 do (ss 4 x s))
      (ss 4 9 k) (ss 4 10 s)
      (ss 5 2 b) (ss 5 3 b) (ss 5 4 s) (ss 5 5 b)
      (loop for x from 6 to 8 do (ss 5 x s))
      (ss 5 9 k)
      (loop for x from 10 to 12 do (ss 5 x s))
      (ss 6 2 b) (ss 6 3 s) (ss 6 4 b) (ss 6 5 b)
      (loop for x from 6 to 8 do (ss 6 x s))
      (ss 6 9 k)
      (loop for x from 10 to 13 do (ss 6 x s))
      (loop for x from 3 to 4 do (ss 7 x b))
      (loop for x from 5 to 9 do (ss 7 x s))
      (loop for x from 10 to 12 do (ss 7 x k))
      (loop for x from 5 to 11 do (ss 8 x s))

      ;; Torso
      (loop for x from 3 to 11 do (ss 10 x hat))
      (ss 10 6 overalls)
      (loop for x from 2 to 12 do (ss 11 x hat))
      (ss 11 5 overalls) (ss 11 7 overalls)
      (loop for x from 2 to 12 do (ss 12 x hat))
      (ss 12 5 overalls) (ss 12 6 hat) (ss 12 7 overalls)
      (loop for x from 2 to 12 do (ss 13 x hat))
      (ss 13 4 overalls) (ss 13 5 hat) (ss 13 6 overalls) (ss 13 7 hat) (ss 13 8 overalls)

      ;; Overalls
      (loop for x from 2 to 12 do (ss 15 x overalls))
      (ss 15 4 y) (ss 15 10 y)
      (loop for x from 2 to 12 do (ss 16 x overalls))
      (loop for x from 2 to 12 do (ss 17 x overalls))
      (ss 17 4 y) (ss 17 10 y)
      (loop for x from 2 to 12 do (ss 18 x overalls))
      (loop for x from 2 to 12 do (ss 19 x overalls))
      (loop for x from 2 to 12 do (ss 20 x overalls))
      (loop for x from 3 to 11 do (ss 21 x overalls))

      ;; Legs by frame
      (case frame
        (0 ; standing
         (loop for x from 3 to 5 do
           (loop for row from 22 to 25 do (ss row x overalls)))
         (loop for x from 9 to 11 do
           (loop for row from 22 to 25 do (ss row x overalls)))
         (loop for x from 2 to 6 do (ss 26 x b) (ss 27 x b))
         (loop for x from 8 to 12 do (ss 26 x b) (ss 27 x b))
         (loop for x from 1 to 6 do (ss 28 x b))
         (loop for x from 8 to 13 do (ss 28 x b))
         (loop for x from 1 to 7 do (ss 29 x b))
         (loop for x from 8 to 14 do (ss 29 x b)))
        (1 ; walk1
         (loop for i in '(4 5 6) do (ss 22 i overalls))
         (ss 22 9 overalls) (ss 22 10 overalls)
         (loop for i in '(4 5 6 7) do (ss 23 i overalls))
         (ss 23 9 overalls) (ss 23 10 overalls)
         (loop for i in '(5 6 7) do (ss 24 i overalls))
         (ss 24 10 overalls) (ss 24 11 overalls)
         (loop for x from 6 to 8 do (ss 25 x b))
         (ss 25 10 b) (ss 25 11 b)
         (loop for x from 6 to 9 do (ss 26 x b))
         (ss 26 11 b) (ss 26 12 b)
         (loop for x from 7 to 10 do (ss 27 x b))
         (ss 27 12 b) (ss 27 13 b))
        (2 ; walk2
         (ss 22 5 overalls) (ss 22 6 overalls)
         (ss 22 8 overalls) (ss 22 9 overalls)
         (ss 23 5 overalls) (ss 23 6 overalls)
         (ss 23 8 overalls) (ss 23 9 overalls)
         (ss 24 4 overalls) (ss 24 5 overalls)
         (ss 24 9 overalls) (ss 24 10 overalls)
         (loop for x from 3 to 6 do (ss 25 x b))
         (loop for x from 9 to 11 do (ss 25 x b))
         (loop for x from 3 to 6 do (ss 26 x b))
         (loop for x from 9 to 12 do (ss 26 x b))
         (loop for x from 2 to 5 do (ss 27 x b))
         (loop for x from 9 to 12 do (ss 27 x b)))
        (otherwise ; jump
         (ss 9 2 s) (ss 9 3 s)
         (ss 22 3 overalls) (ss 22 4 overalls) (ss 22 5 hat)
         (ss 22 10 overalls) (ss 22 11 overalls)
         (ss 23 2 overalls) (ss 23 3 overalls) (ss 23 4 hat)
         (ss 23 11 overalls) (ss 23 12 overalls)
         (ss 24 1 b) (ss 24 2 b) (ss 24 3 b)
         (ss 24 12 overalls) (ss 24 13 overalls)
         (ss 25 1 b) (ss 25 2 b) (ss 25 3 b)
         (ss 25 13 b) (ss 25 14 b)
         (ss 26 1 b) (ss 26 2 b)
         (ss 26 13 b) (ss 26 14 b))))

    (store-sprite name 16 32 g)))

(defun generate-big-mario-duck (name fire)
  (let* ((hat (if fire *WHT* *RED*))
         (overalls (if fire *BRN* *BLU*))
         (tr *T*) (b *BRN*) (s *SKIN*) (k *BLK*) (y *YLW*)
         (g (make-list (* 16 32) :initial-element tr))
         (oy 16))
    (macrolet ((ss (gy gx c) `(sp g 16 ,gy ,gx ,c)))
      (loop for x from 4 to 9 do (ss (+ oy 0) x hat))
      (loop for x from 3 to 12 do (ss (+ oy 1) x hat))
      (loop for x from 3 to 12 do (ss (+ oy 2) x hat))
      (loop for x from 3 to 5 do (ss (+ oy 3) x b))
      (loop for x from 6 to 8 do (ss (+ oy 3) x s))
      (ss (+ oy 3) 9 k) (ss (+ oy 3) 10 s)
      (loop for x from 5 to 11 do (ss (+ oy 4) x s))

      (loop for x from 3 to 11 do (ss (+ oy 5) x hat))
      (loop for x from 2 to 12 do (ss (+ oy 6) x hat))
      (loop for x from 2 to 12 do (ss (+ oy 7) x overalls))
      (ss (+ oy 7) 4 y) (ss (+ oy 7) 10 y)
      (loop for x from 2 to 12 do (ss (+ oy 8) x overalls))
      (loop for x from 2 to 12 do (ss (+ oy 9) x overalls))
      (loop for x from 3 to 11 do (ss (+ oy 10) x overalls))
      (loop for x from 2 to 5 do (ss (+ oy 11) x b))
      (loop for x from 9 to 12 do (ss (+ oy 11) x b))
      (loop for x from 1 to 6 do (ss (+ oy 12) x b))
      (loop for x from 8 to 13 do (ss (+ oy 12) x b)))

    (store-sprite name 16 32 g)))

;;;------------------------------------------------------------
;;; Enemy sprites
;;;------------------------------------------------------------
(defun generate-enemies ()
  (let ((tr *T*) (k *BLK*) (w *WHT*) (s *SKIN*)
        (gb '(172 80 0 255)) (gd '(116 52 0 255))
        (gn *GRN*) (dg *DRK-GRN*) (y *YLW*))
    ;; Goomba frame 0
    (store-sprite "goomba0" 16 16
      (list tr tr tr tr tr tr gb gb gb gb tr tr tr tr tr tr
            tr tr tr tr tr gb gb gb gb gb gb tr tr tr tr tr
            tr tr tr tr gb gb gb gb gb gb gb gb tr tr tr tr
            tr tr tr gb gb gb gb gb gb gb gb gb gb tr tr tr
            tr tr gb gb k  k  gb gb gb gb k  k  gb gb tr tr
            tr gb gb k  w  k  gb gb gb gb k  w  k  gb gb tr
            tr gb gb k  k  gb gb gb gb gb gb k  k  gb gb tr
            tr gb gb gb gb gb gb gb gb gb gb gb gb gb gb tr
            tr tr gb gb gb gb gd gd gd gd gb gb gb gb tr tr
            tr tr tr tr gd gd gd gd gd gd gd gd tr tr tr tr
            tr tr tr gd gd gd gd gd gd gd gd gd gd tr tr tr
            tr tr gd gd gd gd gd gd gd gd gd gd gd gd tr tr
            tr tr tr s  s  gd gd gd gd gd gd s  s  tr tr tr
            tr tr s  s  s  s  tr tr tr tr s  s  s  s  tr tr
            tr k  k  k  s  s  tr tr tr tr s  s  k  k  k  tr
            k  k  k  k  k  tr tr tr tr tr tr k  k  k  k  k))

    ;; Goomba frame 1
    (store-sprite "goomba1" 16 16
      (list tr tr tr tr tr tr gb gb gb gb tr tr tr tr tr tr
            tr tr tr tr tr gb gb gb gb gb gb tr tr tr tr tr
            tr tr tr tr gb gb gb gb gb gb gb gb tr tr tr tr
            tr tr tr gb gb gb gb gb gb gb gb gb gb tr tr tr
            tr tr gb gb k  k  gb gb gb gb k  k  gb gb tr tr
            tr gb gb k  w  k  gb gb gb gb k  w  k  gb gb tr
            tr gb gb k  k  gb gb gb gb gb gb k  k  gb gb tr
            tr gb gb gb gb gb gb gb gb gb gb gb gb gb gb tr
            tr tr gb gb gb gb gd gd gd gd gb gb gb gb tr tr
            tr tr tr tr gd gd gd gd gd gd gd gd tr tr tr tr
            tr tr tr gd gd gd gd gd gd gd gd gd gd tr tr tr
            tr tr gd gd gd gd gd gd gd gd gd gd gd gd tr tr
            tr tr tr gd gd s  s  tr tr s  s  gd gd tr tr tr
            tr tr s  s  s  s  tr tr tr tr s  s  s  s  tr tr
            tr s  s  k  k  k  tr tr tr tr k  k  k  s  s  tr
            tr tr k  k  k  k  k  tr tr k  k  k  k  k  tr tr))

    ;; Goomba flat
    (let ((px (make-list 256 :initial-element tr)))
      (loop for x from 1 to 14 do (sp px 16 14 x gd))
      (loop for x from 2 to 13 do (sp px 16 15 x gd))
      (sp px 16 14 4 k) (sp px 16 14 5 k)
      (sp px 16 14 10 k) (sp px 16 14 11 k)
      (store-sprite "goomba_flat" 16 16 px))

    ;; Koopa frames
    (generate-koopa "koopa0" 0 gn dg w k s y tr)
    (generate-koopa "koopa1" 1 gn dg w k s y tr)

    ;; Koopa shell
    (let ((px (make-list 256 :initial-element tr)))
      (loop for x from 4 to 11 do (sp px 16 2 x gn))
      (loop for x from 3 to 12 do (sp px 16 3 x gn))
      (loop for x from 2 to 13 do (sp px 16 4 x gn))
      (loop for x from 2 to 13 do (sp px 16 5 x dg))
      (sp px 16 5 5 y) (sp px 16 5 6 y) (sp px 16 5 9 y) (sp px 16 5 10 y)
      (loop for x from 2 to 13 do (sp px 16 6 x dg))
      (loop for x from 2 to 13 do (sp px 16 7 x dg))
      (loop for x from 2 to 13 do (sp px 16 8 x gn))
      (loop for x from 2 to 13 do (sp px 16 9 x gn))
      (loop for x from 3 to 12 do (sp px 16 10 x gn))
      (loop for x from 3 to 12 do (sp px 16 11 x w))
      (loop for x from 4 to 11 do (sp px 16 12 x w))
      (loop for x from 5 to 10 do (sp px 16 13 x w))
      (store-sprite "koopa_shell" 16 16 px))))

(defun generate-koopa (name frame gn dg w k s y tr)
  (let ((px (make-list (* 16 24) :initial-element tr))
        (oy 10))
    (macrolet ((ss (gy gx c) `(sp px 16 ,gy ,gx ,c)))
      ;; Head
      (loop for x from 7 to 12 do (ss (+ oy 0) x gn))
      (loop for x from 6 to 13 do (ss (+ oy 1) x gn))
      (loop for x from 6 to 13 do (ss (+ oy 2) x gn))
      (ss (+ oy 2) 10 w) (ss (+ oy 2) 11 w)
      (loop for x from 6 to 13 do (ss (+ oy 3) x gn))
      (ss (+ oy 3) 10 w) (ss (+ oy 3) 11 k) (ss (+ oy 3) 12 s)
      (loop for x from 7 to 13 do (ss (+ oy 4) x gn))
      (ss (+ oy 4) 12 s) (ss (+ oy 4) 13 s)
      (loop for x from 8 to 11 do (ss (+ oy 5) x gn))

      ;; Shell
      (loop for x from 3 to 11 do (ss (+ oy 6) x gn))
      (loop for x from 2 to 12 do (ss (+ oy 7) x gn))
      (loop for x from 2 to 12 do (ss (+ oy 8) x dg))
      (ss (+ oy 8) 5 y) (ss (+ oy 8) 6 y) (ss (+ oy 8) 9 y) (ss (+ oy 8) 10 y)
      (loop for x from 2 to 12 do (ss (+ oy 9) x dg))
      (loop for x from 2 to 12 do (ss (+ oy 10) x gn))
      (loop for x from 3 to 11 do (ss (+ oy 11) x gn))

      ;; Feet
      (if (= frame 0)
          (progn
            (loop for x from 3 to 5 do (ss (+ oy 12) x s))
            (loop for x from 9 to 11 do (ss (+ oy 12) x s))
            (loop for x from 2 to 5 do (ss (+ oy 13) x s))
            (loop for x from 9 to 12 do (ss (+ oy 13) x s)))
          (progn
            (loop for x from 4 to 6 do (ss (+ oy 12) x s))
            (loop for x from 8 to 10 do (ss (+ oy 12) x s))
            (loop for x from 5 to 7 do (ss (+ oy 13) x s))
            (loop for x from 7 to 9 do (ss (+ oy 13) x s)))))

    (store-sprite name 16 24 px)))

;;;------------------------------------------------------------
;;; Item sprites
;;;------------------------------------------------------------
(defun generate-items ()
  (let ((tr *T*) (y *YLW*) (o *ORG*) (k *BLK*) (w *WHT*)
        (r *RED*) (gn *GRN*) (s *SKIN*))
    ;; Coin
    (store-sprite "coin" 16 16
      (list tr tr tr tr tr tr y  y  y  y  tr tr tr tr tr tr
            tr tr tr tr tr y  y  o  o  y  y  tr tr tr tr tr
            tr tr tr tr y  y  o  y  y  o  y  y  tr tr tr tr
            tr tr tr tr y  o  y  y  y  y  o  y  tr tr tr tr
            tr tr tr tr y  o  y  y  y  y  o  y  tr tr tr tr
            tr tr tr tr y  o  y  y  y  y  o  y  tr tr tr tr
            tr tr tr tr y  o  y  y  y  y  o  y  tr tr tr tr
            tr tr tr tr y  o  y  y  y  y  o  y  tr tr tr tr
            tr tr tr tr y  o  y  y  y  y  o  y  tr tr tr tr
            tr tr tr tr y  o  y  y  y  y  o  y  tr tr tr tr
            tr tr tr tr y  o  y  y  y  y  o  y  tr tr tr tr
            tr tr tr tr y  o  y  y  y  y  o  y  tr tr tr tr
            tr tr tr tr y  y  o  y  y  o  y  y  tr tr tr tr
            tr tr tr tr tr y  y  o  o  y  y  tr tr tr tr tr
            tr tr tr tr tr tr y  y  y  y  tr tr tr tr tr tr
            tr tr tr tr tr tr tr tr tr tr tr tr tr tr tr tr))
    (setf (gethash "coin_popup" *sprites*) (gethash "coin" *sprites*))

    ;; Mushroom
    (let ((mr '(200 36 0 255)))
      (store-sprite "mushroom" 16 16
        (list tr tr tr tr tr mr mr mr mr mr mr tr tr tr tr tr
              tr tr tr mr mr mr mr mr mr mr mr mr mr tr tr tr
              tr tr mr mr w  w  mr mr mr mr w  w  mr mr tr tr
              tr mr mr w  w  w  w  mr mr w  w  w  w  mr mr tr
              tr mr w  w  w  w  mr mr mr mr w  w  w  w  mr tr
              mr mr mr w  w  mr mr mr mr mr mr w  w  mr mr mr
              mr mr mr mr mr mr mr mr mr mr mr mr mr mr mr mr
              mr mr mr mr mr mr mr mr mr mr mr mr mr mr mr mr
              tr tr tr s  s  s  s  s  s  s  s  s  s  tr tr tr
              tr tr s  s  s  s  s  s  s  s  s  s  s  s  tr tr
              tr s  s  k  k  s  s  s  s  s  s  k  k  s  s  tr
              tr s  k  k  k  k  s  s  s  s  k  k  k  k  s  tr
              tr s  s  k  k  s  s  s  s  s  s  k  k  s  s  tr
              tr tr s  s  s  s  s  s  s  s  s  s  s  s  tr tr
              tr tr tr s  s  s  s  s  s  s  s  s  s  tr tr tr
              tr tr tr tr tr tr tr tr tr tr tr tr tr tr tr tr)))

    ;; Fire Flower
    (let ((fo '(228 92 16 255)))
      (store-sprite "fireflower" 16 16
        (list tr tr tr tr tr tr r  r  r  r  tr tr tr tr tr tr
              tr tr tr tr r  r  r  y  y  r  r  r  tr tr tr tr
              tr tr tr r  r  y  fo fo fo fo y  r  r  tr tr tr
              tr tr r  r  y  fo fo w  w  fo fo y  r  r  tr tr
              tr tr r  y  fo fo w  w  w  w  fo fo y  r  tr tr
              tr tr r  y  fo fo w  w  w  w  fo fo y  r  tr tr
              tr tr r  r  y  fo fo fo fo fo fo y  r  r  tr tr
              tr tr tr r  r  y  fo fo fo fo y  r  r  tr tr tr
              tr tr tr tr tr gn gn gn gn gn gn tr tr tr tr tr
              tr tr tr tr gn gn tr gn gn tr gn gn tr tr tr tr
              tr tr tr gn gn tr tr gn gn tr tr gn gn tr tr tr
              tr tr tr gn tr tr tr gn gn tr tr tr gn tr tr tr
              tr tr tr tr tr tr tr gn gn tr tr tr tr tr tr tr
              tr tr tr tr tr tr tr gn gn tr tr tr tr tr tr tr
              tr tr tr tr tr tr tr gn gn tr tr tr tr tr tr tr
              tr tr tr tr tr tr tr tr tr tr tr tr tr tr tr tr)))

    ;; Star
    (store-sprite "star" 16 16
      (list tr tr tr tr tr tr tr y  y  tr tr tr tr tr tr tr
            tr tr tr tr tr tr y  y  y  y  tr tr tr tr tr tr
            tr tr tr tr tr tr y  y  y  y  tr tr tr tr tr tr
            tr tr tr tr tr y  y  y  y  y  y  tr tr tr tr tr
            y  y  y  y  y  y  y  y  y  y  y  y  y  y  y  y
            tr y  y  y  y  y  o  o  o  o  y  y  y  y  y  tr
            tr tr y  y  y  o  o  k  k  o  o  y  y  y  tr tr
            tr tr tr y  y  o  k  o  o  k  o  y  y  tr tr tr
            tr tr tr y  y  o  o  o  o  o  o  y  y  tr tr tr
            tr tr tr y  y  y  o  o  o  o  y  y  y  tr tr tr
            tr tr tr tr y  y  y  y  y  y  y  y  tr tr tr tr
            tr tr tr y  y  y  y  tr tr y  y  y  y  tr tr tr
            tr tr y  y  y  tr tr tr tr tr tr y  y  y  tr tr
            tr y  y  y  tr tr tr tr tr tr tr tr y  y  y  tr
            tr tr tr tr tr tr tr tr tr tr tr tr tr tr tr tr
            tr tr tr tr tr tr tr tr tr tr tr tr tr tr tr tr))

    ;; 1-Up mushroom
    (store-sprite "oneup" 16 16
      (list tr tr tr tr tr gn gn gn gn gn gn tr tr tr tr tr
            tr tr tr gn gn gn gn gn gn gn gn gn gn tr tr tr
            tr tr gn gn w  w  gn gn gn gn w  w  gn gn tr tr
            tr gn gn w  w  w  w  gn gn w  w  w  w  gn gn tr
            tr gn w  w  w  w  gn gn gn gn w  w  w  w  gn tr
            gn gn gn w  w  gn gn gn gn gn gn w  w  gn gn gn
            gn gn gn gn gn gn gn gn gn gn gn gn gn gn gn gn
            gn gn gn gn gn gn gn gn gn gn gn gn gn gn gn gn
            tr tr tr s  s  s  s  s  s  s  s  s  s  tr tr tr
            tr tr s  s  s  s  s  s  s  s  s  s  s  s  tr tr
            tr s  s  k  k  s  s  s  s  s  s  k  k  s  s  tr
            tr s  k  k  k  k  s  s  s  s  k  k  k  k  s  tr
            tr s  s  k  k  s  s  s  s  s  s  k  k  s  s  tr
            tr tr s  s  s  s  s  s  s  s  s  s  s  s  tr tr
            tr tr tr s  s  s  s  s  s  s  s  s  s  tr tr tr
            tr tr tr tr tr tr tr tr tr tr tr tr tr tr tr tr))

    ;; Brick debris (8x8)
    (let ((px (make-list 64 :initial-element tr)))
      (loop for y from 0 below 8 do
        (loop for x from 0 below 8 do
          (when (or (= x 0) (= x 7) (= y 0) (= y 7))
            (sp px 8 y x k))
          (when (and (> x 0) (< x 7) (> y 0) (< y 7))
            (sp px 8 y x r))))
      (store-sprite "brick_debris" 8 8 px))))

;;;------------------------------------------------------------
;;; Fireball sprite
;;;------------------------------------------------------------
(defun generate-fireball ()
  (let ((tr *T*) (y *YLW*) (r *RED*)
        (fr '(252 152 56 255)))
    (let ((px (make-list 64 :initial-element tr)))
      (loop for x from 2 to 5 do (sp px 8 1 x fr))
      (loop for x from 1 to 6 do (sp px 8 2 x y))
      (loop for x from 1 to 6 do (sp px 8 3 x y))
      (loop for x from 1 to 6 do (sp px 8 4 x fr))
      (loop for x from 1 to 6 do (sp px 8 5 x fr))
      (loop for x from 2 to 5 do (sp px 8 6 x r))
      (store-sprite "fireball" 8 8 px))))

;;;------------------------------------------------------------
;;; Font sprites (5x7 bitmap font)
;;;------------------------------------------------------------
(defun generate-font ()
  (let ((chars '("0" "1" "2" "3" "4" "5" "6" "7" "8" "9"
                 "A" "B" "C" "D" "E" "F" "G" "H" "I" "J" "K" "L" "M"
                 "N" "O" "P" "Q" "R" "S" "T" "U" "V" "W" "X" "Y" "Z"
                 "-" "x" "!" "." ":" " "))
        (patterns (list
                   '(#x0E #x11 #x13 #x15 #x19 #x11 #x0E)  ; 0
                   '(#x04 #x0C #x04 #x04 #x04 #x04 #x0E)  ; 1
                   '(#x0E #x11 #x01 #x06 #x08 #x10 #x1F)  ; 2
                   '(#x0E #x11 #x01 #x06 #x01 #x11 #x0E)  ; 3
                   '(#x02 #x06 #x0A #x12 #x1F #x02 #x02)  ; 4
                   '(#x1F #x10 #x1E #x01 #x01 #x11 #x0E)  ; 5
                   '(#x06 #x08 #x10 #x1E #x11 #x11 #x0E)  ; 6
                   '(#x1F #x01 #x02 #x04 #x08 #x08 #x08)  ; 7
                   '(#x0E #x11 #x11 #x0E #x11 #x11 #x0E)  ; 8
                   '(#x0E #x11 #x11 #x0F #x01 #x02 #x0C)  ; 9
                   '(#x0E #x11 #x11 #x1F #x11 #x11 #x11)  ; A
                   '(#x1E #x11 #x11 #x1E #x11 #x11 #x1E)  ; B
                   '(#x0E #x11 #x10 #x10 #x10 #x11 #x0E)  ; C
                   '(#x1E #x11 #x11 #x11 #x11 #x11 #x1E)  ; D
                   '(#x1F #x10 #x10 #x1E #x10 #x10 #x1F)  ; E
                   '(#x1F #x10 #x10 #x1E #x10 #x10 #x10)  ; F
                   '(#x0E #x11 #x10 #x17 #x11 #x11 #x0F)  ; G
                   '(#x11 #x11 #x11 #x1F #x11 #x11 #x11)  ; H
                   '(#x0E #x04 #x04 #x04 #x04 #x04 #x0E)  ; I
                   '(#x07 #x02 #x02 #x02 #x02 #x12 #x0C)  ; J
                   '(#x11 #x12 #x14 #x18 #x14 #x12 #x11)  ; K
                   '(#x10 #x10 #x10 #x10 #x10 #x10 #x1F)  ; L
                   '(#x11 #x1B #x15 #x15 #x11 #x11 #x11)  ; M
                   '(#x11 #x11 #x19 #x15 #x13 #x11 #x11)  ; N
                   '(#x0E #x11 #x11 #x11 #x11 #x11 #x0E)  ; O
                   '(#x1E #x11 #x11 #x1E #x10 #x10 #x10)  ; P
                   '(#x0E #x11 #x11 #x11 #x15 #x12 #x0D)  ; Q
                   '(#x1E #x11 #x11 #x1E #x14 #x12 #x11)  ; R
                   '(#x0E #x11 #x10 #x0E #x01 #x11 #x0E)  ; S
                   '(#x1F #x04 #x04 #x04 #x04 #x04 #x04)  ; T
                   '(#x11 #x11 #x11 #x11 #x11 #x11 #x0E)  ; U
                   '(#x11 #x11 #x11 #x11 #x0A #x0A #x04)  ; V
                   '(#x11 #x11 #x11 #x15 #x15 #x1B #x11)  ; W
                   '(#x11 #x11 #x0A #x04 #x0A #x11 #x11)  ; X
                   '(#x11 #x11 #x0A #x04 #x04 #x04 #x04)  ; Y
                   '(#x1F #x01 #x02 #x04 #x08 #x10 #x1F)  ; Z
                   '(#x00 #x00 #x00 #x1F #x00 #x00 #x00)  ; -
                   '(#x00 #x11 #x0A #x04 #x0A #x11 #x00)  ; x
                   '(#x04 #x04 #x04 #x04 #x04 #x00 #x04)  ; !
                   '(#x00 #x00 #x00 #x00 #x00 #x00 #x04)  ; .
                   '(#x00 #x04 #x00 #x00 #x00 #x04 #x00)  ; :
                   '(#x00 #x00 #x00 #x00 #x00 #x00 #x00)  ; space
                   ))
        (tr *T*) (w *WHT*))
    (loop for ch in chars
          for pattern in patterns do
      (let ((data (make-list 35 :initial-element tr)))
        (loop for y from 0 below 7 do
          (loop for x from 0 below 5 do
            (when (logbitp (- 4 x) (nth y pattern))
              (sp data 5 y x w))))
        (store-sprite (format nil "font_~A" ch) 5 7 data)))))

;;;------------------------------------------------------------
;;; Generate all sprites
;;;------------------------------------------------------------
(defun generate-all-sprites ()
  (setf *sprites* (make-hash-table :test 'equal))
  (generate-tiles)
  (generate-mario)
  (generate-enemies)
  (generate-items)
  (generate-fireball)
  (generate-font))
