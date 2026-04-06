(in-package #:aimario)

;;; Mario entity as plist
;;; :body - physics body plist
;;; :power - :small, :big, :fire
;;; :facing-right, :is-dead, :is-invincible, :has-star, :is-ducking, :reached-flag
;;; :invincible-timer, :star-timer, :death-timer, :death-bounce
;;; :blink-timer, :visible, :walk-anim-timer

(defun make-mario ()
  (list :body (make-body :width 14.0 :height 16.0)
        :active t
        :facing-right t
        :power :small
        :is-dead nil
        :is-invincible nil
        :has-star nil
        :is-ducking nil
        :reached-flag nil
        :invincible-timer 0.0
        :star-timer 0.0
        :death-timer 0.0
        :death-bounce nil
        :blink-timer 0.0
        :visible t
        :walk-anim-timer 0.0))

(defun mario-reset (mario x y)
  (let ((body (getf mario :body)))
    (setf (getf body :x) x
          (getf body :y) y
          (getf body :vx) 0.0
          (getf body :vy) 0.0
          (getf body :on-ground) nil
          (getf body :apply-gravity) t
          (getf body :width) 14.0
          (getf body :height) 16.0)
    (setf (getf mario :power) :small
          (getf mario :is-dead) nil
          (getf mario :is-invincible) nil
          (getf mario :has-star) nil
          (getf mario :is-ducking) nil
          (getf mario :reached-flag) nil
          (getf mario :facing-right) t
          (getf mario :active) t
          (getf mario :visible) t
          (getf mario :death-timer) 0.0
          (getf mario :death-bounce) nil
          (getf mario :walk-anim-timer) 0.0)))

(defun mario-update-input (mario dt input)
  (when (getf mario :is-dead)
    (mario-update-death mario dt)
    (return-from mario-update-input))

  (when (getf mario :reached-flag)
    (mario-update-flag-slide mario)
    (return-from mario-update-input))

  (let ((body (getf mario :body)))
    ;; Invincibility flashing
    (when (and (getf mario :is-invincible)
               (not (getf mario :has-star)))
      (decf (getf mario :invincible-timer) dt)
      (incf (getf mario :blink-timer) dt)
      (setf (getf mario :visible)
            (evenp (floor (* (getf mario :blink-timer) 10.0))))
      (when (<= (getf mario :invincible-timer) 0.0)
        (setf (getf mario :is-invincible) nil
              (getf mario :visible) t)))

    ;; Star timer
    (when (getf mario :has-star)
      (decf (getf mario :star-timer) dt)
      (incf (getf mario :blink-timer) dt)
      (setf (getf mario :visible)
            (evenp (floor (* (getf mario :blink-timer) 15.0))))
      (when (<= (getf mario :star-timer) 0.0)
        (setf (getf mario :has-star) nil
              (getf mario :is-invincible) nil
              (getf mario :visible) t)))

    ;; Horizontal movement
    (let ((max-speed (if (getf input :run) +run-max-speed+ +walk-max-speed+))
          (accel (if (getf input :run) +run-accel+ +walk-accel+)))
      (cond
        ((getf input :left)
         (decf (getf body :vx) accel)
         (when (< (getf body :vx) (- max-speed))
           (setf (getf body :vx) (- max-speed)))
         (setf (getf mario :facing-right) nil))
        ((getf input :right)
         (incf (getf body :vx) accel)
         (when (> (getf body :vx) max-speed)
           (setf (getf body :vx) max-speed))
         (setf (getf mario :facing-right) t))
        (t
         (cond
           ((> (getf body :vx) 0.0)
            (decf (getf body :vx) +friction+)
            (when (< (getf body :vx) 0.0) (setf (getf body :vx) 0.0)))
           ((< (getf body :vx) 0.0)
            (incf (getf body :vx) +friction+)
            (when (> (getf body :vx) 0.0) (setf (getf body :vx) 0.0)))))))

    ;; Ducking
    (cond
      ((and (not (eq (getf mario :power) :small))
            (getf body :on-ground)
            (getf input :down))
       (unless (getf mario :is-ducking)
         (setf (getf mario :is-ducking) t)
         (setf (getf body :height) 16.0)
         (incf (getf body :y) 16.0)))
      ((getf mario :is-ducking)
       (setf (getf mario :is-ducking) nil)
       (setf (getf body :height) 32.0)
       (decf (getf body :y) 16.0)))

    ;; Jump
    (when (and (getf input :jump-pressed) (getf body :on-ground))
      (let ((jump-vel (if (> (abs (getf body :vx)) +walk-max-speed+)
                          +jump-velocity-run+
                          +jump-velocity-walk+)))
        (setf (getf body :vy) jump-vel)
        (setf (getf body :on-ground) nil)))

    ;; Variable jump height
    (when (and (not (getf input :jump))
               (< (getf body :vy) +jump-release-cap+))
      (setf (getf body :vy) +jump-release-cap+))

    ;; Physics
    (apply-body-gravity body)

    ;; Walk animation
    (cond
      ((and (> (abs (getf body :vx)) 0.1) (getf body :on-ground))
       (incf (getf mario :walk-anim-timer) (* (abs (getf body :vx)) dt)))
      ((getf body :on-ground)
       (setf (getf mario :walk-anim-timer) 0.0)))))

(defun mario-update-death (mario dt)
  (let ((body (getf mario :body)))
    (incf (getf mario :death-timer) dt)
    (when (and (not (getf mario :death-bounce))
               (> (getf mario :death-timer) 0.5))
      (setf (getf body :vy) -5.0)
      (setf (getf mario :death-bounce) t))
    (when (getf mario :death-bounce)
      (incf (getf body :vy) +gravity+)
      (incf (getf body :y) (getf body :vy)))))

(defun mario-update-flag-slide (mario)
  (let ((body (getf mario :body)))
    (setf (getf body :vx) 0.0)
    (setf (getf body :vy) 2.0)
    (incf (getf body :y) (getf body :vy))
    (let ((ground-y (- (* (- +level-height-tiles+ 2) +tile-size+)
                       (getf body :height))))
      (when (>= (getf body :y) ground-y)
        (setf (getf body :y) ground-y)
        (setf (getf body :vy) 0.0)))))

(defun mario-die (mario)
  (when (getf mario :is-dead) (return-from mario-die))
  (let ((body (getf mario :body)))
    (setf (getf mario :is-dead) t
          (getf mario :death-timer) 0.0
          (getf mario :death-bounce) nil
          (getf body :vx) 0.0
          (getf body :vy) 0.0
          (getf body :apply-gravity) nil
          (getf mario :active) t)))

(defun mario-take-damage (mario)
  (when (or (getf mario :is-invincible) (getf mario :is-dead))
    (return-from mario-take-damage))
  (let ((body (getf mario :body)))
    (if (or (eq (getf mario :power) :fire)
            (eq (getf mario :power) :big))
        (progn
          (setf (getf mario :power) :small)
          (setf (getf body :height) 16.0)
          (setf (getf mario :is-invincible) t)
          (setf (getf mario :invincible-timer) 2.0)
          (setf (getf mario :blink-timer) 0.0))
        (mario-die mario))))

(defun mario-collect-mushroom (mario)
  (when (eq (getf mario :power) :small)
    (let ((body (getf mario :body)))
      (setf (getf mario :power) :big)
      (setf (getf body :height) 32.0)
      (decf (getf body :y) 16.0))))

(defun mario-collect-fire-flower (mario)
  (when (eq (getf mario :power) :small)
    (let ((body (getf mario :body)))
      (setf (getf mario :power) :big)
      (setf (getf body :height) 32.0)
      (decf (getf body :y) 16.0)))
  (setf (getf mario :power) :fire))

(defun mario-collect-star (mario)
  (setf (getf mario :has-star) t
        (getf mario :is-invincible) t
        (getf mario :star-timer) 10.0
        (getf mario :blink-timer) 0.0))

(defun mario-texture-name (mario)
  (let ((prefix (case (getf mario :power)
                  (:fire "mario_fire")
                  (:big "mario_big")
                  (otherwise "mario_small"))))
    (cond
      ((getf mario :is-dead) "mario_small_death")
      ((getf mario :is-ducking) (format nil "~A_duck" prefix))
      ((not (getf (getf mario :body) :on-ground))
       (format nil "~A_jump" prefix))
      ((> (abs (getf (getf mario :body) :vx)) 0.1)
       (let ((frame (1+ (mod (floor (* (getf mario :walk-anim-timer) 8.0)) 3))))
         (format nil "~A_walk~D" prefix frame)))
      (t (format nil "~A_stand" prefix)))))
