ChunkDefs = []

# platform
ChunkDefs[0x0A] = [
  [ 0, 7, 0 ]
]
# platform
ChunkDefs[0x09] = [
  [ 0, 7, 7, 0 ]
]

# brinstar wall
ChunkDefs[0x0B] = [
  [ 6, 6 ]
  [ 1, 0 ]
  [ 0, 5 ]
  [ 5, 5 ]
  [ 0, 0 ]
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

# bush brick
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


