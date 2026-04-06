(in-package #:aimario)

(defun make-title-screen ()
  (list :blink-timer 0.0))

(defun title-screen-update (title dt)
  (incf (getf title :blink-timer) dt))

(defun title-screen-draw (title renderer)
  ;; Shadow layer
  (draw-game-text renderer "SUPER" 81 51 2 0 0 0 80)
  (draw-game-text renderer "MARIO BROS" 45 76 2 0 0 0 80)

  ;; Main title
  (draw-game-text renderer "SUPER" 80 50 2 200 36 0)
  (draw-game-text renderer "MARIO BROS" 44 75 2 252 252 252)

  ;; Subtitle
  (draw-game-text renderer "WORLD 1-1" 89 120 1 248 184 0)

  ;; Blinking prompt
  (when (evenp (floor (* (getf title :blink-timer) 3.0)))
    (draw-game-text renderer "PRESS ENTER" 74 170 1 252 252 252))

  ;; Credits
  (draw-game-text renderer "A FAITHFUL RECREATION" 38 210 1 188 188 188))
