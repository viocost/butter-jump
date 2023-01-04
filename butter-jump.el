;;; butter-jump.el --- Eye pleasent jump experience

;; Copyright (c) 2007-2016 Konstantin Y. Rybakov
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
;;     You may also customize the jump distance by editing
;;


;;; Description
;;
;; The package provides smooth jumping functionality on half-page jump.
;;
;; Instead of jumping deirectly to the destination,
;; the jump is broken into intermediary steps that are executed sequentially
;; with increased delay. That provides an eye pleasent jumping animation.
;;
;; See the README.md for more details.

;;; Code:

(defvar butter-jump-lines-distance 45
  "Jump distance in lines")

(defvar butter-jump-step-delay 0.001
  "Delay between jumping steps in seconds")


(defun butter-jump-perform-jump-move (direction step)
  "Performs a signle jump step"
  (if (eq direction 'up)
      (progn
        (ignore-errors (scroll-down-line step))
        (forward-line (* -1 step)))
      (progn
        (if (not (pos-visible-in-window-p (point-max)))
                (ignore-errors (scroll-up-line step)) )
        (forward-line step))))

(defun butter-jump-perform-smooth-jump (direction &optional step-lines-distance delay iteration)
  "Performs smooth jump"
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
    (if (not (eq step-lines-distance 0))
        (progn
          (butter-jump-perform-jump-move direction step)
          (sit-for calculated-delay)
          (butter-jump-perform-smooth-jump direction (- step-lines-distance step) calculated-delay (+ iteration 1))))))

;;;###autoload
(defun butter-jump-up()
  "Performs smooth jump up"
  (interactive)
  (butter-jump-perform-smooth-jump 'up))

;;;###autoload
(defun butter-jump-down ()
  "Performs smooth jump down"
  (interactive)
  (butter-jump-perform-smooth-jump 'down))

(provide 'butter-jump)
;;; butter-jump.el ends here
