
INSTALL=install
BIN=$(DESTDIR)/usr/bin
SHARE=$(DESTDIR)/usr/share
APPL=$(DESTDIR)/usr/share/applications
PIXMAPS=$(DESTDIR)/usr/share/pixmaps

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
	install -m755 gmd-backend.sh /usr/lib/cups/backend/gmd
	lpadmin -p GnomeManualDuplex -E -v gmd:/ -L "Virtual Printer"
	install -d /usr/lib/bonobo/servers
	install gmd.server /usr/lib/bonobo/servers/
	install -m644 gmd.svg $(SHARE)/pixmaps/
	install -m755 gmd-applet.py $(SHARE)/$(PROG)

clean:
	rm -f $(PROG) $(PROG).xml
