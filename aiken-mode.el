

;; Copyright © 2023 Sebastian Nagel <sebastian.nagel@ncoding.at>

;; Author: Sebastian Nagel <sebastian.nagel@ncoding.at>
;; URL: https://github.com/aiken-lang/aiken-mode
;; Keywords: languages aiken
;; Version: 1.0.3
;; Package-Requires: ((emacs "27.1"))
;; SPDX-License-Identifier: MPL-2.0

;; This file is NOT part of GNU Emacs.

;; This Source Code Form is subject to the terms of the Mozilla Public
;; License, v. 2.0. If a copy of the MPL was not distributed with this
;; file, You can obtain one at http://mozilla.org/MPL/2.0/.

;;; Commentary:

;; Provides Aiken smart contract language with:
;;    - syntax highlighting
;;    - lsp client for interacting with aiken language server using  Language Server Protocol
;;    - aiken code formatting
;;
;; Note:
;; The lsp and aiken code formatter assumes `aiken` binary is in the $PATH

;;; Code:

;; Aiken syntax

(defvar aiken-keywords
  '("if"
    "else"
    "when"
    "is"
    "fn"
    "use"
    "let"
    "pub"
    "type"
    "opaque"
    "const"
    "todo"
    "error"
    "expect"
    "test"
    "trace"
    "fail"
    "validator"
    "and"
    "or"))

(defvar aiken-operators
  '(
    "="
    "->"
    ".."
    "|>"
    ">="
    "<="
    ">"
    "<"
    "!="
    "=="
    "&&"
    "||"
    "!"
    "+"
    "-"
    "/"
    "*"
    "%"
    "?"))

(defvar aiken-font-lock-keywords
  (append
   `(
     ;; Keywords
     (,(regexp-opt aiken-keywords 'symbols) . font-lock-keyword-face)
     ;; CamelCase is a type
     ("[[:upper:]][[:word:]]*" . font-lock-type-face)
     ;; Operators
     (,(regexp-opt aiken-operators nil) . font-lock-builtin-face))
   ;; Identifiers after keywords
   (mapcar (lambda (x)
             (list (concat (car x) "[^(]\\(\\w*\\)")
                   1 ;; apply face ot first match group
                   (cdr x)))
           '(("const" . font-lock-type-face)
             ("type" . font-lock-type-face)
             ("use" . font-lock-constant-face)
             ("fn" . font-lock-function-name-face)))))

;; Mode definitions

;;;###autoload
(define-derived-mode aiken-mode prog-mode "Aiken"
  "Major mode for Aiken code."
  :group 'aiken-mode

  (setq-local indent-tabs-mode nil)

  ;; Syntax highlighting via font-lock
  (setq-local font-lock-defaults '(aiken-font-lock-keywords))

  ;; Syntax: make _ part of words
  (modify-syntax-entry ?_ "w" aiken-mode-syntax-table)

  ;; Comment syntax
  (modify-syntax-entry ?/ ". 124b" aiken-mode-syntax-table)
  (modify-syntax-entry ?\n "> b" aiken-mode-syntax-table)
  (modify-syntax-entry ?\^m "> b" aiken-mode-syntax-table)

  ;; Comment settings
  (setq-local comment-start "// ")
  (setq-local comment-end "")
  (setq-local comment-start-skip "//+ *")
  (setq-local comment-use-syntax t)
  (setq-local comment-auto-fill-only-comments t))

;;;###autoload
(add-to-list 'auto-mode-alist '("\\.ak\\'" . aiken-mode))


(require 'lsp-mode)
;;
;; aiken-lsp starts here
;;
;; ---------------------------------------------------------------------
;; Configuration

(defgroup aiken-lsp nil
  "Customization group for ‘aiken-lsp’."
  :group 'lsp-mode)

;;
;; helper functions
;;
;; we assume the `aiken' binary is in the $PATH
(defcustom aiken-lsp-server-path
  "aiken"
  "The language server executable.
Can be something on the $PATH (e.g. `aiken') or a path to an executable itself."
  :group 'aiken-lsp
  :type 'string)

;; As of aiken v1.0.26, no args are required. However this might change in future version of aiken
(defcustom aiken-lsp-server-args
  `()
  "The arguments for starting the language server."

  :group 'aiken-lsp
  :type '(repeat (string :tag "Argument")))

;; As of aiken v1.0.26, no wrapper is required.
(defcustom aiken-lsp-server-wrapper-function
  #'identity
  "Use this wrapp the lsp server process."
  :group 'aiken-lsp
  :type '(choice
          (function-item :tag "None" :value identity)
          (function :tag "Custom function")))

(defun aiken-lsp--server-command ()
  "Command and arguments for launching the inferior language server process.
These are assembled from the customizable variables `aiken-lsp-server-path'
and `aiken-lsp-server-args' and `aiken-lsp-server-wrapper-function'."
  (funcall aiken-lsp-server-wrapper-function (append (list aiken-lsp-server-path "lsp") aiken-lsp-server-args) ))

(add-to-list 'lsp-language-id-configuration '(aike-mode . "Aiken"))
;;
;; Register the client itself
;;
(lsp-register-client
 (make-lsp-client
  :new-connection (lsp-stdio-connection (lambda () (aiken-lsp--server-command)))
  ;; should run under aiken-mode
  :major-modes '(aiken-mode)
  :server-id 'aiken-lsp
  :activation-fn (lsp-activate-on "aiken")
  ;; :initialized-fn (lambda (workspace) (with-lsp-workspace workspace (lsp--set-configuration (lsp-configuration-section "aiken"))))
  :synchronize-sections '("aiken")
  :language-id "aiken"))

(add-to-list 'lsp-language-id-configuration '(aiken-mode . "aiken"))

;; aiken-lsp ends here
;; ---------------------------------------------------------------------
;; aiken-format starts here
;;
(require 'reformatter)

(defcustom aiken-format-aiken-version "0.10"
  "The version of Aiken against which code should be formatted."
  :group 'aiken-format
  :type 'string)

(defcustom aiken-format-command "aiken"
  "The name of the `aiken-format' command."
  :group 'aiken-format
  :type 'string)

(reformatter-define aiken-format
  :program "aiken"
  :args (list "fmt"  "--stdin")
  :group 'aiken-format
  :lighter " AikenFmt")

;;
(provide 'aiken-mode)
;;; aiken-mode.el ends here
