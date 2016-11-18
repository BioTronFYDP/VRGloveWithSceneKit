
# Copyright (c) 2015  Niklas Rosenstein
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

from __future__ import print_function

import myo as libmyo; libmyo.init()
import time
import sys
from msvcrt import getch

import collections
from scipy.signal import butter, lfilter
import numpy as np
import matplotlib.pyplot as plt
import matplotlib.animation as animation
from scipy.signal import freqz

# setup code for matplotlib liveplotting
print("setting up plotting code")
buffer = collections.deque( maxlen = 32)
#for i in range( 0, 32):
 #   buffer.append(0)
xar = np.arange(0,32)

def animate(i):
    #animate.ycount = np.random.random_sample()
    #buffer.append( animate.ycount)
    ax1.clear()
    ax1.plot( xar, list( buffer))
animate.ycount = 0

#fig = plt.figure()
#ax1 = fig.add_subplot(1,1,1)

#plt.axis([0, 10, 0, 1])
#plt.ion()

#plt.plot( xar, buffer)
#plt.pause(0.1)
# Sample rate and desired cutoff frequencies (in Hz).
fs = 200.0
lowcut = 2.0
order = 4

# -----------------------------------------------------------------#

def butter_bandpass(lowcut, highcut, fs, order=5):
    nyq = 0.5 * fs
    low = lowcut / nyq
    high = highcut / nyq
    b, a = butter(order, [low, high], btype='band')
    return b, a


def butter_bandpass_filter(data, lowcut, highcut, fs, order=5):
    b, a = butter_bandpass(lowcut, highcut, fs, order=order)
    y = lfilter(b, a, data)
    return y

def butter_lowpass(cutoff, fs, order=5):
    nyq = 0.5 * fs
    normal_cutoff = cutoff / nyq
    b, a = butter(order, normal_cutoff, btype='low', analog=False)
    return b, a

def butter_lowpass_filter(data, cutoff, fs, order=5):
    b, a = butter_lowpass(cutoff, fs, order=order)
    y = lfilter(b, a, data)
    return y
# -----------------------------------------------------------------#

b, a = butter_lowpass( lowcut, fs, order)

class Listener(libmyo.DeviceListener):
    """
    Listener implementation. Return False from any function to
    stop the Hub.
    """

    interval = 0.05  # Output only 0.05 seconds

    def __init__(self):
        super(Listener, self).__init__()
        self.orientation = None
        self.pose = libmyo.Pose.rest
        self.emg_enabled = True
        self.locked = False
        self.rssi = None
        self.emg = None
        self.last_time = 0
        #self.buffer = collections.deque( maxlen = 32)
        #for i in range( 0, 32):
        #    buffer.append(0)

    def output(self):
        ctime = time.time()
        if (ctime - self.last_time) < self.interval:
            return
        self.last_time = ctime

        parts = []
        if self.orientation:
            for comp in self.orientation:
                parts.append(str(comp).ljust(15))
        parts.append(str(self.pose).ljust(10))
        parts.append('E' if self.emg_enabled else ' ')
        parts.append('L' if self.locked else ' ')
        parts.append(self.rssi or 'NORSSI')
        if self.emg:
            for comp in self.emg:
                parts.append(str(comp).ljust(5))
        print('\r' + ''.join('[{0}]'.format(p) for p in parts), end='')
        sys.stdout.flush()

    def on_connect(self, myo, timestamp, firmware_version):
        myo.vibrate('short')
        myo.vibrate('short')
        myo.request_rssi()
        myo.request_battery_level()

    def on_rssi(self, myo, timestamp, rssi):
        self.rssi = rssi
        self.output()

    def on_pose(self, myo, timestamp, pose):
        if pose == libmyo.Pose.double_tap:
            myo.set_stream_emg(libmyo.StreamEmg.enabled)
            self.emg_enabled = True
        elif pose == libmyo.Pose.fingers_spread:
            myo.set_stream_emg(libmyo.StreamEmg.disabled)
            self.emg_enabled = False
            self.emg = None
        self.pose = pose
        #self.output()

    def on_orientation_data(self, myo, timestamp, orientation):
        self.orientation = orientation
        #self.output()

    def on_accelerometor_data(self, myo, timestamp, acceleration):
        pass

    def on_gyroscope_data(self, myo, timestamp, gyroscope):
        pass

    def on_emg_data(self, myo, timestamp, emg):
        self.emg = emg
        #self.output()
        #self.buffer.append( emg)
        #print( list(self.buffer)[0])
        buffer.append( emg[0])
        print( emg[0])


    def on_unlock(self, myo, timestamp):
        self.locked = False
        self.output()

    def on_lock(self, myo, timestamp):
        self.locked = True
        self.output()

    def on_event(self, kind, event):
        """
        Called before any of the event callbacks.
        """

    def on_event_finished(self, kind, event):
        """
        Called after the respective event callbacks have been
        invoked. This method is *always* triggered, even if one of
        the callbacks requested the stop of the Hub.
        """

    def on_pair(self, myo, timestamp, firmware_version):
        """
        Called when a Myo armband is paired.
        """

    def on_unpair(self, myo, timestamp):
        """
        Called when a Myo armband is unpaired.
        """

    def on_disconnect(self, myo, timestamp):
        """
        Called when a Myo is disconnected.
        """

    def on_arm_sync(self, myo, timestamp, arm, x_direction, rotation,
                    warmup_state):
        """
        Called when a Myo armband and an arm is synced.
        """

    def on_arm_unsync(self, myo, timestamp):
        """
        Called when a Myo armband and an arm is unsynced.
        """

    def on_battery_level_received(self, myo, timestamp, level):
        """
        Called when the requested battery level received.
        """

    def on_warmup_completed(self, myo, timestamp, warmup_result):
        """
        Called when the warmup completed.
        """
    
    def get_emg(self):
        return self.emg

print("Connecting to Myo ... Use CTRL^C to exit.")

#ani = animation.FuncAnimation(fig, animate, interval=100)
#plt.show()

hub = libmyo.Hub()
hub.set_locking_policy(libmyo.LockingPolicy.none)
ldev = Listener()

hub.run(1000, ldev)
while hub.running and ldev.connected:
    #time.sleep(0.25)
    #print( buffer)
    time.sleep(0.05)
hub.stop()


hub.shutdown()


if 0:

    hub.run(1000, ldev)

#ani = animation.FuncAnimation(fig, animate, interval=100)
#plt.show()

# Listen to keyboard interrupts and stop the hub in that case.
    while hub.running and ldev.connected:
        key = ord(getch())
        if key == 27:
            break
        time.sleep(0.05)
        print("shutting down")
    hub.shutdown()
    sys.exit("Error message")
