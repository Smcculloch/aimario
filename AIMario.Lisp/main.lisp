(in-package #:aimario)

;;;------------------------------------------------------------
;;; SDL2 Renderer helpers
;;;------------------------------------------------------------

(defstruct renderer
  (sdl-renderer nil)
  (textures (make-hash-table :test 'equal))  ; name -> sdl-texture
  (render-target nil))

(defun create-sdl-texture (rend name)
  "Create an SDL texture from sprite data and cache it."
  (let ((sprite (get-sprite name)))
    (when sprite
      (destructuring-bind (w h rgba-bytes) sprite
        (let* ((sdl-renderer (renderer-sdl-renderer rend))
               (pixel-count (* w h 4))
               (sv (static-vectors:make-static-vector
                    pixel-count
                    :element-type '(unsigned-byte 8))))
          ;; Copy pixel data into static vector
          (loop for i from 0 below pixel-count do
            (setf (aref sv i) (aref rgba-bytes i)))
          (let* ((ptr (static-vectors:static-vector-pointer sv))
                 (surface (sdl2:create-rgb-surface-from
                           ptr w h 32 (* w 4)
                           :r-mask #x000000FF :g-mask #x0000FF00
                           :b-mask #x00FF0000 :a-mask #xFF000000))
                 (texture (sdl2:create-texture-from-surface sdl-renderer surface)))
            (sdl2:free-surface surface)
            (static-vectors:free-static-vector sv)
            (sdl2:set-texture-blend-mode texture :blend)
            (setf (gethash name (renderer-textures rend)) texture)
            texture))))))

(defun ensure-texture (rend name)
  "Get or create an SDL texture for the given sprite name."
  (or (gethash name (renderer-textures rend))
      (create-sdl-texture rend name)))

(defun draw-sprite (rend name x y &key (flip-x nil) (flip-y nil)
                                       (dest-w nil) (dest-h nil))
  "Draw a named sprite at (x, y) on the render target."
  (let ((tex (ensure-texture rend name)))
    (when tex
      (let ((sprite (get-sprite name)))
        (when sprite
          (destructuring-bind (w h _bytes) sprite
            (declare (ignore _bytes))
            (let ((dw (or dest-w w))
                  (dh (or dest-h h))
                  (flip (cond ((and flip-x flip-y) (list :horizontal :vertical))
                              (flip-x (list :horizontal))
                              (flip-y (list :vertical))
                              (t (list :none)))))
              (sdl2:render-copy-ex
               (renderer-sdl-renderer rend)
               tex
               :source-rect (sdl2:make-rect 0 0 w h)
               :dest-rect (sdl2:make-rect (floor x) (floor y) dw dh)
               :angle 0.0d0
               :flip flip))))))))
(defun draw-game-text (rend text x y scale r g b &optional (a 255))
  "Draw text using the bitmap font sprites."
  (let ((cx x))
    (loop for c across (string-upcase text) do
      (let* ((key (format nil "font_~A" c))
             (tex (ensure-texture rend key)))
        (when tex
          (sdl2:set-texture-color-mod tex r g b)
          (sdl2:set-texture-alpha-mod tex a)
          (sdl2:render-copy (renderer-sdl-renderer rend) tex
                            :source-rect (sdl2:make-rect 0 0 5 7)
                            :dest-rect (sdl2:make-rect (floor cx) (floor y)
                                                       (* 5 scale) (* 7 scale)))
          ;; Reset color mod
          (sdl2:set-texture-color-mod tex 255 255 255)
          (sdl2:set-texture-alpha-mod tex 255)))
      (incf cx (* 6 scale)))))

;;;------------------------------------------------------------
;;; Level drawing
;;;------------------------------------------------------------

(defun draw-level (rend level)
  (let* ((camera (getf level :camera))
         (cam-x (getf camera :x))
         (tiles (getf level :tiles))
         (is-ug (eq (getf level :current-area) :underground))
         (start-x (max 0 (1- (floor cam-x +tile-size+))))
         (end-x (min (1- +level-width-tiles+)
                     (+ start-x (floor +nes-width+ +tile-size+) 2))))
    ;; Draw tiles
    (loop for y from 0 below +level-height-tiles+ do
      (loop for x from start-x to end-x do
        (let ((tile (aref tiles y x)))
          (when tile
            (draw-tile rend tile cam-x is-ug)))))

    ;; Draw flag (overworld only)
    (when (and (not is-ug)
               (or (getf level :flag-descending) (getf level :level-complete)))
      (let ((flag-draw-x (- (* 206.0 +tile-size+) 16.0)))
        (draw-sprite rend "flag"
                     (- flag-draw-x cam-x) (getf level :flag-y))))

    ;; Draw items
    (dolist (item (getf level :items))
      (when (getf item :active)
        (let ((body (getf item :body)))
          (draw-sprite rend (item-texture-name item)
                       (- (floor (getf body :x)) cam-x)
                       (floor (getf body :y))))))

    ;; Draw enemies
    (dolist (enemy (getf level :enemies))
      (when (and (getf enemy :active)
                 (camera-visible-p camera (getf (getf enemy :body) :x) 16.0))
        (draw-enemy rend enemy cam-x)))

    ;; Draw Mario
    (draw-mario-sprite rend (getf level :mario) cam-x)

    ;; Draw fireballs
    (dolist (fb (getf level :fireballs))
      (when (getf fb :active)
        (let ((body (getf fb :body)))
          (draw-sprite rend "fireball"
                       (- (floor (getf body :x)) cam-x)
                       (floor (getf body :y))))))

    ;; Draw debris
    (dolist (d (getf level :debris))
      (when (getf d :active)
        (draw-sprite rend "brick_debris"
                     (- (floor (getf d :x)) cam-x)
                     (floor (getf d :y)))))

    ;; Draw score popups
    (dolist (popup (getf level :score-popups))
      (draw-game-text rend (format nil "~D" (getf popup :amount))
                      (- (getf popup :x) cam-x) (getf popup :y)
                      1 252 252 252))))

(defun draw-tile (rend tile cam-x &optional (is-underground nil))
  (let ((tex-name (case (getf tile :tile-type)
                    (:ground (if is-underground "ground_ug" "ground"))
                    (:brick (if is-underground "brick_ug" "brick"))
                    (:question (case (tile-anim-frame tile)
                                 (0 "question0") (1 "question1") (otherwise "question2")))
                    (:question-used "used_block")
                    (:hard-block (if is-underground "hard_block_ug" "hard_block"))
                    (:pipe-top-left "pipe_tl")
                    (:pipe-top-right "pipe_tr")
                    (:pipe-body-left "pipe_bl")
                    (:pipe-body-right "pipe_br")
                    (:flag-pole "flagpole")
                    (:flag-top "flagtop")
                    (otherwise nil))))
    (when tex-name
      (let ((draw-x (- (* (getf tile :grid-x) +tile-size+) cam-x))
            (draw-y (+ (* (getf tile :grid-y) +tile-size+)
                       (getf tile :bump-offset))))
        (draw-sprite rend tex-name draw-x draw-y)))))

(defun draw-enemy (rend enemy cam-x)
  (unless (getf enemy :active) (return-from draw-enemy))
  (let* ((tex-name (enemy-texture-name enemy))
         (body (getf enemy :body))
         (draw-y (getf body :y))
         (flip-x nil)
         (flip-y nil))
    (case (getf enemy :enemy-type)
      (:goomba
       (cond
         ((and (getf enemy :is-stomped) (not (getf enemy :is-shell)))
          (if (string= tex-name "goomba_flat")
              (setf draw-y (- (getf body :y) 14.0))
              (setf flip-y t)))))
      (:koopa
       (cond
         ((and (getf enemy :is-stomped) (not (getf enemy :is-shell)))
          (setf flip-y t))
         (t (setf flip-x (getf enemy :facing-right))))))
    (draw-sprite rend tex-name
                 (- (floor (- (getf body :x) 1.0)) cam-x)
                 (floor draw-y)
                 :flip-x flip-x :flip-y flip-y)))

(defun draw-mario-sprite (rend mario cam-x)
  (unless (getf mario :visible) (return-from draw-mario-sprite))
  (let* ((tex-name (mario-texture-name mario))
         (body (getf mario :body))
         (draw-x (- (getf body :x) 1.0 cam-x))
         (draw-y (if (getf mario :is-ducking)
                     (- (getf body :y) 16.0)
                     (getf body :y)))
         (flip-x (not (getf mario :facing-right))))
    (draw-sprite rend tex-name (floor draw-x) (floor draw-y)
                 :flip-x flip-x)))

;;;------------------------------------------------------------
;;; Main game loop
;;;------------------------------------------------------------

(defun run-game ()
  "Entry point: opens SDL2 window and runs the game loop."
  (sdl2:with-init (:video)
    (sdl2:with-window (window :title "CYBER MARIO // SECTOR 1-1"
                              :w +window-width+ :h +window-height+
                              :flags '(:shown))
      (sdl2:with-renderer (sdl-renderer window :flags '(:accelerated :presentvsync))
        ;; Generate all sprites
        (generate-all-sprites)

        (let* ((rend (make-renderer :sdl-renderer sdl-renderer))
               ;; Create render target texture (NES resolution)
               (render-target (sdl2:create-texture sdl-renderer
                                                   :argb8888
                                                   :target
                                                   +nes-width+ +nes-height+))
               (level (make-level))
               (title (make-title-screen))
               (gs (make-game-state))
               (input (make-input))
               (key-states (make-hash-table))
               (last-ticks (sdl2:get-ticks)))

          (setf (renderer-render-target rend) render-target)
          (level-load level)

          ;; Set nearest-neighbor scaling
          (sdl2:set-hint :render-scale-quality "0")

          (sdl2:with-event-loop (:method :poll)
            (:keydown (:keysym keysym)
              (let ((scancode (sdl2:scancode keysym)))
                (setf (gethash scancode key-states) t)))
            (:keyup (:keysym keysym)
              (let ((scancode (sdl2:scancode keysym)))
                (setf (gethash scancode key-states) nil)))
            (:quit () t)
            (:idle ()
              ;; Delta time
              (let* ((now (sdl2:get-ticks))
                     (dt-ms (- now last-ticks))
                     (dt (min (/ dt-ms 1000.0) 0.05)))
                (setf last-ticks now)

                ;; Update input
                (update-input input key-states)

                ;; Check escape
                (when (gethash :scancode-escape key-states)
                  (sdl2:push-quit-event))

                ;; Update game state timer
                (game-state-update gs dt)

                ;; Update
                (case (getf gs :current)
                  (:title
                   (title-screen-update title dt)
                   (when (getf input :start)
                     (level-load level)
                     (game-state-set gs :playing)))
                  (:playing
                   (level-update level dt input)
                   (cond
                     ((getf (getf level :mario) :is-dead)
                      (game-state-set gs :death))
                     ((getf level :level-complete)
                      (game-state-set gs :level-complete))))
                  (:death
                   (level-update level dt input)
                   (when (> (getf gs :timer) 3.0)
                     (decf (getf level :lives))
                     (if (<= (getf level :lives) 0)
                         (game-state-set gs :game-over)
                         (progn
                           (level-reset level)
                           (game-state-set gs :playing)))))
                  (:level-complete
                   (level-update level dt input)
                   (when (> (getf gs :timer) 5.0)
                     (game-state-set gs :title)))
                  (:game-over
                   (when (> (getf gs :timer) 3.0)
                     (setf (getf level :lives) +starting-lives+
                           (getf level :score) 0
                           (getf level :coins) 0)
                     (game-state-set gs :title))))

                ;; Draw to render target
                (sdl2:set-render-target sdl-renderer render-target)
                (let ((bg (level-background-color level)))
                  (sdl2:set-render-draw-color sdl-renderer
                                              (first bg) (second bg) (third bg) 255))
                (sdl2:render-clear sdl-renderer)

                (case (getf gs :current)
                  (:title
                   (title-screen-draw title rend))
                  ((:playing :death :level-complete)
                   (draw-level rend level))
                  (:game-over
                   (sdl2:set-render-draw-color sdl-renderer 0 0 0 255)
                   (sdl2:render-clear sdl-renderer)
                   (draw-game-text rend "GAME OVER" 88 112 1 252 252 252)))

                ;; HUD
                (when (not (eq (getf gs :current) :title))
                  (unless (eq (getf gs :current) :game-over)
                    (draw-hud rend level)))

                ;; Scale render target to window
                (sdl2:set-render-target sdl-renderer nil)
                (sdl2:set-render-draw-color sdl-renderer 0 0 0 255)
                (sdl2:render-clear sdl-renderer)
                (sdl2:render-copy sdl-renderer render-target
                                  :source-rect (sdl2:make-rect 0 0 +nes-width+ +nes-height+)
                                  :dest-rect (sdl2:make-rect 0 0 +window-width+ +window-height+))
                (sdl2:render-present sdl-renderer)))))))))
