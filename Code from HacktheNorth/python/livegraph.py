import matplotlib.pyplot as plt
import matplotlib.animation as animation
import time
import collections
import numpy as np

fig = plt.figure()
ax1 = fig.add_subplot(1,1,1)
buffer = collections.deque( maxlen = 32)
for i in range( 0, 32):
    buffer.append(0)

ycount = 0
xar = np.arange(0,32)

def update( y):
    y = y + 1
    return y

def animate(i):
    animate.ycount = np.random.random_sample()
    buffer.append( animate.ycount)
    ax1.clear()
    ax1.plot( xar, list( buffer))
animate.ycount = 0

ani = animation.FuncAnimation(fig, animate, interval=100)
print("After ani")
plt.show()
