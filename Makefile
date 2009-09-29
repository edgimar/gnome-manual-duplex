
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

x:
	install -m755 psproc_applet.py /usr/bin/psproc_applet
	#install -m755 psproc_backend.py /usr/lib/cups/backend/psproc
	install -d /usr/lib/bonobo/servers
	install gtkpsproc.server /usr/lib/bonobo/servers/
	install -m644 gtkpsproc.svg /usr/share/pixmaps/
	install -m644 gtkpsproc.png /usr/share/pixmaps/
	#lpadmin -p GnomeManualDuplex -E -v psproc:/ -L "Virtual Printer"

clean:
	rm -f $(PROG) $(PROG).xml
