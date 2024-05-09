# Emacs mode for [aiken](https://github.com/aiken-lang/aiken)

An emacs major mode providing syntax highlighting, indentation and formatting
commands for the Aiken smart contract language.

## Features

- [x] Syntax highlighting
- [x] `aiken fmt` command 
- [ ] Indentation
- [x] Aiken LSP client

## Installation

The package is [not yet on MELPA](https://github.com/melpa/melpa/pull/8736), so pointing your emacs config to this
repository is the way to go for now.

### [doom-emacs](https://github.com/doomemacs/doomemacs/) (recommended :smiling_imp:)

Add this to your `packages.el`:

```elisp
(package! aiken-mode
  :recipe (:host github :repo "aiken-lang/aiken-mode"))
```

Add this to your `config.el`:

``` elisp
(use-package! aiken-mode
  :config
  (use-package! lsp
    :hook
    (aiken-mode . lsp))
  :bind
  ("C-c C-b" . aiken-format-buffer))
  ("C-c C-r" . aiken-format-region))
```

and run `doom sync`.

For faster feedback time during development:

```elisp
(package! aiken-mode
  :recipe (:local-repo "~/path/to/aiken-mode"))
```

### use-package

```elisp
(use-package aiken-mode
  :load-path "~/path/to/aiken-mode")
  :config
  (use-package lsp
    :hook
    (aiken-mode . lsp))
  :bind
  ("C-c C-b" . aiken-format-buffer))
  ("C-c C-r" . aiken-format-region))
```

### vanilla

```elisp
(add-to-list 'load-path "~/path/to/aiken-mode")
(load-library "aiken-mode")
```
