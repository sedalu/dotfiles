;; Indentation rules for markdown lists and nested structures

;; Ordered and unordered lists
(list_item) @indent

;; Fenced code blocks
(fenced_code_block
  (info_string) @indent)

;; Block quotes
(block_quote) @indent

;; List continuations (continuation of list item content)
(list_item
  (block_quote) @indent
  (list) @indent
  (fenced_code_block) @indent
  (paragraph) @indent)
