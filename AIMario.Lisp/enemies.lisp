(in-package #:aimario)

;;; Enemy entity as plist
;;; :body, :active, :facing-right, :is-stomped, :enemy-type (:goomba/:koopa)
;;; :can-be-stomped, :flat, :flat-timer, :turn-cooldown
;;; :is-shell, :shell-moving, :shell-kick-cooldown
;;; :anim-timer, :death-timer

(defun make-goomba ()
  (list :body (make-body :width 14.0 :height 16.0 :vx (- +goomba-speed+))
        :active t :facing-right nil :is-stomped nil
        :enemy-type :goomba :can-be-stomped t
        :flat nil :flat-timer 0.0 :turn-cooldown 0.0
        :is-shell nil :shell-moving nil :shell-kick-cooldown 0.0
        :anim-timer 0.0 :death-timer 0.0))

(defun make-koopa ()
  (list :body (make-body :width 14.0 :height 24.0 :vx (- +koopa-speed+))
        :active t :facing-right nil :is-stomped nil
        :enemy-type :koopa :can-be-stomped t
        :flat nil :flat-timer 0.0 :turn-cooldown 0.0
        :is-shell nil :shell-moving nil :shell-kick-cooldown 0.0
        :anim-timer 0.0 :death-timer 0.0))

(defun enemy-update (enemy dt tiles)
  (case (getf enemy :enemy-type)
    (:goomba (enemy-update-goomba enemy dt tiles))
    (:koopa  (enemy-update-koopa enemy dt tiles))))

(defun enemy-update-goomba (enemy dt tiles)
  (let ((body (getf enemy :body)))
    ;; Flat (stomped goomba visual)
    (when (getf enemy :flat)
      (incf (getf enemy :flat-timer) dt)
      (when (> (getf enemy :flat-timer) 0.5)
        (setf (getf enemy :active) nil))
      (return-from enemy-update-goomba))

    ;; Killed by hit (flying off)
    (when (getf enemy :is-stomped)
      (incf (getf body :vy) +gravity+)
      (incf (getf body :x) (getf body :vx))
      (incf (getf body :y) (getf body :vy))
      (incf (getf enemy :death-timer) dt)
      (when (> (getf enemy :death-timer) 2.0)
        (setf (getf enemy :active) nil))
      (return-from enemy-update-goomba))

    ;; Normal movement
    (incf (getf enemy :anim-timer) dt)
    (decf (getf enemy :turn-cooldown) dt)
    (apply-body-gravity body)
    (let ((result (move-and-collide body tiles)))
      (when (and (or (getf result :hit-left) (getf result :hit-right))
                 (<= (getf enemy :turn-cooldown) 0.0))
        (setf (getf body :vx) (if (getf result :hit-left) +goomba-speed+ (- +goomba-speed+)))
        (setf (getf enemy :turn-cooldown) 0.1)))

    (when (> (getf body :y) (* +level-height-tiles+ +tile-size+))
      (setf (getf enemy :active) nil))))

(defun enemy-update-koopa (enemy dt tiles)
  (let ((body (getf enemy :body)))
    ;; Killed by hit (not shell)
    (when (and (getf enemy :is-stomped) (not (getf enemy :is-shell)))
      (incf (getf body :vy) +gravity+)
      (incf (getf body :x) (getf body :vx))
      (incf (getf body :y) (getf body :vy))
      (incf (getf enemy :death-timer) dt)
      (when (> (getf enemy :death-timer) 2.0)
        (setf (getf enemy :active) nil))
      (return-from enemy-update-koopa))

    (incf (getf enemy :anim-timer) dt)
    (decf (getf enemy :shell-kick-cooldown) dt)
    (decf (getf enemy :turn-cooldown) dt)

    (apply-body-gravity body)
    (let ((result (move-and-collide body tiles)))
      (when (and (or (getf result :hit-left) (getf result :hit-right))
                 (<= (getf enemy :turn-cooldown) 0.0))
        (let ((speed (if (getf enemy :shell-moving) +shell-speed+ +koopa-speed+)))
          (setf (getf body :vx) (if (getf result :hit-left) speed (- speed))))
        (setf (getf enemy :facing-right) (> (getf body :vx) 0.0))
        (setf (getf enemy :turn-cooldown) 0.1)))

    (when (> (getf body :y) (* +level-height-tiles+ +tile-size+))
      (setf (getf enemy :active) nil))))

(defun enemy-on-stomped-goomba (enemy)
  (let ((body (getf enemy :body)))
    (setf (getf enemy :flat) t
          (getf enemy :is-stomped) t
          (getf enemy :flat-timer) 0.0
          (getf body :vx) 0.0)
    (incf (getf body :y) (- (getf body :height) 2.0))
    (setf (getf body :height) 2.0)))

(defun enemy-on-stomped-koopa (enemy mario-x)
  (let ((body (getf enemy :body)))
    (cond
      ((not (getf enemy :is-shell))
       (setf (getf enemy :is-shell) t
             (getf enemy :shell-moving) nil
             (getf body :vx) 0.0
             (getf body :height) 16.0)
       (incf (getf body :y) 8.0)
       (setf (getf enemy :shell-kick-cooldown) 0.2))
      ((and (not (getf enemy :shell-moving))
            (<= (getf enemy :shell-kick-cooldown) 0.0))
       (enemy-kick-shell enemy (< mario-x (getf body :x))))
      ((getf enemy :shell-moving)
       (setf (getf enemy :shell-moving) nil
             (getf body :vx) 0.0
             (getf enemy :shell-kick-cooldown) 0.2)))))

(defun enemy-kick-shell (enemy kick-right)
  (setf (getf enemy :shell-moving) t)
  (setf (getf (getf enemy :body) :vx)
        (if kick-right +shell-speed+ (- +shell-speed+)))
  (setf (getf enemy :shell-kick-cooldown) 0.2))

(defun enemy-kill-by-hit (enemy)
  (setf (getf enemy :is-stomped) t)
  (setf (getf (getf enemy :body) :vy) -3.0))

(defun enemy-texture-name (enemy)
  (case (getf enemy :enemy-type)
    (:goomba
     (cond
       ((getf enemy :flat) "goomba_flat")
       (t (if (evenp (floor (* (getf enemy :anim-timer) 4.0)))
              "goomba0" "goomba1"))))
    (:koopa
     (cond
       ((getf enemy :is-shell) "koopa_shell")
       (t (if (evenp (floor (* (getf enemy :anim-timer) 4.0)))
              "koopa0" "koopa1"))))))
