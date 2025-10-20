# Simplified Research Agenda Diagram for Slides (Horizontal with Wrapped Text)
# Left-to-right orientation, larger fonts, wrapped labels for readability.

if (!requireNamespace("DiagrammeR", quietly = TRUE)) install.packages("DiagrammeR")
if (!requireNamespace("DiagrammeRsvg", quietly = TRUE)) install.packages("DiagrammeRsvg")
if (!requireNamespace("rsvg", quietly = TRUE)) install.packages("rsvg")
if (!requireNamespace("here", quietly = TRUE)) install.packages("here")
if (!requireNamespace("fs", quietly = TRUE)) install.packages("fs")

library(DiagrammeR)
library(DiagrammeRsvg)
library(rsvg)
library(here)
library(fs)

rankdir <- "LR"

dot <- sprintf('digraph research_agenda {
  graph [rankdir=%s, nodesep=1.0, ranksep=1.2, fontsize=28, fontname="Helvetica"]
  node  [shape=box, style=rounded, fontname="Helvetica", fontsize=24, width=5, height=1.2]
  edge  [fontname="Helvetica", fontsize=20, arrowsize=1.0]

  Q  [label="How governments and communities\nbuild capacity to implement policy (UNC)", style="rounded,filled", fillcolor="#eef3f8"]

  H  [label="War on Poverty and\nCommunity organizing:\nUC Berkeley"]
  C  [label="Civic infrastructure and\n Democratic governance:\nJohns Hopkins & Harvard"]
  P  [label="Policy implementation, Data science, and AI:\nCode for America and\nBetter Government Lab\n(Georgetown & Michigan)"]

  O1 [label="Papers &\nBook:\nUnseen and Uncounted", URL="https://jaeyk.github.io/book_projects/books.html"]
  O2 [label="Papers &\nApplied tools"]

  {rank=same; Q}
  {rank=same; H; C; P}
  {rank=same; O1; O2}

  Q -> H
  Q -> C
  Q -> P

  H -> O1
  C -> O2
  P -> O2
}', rankdir)

viz <- grViz(dot)
viz

# Save as PNG for slides with larger dimensions, horizontal layout and wrapped text
fig_path <- here("misc", "research_agenda_slide_horizontal_wrapped.png")
dir_create(path_dir(fig_path))

svg_txt <- export_svg(viz)
rsvg_png(charToRaw(svg_txt), file = fig_path, width = 3200, height = 1600)
cat("Saved:", fig_path, "\n")
