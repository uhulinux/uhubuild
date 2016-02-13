SGML_TOOLS_PATH = /usr/share/linuxdoc-tools:/usr/share/sgml-tools:/usr/lib/sgml-tools

PAPER = a4

.SECONDARY:

FILES = uhubuild
ALLTARGETS = txt_tty txt info html html_big latex dvi ps ps_half ps_dup ps_half_dup pdf pdf_half
#BUILDTARGETS = $(ALLTARGETS)
BUILDTARGETS = html

default: $(BUILDTARGETS)
all: $(ALLTARGETS)

txt_tty: $(patsubst %,txt_tty/%_tty.txt,$(FILES))
txt: $(patsubst %,txt/%.txt,$(FILES))
info: $(patsubst %,info/%.info,$(FILES))
html: $(patsubst %,html/%-0.html,$(FILES))
html_big: $(patsubst %,html_big/%.html,$(FILES))
latex: $(patsubst %,latex/%.tex,$(FILES))
dvi: $(patsubst %,dvi/%.dvi,$(FILES))
ps: $(patsubst %,ps/%.ps,$(FILES))
ps_half: $(patsubst %,ps_half/%_half.ps,$(FILES))
ps_dup: $(patsubst %,ps_dup/%_1.ps,$(FILES))
ps_half_dup: $(patsubst %,ps_half_dup/%_half_1.ps,$(FILES))
pdf: $(patsubst %,pdf/%.pdf,$(FILES))
pdf_half: $(patsubst %,pdf_half/%_half.pdf,$(FILES))


escaped/%.sgml: %.sgml
	test -d escaped || mkdir escaped
	uni2ascii -q -Z U+%04X <$< >$@

txt_tty/%_tty.txt: escaped/%.sgml
	test -d txt_tty || mkdir txt_tty
	sgml2txt -p $(PAPER) -c latin $<
	ascii2uni -q -Z U+%04X <$*.txt >$*.txt.unescaped
	mv $*.txt.unescaped $*.txt
	sed -e 's@\x08@¤@g' \
	    -e 's@---@--@g' \
	    -e 's@_¤`_¤`@_¤"@g' -e "s@_¤'_¤'@_¤\"@g" \
	    -e 's@`¤``¤`@"¤"@g' -e "s@'¤''¤'@\"¤\"@g" \
	    -e 's@``@"@g' -e "s@''@\"@g" \
	    -e 's@Table of Contents@Tartalomjegyzék@g' \
	    -e 's@ˇ@°@g' \
	    -e 's@¤@\x08@g' \
	    <$*.txt >$@
	rm $*.txt

txt/%.txt: txt_tty/%_tty.txt
	test -d txt || mkdir txt
	sed -e 's@.\x08@¤@g' <$< >$@

info/%.info: escaped/%.sgml
	test -d info || mkdir info
	sgml2info -p $(PAPER) $<
	ascii2uni -q -Z U+%04X <$*.info >$*.info.unescaped
	mv $*.info.unescaped $*.info
	for i in $*.info*; do \
		sed -e 's@"`@"@g' -e 's@"'\''@"@g' <$${i} > info/$${i}; \
		rm $${i}; \
	done

html/%-0.html: escaped/%.sgml
	test -d html || mkdir html
	sgml2html -p $(PAPER) $<
	for i in $**.html; do \
		ascii2uni -q -Z U+%04X <$$i >$$i.unescaped; \
		mv $$i.unescaped $$i; \
	done
	mv $*.html $*-0.html
	for i in $**.html; do \
		sed -e 's@---@--@g' \
		    -e 's@``@"@g' -e "s@''@\"@g" \
		    -e 's@^ <TITLE>@ <META HTTP-EQUIV="Content-Type" CONTENT="text/html; charset=UTF-8">¤\0@g' \
		    -e 's@Next@Következő@g' \
		    -e 's@Previous@Előző@g' \
		    -e 's@Contents@Tartalomjegyzék@g' \
		    -e 's@^.*Tartalomjegyzék.*$$@\0¤<A HREF="./">Kilépés</A>@g' \
		    -e 's@$*\.html@$*-0\.html@g' \
		    -e 's@\(<A [^>]*>[^ ]*[0-9]\) @\1. @g' \
		    -e 's@\(<A [^>]*>[^ ]*[0-9]\)\(</A> \)@\1.\2@g' \
		    -e 's@¤@\n@g' <$${i} \
		    >html/$${i}; \
		rm $${i}; \
	done

