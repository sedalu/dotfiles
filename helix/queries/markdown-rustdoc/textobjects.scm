;; Paragraphs (blocks of text separated by blank lines)
(paragraph) @paragraph.inner
(paragraph)+ @paragraph.outer

;; Code blocks (fenced code blocks)
(fenced_code_block) @code_block.inner
(fenced_code_block)+ @code_block.outer

;; List items
(list_item) @list_item.inner
(list_item)+ @list_item.outer

;; Headings
(atx_heading) @heading.inner
(atx_heading)+ @heading.outer

;; Block quotes
(block_quote) @quote.inner
(block_quote)+ @quote.outer
