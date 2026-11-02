import numpy as np 

def pack(values, bits):
    word = 0
    for j, v in enumerate(values):
        word |= (int(v) & ((1 << bits) - 1)) << (bits * j)
    return f"{word:0{len(values) * bits // 4}x}"

def write_hex(name, rows, bits):
    with open(name, "w") as f:
        for r in rows:
            f.write(pack(r, bits) + "\n")

N, T = 10, 1000                 
L = 3*N + 2                  
rng = np.random.default_rng(2026)

tiles = rng.integers(-128, 128, size=(T, N, N), dtype=np.int32) 
X     = rng.integers(-128, 128, size=(T*L, N), dtype=np.int32)    
S     = rng.integers(2*N - 2, L - N + 1, size=T)                  

tiles[0] = -128; X[0:L]     = -128   
tiles[1] =  127; X[L:2*L]   =  127    
tiles[2] = -128; X[2*L:3*L] =  127    

EY = np.vstack([X[t*L:(t+1)*L] @ tiles[t] for t in range(T)])

write_hex("tiles.hex", tiles.reshape(T*N, N), 8)
write_hex("iv.hex", X, 8)
write_hex("ey.hex", EY, 32)
with open("s.hex", "w") as f:
    for s in S:
        f.write(f"{int(s):02x}\n")

print("wrote", T, "blocks at N =", N)