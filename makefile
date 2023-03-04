TEX = pandoc
FLAGS = --pdf-engine=xelatex

salary.pdf : template.tex details.yaml salary.cls
	$(TEX) -f markdown template.tex details.yaml -o $@ --template=$< $(FLAGS)

example : template.tex exampleDetails.yaml salary.cls
	$(TEX) -f markdown template.tex exampleDetails.yaml -o $@.pdf --template=$< $(FLAGS)

.PHONY: clean
clean :
	rm -f *.pdf *.out *aux *log *.synctex\(busy\)
