(in-package #:aimario)

;;; Item entity as plist
;;; :body, :active, :item-type (:coin/:mushroom/:one-up/:fire-flower/:star)
;;; :timer, :start-y, :is-popup, :emerged, :emerge-timer

(defun make-static-coin (x y)
  "Create a static coin item (for underground room)."
  (list :body (make-body :x x :y y :width 16.0 :height 16.0 :apply-gravity nil)
        :active t :item-type :coin
        :timer 0.0 :start-y y :is-popup nil :emerged t :emerge-timer 0.0))

(defun make-coin-popup (x y)
  (list :body (make-body :x x :y y :width 16.0 :height 16.0 :vy -6.0 :apply-gravity nil)
        :active t :item-type :coin
        :timer 0.0 :start-y 0.0 :is-popup t :emerged t :emerge-timer 0.0))

(defun make-mushroom-item (x y is-oneup)
  (list :body (make-body :x x :y y :width 16.0 :height 16.0 :apply-gravity nil)
        :active t :item-type (if is-oneup :one-up :mushroom)
        :timer 0.0 :start-y y :is-popup nil :emerged nil :emerge-timer 0.0))

(defun make-fire-flower-item (x y)
  (list :body (make-body :x x :y y :width 16.0 :height 16.0 :apply-gravity nil)
        :active t :item-type :fire-flower
        :timer 0.0 :start-y y :is-popup nil :emerged nil :emerge-timer 0.0))

(defun make-star-item (x y)
  (list :body (make-body :x x :y y :width 16.0 :height 16.0 :apply-gravity nil)
        :active t :item-type :star
        :timer 0.0 :start-y y :is-popup nil :emerged nil :emerge-timer 0.0))

(defun item-update (item dt tiles)
  (incf (getf item :timer) dt)
  (let ((body (getf item :body)))
    (case (getf item :item-type)
      (:coin
       (when (getf item :is-popup)
         (when (= (getf item :start-y) 0.0)
           (setf (getf item :start-y) (getf body :y)))
         (incf (getf body :vy) 0.3)
         (incf (getf body :y) (getf body :vy))
         (when (> (getf body :y) (getf item :start-y))
           (setf (getf item :active) nil))))

      ((:mushroom :one-up)
       (cond
         ((not (getf item :emerged))
          (incf (getf item :emerge-timer) dt)
          (setf (getf body :y)
                (- (getf item :start-y)
                   (* (/ (getf item :emerge-timer) 0.5) 16.0)))
          (when (>= (getf item :emerge-timer) 0.5)
            (setf (getf item :emerged) t)
            (setf (getf body :y) (- (getf item :start-y) 16.0))
            (setf (getf body :vx) +mushroom-speed+)
            (setf (getf body :apply-gravity) t)))
         (t
          (apply-body-gravity body)
          (let ((result (move-and-collide body tiles)))
            (when (or (getf result :hit-left) (getf result :hit-right))
              (setf (getf body :vx) (if (getf result :hit-left) +mushroom-speed+ (- +mushroom-speed+)))))
          (when (> (getf body :y) (* +level-height-tiles+ +tile-size+))
            (setf (getf item :active) nil)))))

      (:fire-flower
       (when (not (getf item :emerged))
         (incf (getf item :emerge-timer) dt)
         (setf (getf body :y)
               (- (getf item :start-y)
                  (* (/ (getf item :emerge-timer) 0.5) 16.0)))
         (when (>= (getf item :emerge-timer) 0.5)
           (setf (getf item :emerged) t)
           (setf (getf body :y) (- (getf item :start-y) 16.0)))))

      (:star
       (cond
         ((not (getf item :emerged))
          (incf (getf item :emerge-timer) dt)
          (setf (getf body :y)
                (- (getf item :start-y)
                   (* (/ (getf item :emerge-timer) 0.5) 16.0)))
          (when (>= (getf item :emerge-timer) 0.5)
            (setf (getf item :emerged) t)
            (setf (getf body :y) (- (getf item :start-y) 16.0))
            (setf (getf body :vx) +star-speed+)
            (setf (getf body :vy) +star-bounce+)
            (setf (getf body :apply-gravity) t)))
         (t
          (apply-body-gravity body)
          (let ((result (move-and-collide body tiles)))
            (when (or (getf result :hit-left) (getf result :hit-right))
              (setf (getf body :vx) (if (getf result :hit-left) +star-speed+ (- +star-speed+))))
            (when (getf result :hit-bottom)
              (setf (getf body :vy) +star-bounce+)))
          (when (> (getf body :y) (* +level-height-tiles+ +tile-size+))
            (setf (getf item :active) nil))))))))

(defun item-texture-name (item)
  (case (getf item :item-type)
    (:coin "coin")
    (:mushroom "mushroom")
    (:one-up "oneup")
    (:fire-flower "fireflower")
    (:star "star")))
