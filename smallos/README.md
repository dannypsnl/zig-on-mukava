# smallos

```shell
# build kernel
zig build-exe kernel.zig -target i386-freestanding -T linker.ld
# run up
qemu-system-i386 -kernel kernel
```
