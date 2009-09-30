
VERSION=0.0
INSTALL=install
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
	gmd-applet.py \
	gmd-backend.sh \
	gmd.server \
	gmd.svg \
	gnome-manual-duplex.desktop \
	gnome-manual-duplex.glade \
	gnome-manual-duplex.png \
	gnome-manual-duplex.py \
	gnome-manual-duplex.spec \
	long_edge.xpm \
	Makefile \
	README \
	short_edge.xpm \
	$(NULL)

.SUFFIXES: .glade .xml

.glade.xml:
	gtk-builder-convert $*.glade $*.xml

% : %.py
	rm -f $@; cp -a $*.py $@; chmod +x-w $@

PROG=gnome-manual-duplex

all: $(PROG) $(PROG).xml

install: all
	# /usr/bin...
	$(INSTALL) -d $(BIN)
	$(INSTALL) $(PROG) $(BIN)
	# /usr/share/gnome-manual-duplex
	$(INSTALL) -d $(SHARE)/$(PROG)
	$(INSTALL) *.xml $(SHARE)/$(PROG)
	$(INSTALL) *.xpm $(SHARE)/$(PROG)
	$(INSTALL) -m755 gmd-applet.py $(SHARE)/$(PROG)
	#
	$(INSTALL) -d $(APPL)
	$(INSTALL) -c -m 644 *.desktop $(APPL)
	#
	$(INSTALL) -d $(PIXMAPS)
	$(INSTALL) -c -m 644 $(PROG).png $(PIXMAPS)
	$(INSTALL) -m644 gmd.svg $(PIXMAPS)
	#
	$(INSTALL) -d $(LIBCUPS)
	$(INSTALL) -d $(LIBCUPS)/backend
	$(INSTALL) -m755 gmd-backend.sh $(LIBCUPS)/backend/gmd
	lpadmin -p GnomeManualDuplex -E -v gmd:/ -L "Virtual Printer"
	#
	$(INSTALL) -d $(LIBBONOBO)
	$(INSTALL) -d $(LIBBONOBO)/servers
	$(INSTALL) -d $(LIBBONOBO)/servers
	$(INSTALL) gmd.server $(LIBBONOBO)/servers/

clean:
	rm -f $(PROG) $(PROG).xml *.tar.gz

tar:
	HERE=`basename $$PWD`; \
        /bin/ls $(FILES) | \
        sed -e "s?^?$$HERE/?" | \
        (cd ..; tar -c -z -f $$HERE/$$HERE.tar.gz -T-)

tarver: 
	HERENO=`basename $$PWD`; \
        HERE=`basename $$PWD-$(VERSION)`; \
        ln -sf $$HERENO ../$$HERE; \
        /bin/ls $(FILES) | \
        sed -e "s?^?$$HERE/?" | \
        (cd ..; tar -c -z -f $$HERE/$$HERE.tar.gz -T-); \
        rm -f ../$$HERE
