import serial #PySerial
import time
import termios, fcntl, sys, os

ser = serial.Serial('/dev/cu.usbmodem1411', 9600)

fd = sys.stdin.fileno()

oldterm = termios.tcgetattr(fd)
newattr = termios.tcgetattr(fd)
newattr[3] = newattr[3] & ~termios.ICANON & ~termios.ECHO
termios.tcsetattr(fd, termios.TCSANOW, newattr)

oldflags = fcntl.fcntl(fd, fcntl.F_GETFL)
fcntl.fcntl(fd, fcntl.F_SETFL, oldflags | os.O_NONBLOCK)

try:
	while 1:
		try:
			userInput = sys.stdin.read(1)
			if userInput is not None:
				print "Got character", repr(userInput)
				ser.write(userInput)

				if userInput == "c":
					break
				
		except IOError: pass
finally:
	termios.tcsetattr(fd, termios.TCSAFLUSH, oldterm)
	fcntl.fcntl(fd, fcntl.F_SETFL, oldflags)