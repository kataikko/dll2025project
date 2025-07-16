#import "@preview/touying:0.6.1": *
#import "themes/UFR.typ": *
#import "@preview/numbly:0.1.0": numbly
#import "@preview/muchpdf:0.1.1": muchpdf

#show: metropolis-theme.with(
  aspect-ratio: "16-9",
  footer: self => self.info.institution
)

#pdfpc.config(
  duration-minutes: 30,
  start-time: datetime(hour: 10, minute: 5, second: 0),
  last-minutes: 5,
  note-font-size: 12,
  disable-markdown: false,

)

#set heading(numbering: numbly("{1}.", default: "1.1"))

#let note = pdfpc.speaker-note
#let vizfig(content) = {
  figure(
      content,
      caption: text(size: 15pt)[Illustration by Müller et. al.],
      supplement: [Architecture],
      numbering: none,
  )
}
#let pdf(path, scale: 2.0) = {
  muchpdf(scale: scale, read(path, encoding: none))
}
= topic
== item
another item
#focus-slide[Thank you for your attention!]