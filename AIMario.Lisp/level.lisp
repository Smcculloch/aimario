(in-package #:aimario)

;;; Score popup: (list :amount N :x F :y F :timer F)
;;; Brick debris: (list :x F :y F :vx F :vy F :active T)

(defun make-debris (x y vx vy)
  (list :x x :y y :vx vx :vy vy :active t))

(defun update-debris (d)
  (incf (getf d :vy) +gravity+)
  (incf (getf d :x) (getf d :vx))
  (incf (getf d :y) (getf d :vy))
  (when (> (getf d :y) (* +level-height-tiles+ +tile-size+))
    (setf (getf d :active) nil)))

;;; Level state - central game manager
(defun make-level ()
  (list :mario (make-mario)
        :camera (make-camera)
        :tiles nil           ; 2D array of tile plists (or nil)
        :enemies nil         ; list of enemy plists
        :items nil           ; list of item plists
        :fireballs nil       ; list of fireball plists
        :score-popups nil
        :debris nil
        :score 0
        :coins 0
        :lives +starting-lives+
        :timer +level-time+
        :timer-accum 0.0
        :level-complete nil
        :fireball-cooldown 0.0
        :flag-descending nil
        :flag-y 0.0
        :flag-target-y 0.0
        ;; Underground pipe transition
        :current-area :overworld
        :overworld-tiles nil
        :underground-tiles nil
        :underground-coins nil
        :overworld-enemies nil
        :pipe-state :none
        :pipe-timer 0.0
        :saved-camera-x 0.0))

(defun level-load (level)
  (let* ((map-data (get-world-1-1))
         (block-contents (get-block-contents))
         (enemy-spawns (get-enemy-spawns))
         (tiles (make-array (list +level-height-tiles+ +level-width-tiles+)
                            :initial-element nil)))
    ;; Build tiles
    (loop for y from 0 below +level-height-tiles+ do
      (loop for x from 0 below +level-width-tiles+ do
        (let ((tt (tile-type-from-int (aref map-data y x))))
          (unless (eq tt :empty)
            (let ((tile (make-tile tt x y))
                  (content (gethash (cons x y) block-contents)))
              (when content
                (setf (getf tile :content) content))
              (setf (aref tiles y x) tile))))))
    (setf (getf level :tiles) tiles)
    ;; Save copy as overworld tiles
    (setf (getf level :overworld-tiles) (copy-tile-array tiles))

    ;; Load underground data
    (multiple-value-bind (ug-map-data ug-coins) (get-underground)
      (let ((ug-tiles (make-array (list +level-height-tiles+ +level-width-tiles+)
                                  :initial-element nil)))
        (loop for y from 0 below +level-height-tiles+ do
          (loop for x from 0 below +level-width-tiles+ do
            (let ((tt (tile-type-from-int (aref ug-map-data y x))))
              (unless (eq tt :empty)
                (setf (aref ug-tiles y x) (make-tile tt x y))))))
        (setf (getf level :underground-tiles) ug-tiles)
        (setf (getf level :underground-coins) ug-coins)))

    ;; Build enemies
    (let ((enemies nil))
      (dolist (spawn enemy-spawns)
        (let ((enemy (case (getf spawn :enemy-type)
                       (:goomba (make-goomba))
                       (:koopa (make-koopa))))
              (body nil))
          (setf body (getf enemy :body))
          (setf (getf body :x) (+ (* (getf spawn :x) +tile-size+) 1.0))
          (setf (getf body :y) (- (* (getf spawn :y) +tile-size+)
                                   (getf body :height)))
          (push enemy enemies)))
      (setf (getf level :enemies) (nreverse enemies)))

    ;; Reset other state
    (setf (getf level :camera) (make-camera))
    (setf (getf level :mario) (make-mario))
    (mario-reset (getf level :mario) 40.0
                 (* (- +level-height-tiles+ 3) +tile-size+))
    (setf (getf level :items) nil
          (getf level :fireballs) nil
          (getf level :score-popups) nil
          (getf level :debris) nil
          (getf level :timer) +level-time+
          (getf level :timer-accum) 0.0
          (getf level :level-complete) nil
          (getf level :flag-descending) nil
          (getf level :current-area) :overworld
          (getf level :pipe-state) :none
          (getf level :pipe-timer) 0.0)))

(defun level-reset (level)
  (mario-reset (getf level :mario) 40.0
               (* (- +level-height-tiles+ 3) +tile-size+))
  (camera-reset (getf level :camera))
  (setf (getf level :timer) +level-time+
        (getf level :timer-accum) 0.0
        (getf level :items) nil
        (getf level :fireballs) nil
        (getf level :score-popups) nil
        (getf level :debris) nil
        (getf level :level-complete) nil
        (getf level :flag-descending) nil
        (getf level :current-area) :overworld
        (getf level :pipe-state) :none
        (getf level :pipe-timer) 0.0)
  ;; Reload tiles and enemies
  (let* ((map-data (get-world-1-1))
         (block-contents (get-block-contents))
         (tiles (make-array (list +level-height-tiles+ +level-width-tiles+)
                            :initial-element nil)))
    (loop for y from 0 below +level-height-tiles+ do
      (loop for x from 0 below +level-width-tiles+ do
        (let ((tt (tile-type-from-int (aref map-data y x))))
          (unless (eq tt :empty)
            (let ((tile (make-tile tt x y))
                  (content (gethash (cons x y) block-contents)))
              (when content (setf (getf tile :content) content))
              (setf (aref tiles y x) tile))))))
    (setf (getf level :tiles) tiles)
    (setf (getf level :overworld-tiles) (copy-tile-array tiles)))
  ;; Reload underground
  (multiple-value-bind (ug-map-data ug-coins) (get-underground)
    (let ((ug-tiles (make-array (list +level-height-tiles+ +level-width-tiles+)
                                :initial-element nil)))
      (loop for y from 0 below +level-height-tiles+ do
        (loop for x from 0 below +level-width-tiles+ do
          (let ((tt (tile-type-from-int (aref ug-map-data y x))))
            (unless (eq tt :empty)
              (setf (aref ug-tiles y x) (make-tile tt x y))))))
      (setf (getf level :underground-tiles) ug-tiles)
      (setf (getf level :underground-coins) ug-coins)))
  (let ((enemy-spawns (get-enemy-spawns))
        (enemies nil))
    (dolist (spawn enemy-spawns)
      (let* ((enemy (case (getf spawn :enemy-type)
                      (:goomba (make-goomba))
                      (:koopa (make-koopa))))
             (body (getf enemy :body)))
        (setf (getf body :x) (+ (* (getf spawn :x) +tile-size+) 1.0))
        (setf (getf body :y) (- (* (getf spawn :y) +tile-size+)
                                 (getf body :height)))
        (push enemy enemies)))
    (setf (getf level :enemies) (nreverse enemies))))

(defun copy-tile-array (tiles)
  "Create a deep copy of the tile 2D array."
  (let ((new-tiles (make-array (list +level-height-tiles+ +level-width-tiles+)
                               :initial-element nil)))
    (loop for y from 0 below +level-height-tiles+ do
      (loop for x from 0 below +level-width-tiles+ do
        (let ((tile (aref tiles y x)))
          (when tile
            (setf (aref new-tiles y x) (copy-list tile))))))
    new-tiles))

(defun level-background-color (level)
  "Returns (r g b) list for the current area background."
  (if (eq (getf level :current-area) :underground)
      (list 0 0 0)
      (list +sky-r+ +sky-g+ +sky-b+)))

(defun check-pipe-entry (level input)
  "Detect if Mario is standing on an enterable pipe and pressing down."
  (let* ((mario (getf level :mario))
         (body (getf mario :body))
         (mario-center-x (/ (+ (getf body :x) (/ (getf body :width) 2.0))
                            (float +tile-size+)))
         (mario-feet-y (floor (body-bottom body) +tile-size+)))
    (case (getf level :current-area)
      (:overworld
       ;; Check if Mario is on the enterable pipe at x=46 (pipe top is at y=9)
       (let ((pipe-x (float +pipe-entry-x+)))
         (when (and (>= mario-center-x pipe-x)
                    (<= mario-center-x (+ pipe-x 2.0))
                    (= mario-feet-y +pipe-entry-top-y+))
           (setf (getf level :pipe-state) :entering-pipe
                 (getf level :pipe-timer) 0.0
                 (getf level :saved-camera-x) (getf (getf level :camera) :x)
                 (getf level :overworld-enemies) (getf level :enemies))
           (setf (getf body :vx) 0.0
                 (getf body :vy) 0.0)
           ;; Center Mario on pipe
           (setf (getf body :x) (- (* (+ (float +pipe-entry-x+) 0.5) +tile-size+)
                                    (/ (getf body :width) 2.0))))))
      (:underground
       ;; Check if Mario is on the exit pipe at x=13 (pipe top at y=11)
       (let ((pipe-x 13.0))
         (when (and (>= mario-center-x pipe-x)
                    (<= mario-center-x (+ pipe-x 2.0))
                    (= mario-feet-y 11))
           (setf (getf level :pipe-state) :entering-pipe
                 (getf level :pipe-timer) 0.0)
           (setf (getf body :vx) 0.0
                 (getf body :vy) 0.0)
           ;; Center Mario on pipe
           (setf (getf body :x) (- (+ (* 13.0 +tile-size+) +tile-size+)
                                    (/ (getf body :width) 2.0)))))))))

(defun update-pipe-transition (level dt)
  "Handle pipe enter/exit animation and area swap."
  (incf (getf level :pipe-timer) dt)
  (let ((mario (getf level :mario))
        (body (getf (getf level :mario) :body)))
    (case (getf level :pipe-state)
      (:entering-pipe
       ;; Slide Mario down into the pipe
       (incf (getf body :y) 1.0)
       (when (>= (getf level :pipe-timer) +pipe-anim-duration+)
         ;; Done entering -- swap areas
         (case (getf level :current-area)
           (:overworld
            ;; Save overworld tiles state
            (setf (getf level :overworld-tiles) (copy-tile-array (getf level :tiles)))
            ;; Switch to underground
            (setf (getf level :tiles) (copy-tile-array (getf level :underground-tiles)))
            (setf (getf level :current-area) :underground)
            ;; Reset camera for underground (one screen)
            (setf (getf level :camera)
                  (list :x 0.0
                        :max-x (- (* +underground-width-tiles+ +tile-size+) +nes-width+)))
            ;; Place Mario at underground entry
            (setf (getf body :x) (* 2.0 +tile-size+)
                  (getf body :y) (- (* 11.0 +tile-size+) (getf body :height))
                  (getf body :vx) 0.0
                  (getf body :vy) 0.0
                  (getf body :on-ground) nil)
            (setf (getf mario :visible) t)
            ;; Spawn underground coins as items
            (multiple-value-bind (ug-map ug-coins) (get-underground)
              (declare (ignore ug-map))
              (setf (getf level :items) ug-coins))
            (setf (getf level :fireballs) nil
                  (getf level :enemies) nil
                  (getf level :pipe-state) :none))
           (:underground
            ;; Switch back to overworld
            (setf (getf level :tiles) (copy-tile-array (getf level :overworld-tiles)))
            (setf (getf level :current-area) :overworld)
            ;; Restore camera
            (setf (getf level :camera)
                  (list :x 0.0
                        :max-x (- (* +level-width-tiles+ +tile-size+) +nes-width+)))
            ;; Place Mario inside the exit pipe (he'll slide up out of it)
            (let* ((exit-x (- (+ (* (float +pipe-exit-return-x+) +tile-size+) +tile-size+)
                              (/ (getf body :width) 2.0)))
                   (pipe-top-y (* 11.0 +tile-size+)))
              (setf (getf body :x) exit-x
                    (getf body :y) pipe-top-y
                    (getf body :vx) 0.0
                    (getf body :vy) 0.0
                    (getf body :on-ground) nil)
              (setf (getf mario :visible) t)
              ;; Restore enemies
              (setf (getf level :enemies) (getf level :overworld-enemies))
              (setf (getf level :overworld-enemies) nil)
              (setf (getf level :items) nil
                    (getf level :fireballs) nil)
              ;; Set camera to Mario's position
              (let ((cam-max (getf (getf level :camera) :max-x)))
                (setf (getf (getf level :camera) :x)
                      (max 0.0 (min cam-max (- exit-x (/ +nes-width+ 2.0)))))))
            (setf (getf level :pipe-state) :exiting-pipe
                  (getf level :pipe-timer) 0.0)))))
      (:exiting-pipe
       ;; Mario slides up out of the pipe at overworld exit
       (let* ((pipe-top-y (* 11.0 +tile-size+))
              (target-y (- pipe-top-y (getf body :height))))
         (decf (getf body :y) 1.0)
         (when (or (<= (getf body :y) target-y)
                   (>= (getf level :pipe-timer) +pipe-anim-duration+))
           (setf (getf body :y) target-y
                 (getf body :on-ground) t)
           (setf (getf level :pipe-state) :none))))
      (otherwise nil))))

(defun level-update (level dt input)
  ;; Handle pipe animation states
  (when (not (eq (getf level :pipe-state) :none))
    (update-pipe-transition level dt)
    (return-from level-update))

  (let ((mario (getf level :mario))
        (tiles (getf level :tiles))
        (camera (getf level :camera)))
    ;; Timer
    (when (and (not (getf level :level-complete))
               (not (getf mario :is-dead)))
      (incf (getf level :timer-accum) dt)
      (loop while (>= (getf level :timer-accum) +timer-tick-rate+) do
        (decf (getf level :timer-accum) +timer-tick-rate+)
        (decf (getf level :timer) 1.0)
        (when (<= (getf level :timer) 0.0)
          (setf (getf level :timer) 0.0)
          (mario-die mario))))

    ;; Mario
    (mario-update-input mario dt input)

    ;; Collision with tiles
    (when (and (not (getf mario :is-dead))
               (not (getf mario :reached-flag)))
      (let ((result (move-and-collide (getf mario :body) tiles)))
        (when (and (getf result :hit-top) (getf result :has-hit-tile))
          (level-hit-block level (getf result :hit-tile-x) (getf result :hit-tile-y))))
      ;; Don't go left of camera
      (when (< (getf (getf mario :body) :x) (getf camera :x))
        (setf (getf (getf mario :body) :x) (getf camera :x)))
      ;; Fell in pit
      (when (> (getf (getf mario :body) :y) (* +level-height-tiles+ +tile-size+))
        (mario-die mario))

      ;; Pipe entry detection
      (when (and (getf input :down-pressed)
                 (getf (getf mario :body) :on-ground))
        (check-pipe-entry level input)))

    ;; Camera
    (unless (getf mario :is-dead)
      (camera-follow camera (getf (getf mario :body) :x)))

    ;; Fireball shooting
    (decf (getf level :fireball-cooldown) dt)
    (when (and (eq (getf mario :power) :fire)
               (getf input :run-pressed)
               (<= (getf level :fireball-cooldown) 0.0)
               (not (getf mario :is-dead)))
      (let ((active-count (count-if (lambda (f) (getf f :active))
                                    (getf level :fireballs))))
        (when (< active-count 2)
          (let ((fx (+ (getf (getf mario :body) :x)
                       (if (getf mario :facing-right) 12.0 -8.0)))
                (fy (+ (getf (getf mario :body) :y) 8.0)))
            (push (make-fireball fx fy (getf mario :facing-right))
                  (getf level :fireballs))
            (setf (getf level :fireball-cooldown) 0.3)))))

    ;; Update tiles
    (loop for y from 0 below +level-height-tiles+ do
      (loop for x from 0 below +level-width-tiles+ do
        (let ((tile (aref tiles y x)))
          (when tile (update-tile tile dt)))))

    ;; Update enemies
    (dolist (enemy (getf level :enemies))
      (when (and (getf enemy :active)
                 (camera-visible-p camera
                                   (getf (getf enemy :body) :x)
                                   (+ (getf (getf enemy :body) :width) 16.0)))
        (enemy-update enemy dt tiles)))

    ;; Update items
    (dolist (item (getf level :items))
      (item-update item dt tiles))
    (setf (getf level :items)
          (remove-if-not (lambda (i) (getf i :active)) (getf level :items)))

    ;; Update fireballs
    (dolist (fb (getf level :fireballs))
      (fireball-update fb dt tiles))

    ;; Fireball-enemy collisions
    (dolist (fb (getf level :fireballs))
      (when (getf fb :active)
        (dolist (enemy (getf level :enemies))
          (when (and (getf enemy :active) (not (getf enemy :is-stomped)))
            (when (bodies-intersect-p (getf fb :body) (getf enemy :body))
              (setf (getf fb :active) nil)
              (let ((pos-x (getf (getf enemy :body) :x))
                    (pos-y (getf (getf enemy :body) :y)))
                (enemy-kill-by-hit enemy)
                (level-add-score level +score-goomba+ pos-x pos-y)))))))
    (setf (getf level :fireballs)
          (remove-if-not (lambda (f) (getf f :active)) (getf level :fireballs)))

    ;; Update score popups
    (dolist (p (getf level :score-popups))
      (decf (getf p :timer) dt)
      (decf (getf p :y) 1.0))
    (setf (getf level :score-popups)
          (remove-if-not (lambda (p) (> (getf p :timer) 0.0))
                         (getf level :score-popups)))

    ;; Update debris
    (dolist (d (getf level :debris))
      (update-debris d))
    (setf (getf level :debris)
          (remove-if-not (lambda (d) (getf d :active)) (getf level :debris)))

    ;; Flag animation
    (when (getf level :flag-descending)
      (incf (getf level :flag-y) 2.0)
      (when (>= (getf level :flag-y) (getf level :flag-target-y))
        (setf (getf level :flag-y) (getf level :flag-target-y))))

    ;; Mario vs Enemies
    (when (and (not (getf mario :is-dead))
               (not (getf mario :reached-flag)))
      (level-check-enemy-collisions level))

    ;; Mario vs Items
    (unless (getf mario :is-dead)
      (level-check-item-collisions level))

    ;; Check flagpole
    (when (and (not (getf level :level-complete))
               (not (getf mario :is-dead)))
      (level-check-flagpole level))))

(defun level-check-enemy-collisions (level)
  (let* ((mario (getf level :mario))
         (mario-body (getf mario :body)))
    ;; Mario vs each enemy
    (dolist (enemy (getf level :enemies))
      (when (and (getf enemy :active)
                 (not (getf enemy :is-stomped)))
        (let ((is-stationary-shell
                (and (eq (getf enemy :enemy-type) :koopa)
                     (getf enemy :is-shell)
                     (not (getf enemy :shell-moving)))))
          (cond
            ;; Stationary shell - kick it
            ((and is-stationary-shell
                  (bodies-intersect-p mario-body (getf enemy :body)))
             (let ((kick-right (< (getf mario-body :x)
                                  (getf (getf enemy :body) :x))))
               (enemy-kick-shell enemy kick-right)))
            ;; Normal enemy collision
            ((and (not is-stationary-shell)
                  (bodies-intersect-p mario-body (getf enemy :body)))
             (let* ((enemy-body (getf enemy :body))
                    (mario-feet-prev (- (body-bottom mario-body)
                                       (getf mario-body :vy)))
                    (is-falling (> (getf mario-body :vy) 0.0))
                    (feet-above-mid (< (body-bottom mario-body)
                                       (+ (body-top enemy-body)
                                          (/ (getf enemy-body :height) 2.0))))
                    (was-above (<= mario-feet-prev
                                   (+ (body-top enemy-body) 2.0))))
               (cond
                 ;; Stomp
                 ((and is-falling
                       (or feet-above-mid was-above)
                       (getf enemy :can-be-stomped))
                  (let ((et (getf enemy :enemy-type))
                        (px (getf enemy-body :x))
                        (py (getf enemy-body :y)))
                    (case et
                      (:goomba (enemy-on-stomped-goomba enemy))
                      (:koopa (enemy-on-stomped-koopa enemy (getf mario-body :x))))
                    (setf (getf mario-body :vy) (* +jump-velocity-walk+ 0.6))
                    (level-add-score level
                                     (if (eq et :goomba) +score-goomba+ +score-koopa+)
                                     px py)))
                 ;; Star kill
                 ((getf mario :has-star)
                  (enemy-kill-by-hit enemy)
                  (level-add-score level +score-goomba+
                                   (getf enemy-body :x) (getf enemy-body :y)))
                 ;; Damage
                 (t (mario-take-damage mario)))))))))
    ;; Shell kills other enemies
    (dolist (shell (getf level :enemies))
      (when (and (getf shell :active)
                 (eq (getf shell :enemy-type) :koopa)
                 (getf shell :is-shell)
                 (getf shell :shell-moving))
        (dolist (other (getf level :enemies))
          (when (and (not (eq shell other))
                     (getf other :active)
                     (not (getf other :is-stomped))
                     (bodies-intersect-p (getf shell :body) (getf other :body)))
            (enemy-kill-by-hit other)
            (level-add-score level +score-koopa+
                             (getf (getf other :body) :x)
                             (getf (getf other :body) :y))))))))
(defun level-check-item-collisions (level)
  (let ((mario (getf level :mario))
        (mario-body (getf (getf level :mario) :body)))
    (dolist (item (getf level :items))
      (when (and (getf item :active)
                 (bodies-intersect-p mario-body (getf item :body)))
        (case (getf item :item-type)
          (:mushroom
           (mario-collect-mushroom mario)
           (level-add-score level +score-mushroom+
                            (getf (getf item :body) :x)
                            (getf (getf item :body) :y))
           (setf (getf item :active) nil))
          (:one-up
           (incf (getf level :lives))
           (setf (getf item :active) nil))
          (:fire-flower
           (mario-collect-fire-flower mario)
           (level-add-score level +score-fire-flower+
                            (getf (getf item :body) :x)
                            (getf (getf item :body) :y))
           (setf (getf item :active) nil))
          (:star
           (mario-collect-star mario)
           (level-add-score level +score-star+
                            (getf (getf item :body) :x)
                            (getf (getf item :body) :y))
           (setf (getf item :active) nil))
          (:coin
           (incf (getf level :coins))
           (incf (getf level :score) +score-coin+)
           (when (>= (getf level :coins) 100)
             (decf (getf level :coins) 100)
             (incf (getf level :lives)))
           (setf (getf item :active) nil)))))))

(defun level-check-flagpole (level)
  (let* ((mario (getf level :mario))
         (mario-body (getf mario :body))
         (flag-x (* 206.0 +tile-size+)))
    (when (and (>= (body-right mario-body) flag-x)
               (<= (body-left mario-body) (+ flag-x +tile-size+))
               (not (getf level :level-complete)))
      (setf (getf level :level-complete) t)
      (setf (getf mario :reached-flag) t)
      (setf (getf mario-body :x) (- flag-x (getf mario-body :width)))
      (let* ((height (getf mario-body :y))
             (flag-score (cond ((< height (* 4.0 +tile-size+)) 5000)
                               ((< height (* 6.0 +tile-size+)) 2000)
                               ((< height (* 8.0 +tile-size+)) 800)
                               ((< height (* 10.0 +tile-size+)) 400)
                               (t +score-flag-base+))))
        (level-add-score level flag-score (getf mario-body :x) (getf mario-body :y)))
      (setf (getf level :flag-descending) t
            (getf level :flag-y) (* 2.0 +tile-size+)
            (getf level :flag-target-y) (* 12.0 +tile-size+)))))

(defun level-hit-block (level grid-x grid-y)
  (let* ((tiles (getf level :tiles))
         (tile (aref tiles grid-y grid-x)))
    (unless tile (return-from level-hit-block))
    (when (and (getf tile :is-hit) (eq (getf tile :tile-type) :question-used))
      (return-from level-hit-block))

    ;; Set bump
    (setf (getf tile :bump-offset) -8.0)

    (cond
      ;; Question block
      ((eq (getf tile :tile-type) :question)
       (setf (getf tile :is-hit) t)
       (setf (getf tile :tile-type) :question-used)
       (level-spawn-item-from-block level tile))

      ;; Brick
      ((eq (getf tile :tile-type) :brick)
       (let ((mario (getf level :mario)))
         (cond
           ;; Big/Fire Mario breaks brick
           ((not (eq (getf mario :power) :small))
            (level-break-brick level grid-x grid-y))
           ;; Has content
           ((not (eq (getf tile :content) :none))
            (setf (getf tile :is-hit) t)
            (setf (getf tile :tile-type) :question-used)
            (level-spawn-item-from-block level tile))
           ;; Just bump
           (t (setf (getf tile :bump-offset) -4.0)))))

    ;; Bump kills enemies on top (for bricks)
    (when (eq (getf tile :tile-type) :brick)
      (return-from level-hit-block))
    ;; Also check for brick bumps (already handled above with the bump)
    (dolist (enemy (getf level :enemies))
      (when (and (getf enemy :active) (not (getf enemy :is-stomped)))
        (let* ((eb (getf enemy :body))
               (ex (floor (+ (getf eb :x) (/ (getf eb :width) 2.0)) +tile-size+))
               (ey (floor (body-bottom eb) +tile-size+)))
          (when (and (= ex grid-x) (= ey grid-y))
            (let ((pos-x (getf eb :x))
                  (pos-y (getf eb :y)))
              (enemy-kill-by-hit enemy)
              (incf (getf level :score) +score-goomba+)
              (push (list :amount +score-goomba+ :x pos-x :y pos-y :timer 1.0)
                    (getf level :score-popups))))))))))

(defun level-spawn-item-from-block (level tile)
  (let ((spawn-x (* (getf tile :grid-x) (float +tile-size+)))
        (spawn-y (* (getf tile :grid-y) (float +tile-size+))))
    (case (getf tile :content)
      (:coin
       (incf (getf level :coins))
       (incf (getf level :score) +score-coin+)
       (when (>= (getf level :coins) 100)
         (decf (getf level :coins) 100)
         (incf (getf level :lives)))
       (push (make-coin-popup spawn-x spawn-y) (getf level :items)))
      (:mushroom
       (if (eq (getf (getf level :mario) :power) :small)
           (push (make-mushroom-item spawn-x spawn-y nil) (getf level :items))
           (push (make-fire-flower-item spawn-x spawn-y) (getf level :items))))
      (:star
       (push (make-star-item spawn-x spawn-y) (getf level :items)))
      (:one-up
       (push (make-mushroom-item spawn-x spawn-y t) (getf level :items)))
      (otherwise
       (incf (getf level :coins))
       (incf (getf level :score) +score-coin+)
       (when (>= (getf level :coins) 100)
         (decf (getf level :coins) 100)
         (incf (getf level :lives)))
       (push (make-coin-popup spawn-x spawn-y) (getf level :items))))))

(defun level-break-brick (level grid-x grid-y)
  (setf (aref (getf level :tiles) grid-y grid-x) nil)
  (incf (getf level :score) +score-brick+)
  (let ((bx (+ (* grid-x +tile-size+) 8.0))
        (by (+ (* grid-y +tile-size+) 8.0)))
    (push (make-debris (- bx 4.0) (- by 4.0) -1.5 -4.0) (getf level :debris))
    (push (make-debris (+ bx 4.0) (- by 4.0)  1.5 -4.0) (getf level :debris))
    (push (make-debris (- bx 4.0) (+ by 4.0) -1.0 -3.0) (getf level :debris))
    (push (make-debris (+ bx 4.0) (+ by 4.0)  1.0 -3.0) (getf level :debris))))

(defun level-add-score (level amount x y)
  (incf (getf level :score) amount)
  (push (list :amount amount :x x :y y :timer 1.0)
        (getf level :score-popups)))
