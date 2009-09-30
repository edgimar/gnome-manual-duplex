#!/usr/bin/python
# -*- coding: UTF-8 -*-

# Copyright 2006-2007 (C) Raster Software Vigo (Sergio Costas)
# Copyright 2009 (C) Rick Richardson
#
# This file is part of Gnome Manual Duplex (GMD)
#
# GMD is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.
#
# GMD is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

import pygtk
pygtk.require('2.0')

import os
import time
import sys
import select
import subprocess
import pwd

needed=""

try:
	import gamin
except :
	needed+="python-gamin\n"

try:
	import gtk
except:
	needed+="python-gtk2\n"

try:
	import gnomeapplet
except:
	needed+="python-gnome2-desktop\n"
	
try:
	import gobject
except:
	needed+="python-gobject\n"


def send_error(message):

	try:
		fichero=open("/var/tmp/gmd/error.log","a")
	except:
		return
		
	fichero.write(str(pwd.getpwuid(os.getuid())[0])+": "+message+"\n")
	fichero.close()


def read_line(fichero):

	linea=fichero.readline()
	if linea[-1]=='\n':
		linea=linea[:-1]
	return linea


def launch_gmd(filename):

	global directory

	time.sleep(1) # wait one second to ensure that the file is fully wrote
	try:
		fichero=open(directory+"/list/"+filename,"r");
	except IOError:
		send_error("Error de E/S")
		return
	newfile=read_line(fichero)
	if (-1!=newfile.find("/")): # don't allow the '/' in the filename to avoid security issues
		send_error( "Has /: "+newfile)
		return
	print directory+"/"+newfile
	title2=read_line(fichero)
	
	title=""
	for letra in title2:
		if letra=='"':
			title+="'"
		elif letra=='\\':
			title+='/'
		else:
			title+=letra
	print title
	copies=read_line(fichero)
	fichero.close()
	print copies
	
	#comando='/usr/bin/gnome-manual-duplex -T "'+title+'" -# '+copies+' "'+directory+"/"+newfile+'"'
	comando='/usr/bin/gnome-manual-duplex "' + directory + "/" + newfile + '"'
	send_error(comando)
	p=subprocess.Popen(comando,shell=True,bufsize=32768)
	p.wait()
	
	comando='rm -f "'+directory+"/"+newfile+'" "'+directory+"/list/"+filename+'"'
	p=subprocess.Popen(comando,shell=True,bufsize=32768)
	p.wait()

def read_event2(path,event):

	global fc
	
	print "path: "+str(path)+" event: "+str(event)
	if (event==5): # new file created
		launch_gmd(path)
		
	return True

def read_event(path,event):

	global fc
	
	print "path: "+str(path)+" event: "+str(event)

	ret = fc.event_pending()
	if ret>0:
		fc.handle_one_event()
		fc.handle_events()
	return True


def init_scan():

	global fc
	global directory
	global evento
	global request

	try:
		directory="/var/tmp/gmd/"+str(pwd.getpwuid(os.getuid())[0])
	except :
		send_error("Failed to get the UID")
		return gtk.FALSE

	# erase the directory to ensure that there are no spare works
	p=subprocess.Popen("rm -rf "+directory,shell=True,bufsize=32768)
	p.wait()

	try:
		os.makedirs(directory+"/list")
	except OSError:
		pass
		
	# set priviliges to RWX-WX-WX, to allow everybody to write into it, but
	# only the user to read, to preserve privacy
	
	p=subprocess.Popen("chmod 733 "+directory,shell=True,bufsize=32768)
	p.wait()
	p=subprocess.Popen("chmod 733 "+directory+"/list",shell=True,bufsize=32768)
	p.wait()
	
	fc=gamin.WatchMonitor()
	
	if (fc==None):
		send_error("Failed to create a GAMIN session. Check that the GAMIN daemon is running\n")
	
	request=fc.watch_directory(directory+"/list",read_event2)
		
	if (request==None):
		send_error("Failed to create a GAMIN request. Check that the GAMIN daemon is running\n")

	evento=gobject.io_add_watch(fc.get_fd(),gobject.IO_IN,read_event)
	
	if (evento==None):
		send_error("Failed to create a FAM event. Check that the FAM daemon is running\n")


def wdelete_event(widget, event, data=None):
	
	return False

	
def wdestroy(widget, data=None):
	
	sys.exit(0)


def factory(applet, iid):

	global needed
	global window

	label = gtk.Label("GMD")
	frame = gtk.Frame()
	frame.add(label)
	applet.add(frame)
	frame.set_shadow_type(gtk.SHADOW_ETCHED_IN)
	applet.show_all()
	check_needed()


def check_needed():

	global needed

	os.system(
	    'lpadmin -p GnomeManualDuplex -E -v gmd:/ -L "Virtual Printer"')

	if needed=="":
		init_scan()
	else:
		window=gtk.Window(gtk.WINDOW_TOPLEVEL)
		window.set_title("Error, module not found")
		window.connect("delete_event", wdelete_event)
		window.connect("destroy", wdestroy)
		window.set_border_width(10)
		button = gtk.Button("Ok")
		button.connect("clicked", wdestroy, None)
		label = gtk.Label("You need to install the followin python modules in order to use GMD:\n\n"+needed)
		box=gtk.VBox()
		window.add(box)
		box.add(label)
		box.add(button)
		button.show()
		label.show()
		box.show()
		window.show()
	
	return gtk.TRUE


fc=None
request=None
evento=None
directory=""
window=None

if (len(sys.argv) == 2) and (sys.argv[1] == "standalone"):
	check_needed()
	gtk.main()
else:
	gnomeapplet.bonobo_factory("OAFIID:GNOME_GMD_applet_Factory",gnomeapplet.Applet.__gtype__,"GMD","3",factory)
