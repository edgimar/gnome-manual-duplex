#!/usr/bin/env python
 
import sys
import os
import tempfile

import pygtk
pygtk.require("2.0")
import gtk
import gtkunixprint

global Debug
Debug = 0
 
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

	self.printdialog = builder.get_object("printdialog1")
	self.evenok = builder.get_object("even-pages-ok")
	self.LongEdge = 1;
	builder.connect_signals(self)
	self.window.show()

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

    def print_cb(self, widget, data=None):
	self.window.hide()
        self.printdialog.show()

    def odd_pages_send_cb(self, widget, data, errormsg):
	return

    def printdialog1_response_cb(self, widget, data=None):
	# print "pclicked" , data
	if data == gtk.RESPONSE_DELETE_EVENT:
	    gtk.main_quit()
	if data == gtk.RESPONSE_CANCEL:
	    gtk.main_quit()
	if data == gtk.RESPONSE_OK:
	    # Print out odd pages
	    self.tempfile = tempfile.NamedTemporaryFile()
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
	if self.LongEdge == 1:
	    # Print out even pages in reverse order and flipped
	    os.system("pstops '2:-1U(1w,1h)' "
		+ self.filename + " " + self.tempfile.name)
	else:
	    # Print out even pages in reverse order
	    os.system("pstops '2:-1' "
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
