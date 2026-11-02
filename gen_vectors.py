import numpy as np 
A = np.array([[2,1,3],
              [1,4,2],
              [3,2,1]], dtype=np.int32)

x = np.array([1,2,3], dtype=np.int32)

y = x @ A 
print(y)

N = 3
rng = np.random.default_rng(2026)
Wr = rng.integers(-128, 128, size=(N,N), dtype=np.int32)
xr = rng.integers(-128, 128, size=N, dtype=np.int32)

def pack(values, bits):
    word = 0
    for j, v in enumerate(values):
        word |= (int(v) & ((1 << bits) - 1)) << (bits * j)
    return f"{word:0{len(values) * bits // 4}x}"

print(pack(A[0], 8))
print(pack(x @ A, 32))

B = np.array([[-1, 2, 0],
              [3, -2, 1],
              [1, 0, -3]], dtype=np.int32)

X = np.array([[1,2,3], [2,0,1], [0,3,1], [3,1,2], [1,1,1], [2,2,0], [0,1,3], [3,0,2], [1,3,0],
              [2,1,0], [1,2,1], [0,0,3], [3,2,1], [1,0,2], [2,3,1], [0,2,2], [1,1,3], [3,1,0]],
             dtype=np.int32)

EY = np.vstack([X[:9] @ A, X[9:] @ B])

def write_hex(name, rows, bits):
    with open(name, "w") as f:
        for r in rows:
            f.write(pack(r, bits) + "\n")

write_hex("tileA.hex", A, 8)
write_hex("tileB.hex", B, 8)
write_hex("iv.hex", X, 8)
write_hex("ey.hex", EY, 32)