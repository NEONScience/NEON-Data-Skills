## Instructor notes for "Functions for figures"

Again, the instructor should show what the chunks of code do before letting
participants convert them into functions.

Here we use the `pdf(...); code_for_figure; dev.off()` instead of `ggsave` so
that the function also works for non ggplot2 code.
