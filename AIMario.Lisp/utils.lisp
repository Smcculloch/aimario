(in-package #:aimario)

;;; Property list accessors (shorthand)
(defun prop (plist key)
  (getf plist key))

(defun (setf prop) (value plist key)
  (setf (getf plist key) value))

;;; Clamp a value between min and max
(defun clampf (value lo hi)
  (max lo (min hi value)))

;;; Create an RGBA pixel array from color constants
(defun make-rgba-bytes (pixel-colors width height)
  "Convert a list of (r g b a) color lists into a flat (unsigned-byte 8) array."
  (let ((bytes (make-array (* width height 4) :element-type '(unsigned-byte 8))))
    (loop for i from 0
          for color in pixel-colors
          for offset = (* i 4)
          do (setf (aref bytes offset)       (first color))
             (setf (aref bytes (+ offset 1)) (second color))
             (setf (aref bytes (+ offset 2)) (third color))
             (setf (aref bytes (+ offset 3)) (fourth color)))
    bytes))

;;; Floor to integer
(defun floori (x)
  (floor x))
