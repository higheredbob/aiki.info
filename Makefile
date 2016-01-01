#!/usr/bin/make -f

#all: perms $(shell find . -maxdepth 1 -path '*/.*' -prune -o -name '*.txt' -type f -print | sed 's/\.txt$$/.html/') $(shell find . -maxdepth 1 -path '*/.*' -prune -o \( -name '*.png' -o -name '*.jpg' \) -type f -print | sed 's,\(.*/\),\1tn/,;')

all: html labs+ Aikido.html aiki.html notes_html waza-nihongo.txt waza-english.txt
# html: $(patsubst %.txt,%.html,$(wildcard *.txt))
html: index.html

labs+:
	cd labs; $(MAKE)

%.html: %.txt $(shell which text2html)
	text2html $< >$@ ; hide $@

perms:
	if [ -e x -a -e x/env ]; then q x/env; fi
	if [ -e x ]; then chmod -R go+rX,g-w x ; chgrp -R www-data x; fi

tn/%.png: %.png Makefile
	<$< pngtopnm | pnmscale -width=256 | pnmtopng >$@

tn/%.jpg: %.jpg Makefile
	<$< jpegtopnm | pnmscale -width=310 | pnmtojpeg -quality=95 >$@

replacements.sed: replacements.txt
	<$< sed 's/^/s|/; s/$$/|g;/; s/\t/|/;' >$@

Aikido.html: Aikido.2.html replacements.sed
	sed -f replacements.sed <$< >$@

aiki.html: aiki.1.html
	./add-links-and-translations.pl <$< >$@

notes_html:
	cd notes; $(MAKE)

waza-nihongo.txt: waza-romaji.txt romaji-to-nihogo.sub romaji-to-nihogo-2.sub
	sub -w -m=romaji-to-nihogo.sub < waza-romaji.txt | sub -m=romaji-to-nihogo-2.sub > waza-nihongo.txt

waza-english.txt: waza-romaji.txt romaji-to-english.sub
	sub -w -m=romaji-to-english.sub < waza-romaji.txt > waza-english.txt

.PHONY: all html
