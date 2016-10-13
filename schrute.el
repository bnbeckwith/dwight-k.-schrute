;;; schrute.el --- waste less time using efficient commands by using inefficient ones.

;; Copyright (C) 2016 Jorge Araya Navarro

;; Author: Jorge Araya Navarro <elcorreo@deshackra.com>
;; Keywords: convenience
;; Package-Requires: ((emacs "24.4"))
;; Package-Version: 0.1
;; Homepage: https://bitbucket.org/shackra/dwight-k.-schrute

;; This file is not part of GNU Emacs.

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:

;; schrute.el is the main file of the project

;;; Prayer:

;; Domine Iesu Christe, Fili Dei, miserere mei, peccatoris
;; Κύριε Ἰησοῦ Χριστέ, Υἱὲ τοῦ Θεοῦ, ἐλέησόν με τὸν ἁμαρτωλόν.
;; אדון ישוע משיח, בנו של אלוהים, רחם עליי, החוטא.
;; Nkosi Jesu Kristu, iNdodana kaNkulunkulu, ngihawukele mina, isoni.
;; Señor Jesucristo, Hijo de Dios, ten misericordia de mí, pecador.
;; Herr Jesus Christus, Sohn Gottes, hab Erbarmen mit mir Sünder.
;; Господи, Иисусе Христе, Сыне Божий, помилуй мя грешного/грешную.
;; Sinjoro Jesuo Kristo, Difilo, kompatu min pekulon.
;; Tuhan Yesus Kristus, Putera Allah, kasihanilah aku, seorang pendosa.
;; Bwana Yesu Kristo, Mwana wa Mungu, unihurumie mimi mtenda dhambi.
;; Doamne Iisuse Hristoase, Fiul lui Dumnezeu, miluiește-mă pe mine, păcătosul.
;; 主耶穌基督，上帝之子，憐憫我罪人。

;;; Code:

(defgroup schrute nil "waste less time using efficient commands by using inefficient ones"
  :group 'convenience)

(defcustom schrute-shortcuts-commands nil "Command that will be use instead of the command invoked multiple times by the user."
  :type 'list :group 'schrute)

(defvar-local schrute--times-last-command 0 "Times the same command have been invoke.")
(defvar-local schrute--time-last-command (current-time) "Time of invocation for `last-command'.")
(defvar schrute--interesting-commands nil "List of commands we care about.  Generated when `schrute-mode' is activated.")

(defun schrute--run-command ()
  "Helper that will run an alternative-command."
  (let* ((alternative-command)
         (command-list))
    (dolist (elem schrute-shortcuts-commands)
      (setf alternative-command (car elem))
      (setf command-list (cadr elem))
      (when (or (member this-command command-list)
               (eq this-command command-list))
        (funcall-interactively alternative-command)))))

(defun schrute--do-nothing ()
  "Does nothing; use instead of `ignore'.")

(define-minor-mode schrute-mode "Waste less time using efficient commands by using inefficient ones."
  :lighter " 🐻"
  :group 'schrute
  :global t
  (schrute-mode-activate (not schrute-mode)))

(defun schrute-mode-activate (&optional turnoff)
  "Do some setup when the global minor mode is activated.

`TURNOFF' simply removes the function from the `post-command-hook'"
  (if turnoff
      (remove-hook 'post-command-hook 'schrute-check-last-command)
    (add-hook 'post-command-hook #'schrute-check-last-command))
  ;; regenerate the list of commands we are interested
  (let* ((elemen)
         (command-list))
    (setf schrute--interesting-commands nil)
    (dolist (elemen schrute-shortcuts-commands)
      (setf command-list (cadr elemen))
      (cond ((symbolp command-list) (push command-list schrute--interesting-commands))
            ((listp command-list) (setf schrute--interesting-commands (append schrute--interesting-commands command-list)))))))

(defun schrute-check-last-command ()
  "Check what command was used last time.

It also check the time between the last two invocations of the
same command and use the alternative command instead."
  (when (eq this-command last-command)
    (if (member this-command schrute--interesting-commands)
        (let* ((time-passed (float-time (time-subtract (current-time) schrute--time-last-command))))
          (if (<= time-passed 1.0)
              (setf schrute--times-last-command (1+ schrute--times-last-command)))
          (setf schrute--time-last-command (current-time)))))
  (when (> schrute--times-last-command 2)
    (setf schrute--times-last-command 0)
    ;; Call the alternative command for `this-command'
    (ignore-errors (schrute--run-command))))

;;; schrute.el ends here
