;;; funcs.el --- agent-shell layer functions for Spacemacs.
;;
;; Copyright (c) 2026 Cate B.
;;
;; Author: Cate B. <0x6362@users.noreply.github.com>
;; URL: https://github.com/0x6362/agent-shell-layer
;;
;; This file is not part of GNU Emacs.
;;
;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.
;;
;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.
;;
;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:
;; Functions for the agent-shell Spacemacs layer.

;;; Code:

(defun agent-shell//current-shell-buffer ()
  "Return the agent-shell shell buffer for the current buffer, or nil.
Handles shell buffers directly and both viewport modes transparently."
  (cond
   ((derived-mode-p 'agent-shell-mode) (current-buffer))
   ((derived-mode-p 'agent-shell-viewport-view-mode
                    'agent-shell-viewport-edit-mode)
    (agent-shell-viewport--shell-buffer))
   (t nil)))

(defun agent-shell//switch-to-buffer ()
  "Switch to an agent-shell buffer using completing-read."
  (interactive)
  (when-let* ((buffers (agent-shell-buffers))
              (names (mapcar #'buffer-name buffers))
              (name (completing-read "Agent shell: " names nil t)))
    (switch-to-buffer name)))

(defun agent-shell/set-project (dir)
  "Change the project directory for an agent-shell buffer to DIR.

When called from an agent-shell or viewport buffer, targets that buffer's
underlying shell.  Otherwise prompts to select one.

Overrides `agent-shell-cwd-function' buffer-locally so project detection
via projectile or project.el is bypassed for this shell only."
  (interactive
   (let* ((shell (agent-shell//current-shell-buffer))
          (current (when shell
                     (with-current-buffer shell (agent-shell-cwd)))))
     (list (read-directory-name "Project directory: "
                                (or current default-directory)
                                nil t))))
  (let ((shell (or (agent-shell//current-shell-buffer)
                   (when-let* ((buffers (agent-shell-buffers)))
                     (get-buffer
                      (completing-read "Agent shell: "
                                       (mapcar #'buffer-name buffers)
                                       nil t))))))
    (unless shell (user-error "No agent-shell buffer found"))
    (with-current-buffer shell
      (setq-local agent-shell-cwd-function (lambda () dir))
      (setq-local default-directory dir))
    (message "Agent shell project: %s" (abbreviate-file-name dir))))

;;; funcs.el ends here