html_big/%.html: escaped/%.sgml
	test -d html_big || mkdir html_big
	sgml2html -p $(PAPER) -s 0 $<
	ascii2uni -q -Z U+%04X <$*.html >$*.html.unescaped
	mv $*.html.unescaped $*.html
	sed -e 's@---@--@g' \
	    -e 's@``@"@g' -e "s@''@\"@g" \
	    -e 's@^ <TITLE>@ <META HTTP-EQUIV="Content-Type" CONTENT="text/html; charset=UTF-8">¤\0@g' \
	    -e 's@\(<A [^>]*>[^ ]*[0-9]\) @\1. @g' \
	    -e 's@\(<A [^>]*>[^ ]*[0-9]\)\(</A> \)@\1.\2@g' \
	    -e 's@¤@\n@g' \
	    <$*.html >html_big/$*.html
	rm $*.html

latex/%.tex: escaped/%.sgml
	test -d latex || mkdir latex
	sgml2latex -p $(PAPER) -o tex $<
	ascii2uni -q -Z U+%04X <$*.tex >$*.tex.unescaped
	mv $*.tex.unescaped $*.tex
	sed -e 's@^\(\\usepackage{url}\)$$@\1¤\\usepackage{times}@g' \
	    -e 's@^\\usepackage\[latin1\]{inputenc}$$@\\usepackage[utf8]{inputenc}@g' \
	    -e 's@^\\usepackage.*{babel}$$@\\usepackage[magyar]{babel}@g' \
	    -e 's@^\\begin{document}$$@\\frenchspacing¤\\sloppy¤¤\0@g' \
	    -e 's@^\(\\section{\)@\\newpage¤¤\1@g' \
	    -e 's@``@,,@g' \
	    -e 's@\$$<\$$@<@g' -e 's@\$$>\$$@>@g' \
	    -e 's@¤@\n@g' \
	    <$*.tex >$@
	rm $*.tex

dvi/%.dvi: latex/%.tex
	test -d dvi || mkdir dvi
	TEXINPUTS=$$TEXINPUTS:$(SGML_TOOLS_PATH) latex -output-comment=UHUBUILD $<
	TEXINPUTS=$$TEXINPUTS:$(SGML_TOOLS_PATH) latex -output-comment=UHUBUILD $<
	TEXINPUTS=$$TEXINPUTS:$(SGML_TOOLS_PATH) latex -output-comment=UHUBUILD $<
	mv $*.dvi dvi/
	rm $*.aux $*.log $*.toc

ps/%.ps: dvi/%.dvi
	test -d ps || mkdir ps
	dvips -t $(PAPER) -o $@ $<
	bin/pagenumfix.sh '@' $@

ps_half/%_half.ps: ps/%.ps
	test -d ps_half || mkdir ps_half
	pstops -q -p$(PAPER) '2:0L@.7(1w,0)+1L@.7(1w,.5h)' $< $@
	bin/pagenumfix.sh '@+1' $@

ps_dup/%_1.ps: ps/%.ps
	test -d ps_dup || mkdir ps_dup
	pstops -q -p$(PAPER) '2:0'           $< ps_dup/$*_1.ps
	pstops -q -p$(PAPER) '2:-0'          $< ps_dup/$*_1r.ps
	pstops -q -p$(PAPER) '2:1'           $< ps_dup/$*_2.ps
	pstops -q -p$(PAPER) '2:-1'          $< ps_dup/$*_2r.ps
	pstops -q -p$(PAPER) '2:0,1U(1w,1h)' $< ps_dup/$*_ud.ps
	bin/pagenumfix.sh '@+1' ps_dup/$*_{{1,2}{,r},ud}.ps

ps_half_dup/%_1.ps: ps_half/%.ps
	test -d ps_half_dup || mkdir ps_half_dup
	pstops -q -p$(PAPER) '2:0'           $< ps_half_dup/$*_1.ps
	pstops -q -p$(PAPER) '2:-0'          $< ps_half_dup/$*_1r.ps
	pstops -q -p$(PAPER) '2:1'           $< ps_half_dup/$*_2.ps
	pstops -q -p$(PAPER) '2:-1'          $< ps_half_dup/$*_2r.ps
	pstops -q -p$(PAPER) '2:0,1U(1w,1h)' $< ps_half_dup/$*_ud.ps
	bin/pagenumfix.sh '2*@+1,2*@+2' ps_half_dup/$*_{{1,2}{,r},ud}.ps

pdf/%.pdf: ps/%.ps
	test -d pdf || mkdir pdf
	ps2pdf $< pdf/$*.pdf

pdf_half/%_half.pdf: ps_half/%_half.ps
	test -d pdf_half || mkdir pdf_half
	ps2pdf $< pdf_half/$*_half.pdf


datefix:
	bin/datefix.sh $(patsubst %,%.sgml,$(FILES))

spellcheck:
	bin/spellcheck.sh $(patsubst %,%.sgml,$(FILES))


clean:
	rm -rf escaped spell.txt $(ALLTARGETS)

