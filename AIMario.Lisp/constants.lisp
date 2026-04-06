(in-package #:aimario)

;;; Screen
(defconstant +nes-width+ 256)
(defconstant +nes-height+ 240)
(defconstant +window-scale+ 3)
(defconstant +window-width+ (* +nes-width+ +window-scale+))
(defconstant +window-height+ (* +nes-height+ +window-scale+))

;;; Tiles
(defconstant +tile-size+ 16)

;;; Level
(defconstant +level-width-tiles+ 224)
(defconstant +level-height-tiles+ 15)

;;; Physics (per frame at 60 FPS)
(defconstant +gravity+ 0.28)
(defconstant +max-fall-speed+ 5.0)

;;; Mario movement
(defconstant +walk-accel+ 0.1)
(defconstant +walk-max-speed+ 1.5)
(defconstant +run-accel+ 0.1)
(defconstant +run-max-speed+ 2.5)
(defconstant +friction+ 0.15)
(defconstant +jump-velocity-walk+ -6.3)
(defconstant +jump-velocity-run+ -7.2)
(defconstant +jump-release-cap+ -2.0)

;;; Enemy
(defconstant +goomba-speed+ 0.5)
(defconstant +koopa-speed+ 0.5)
(defconstant +shell-speed+ 3.0)
(defconstant +fireball-speed+ 3.0)
(defconstant +fireball-gravity+ 0.3)
(defconstant +fireball-bounce+ -3.5)

;;; Items
(defconstant +mushroom-speed+ 1.0)
(defconstant +star-speed+ 1.5)
(defconstant +star-bounce+ -4.0)

;;; Scoring
(defconstant +score-coin+ 200)
(defconstant +score-goomba+ 100)
(defconstant +score-koopa+ 100)
(defconstant +score-mushroom+ 1000)
(defconstant +score-fire-flower+ 1000)
(defconstant +score-star+ 1000)
(defconstant +score-brick+ 50)
(defconstant +score-flag-base+ 100)

;;; Timer
(defconstant +level-time+ 400.0)
(defconstant +timer-tick-rate+ 0.4)

;;; Lives
(defconstant +starting-lives+ 3)

;;; Sky color
(defconstant +sky-r+ 92)
(defconstant +sky-g+ 148)
(defconstant +sky-b+ 252)

;;; Underground
(defconstant +underground-width-tiles+ 16)
(defconstant +pipe-entry-x+ 46)
(defconstant +pipe-entry-top-y+ 9)
(defconstant +pipe-exit-return-x+ 163)
(defconstant +pipe-anim-duration+ 0.5)
