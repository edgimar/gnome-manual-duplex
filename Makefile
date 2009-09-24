
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

clean:
	rm -f $(PROG) $(PROG).xml
	
