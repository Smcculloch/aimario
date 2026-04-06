(in-package #:aimario)

;;; Physics body as plist:
;;; (:x 0.0 :y 0.0 :vx 0.0 :vy 0.0 :width 0.0 :height 0.0
;;;  :on-ground nil :apply-gravity t)

(defun make-body (&key (x 0.0) (y 0.0) (vx 0.0) (vy 0.0)
                       (width 0.0) (height 0.0)
                       (on-ground nil) (apply-gravity t))
  (list :x x :y y :vx vx :vy vy
        :width width :height height
        :on-ground on-ground :apply-gravity apply-gravity))

(defun body-left (b) (getf b :x))
(defun body-right (b) (+ (getf b :x) (getf b :width)))
(defun body-top (b) (getf b :y))
(defun body-bottom (b) (+ (getf b :y) (getf b :height)))

(defun apply-body-gravity (body)
  (when (getf body :apply-gravity)
    (incf (getf body :vy) +gravity+)
    (when (> (getf body :vy) +max-fall-speed+)
      (setf (getf body :vy) +max-fall-speed+))))

(defun rects-intersect-p (ax ay aw ah bx by bw bh)
  (and (< ax (+ bx bw))
       (> (+ ax aw) bx)
       (< ay (+ by bh))
       (> (+ ay ah) by)))

(defun body-intersects-rect-p (body rx ry rw rh)
  (rects-intersect-p (body-left body) (body-top body)
                     (getf body :width) (getf body :height)
                     rx ry rw rh))

(defun bodies-intersect-p (a b)
  (rects-intersect-p (body-left a) (body-top a)
                     (getf a :width) (getf a :height)
                     (body-left b) (body-top b)
                     (getf b :width) (getf b :height)))

;;; Collision result plist
(defun make-collision-result ()
  (list :hit-left nil :hit-right nil :hit-top nil :hit-bottom nil
        :hit-tile-x 0 :hit-tile-y 0 :has-hit-tile nil))

(defun move-and-collide (body tiles)
  "2-pass collision: X then Y. Returns collision result plist."
  (let ((result (make-collision-result)))
    ;; X pass
    (incf (getf body :x) (getf body :vx))
    (resolve-x body tiles result)
    ;; Y pass
    (incf (getf body :y) (getf body :vy))
    (resolve-y body tiles result)
    result))

(defun resolve-x (body tiles result)
  (let ((tile-left (max 0 (1- (floor (body-left body) +tile-size+))))
        (tile-right (min (1- +level-width-tiles+) (1+ (floor (body-right body) +tile-size+))))
        (tile-top (max 0 (floor (body-top body) +tile-size+)))
        (tile-bottom (min (1- +level-height-tiles+) (floor (1- (body-bottom body)) +tile-size+))))
    (loop for gy from tile-top to tile-bottom do
      (loop for gx from tile-left to tile-right do
        (let ((tile (aref tiles gy gx)))
          (when (and tile (tile-solid-p tile))
            (multiple-value-bind (tx ty tw th) (tile-bounds tile)
              (let ((txf (float tx)) (tyf (float ty))
                    (twf (float tw)) (thf (float th)))
                (when (body-intersects-rect-p body txf tyf twf thf)
                  (cond ((> (getf body :vx) 0.0)
                         (setf (getf body :x) (- txf (getf body :width)))
                         (setf (getf body :vx) 0.0)
                         (setf (getf result :hit-right) t))
                        ((< (getf body :vx) 0.0)
                         (setf (getf body :x) (+ txf twf))
                         (setf (getf body :vx) 0.0)
                         (setf (getf result :hit-left) t))))))))))))

(defun resolve-y (body tiles result)
  (let ((tile-left (max 0 (floor (body-left body) +tile-size+)))
        (tile-right (min (1- +level-width-tiles+) (floor (1- (body-right body)) +tile-size+)))
        (tile-top (max 0 (1- (floor (body-top body) +tile-size+))))
        (tile-bottom (min (1- +level-height-tiles+) (1+ (floor (body-bottom body) +tile-size+)))))
    (setf (getf body :on-ground) nil)
    (loop for gy from tile-top to tile-bottom do
      (loop for gx from tile-left to tile-right do
        (let ((tile (aref tiles gy gx)))
          (when (and tile (tile-solid-p tile))
            (multiple-value-bind (tx ty tw th) (tile-bounds tile)
              (let ((txf (float tx)) (tyf (float ty))
                    (twf (float tw)) (thf (float th)))
                (when (body-intersects-rect-p body txf tyf twf thf)
                  (cond ((> (getf body :vy) 0.0)
                         (setf (getf body :y) (- tyf (getf body :height)))
                         (setf (getf body :vy) 0.0)
                         (setf (getf body :on-ground) t)
                         (setf (getf result :hit-bottom) t))
                        ((< (getf body :vy) 0.0)
                         (setf (getf body :y) (+ tyf thf))
                         (setf (getf body :vy) 0.0)
                         (setf (getf result :hit-top) t)
                         (setf (getf result :has-hit-tile) t)
                         (setf (getf result :hit-tile-x) (getf tile :grid-x))
                         (setf (getf result :hit-tile-y) (getf tile :grid-y)))))))))))))

(defun is-solid-at (tiles world-x world-y)
  (let ((gx (floor world-x +tile-size+))
        (gy (floor world-y +tile-size+)))
    (when (and (>= gx 0) (< gx +level-width-tiles+)
               (>= gy 0) (< gy +level-height-tiles+))
      (let ((tile (aref tiles gy gx)))
        (and tile (tile-solid-p tile))))))
