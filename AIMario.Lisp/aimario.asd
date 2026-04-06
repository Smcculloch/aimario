(defsystem #:aimario
  :description "CYBER MARIO // SECTOR 1-1 - Common Lisp port"
  :version "1.0.0"
  :depends-on (#:sdl2 #:alexandria #:static-vectors)
  :serial t
  :components ((:file "package")
               (:file "constants")
               (:file "utils")
               (:file "input")
               (:file "camera")
               (:file "tiles")
               (:file "physics")
               (:file "sprites")
               (:file "mario")
               (:file "enemies")
               (:file "items")
               (:file "fireball")
               (:file "level-data")
               (:file "level")
               (:file "hud")
               (:file "title-screen")
               (:file "game-state")
               (:file "main")))
