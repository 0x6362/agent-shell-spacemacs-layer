;;; packages.el --- agent-shell layer packages file for Spacemacs.
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
;;
;; See the Spacemacs documentation and FAQs for instructions on how to
;; implement a new layer:
;;
;;   SPC h SPC layers RET

;;; Code:

(defconst agent-shell-packages
  '((agent-shell :location (recipe :fetcher github
                                   :repo "xenodium/agent-shell"
                                   :files ("*.el"))))
  "The list of Lisp packages required by the agent-shell layer.

Each entry is either:

1. A symbol, which is interpreted as a package to be installed, or

2. A list of the form (PACKAGE KEYS...), where PACKAGE is the
    name of the package to be installed or loaded, and KEYS are
    any number of keyword-value-pairs.

    The following keys are accepted:

    - :excluded (t or nil): Prevent the package from being loaded
      if value is non-nil

    - :location: Specify a custom installation location.
      The following values are legal:

      - The symbol `elpa' (default) means PACKAGE will be
        installed using the Emacs package manager.

      - The symbol `local' directs Spacemacs to load the file at
        `./local/PACKAGE/PACKAGE.el'

      - A list beginning with the symbol `recipe' is a melpa
        recipe.  See: https://github.com/milkypostman/melpa#recipe-format")

(defun agent-shell/init-agent-shell ()
  "Initialize the agent-shell package."
  ;; When a local source path is configured, prepend it so it wins over the
  ;; recipe-installed copy.  Useful when working against a fork or dev branch.
  (when (and agent-shell-layer-source-path
             (file-directory-p agent-shell-layer-source-path))
    (add-to-list 'load-path agent-shell-layer-source-path))
  (use-package agent-shell
    :defer t
    :config

    ;; Evil: agent-shell-mode — normal-state RET sends, insert-state RET newlines
    (evil-define-key 'normal agent-shell-mode-map
      (kbd "RET")        #'comint-send-input
      (kbd "S-<return>") #'comint-send-input)
    (evil-define-key 'insert agent-shell-mode-map
      (kbd "RET")        #'newline
      (kbd "S-<return>") #'comint-send-input)

    ;; Evil: viewport-view → motion state; diff buffers → emacs state
    (add-hook 'agent-shell-viewport-view-mode-hook #'evil-motion-state)
    (add-hook 'diff-mode-hook
              (lambda ()
                (when (string-match-p "\\*agent-shell-diff\\*" (buffer-name))
                  (evil-emacs-state))))

    ;; Remove single-letter bindings that now live in transients/leader.
    ;; agent-shell-mode: n/p/r shadow evil-normal via the mode map.
    (dolist (key '("n" "p" "r"))
      (define-key agent-shell-mode-map (kbd key) nil))
    ;; viewport-view: all letter bindings move into the transient.
    (dolist (key '("n" "p" "f" "b" "r" "R" "y" "m" "a" "c" "q" "v"
                   "1" "2" "3" "4" "5" "6" "7" "8" "9"))
      (define-key agent-shell-viewport-view-mode-map (kbd key) nil))

    ;; Transient state: agent-shell-mode
    (spacemacs|define-transient-state agent-shell-shell
      :title "Agent Shell"
      :doc "
  Navigate  [_n_] next item    [_p_] prev item
  Act       [_r_] quote-region  [_d_] set project dir
  Session   [_v_] model  [_s_] mode  [_t_] thought  [_c_] cycle  [_C_] config
  Other     [_i_] interrupt  [_o_] other buf  [_q_] quit"
      :bindings
      ("n" agent-shell-next-item)
      ("p" agent-shell-previous-item)
      ("r" agent-shell-quote-region)
      ("d" agent-shell/set-project :exit t)
      ("v" agent-shell-set-session-model :exit t)
      ("s" agent-shell-set-session-mode :exit t)
      ("t" agent-shell-set-session-thought-level :exit t)
      ("c" agent-shell-cycle-session-mode :exit t)
      ("C" agent-shell-set-session-config-option :exit t)
      ("i" agent-shell-interrupt :exit t)
      ("o" agent-shell-other-buffer :exit t)
      ("q" nil :exit t))

    ;; Transient state: viewport-view-mode
    (spacemacs|define-transient-state agent-shell-viewport
      :title "Agent Shell Viewport"
      :doc "
  Navigate  [_n_] next item  [_p_] prev item  [_f_] next page  [_b_] prev page
  Reply     [_r_] reply  [_R_] quote  [_y_] yes  [_m_] more  [_a_] again  [_c_] continue
            [_1_]..[_9_] reply 1-9
  Session   [_v_] model  [_s_] mode  [_t_] thought  [_d_] set project dir
  Other     [_i_] interrupt  [_o_] other buf  [_q_] quit"
      :bindings
      ("n" agent-shell-viewport-next-item)
      ("p" agent-shell-viewport-previous-item)
      ("f" agent-shell-viewport-next-page)
      ("b" agent-shell-viewport-previous-page)
      ("r" agent-shell-viewport-reply)
      ("R" agent-shell-viewport-quote-reply)
      ("y" agent-shell-viewport-reply-yes)
      ("m" agent-shell-viewport-reply-more)
      ("a" agent-shell-viewport-reply-again)
      ("c" agent-shell-viewport-reply-continue)
      ("1" agent-shell-viewport-reply-1)
      ("2" agent-shell-viewport-reply-2)
      ("3" agent-shell-viewport-reply-3)
      ("4" agent-shell-viewport-reply-4)
      ("5" agent-shell-viewport-reply-5)
      ("6" agent-shell-viewport-reply-6)
      ("7" agent-shell-viewport-reply-7)
      ("8" agent-shell-viewport-reply-8)
      ("9" agent-shell-viewport-reply-9)
      ("d" agent-shell/set-project :exit t)
      ("v" agent-shell-viewport-set-session-model :exit t)
      ("s" agent-shell-viewport-set-session-mode :exit t)
      ("t" agent-shell-viewport-set-session-thought-level :exit t)
      ("i" agent-shell-viewport-interrupt :exit t)
      ("o" agent-shell-other-buffer :exit t)
      ("q" nil :exit t))

    ;; Global prefix map — minor-mode-style bindings under agent-shell-layer-global-key.
    ;; which-key shows individual commands after the prefix; no hydra involved.
    (defvar agent-shell-layer--global-map
      (let ((map (make-sparse-keymap)))
        ;; Send
        (define-key map (kbd "r") #'agent-shell-send-region)
        (define-key map (kbd "R") #'agent-shell-send-region-to)
        (define-key map (kbd "f") #'agent-shell-send-file)
        (define-key map (kbd "F") #'agent-shell-send-file-to)
        (define-key map (kbd "o") #'agent-shell-send-other-file)
        (define-key map (kbd "s") #'agent-shell-send-screenshot)
        (define-key map (kbd "S") #'agent-shell-send-screenshot-to)
        (define-key map (kbd "i") #'agent-shell-send-clipboard-image)
        (define-key map (kbd "I") #'agent-shell-send-clipboard-image-to)
        ;; Jump
        (define-key map (kbd "j") #'agent-shell//switch-to-buffer)
        (define-key map (kbd "t") #'agent-shell-toggle)
        (define-key map (kbd "d") #'agent-shell/set-project)
        ;; New
        (define-key map (kbd "n") #'agent-shell-new-shell)
        (define-key map (kbd "N") #'agent-shell-new-temp-shell)
        (define-key map (kbd "c") #'agent-shell-prompt-compose)
        map)
      "Global prefix map for agent-shell commands.")
    (global-set-key (kbd agent-shell-layer-global-key) agent-shell-layer--global-map)
    (when (fboundp 'which-key-add-key-based-replacements)
      (which-key-add-key-based-replacements agent-shell-layer-global-key "agent-shell"))

    ;; C-c . → per-mode transient (reachable in all evil states via C-c prefix)
    (define-key agent-shell-mode-map (kbd "C-c .")
      #'spacemacs/agent-shell-shell-transient-state/body)
    (define-key agent-shell-viewport-view-mode-map (kbd "C-c .")
      #'spacemacs/agent-shell-viewport-transient-state/body)
    (define-key agent-shell-viewport-edit-mode-map (kbd "C-c .")
      #'spacemacs/agent-shell-viewport-transient-state/body)

    ;; Leader bindings: agent-shell-mode
    (spacemacs/set-leader-keys-for-major-mode 'agent-shell-mode
      "." #'spacemacs/agent-shell-shell-transient-state/body
      "c" #'agent-shell-cycle-session-mode
      "C" #'agent-shell-set-session-config-option
      "d" #'agent-shell/set-project
      "i" #'agent-shell-interrupt
      "n" #'agent-shell-next-item
      "o" #'agent-shell-other-buffer
      "p" #'agent-shell-previous-item
      "r" #'agent-shell-quote-region
      "s" #'agent-shell-set-session-mode
      "t" #'agent-shell-set-session-thought-level
      "v" #'agent-shell-set-session-model)

    ;; Leader bindings: viewport-view-mode
    (spacemacs/set-leader-keys-for-major-mode 'agent-shell-viewport-view-mode
      "." #'spacemacs/agent-shell-viewport-transient-state/body
      "a" #'agent-shell-viewport-reply-again
      "b" #'agent-shell-viewport-previous-page
      "c" #'agent-shell-viewport-reply-continue
      "d" #'agent-shell/set-project
      "f" #'agent-shell-viewport-next-page
      "i" #'agent-shell-viewport-interrupt
      "m" #'agent-shell-viewport-reply-more
      "n" #'agent-shell-viewport-next-item
      "o" #'agent-shell-other-buffer
      "p" #'agent-shell-viewport-previous-item
      "q" #'bury-buffer
      "r" #'agent-shell-viewport-reply
      "R" #'agent-shell-viewport-quote-reply
      "s" #'agent-shell-viewport-set-session-mode
      "t" #'agent-shell-viewport-set-session-thought-level
      "v" #'agent-shell-viewport-set-session-model
      "y" #'agent-shell-viewport-reply-yes)

    ;; Leader bindings: viewport-edit-mode
    (spacemacs/set-leader-keys-for-major-mode 'agent-shell-viewport-edit-mode
      "RET" #'agent-shell-viewport-compose-send
      "h"   #'agent-shell-viewport-compose-help-menu
      "k"   #'agent-shell-viewport-compose-cancel
      "o"   #'agent-shell-other-buffer
      "p"   #'agent-shell-viewport-compose-peek-last
      "s"   #'agent-shell-viewport-set-session-mode
      "t"   #'agent-shell-viewport-set-session-thought-level
      "v"   #'agent-shell-viewport-set-session-model)

    ;; User-supplied configuration (authentication, preferred agent, etc.)
    (when (functionp agent-shell-layer-configure-fn)
      (funcall agent-shell-layer-configure-fn))))

;;; packages.el ends here
