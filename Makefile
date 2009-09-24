
.SUFFIXES: .glade .xml

.glade.xml:
	gtk-builder-convert $*.glade $*.xml

% : %.py
	rm -f $@; cp -a $*.py $@; chmod +x-w $@

PROG=gnome-manual-duplex

all: $(PROG) $(PROG).xml

install: all
	install $(PROG) /usr/bin
	install -d /usr/share/gnome-manual-duplex
	install *.xml /usr/share/gnome-manual-duplex
	install *.xpm /usr/share/gnome-manual-duplex

clean:
	rm -f $(PROG) $(PROG).xml
	
