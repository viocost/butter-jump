;;; butter-jump.el --- Eye pleasant jump experience

;; Copyright (c) 2007-2023 Konstantin Y. Rybakov
;;
;; Filename: butter-jump.el
;; Description: Make emacs jump smoothly
;; Author: Konstantin Y. Rybakov <viocost@gmail.com>
;; Maintainer: Konstantin Y. Rybakov <viocost@gmail.com>
;; Homepage: http://github.com/viocost/butter-jump
;; Version: 2.0.0
;; Keywords: convenience
;; GitHub: http://github.com/viocost/butter-jump

;; This file is not part of GNU Emacs

;;; License:
;;
;; This program is free software; you can redistribute it and/or
;; modify it under the terms of the GNU General Public License
;; as published by the Free Software Foundation; either version 2
;; of the License, or (at your option) any later version.
;;
;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.
;;
;; You should have received a copy of the GNU General Public License
;; along with this program; if not, write to the Free Software
;; Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.

;;; Commentary:

;; The package provides 2 functions:
;;     butter-jump-up
;;     butter-jump-down
;;
;;     Bind them to a key combination of your choice.
;;     You may also customize the jump distance by editing variables:
;;
;;     butter-jump-lines-distance - how many lines covered per jump
;;
;;     butter-jump-step-delay - intermediary steps delay, this affects the speed of the jump.

;;; Code:
(defvar butter-jump-lines-distance 45
  "Jump distance in lines.")

(defvar butter-jump-step-delay 0.001
  "Delay between jumping steps in seconds.")


(defun butter-jump-perform-jump-move (direction step)
  "Perform a single jump STEP.
Argument DIRECTION jump direction."
  (if (eq direction 'up)
      (progn
        (ignore-errors (scroll-down-line step))
        (forward-line (* -1 step)))
        (unless (pos-visible-in-window-p (point-max))
                (ignore-errors (scroll-up-line step)))
        (forward-line step)))

(defun butter-jump-perform-smooth-jump (direction &optional step-lines-distance delay iteration)
  "Perform smooth jump.
Argument DIRECTION jump direction.
Optional argument STEP-LINES-DISTANCE number of lines to jump.
Optional argument DELAY Delay before next step in seconds.
Optional argument ITERATION jump step number."
  (unless delay (setq delay 1))
  (unless iteration (setq iteration 1))
  (unless step-lines-distance (setq step-lines-distance butter-jump-lines-distance))

  (let* (
         ;; calculating step distance based on number of lines remained to jump using log base 2 of number of lines to cover
         ;; this is needed to optimize performance and reduce number of steps
         (step (max 1(floor (log (max step-lines-distance 1) 2))))

         ;; calculating delay for the next step based on iteration using exponential function
         ;; this is needed to achieve slowdown by the end of the jump
         (calculated-delay (* butter-jump-step-delay (expt 1.4  iteration )) ))
    (unless (eq step-lines-distance 0)
        (progn
          (butter-jump-perform-jump-move direction step)
          (sit-for calculated-delay)
          (butter-jump-perform-smooth-jump direction (- step-lines-distance step) calculated-delay (+ iteration 1))))))

;;;###autoload
(defun butter-jump-up()
  "Perform smooth jump up."
  (interactive)
  (butter-jump-perform-smooth-jump 'up))

;;;###autoload
(defun butter-jump-down ()
  "Perform smooth jump down."
  (interactive)
  (butter-jump-perform-smooth-jump 'down))

(provide 'butter-jump)
;;; butter-jump.el ends here
