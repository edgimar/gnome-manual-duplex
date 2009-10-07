#!/usr/bin/env python

global Debug
Debug = 0
 
import sys
import os
import tempfile

import pygtk
pygtk.require("2.0")
import gobject
import gtk
import gtkunixprint
import cups
import ConfigParser

REVERSE = 2
INVERT = 1

def load_config(self):
    global cp

    cp = ConfigParser.ConfigParser()
    try:
	cp.read([os.path.expanduser('~/.config/gnome-manual-duplex.cfg')])
	#print cp.get('hp1020', 'long_edge_config', 0)
    except:
	return
 
class App(object):       
    def __init__(self):

	builder = gtk.Builder()
	ui_file = "gnome-manual-duplex.xml"
	ui_folders = [ '.', '/usr/share/gnome-manual-duplex']
	for ui_folder in ui_folders:
            filename = os.path.join(ui_folder, ui_file)
            if os.path.exists(filename):
                builder.add_from_file(filename)
                break

	#builder.add_from_file("manfeed.xml")
	self.window = builder.get_object("window1")
	self.JobName = builder.get_object("filechooserbutton1")
	if len(sys.argv) == 2:
	    self.filename = sys.argv[1]
	    self.JobName.set_filename(sys.argv[1])
	else:
	    self.filename = ''

	self.pref = builder.get_object("pref")
	self.combo_printers = builder.get_object("combobox1")

	# populate combo_printers
        self.combo_printers = builder.get_object("combobox1")
	connection = cups.Connection()
	dests = connection.getDests()
	default_printer = connection.getDefault()

        liststore = gtk.ListStore(gobject.TYPE_STRING)
	default_index = i = 0
	for (printer, instance) in dests.keys ():
	    if default_printer == printer:
		default_index = i
	    if printer == None:
		continue
	    if instance != None:
		continue
	    liststore.append([printer])
	    i = i + 1
        self.combo_printers.set_model(liststore)
        cell = gtk.CellRendererText()
        self.combo_printers.pack_start(cell, True)
        self.combo_printers.add_attribute(cell, 'text', 0)
        self.combo_printers.set_active(default_index)

	self.printdialog = builder.get_object("printdialog1")
	self.evenok = builder.get_object("even-pages-ok")
	self.LongEdge = 1;
	self.SkipOddPages = 0;
	builder.connect_signals(self)
	self.window.show()

	load_config(self)
	self.long_edge_config = REVERSE | INVERT
	self.short_edge_config = REVERSE

    def filechooserbutton1_file_set_cb(self, widget, data=None):
	self.filename = widget.get_filename()

    def gtk_main_quit(self, widget, data=None):
	gtk.main_quit()

    def delete_event(self, widget, data=None):
	gtk.main_quit()
	return False

    def destroy_event(self, widget, data=None):
        gtk.main_quit()

    def button1_clicked_cb(self, widget, data=None):
	print "clicked"

    def radiobutton1_toggled_cb(self, widget, data=None):
	self.LongEdge = not self.LongEdge

    def checkbutton1_toggled_cb(self, widget, data=None):
	self.SkipOddPages = not self.SkipOddPages

    def pref_cb(self, widget, data=None):
	# self.window.hide()
        self.pref.show()

    def print_cb(self, widget, data=None):
	self.window.hide()
        self.printdialog.show()

    def pref_cancel_clicked_cb(self, widget, data=None):
	self.pref.hide()

    def pref_save_clicked_cb(self, widget, data=None):
	self.pref.hide()

    def odd_pages_send_cb(self, widget, data, errormsg):
	return

    def printdialog1_response_cb(self, widget, data=None):
	# print "pclicked" , data
	if data == gtk.RESPONSE_DELETE_EVENT:
	    gtk.main_quit()
	if data == gtk.RESPONSE_CANCEL:
	    gtk.main_quit()
	if data == gtk.RESPONSE_OK:
	    self.tempfile = tempfile.NamedTemporaryFile()
	    if not self.SkipOddPages:
		# Print out odd pages
		# print self.filename
		os.system("pstops 2:0 "
		    + self.filename + " " + self.tempfile.name)
		self.printdialog.PrintJob = gtkunixprint.PrintJob(
		    "title",
		    self.printdialog.get_selected_printer(),
		    self.printdialog.get_settings(),
		    self.printdialog.get_page_setup())
		self.printdialog.PrintJob.set_source_file(self.tempfile.name)
		if Debug == 0:
		    self.printdialog.PrintJob.send(self.odd_pages_send_cb)
		# print "print"
        self.evenok.show()
	self.printdialog.hide()
	self.evenok_clicked = -1;

    def even_cancel_clicked_cb(self, widget, data=None):
	gtk.main_quit()

    def even_ok_clicked_cb(self, widget, data=None):
	printer = self.printdialog.get_selected_printer()
	if self.LongEdge == 1:
	    try:
		config = int(cp.get(printer.get_name(), 'long_edge_config', 0))
		#print printer.get_name(), config
	    except:
		config = self.long_edge_config
	else:
	    try:
		config = int(cp.get(printer.get_name(), 'short_edge_config', 0))
	    except:
		config = self.short_edge_config
	reverse = [ '1', '-1' ]
	invert = [ '', 'U(1w,1h)' ]
	os.system("pstops '2:" 
	    + reverse[(config>>1) & 1] + invert[config&1] + "' "
	    + self.filename + " " + self.tempfile.name)
	self.printdialog.PrintJob = gtkunixprint.PrintJob(
	    "title",
	    self.printdialog.get_selected_printer(),
	    self.printdialog.get_settings(),
	    self.printdialog.get_page_setup())
	self.printdialog.PrintJob.set_source_file(self.tempfile.name)
	if Debug == 0:
	    self.printdialog.PrintJob.send(self.even_pages_send_cb)
	self.evenok.hide()
	self.tempfile.close()

    def even_pages_send_cb(self, widget, data, errormsg):
	gtk.main_quit()
	return

if __name__ == "__main__":
    app = App()
    gtk.main()
