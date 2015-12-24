ChunkDefs = []

# platform
ChunkDefs[0x09] = [
  [ 0, 7, 7, 0 ]
]

# platform
ChunkDefs[0x0A] = [
  [ 0, 7, 0 ]
]

# brinstar wall
ChunkDefs[0x0B] = [
  [ 6, 6 ]
  [ 1, 0 ]
  [ 0, 5 ]
  [ 5, 5 ]
  [ 0, 0 ]
]

# small steel platform
ChunkDefs[0x0c] = [
  [ 9, 9 ]
]

# Brinstar floor
ChunkDefs[0x10] = [
  [ 0, 4, 4, 4, 4, 0, 4, 4]
  [ 0, 0, 1, 1, 0, 0, 1, 0]
]

# Jagged roof
ChunkDefs[0x11] = [
  [ 1, 0, 0, 0, 0, 2, 0, 1]
  [ 0, 2, 3, 2, null, null, 0, 0]
  [ 0 ]
]

# steel pedastal (for ball)
ChunkDefs[0x15] = [
  [ 9 ]
  [ 9 ]
  [11 ]
  [11 ]
  [ 9 ]
]

# large steel platform
ChunkDefs[0x16] = [
  [ 9, 9, 9, 9, 9, 9, 9 ]
  [ 9,13, 9,12, 9,13, 9 ]
]

# skull-on-post
ChunkDefs[0x1D] = [
  [ 10 ]
  [ 12 ]
]

# big block
ChunkDefs[0x1E] = [
  [ 0, 7, 0, 0 ]
  [ 0, 1, 0, 5 ]
  [ 5, 0, 0, 0 ]
  [ 0, 0, 1, 0 ]
]

# big bush-block
ChunkDefs[0x1F] = [
  [ 8, 8, 8, 8 ]
  [ 8, 1, 1, 8 ]
  [ 1, 8, 1, 1 ]
  [ 8, 1, 8, 8 ]
]

# Door Stand-in
ChunkDefs[0xF0] = [
  [ 5 ]
  [ 5 ]
  [ 5 ]
]
  

module.exports = ChunkDefs


