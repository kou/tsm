images: \
	do-next.png \
	do-next.eps \
	event.png \
	event.eps \
	event-driven-to-pull-event.png \
	event-driven-to-pull-event.eps \
	system-architecture.png \
	system-architecture.png \
	system-architecture.eps

.SUFFIXES: .png .eps .dia.gz

.dia.gz.eps:
	dia -e $@ -t eps-pango $<

.dia.gz.png:
	dia -e $@ -t png $<
