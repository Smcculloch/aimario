(in-package #:aimario)

(defun make-camera ()
  (list :x 0.0
        :max-x (- (* +level-width-tiles+ +tile-size+) +nes-width+)))

(defun camera-follow (camera target-x)
  (let ((desired (- target-x (/ +nes-width+ 2.0))))
    (when (> desired (getf camera :x))
      (setf (getf camera :x) desired))
    (when (< (getf camera :x) 0.0)
      (setf (getf camera :x) 0.0))
    (when (> (getf camera :x) (getf camera :max-x))
      (setf (getf camera :x) (getf camera :max-x)))))

(defun camera-visible-p (camera entity-x width)
  (let ((cam-x (getf camera :x)))
    (and (> (+ entity-x width) (- cam-x 16.0))
         (< entity-x (+ cam-x +nes-width+ 16.0)))))

(defun camera-reset (camera)
  (setf (getf camera :x) 0.0))
