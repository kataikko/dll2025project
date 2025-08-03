FLAGS=--font-path ./fonts
default: createFolder pdfpc
	typst compile $(FLAGS) main.typ build/presentation.pdf

pdfpc: createFolder
	typst query --root . ./main.typ $(FLAGS) --field value --one "<pdfpc-file>" > build/presentation.pdfpc

createFolder:
	mkdir -p build/

present: default
	pdfpc build/presentation.pdf

poster:
	typst compile --font-path fonts poster.typ build/poster.pdf

show: poster
	open build/poster.pdf