(in-package #:aimario)

;;; Fireball entity as plist

(defun make-fireball (x y go-right)
  (list :body (make-body :x x :y y :width 8.0 :height 8.0
                         :vx (if go-right +fireball-speed+ (- +fireball-speed+))
                         :apply-gravity nil)
        :active t
        :timer 0.0))

(defun fireball-update (fb dt tiles)
  (incf (getf fb :timer) dt)
  (let ((body (getf fb :body)))
    ;; Custom gravity for bounce
    (incf (getf body :vy) +fireball-gravity+)
    (when (> (getf body :vy) +max-fall-speed+)
      (setf (getf body :vy) +max-fall-speed+))

    (let ((result (move-and-collide body tiles)))
      (when (or (getf result :hit-left) (getf result :hit-right))
        (setf (getf fb :active) nil)
        (return-from fireball-update))
      (when (getf result :hit-bottom)
        (setf (getf body :vy) +fireball-bounce+)))

    (when (> (getf body :y) (* +level-height-tiles+ +tile-size+))
      (setf (getf fb :active) nil))
    (when (> (getf fb :timer) 3.0)
      (setf (getf fb :active) nil))))
