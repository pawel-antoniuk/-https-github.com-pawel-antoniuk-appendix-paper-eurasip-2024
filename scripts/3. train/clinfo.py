import pyopencl as cl
p=cl.get_platforms()
print(p[0].get_devices())