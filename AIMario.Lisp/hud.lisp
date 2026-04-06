(in-package #:aimario)

;;; HUD drawing - uses the renderer to draw text on screen

(defun draw-hud (renderer level)
  (let ((y 8) (scale 1))
    ;; MARIO
    (draw-game-text renderer "MARIO" 24 y scale 252 252 252)
    (draw-game-text renderer (format nil "~6,'0D" (getf level :score))
                    24 (+ y 10) scale 252 252 252)
    ;; Coins
    (draw-game-text renderer (format nil "x~2,'0D" (getf level :coins))
                    96 (+ y 10) scale 248 184 0)
    ;; WORLD
    (draw-game-text renderer "WORLD" 144 y scale 252 252 252)
    (draw-game-text renderer "1-1" 152 (+ y 10) scale 252 252 252)
    ;; TIME
    (draw-game-text renderer "TIME" 200 y scale 252 252 252)
    (draw-game-text renderer (format nil "~3,'0D" (floor (getf level :timer)))
                    208 (+ y 10) scale 252 252 252)))
