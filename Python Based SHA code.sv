Python Based SHA code:
import struct
import sys
class SHA1:
"""SHA-1 hash implementation"""
def init (self):
# SHA-1 initial hash values
self.h0 = 0x67452301
self.h1 = 0xEFCDAB89
self.h2 = 0x98BADCFE
self.h3 = 0x10325476
self.h4 = 0xC3D2E1F0
def _left_rotate(self, n, b):
"""Left rotate a 32-bit integer n by b bits."""
return ((n << b) | (n >> (32 - b))) & 0xffffffff
def _f(self, t, b, c, d):
"""SHA-1 logical functions"""
if t < 20:
return (b & c) | ((~b) & d)
elif t < 40:
return b ^ c ^ d
elif t < 60:
return (b & c) | (b & d) | (c & d)
else:
return b ^ c ^ d
def _k(self, t):
"""SHA-1 constants"""
if t < 20:
return 0x5A827999
elif t < 40:
return 0x6ED9EBA1
elif t < 60:
return 0x8F1BBCDC
else:
return 0xCA62C1D6

def _pad_message(self, message):
"""Pad message according to SHA-1 specification"""
msg_len = len(message)
message += b'\x80' # Append bit '1' followed by zeros
# Pad with zeros until length ≡ 448 (mod 512) bits, or 56 (mod 64) bytes
while (len(message) % 64) != 56:
message += b'\x00'
# Append original message length in bits as 64-bit big-endian integer
message += struct.pack('>Q', msg_len * 8)
return message

def _process_chunk(self, chunk):
"""Process a single 512-bit chunk"""
# Break chunk into sixteen 32-bit big-endian words
w = list(struct.unpack('>16I', chunk))
# Extend the sixteen 32-bit words into eighty 32-bit words
for i in range(16, 80):
w.append(self._left_rotate(w[i-3] ^ w[i-8] ^ w[i-14] ^ w[i-16], 1))
# Initialize working variables
a = self.h0
b = self.h1
c = self.h2
d = self.h3
e = self.h4
# Main loop
for t in range(80):
temp = (self._left_rotate(a, 5) + self._f(t, b, c, d) +
e + self._k(t) + w[t]) & 0xffffffff
e = d
d = c
c = self._left_rotate(b, 30)
b = a
a = temp
# Add this chunk's hash to result so far
self.h0 = (self.h0 + a) & 0xffffffff
self.h1 = (self.h1 + b) & 0xffffffff
self.h2 = (self.h2 + c) & 0xffffffff
self.h3 = (self.h3 + d) & 0xffffffff
self.h4 = (self.h4 + e) & 0xffffffff
def update(self, message):
"""Update hash with new data"""
if isinstance(message, str):
message = message.encode('utf-8')
# Pad the message
padded_msg = self._pad_message(message)
# Process each 512-bit chunk
for i in range(0, len(padded_msg), 64):
self._process_chunk(padded_msg[i:i+64])

def digest(self):
"""Return the digest as bytes"""
return struct.pack('>5I', self.h0, self.h1, self.h2, self.h3, self.h4)

def hexdigest(self):
"""Return the digest as a hex string"""
return self.digest().hex()
def sha1(message):
"""Convenience function to compute SHA-1 hash"""
hasher = SHA1()
hasher.update(message)
return hasher.hexdigest()

def interactive_mode():
"""Interactive mode to hash custom messages"""
print("\n" + "=" * 70)
print(" SHA-1 Interactive Hash Tool")
print("=" * 70)
print("\nEnter messages to hash (type 'quit' or 'exit' to stop)")
print("Type 'test' to run test suite\n")
while True:
try:
user_input = input("Enter message: ").strip()
if user_input.lower() in ['quit', 'exit', 'q']:
print("\nGoodbye!")
break
if user_input.lower() == 'test':
run_tests()
continue
if not user_input:
print("Empty string detected")
# Compute hash
hash_result = sha1(user_input)
print(f"\n Message: '{user_input}'")
print(f" Length: {len(user_input)} bytes ({len(user_input) * 8} bits)")
print(f" SHA-1: {hash_result}")
print()
except KeyboardInterrupt:
print("\n\nInterrupted. Goodbye!")
break
except Exception as e:
print(f"Error: {e}")
def run_tests():
"""Run test suite"""
print("\n" + "=" * 70)
print(" SHA-1 Test Suite")
print("=" * 70)
test_vectors = [
("abc", "a9993e364706816aba3e25717850c26c9cd0d89d"),
("", "da39a3ee5e6b4b0d3255bfef95601890afd80709"),
("a", "86f7e437faa5a7fce15d1ddcb9eaeaea377667b8"),
("message digest", "c12252ceda8be8994d5fa0290a47231c1d16aae3"),
("abcdbcdecdefdefgefghfghighijhijkijkljklmklmnlmnomnopnopq",
"84983e441c3bd26ebaae4aa1f95129e5e54670f1"),
("The quick brown fox jumps over the lazy dog",
"2fd4e1c67a2d28fced849ee1bb76e7391b93eb12"),
("The quick brown fox jumps over the lazy cog",
"de9f2c7fd25e1b3afad3e85a0bd17d9b100db4b3"),
("Hello World", "0a4d55a8d778e5022fab701977c5d840bbc486d0"),
("password", "5baa61e4c9b93f3f0682250b6cf8331b7ee68fd8"),
]
all_passed = True
passed_count = 0
for message, expected in test_vectors:
result = sha1(message)
status = "PASS" if result == expected else " FAIL"
if result == expected:
passed_count += 1
else:
all_passed = False
display_msg = repr(message) if len(message) <= 40 else repr(message[:40]) + "..."
print(f"\nMessage: {display_msg}")
print(f"Got: {result}")
print(f"Expected: {expected}")
print(f"Status: {status}")
print("\n" + "=" * 70)
print(f"Results: {passed_count}/{len(test_vectors)} tests passed")
if all_passed:
print("All tests PASSED! ")
else:
print("Some tests FAILED! ") print()
def hash_from_args():
"""Hash messages from command line arguments"""
if len(sys.argv) < 2:
return False
# Check for special flags
if sys.argv[1] in ['-h', '--help']:
print_usage()
return True
if sys.argv[1] in ['-t', '--test']:
run_tests()
return True
# Hash all arguments
for message in sys.argv[1:]:
hash_result = sha1(message)
print(f"Message: '{message}'")
print(f"SHA-1: {hash_result}\n")
return True
def print_usage():
"""Print usage information"""
print("\nSHA-1 Hash Tool - Usage:")
print("=" * 70)
print("\n Interactive mode:")
print(" python sha1.py")
print("\n Hash command-line arguments:")
print(" python sha1.py 'message1' 'message2' ...")
print("\n Run test suite:")
print(" python sha1.py --test")
print(" python sha1.py -t")
print("\n Show help:")
print(" python sha1.py --help")
print(" python sha1.py -h")
print("\n" + "=" * 70)
if name == " main ":
# If command line arguments provided, use them
if not hash_from_args():
# Otherwise, enter interactive mode
interactive_mode()

