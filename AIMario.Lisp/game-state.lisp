(in-package #:aimario)

;;; Game states: :title :playing :death :game-over :level-complete

(defun make-game-state ()
  (list :current :title
        :timer 0.0))

(defun game-state-set (gs state)
  (setf (getf gs :current) state
        (getf gs :timer) 0.0))

(defun game-state-update (gs dt)
  (incf (getf gs :timer) dt))
