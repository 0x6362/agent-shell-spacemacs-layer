;;; config.el --- agent-shell layer configuration for Spacemacs.
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
;; Layer variables for the agent-shell Spacemacs layer.

;;; Code:

(defvar agent-shell-layer-source-path nil
  "When non-nil, path to a local agent-shell source checkout.
Takes precedence over the version installed by Spacemacs.  Useful when
working against a development branch or a fork.  Set this in the layer
variables list:

  (agent-shell :variables agent-shell-layer-source-path \"~/dev/agent-shell\")")

(defvar agent-shell-layer-global-key "C-c s"
  "Global prefix key for the agent-shell command map.
The map provides send, jump, and session-management commands from any buffer.
Customise in the layer variables list:

  (agent-shell :variables agent-shell-layer-global-key \"C-c a\")")

(defvar agent-shell-layer-configure-fn nil
  "When non-nil, a function called at the end of agent-shell's config phase.
Use it to set authentication and other personal settings from the layer
variables list, where all agent-shell functions are already available.

  (agent-shell :variables
               agent-shell-layer-configure-fn
               (lambda ()
                 (setq agent-shell-anthropic-authentication
                       (agent-shell-anthropic-make-authentication :login t)
                       agent-shell-preferred-agent-config
                       (agent-shell-anthropic-make-claude-code-config))))")

;;; config.el ends here
