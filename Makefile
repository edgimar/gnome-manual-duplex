
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
	$(INSTALL) $(PROG) $(BIN)
	$(INSTALL) -d $(SHARE)/$(PROG)
	$(INSTALL) *.xml $(SHARE)/$(PROG)
	$(INSTALL) *.xpm $(SHARE)/$(PROG)
	if [ -d $(APPL) ]; then \
	    $(INSTALL) -c -m 644 *.desktop $(APPL); \
	fi
	if [ -d $(PIXMAPS) ]; then \
	    $(INSTALL) -c -m 644 $(PROG).png $(PIXMAPS); \
	fi
	install -m755 gmd-backend.sh $(LIBCUPS)/backend/gmd
	lpadmin -p GnomeManualDuplex -E -v gmd:/ -L "Virtual Printer"
	install -d $(LIBBONOBO)/servers
	install gmd.server $(LIBBONOBO)/servers/
	install -m644 gmd.svg $(SHARE)/pixmaps/
	install -m755 gmd-applet.py $(SHARE)/$(PROG)

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
