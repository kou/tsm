images: \
	system-architecture.png \
	system-architecture.eps

.SUFFIXES: .png .eps .dia.gz

.dia.gz.eps:
	dia -e $@ -t eps-pango $<

.dia.gz.png:
	dia -e $@ -t png $<
