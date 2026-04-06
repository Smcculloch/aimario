(in-package #:aimario)

;;; Tile types (as keywords)
;;; :empty :ground :brick :question :question-used :hard-block
;;; :pipe-top-left :pipe-top-right :pipe-body-left :pipe-body-right
;;; :invisible :flag-pole :flag-top

;;; Item contents for blocks
;;; :none :coin :mushroom :star :one-up :multi-coin

(defun tile-type-from-int (v)
  (case v
    (1 :ground) (2 :brick) (3 :question) (4 :question-used)
    (5 :hard-block) (6 :pipe-top-left) (7 :pipe-top-right)
    (8 :pipe-body-left) (9 :pipe-body-right) (10 :invisible)
    (11 :flag-pole) (12 :flag-top)
    (otherwise :empty)))

(defun tile-type-to-int (tt)
  (case tt
    (:ground 1) (:brick 2) (:question 3) (:question-used 4)
    (:hard-block 5) (:pipe-top-left 6) (:pipe-top-right 7)
    (:pipe-body-left 8) (:pipe-body-right 9) (:invisible 10)
    (:flag-pole 11) (:flag-top 12)
    (otherwise 0)))

(defun make-tile (tile-type grid-x grid-y)
  (list :tile-type tile-type
        :grid-x grid-x
        :grid-y grid-y
        :content :none
        :is-hit nil
        :bump-offset 0.0
        :anim-timer 0.0))

(defun tile-solid-p (tile)
  (let ((tt (getf tile :tile-type)))
    (case tt
      (:empty nil)
      (:flag-pole nil)
      (:flag-top nil)
      (:invisible (getf tile :is-hit))
      (otherwise t))))

(defun tile-bounds (tile)
  "Returns (x y w h) as multiple values."
  (values (* (getf tile :grid-x) +tile-size+)
          (* (getf tile :grid-y) +tile-size+)
          +tile-size+
          +tile-size+))

(defun update-tile (tile dt)
  (when (eq (getf tile :tile-type) :question)
    (incf (getf tile :anim-timer) dt))
  (when (< (getf tile :bump-offset) 0.0)
    (incf (getf tile :bump-offset) 0.5)
    (when (> (getf tile :bump-offset) 0.0)
      (setf (getf tile :bump-offset) 0.0))))

(defun tile-anim-frame (tile)
  (if (not (eq (getf tile :tile-type) :question))
      0
      (let ((cycle (mod (getf tile :anim-timer) 1.0)))
        (cond ((< cycle 0.5) 0)
              ((< cycle 0.65) 1)
              ((< cycle 0.8) 2)
              (t 1)))))
