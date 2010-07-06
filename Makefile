
PROG=gnome-manual-duplex
VERSION=0.20

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
	2pages.pdf \
	COPYING \
	debian.changelog \
	debian.control \
	debian.rules \
	gmd-applet.py.in \
	gmd-backend.sh \
	gmd.server \
	gmd.svg \
	$(PROG).desktop \
	$(PROG).dsc.in \
	$(PROG).glade \
	$(PROG).png \
	$(PROG).ppd \
	$(PROG).py \
	$(PROG).spec.in \
	long_edge.fig \
	Makefile \
	README \
	short_edge.fig \
	po/en_US.po \
	$(NULL)

.SUFFIXES: .glade .xml .fig .xpm .py.in .py

.glade.xml:
	gtk-builder-convert $*.glade - \
	    | sed -e "s@\$${VERSION}@$(VERSION)@" > $*.xml

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

all: $(PROG) $(PROG).xml $(PROG).spec $(PROG).dsc messages \
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

$(PROG).xml: Makefile

messages: messages.pot locale/en_US/LC_MESSAGES/$(PROG).mo

messages.pot: $(PROG).py $(PROG).glade gmd-applet.py Makefile
	xgettext -k_ -kN_ -o $@ $(PROG).py $(PROG).glade gmd-applet.py
	sed -i'~' -e 's/SOME .* TITLE/gmd translation template/g' \
	    -e 's/YEAR THE .* HOLDER/2010 Rick Richardson/g' \
	    -e 's/FIRST .*, YEAR/Rick Richardson <rickrich@gmail.com>, 2010/g' \
	    -e 's/PACKAGE VERSION/$(PROG) '$(VERSION)'/g' \
	    -e 's/PACKAGE/$(PROG)/g' $@

# msginit -i messages.pot -o po/en_US.po
po/en_US.po: messages.pot
	msgmerge -U $@ messages.pot
	touch $@

locale/en_US/LC_MESSAGES/$(PROG).mo: po/en_US.po
	mkdir -p locale/en_US/LC_MESSAGES/
	msgfmt po/en_US.po -o $@

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
	$(INSTALL) -d $(SHARE)/cups/model
	$(INSTALL) $(PROG).ppd $(SHARE)/cups/model
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
	rm -f messages.pot*
	rm -rf locale

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

w:	all
	root $(MAKE) install
	$(MAKE) tar
