
VERSION=0.14

INSTALL=install
LPADMIN=/usr/sbin/lpadmin

BIN=$(DESTDIR)/usr/bin
SHARE=$(DESTDIR)/usr/share
APPL=$(DESTDIR)/usr/share/applications
PIXMAPS=$(DESTDIR)/usr/share/pixmaps
LIBCUPS=$(DESTDIR)/usr/lib/cups
LIBBONOBO=$(DESTDIR)/usr/lib/bonobo

NULL=
FILES=\
	2pages.ps \
	COPYING \
	debian.changelog \
	debian.control \
	debian.rules \
	gmd-applet.py.in \
	gmd-backend.sh \
	gmd.server \
	gmd.svg \
	gnome-manual-duplex.desktop \
	gnome-manual-duplex.dsc.in \
	gnome-manual-duplex.glade \
	gnome-manual-duplex.png \
	gnome-manual-duplex.py \
	gnome-manual-duplex.spec.in \
	long_edge.fig \
	Makefile \
	README \
	short_edge.fig \
	$(NULL)

.SUFFIXES: .glade .xml .fig .xpm .py.in .py

.glade.xml:
	gtk-builder-convert $*.glade $*.xml

%.py : %.py.in
	rm -f $@; sed < $*.py.in > $@ \
            -e "s@\$${VERSION}@$(VERSION)@"; chmod +x-w $@ \
            || (rm -f $@ && exit 1)

% : %.py.in
	rm -f $@; sed < $*.py.in > $@ \
            -e "s@\$${VERSION}@$(VERSION)@"; chmod +x-w $@ \
            || (rm -f $@ && exit 1)

% : %.py
	rm -f $@; cp -a $*.py $@; chmod +x-w $@

.fig.xpm:
	fig2dev -m 0.50 -L xpm $*.fig \
	    | sed -e 's/White/None/' -e 's/#FFFFFF/None/' \
	    > $*.xpm

PROG=gnome-manual-duplex

all: $(PROG) $(PROG).xml $(PROG).spec $(PROG).dsc \
	long_edge.xpm short_edge.xpm gmd-applet.py

$(PROG).spec: $(PROG).spec.in Makefile
	rm -f $@
	sed < $@.in > $@ \
            -e "s@\$${VERSION}@$(VERSION)@" \
            || (rm -f $@ && exit 1)
	chmod 444 $@

$(PROG).dsc: $(PROG).dsc.in Makefile
	rm -f $@
	sed < $@.in > $@ \
            -e "s@\$${VERSION}@$(VERSION)@" \
            || (rm -f $@ && exit 1)
	chmod 444 $@

gmd-applet.py: Makefile gmd-applet.py.in

install: all
	# /usr/bin...
	$(INSTALL) -d $(BIN)
	$(INSTALL) $(PROG) $(BIN)
	# /usr/share/gnome-manual-duplex
	$(INSTALL) -d $(SHARE)/$(PROG)
	$(INSTALL) -m644 *.xml $(SHARE)/$(PROG)
	$(INSTALL) -m644 *.xpm $(SHARE)/$(PROG)
	$(INSTALL) -m755 gmd-applet.py $(SHARE)/$(PROG)
	#
	$(INSTALL) -d $(APPL)
	$(INSTALL) -c -m 644 *.desktop $(APPL)
	#
	$(INSTALL) -d $(PIXMAPS)
	$(INSTALL) -c -m644 $(PROG).png $(PIXMAPS)
	$(INSTALL) -m644 gmd.svg $(PIXMAPS)
	#
	$(INSTALL) -d $(LIBCUPS)
	$(INSTALL) -d $(LIBCUPS)/backend
	$(INSTALL) -m755 gmd-backend.sh $(LIBCUPS)/backend/gmd
	#
	# Done in gmd-applet.py now...
	#$(LPADMIN) -p GnomeManualDuplex -E -v gmd:/ -L "Virtual Printer"
	#
	$(INSTALL) -d $(LIBBONOBO)
	$(INSTALL) -d $(LIBBONOBO)/servers
	$(INSTALL) -m644 gmd.server $(LIBBONOBO)/servers/
	#
	$(INSTALL) -d $(SHARE)/doc/$(PROG)
	$(INSTALL) -m644 README $(SHARE)/doc/$(PROG)
	$(INSTALL) -m644 COPYING $(SHARE)/doc/$(PROG)

clean:
	rm -f $(PROG) $(PROG).xml *.tar.gz *.spec *.dsc
	rm -f long_edge.xpm short_edge.xpm
	rm -f gmd-applet.py

tar:	tarver
	HERE=`basename $$PWD`; \
        /bin/ls $(FILES) | \
        sed -e "s?^?$$HERE/?" | \
        (cd ..; tar -c -z -f $$HERE/$$HERE.tar.gz -T-)

tarver: all
	HERENO=`basename $$PWD`; \
        HERE=`basename $$PWD-$(VERSION)`; \
        ln -sf $$HERENO ../$$HERE; \
        /bin/ls $(FILES) | \
        sed -e "s?^?$$HERE/?" | \
        (cd ..; tar -c -z -f $$HERE/$$HERE.tar.gz -T-); \
        rm -f ../$$HERE
