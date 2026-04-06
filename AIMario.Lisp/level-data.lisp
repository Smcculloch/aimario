(in-package #:aimario)

;;; World 1-1 level layout

(defun set-tile-data (map x y tile-type)
  (when (and (>= x 0) (< x +level-width-tiles+)
             (>= y 0) (< y +level-height-tiles+))
    (setf (aref map y x) (tile-type-to-int tile-type))))

(defun clear-ground (map start-x end-x)
  (loop for x from start-x to end-x do
    (setf (aref map 13 x) 0)
    (setf (aref map 14 x) 0)))

(defun set-pipe (map x top-y height)
  (set-tile-data map x top-y :pipe-top-left)
  (set-tile-data map (1+ x) top-y :pipe-top-right)
  (loop for y from (1+ top-y) below (+ top-y height) do
    (set-tile-data map x y :pipe-body-left)
    (set-tile-data map (1+ x) y :pipe-body-right)))

(defun build-stair (map start-x bottom-y height ascending)
  (loop for i from 0 below height do
    (let ((x (+ start-x i))
          (col-height (if ascending (1+ i) (- height i))))
      (loop for h from 0 below col-height do
        (set-tile-data map x (- bottom-y h) :hard-block)))))

(defun get-world-1-1 ()
  "Returns a 2D array (rows x cols) of tile type integers."
  (let ((map (make-array (list +level-height-tiles+ +level-width-tiles+)
                         :initial-element 0)))
    ;; Fill ground (rows 13-14)
    (loop for x from 0 below +level-width-tiles+ do
      (setf (aref map 13 x) (tile-type-to-int :ground))
      (setf (aref map 14 x) (tile-type-to-int :ground)))

    ;; Pits
    (clear-ground map 69 70)
    (clear-ground map 86 88)
    (clear-ground map 153 154)

    ;; Question/brick blocks
    (set-tile-data map 16 9 :question)
    (set-tile-data map 20 9 :brick)
    (set-tile-data map 21 9 :question)
    (set-tile-data map 22 9 :brick)
    (set-tile-data map 23 9 :question)
    (set-tile-data map 22 5 :question)

    ;; Pipes
    (set-pipe map 28 11 2)
    (set-pipe map 38 10 3)
    (set-pipe map 46 9 4)
    (set-pipe map 57 9 4)

    ;; Exit pipe (underground return)
    (set-pipe map 163 11 2)

    ;; Block formations
    (set-tile-data map 77 9 :question)
    (set-tile-data map 80 9 :brick)
    (loop for x from 81 to 88 do (set-tile-data map x 5 :brick))

    (set-tile-data map 91 5 :brick)
    (set-tile-data map 92 5 :brick)
    (set-tile-data map 93 5 :brick)
    (set-tile-data map 94 9 :question)

    (set-tile-data map 100 9 :brick)
    (set-tile-data map 101 9 :question)
    (set-tile-data map 102 9 :brick)
    (set-tile-data map 101 5 :question)

    (set-tile-data map 106 9 :question)
    (set-tile-data map 109 9 :question)
    (set-tile-data map 109 5 :question)
    (set-tile-data map 112 9 :question)

    (set-tile-data map 118 9 :brick)
    (set-tile-data map 119 5 :brick)
    (set-tile-data map 120 5 :brick)
    (set-tile-data map 121 5 :brick)

    (set-tile-data map 128 5 :brick)
    (set-tile-data map 129 5 :question)
    (set-tile-data map 130 5 :question)
    (set-tile-data map 131 5 :brick)
    (set-tile-data map 129 9 :brick)
    (set-tile-data map 130 9 :brick)

    ;; Staircases
    (build-stair map 134 12 4 t)
    (build-stair map 140 12 4 t)
    (build-stair map 144 12 4 nil)
    (build-stair map 148 12 4 t)
    (build-stair map 152 12 5 nil)

    (build-stair map 181 12 4 t)
    (build-stair map 185 12 4 nil)
    (build-stair map 189 12 4 t)
    (build-stair map 193 12 4 nil)

    ;; Final staircase
    (build-stair map 198 12 8 t)

    ;; Flagpole
    (loop for y from 2 to 12 do (set-tile-data map 206 y :flag-pole))
    (set-tile-data map 206 1 :flag-top)

    ;; Castle
    (loop for x from 208 to 212 do
      (loop for y from 9 to 12 do (set-tile-data map x y :hard-block)))
    (loop for x from 209 to 211 do (set-tile-data map x 8 :hard-block))
    (set-tile-data map 210 7 :hard-block)

    map))

(defun get-enemy-spawns ()
  "Returns a list of (x y enemy-type) plists."
  (list
   (list :x 22  :y 12 :enemy-type :goomba)
   (list :x 40  :y 12 :enemy-type :goomba)
   (list :x 51  :y 12 :enemy-type :goomba)
   (list :x 52  :y 12 :enemy-type :goomba)
   (list :x 80  :y 4  :enemy-type :goomba)
   (list :x 82  :y 4  :enemy-type :goomba)
   (list :x 97  :y 12 :enemy-type :goomba)
   (list :x 98  :y 12 :enemy-type :goomba)
   (list :x 107 :y 12 :enemy-type :koopa)
   (list :x 114 :y 12 :enemy-type :goomba)
   (list :x 115 :y 12 :enemy-type :goomba)
   (list :x 124 :y 12 :enemy-type :goomba)
   (list :x 125 :y 12 :enemy-type :goomba)
   (list :x 128 :y 12 :enemy-type :goomba)
   (list :x 129 :y 12 :enemy-type :goomba)
   (list :x 174 :y 12 :enemy-type :goomba)
   (list :x 175 :y 12 :enemy-type :goomba)))

(defun get-underground ()
  "Returns two values: underground tile map (2D array) and list of coin item plists."
  (let ((map (make-array (list +level-height-tiles+ +level-width-tiles+)
                         :initial-element 0))
        (uw +underground-width-tiles+))
    ;; Ceiling: rows 0-1
    (loop for x from 0 below uw do
      (setf (aref map 0 x) (tile-type-to-int :hard-block))
      (setf (aref map 1 x) (tile-type-to-int :hard-block)))
    ;; Floor: rows 13-14
    (loop for x from 0 below uw do
      (setf (aref map 13 x) (tile-type-to-int :hard-block))
      (setf (aref map 14 x) (tile-type-to-int :hard-block)))
    ;; Walls: column 0 and 15 for rows 2-12
    (loop for y from 2 to 12 do
      (setf (aref map y 0) (tile-type-to-int :hard-block))
      (setf (aref map y (1- uw)) (tile-type-to-int :hard-block)))
    ;; Exit pipe at x=13, y=11 (top), height 2
    (set-pipe map 13 11 2)
    ;; Spawn coins as items
    (let ((coins nil))
      (dolist (row '(4 6 8))
        (loop for col from 2 to 13 do
          (push (make-static-coin (* col (float +tile-size+))
                                  (* row (float +tile-size+)))
                coins)))
      (values map (nreverse coins)))))

(defun get-block-contents ()
  "Returns a hash table mapping (x . y) to item content keywords."
  (let ((m (make-hash-table :test 'equal)))
    (setf (gethash '(16 . 9) m) :coin)
    (setf (gethash '(21 . 9) m) :mushroom)
    (setf (gethash '(23 . 9) m) :coin)
    (setf (gethash '(22 . 5) m) :one-up)
    (setf (gethash '(77 . 9) m) :coin)
    (setf (gethash '(94 . 9) m) :coin)
    (setf (gethash '(101 . 9) m) :coin)
    (setf (gethash '(101 . 5) m) :star)
    (setf (gethash '(106 . 9) m) :mushroom)
    (setf (gethash '(109 . 9) m) :coin)
    (setf (gethash '(109 . 5) m) :coin)
    (setf (gethash '(112 . 9) m) :coin)
    (setf (gethash '(129 . 5) m) :coin)
    (setf (gethash '(130 . 5) m) :coin)
    m))
