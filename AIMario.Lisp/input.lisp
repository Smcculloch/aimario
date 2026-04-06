(in-package #:aimario)

;;; Input state - plain plist
(defun make-input ()
  (list :left nil :right nil :down nil :down-pressed nil
        :jump nil :jump-pressed nil
        :run nil :run-pressed nil
        :start nil
        :prev-keys (make-hash-table)))

(defun update-input (input key-states)
  "Update input from current key-states hash table.
   key-states maps SDL scancode keywords to booleans."
  (let ((prev (getf input :prev-keys)))
    (setf (getf input :left) (gethash :scancode-left key-states))
    (setf (getf input :right) (gethash :scancode-right key-states))
    (setf (getf input :down) (gethash :scancode-down key-states))

    (let ((down-now (gethash :scancode-down key-states))
          (down-prev (gethash :scancode-down prev)))
      (setf (getf input :down-pressed) (and down-now (not down-prev))))

    (let ((jump-now (or (gethash :scancode-z key-states)
                        (gethash :scancode-space key-states)))
          (jump-prev (or (gethash :scancode-z prev)
                         (gethash :scancode-space prev))))
      (setf (getf input :jump) jump-now)
      (setf (getf input :jump-pressed) (and jump-now (not jump-prev))))

    (let ((run-now (or (gethash :scancode-x key-states)
                       (gethash :scancode-lshift key-states)))
          (run-prev (or (gethash :scancode-x prev)
                        (gethash :scancode-lshift prev))))
      (setf (getf input :run) run-now)
      (setf (getf input :run-pressed) (and run-now (not run-prev))))

    (let ((start-now (gethash :scancode-return key-states))
          (start-prev (gethash :scancode-return prev)))
      (setf (getf input :start) (and start-now (not start-prev))))

    ;; Copy current to prev
    (clrhash prev)
    (maphash (lambda (k v) (setf (gethash k prev) v)) key-states))
  input)
