
RoomDefs = []



# Skree hall, door on left
RoomDefs[0x12] =
  chunks: [
    [0x0,0x0, 0x0B]
    # [0x0,0x5, 0xF0] # XXX stand-in for the door
    [0x0,0x8, 0x0B]
    [0x2,0x8, 0x0A]
    [0x2,0x0, 0x11]
    [0xA,0x0, 0x11]
    [0x0,0xD, 0x10]
    [0x8,0xD, 0x10]
  ]
  enemies: [
    [0x9,0x2, 'basicSkree']
    [0xA,0x3, 'basicSkree']
    [0xE,0x1, 'basicSkree']
    [0x7,0xC, 'basicZoomer']
    [0xB,0xC, 'basicZoomer']
  ]
  items: [
  ]

# hall, door on right
RoomDefs[0x13] =
  chunks: [
    [0x0,0x0, 0x11]
    [0x8,0x0, 0x10]

    [0x0,0xD, 0x10] # floor
    [0x8,0xD, 0x10]
    [0xA,0x8, 0x09] # platform
    [0xE,0x0, 0x0B] # right wall up
    [0xE,0x8, 0x0B]
    # [0xF,0x5, 0xF0] # XXX stand-in for the door
  ]
  items: [
  ]

# Skree hall
RoomDefs[0x14] =
  chunks: [
    [0x0,0x0, 0x11]
    [0x8,0x0, 0x11]
    [0x0,0xD, 0x10]
    [0x8,0xD, 0x10]
  ]
  enemies: [
    [0x4,0x1, 'basicSkree'] # skree
    [0x8,0x3, 'basicSkree']
    [0xE,0x2, 'basicSkree']
  ]

# bush tunnel
RoomDefs[0x19] =
  chunks: [
    [0x0,0x0, 0x10]
    [0x4,0x0, 0x1F]
    [0x8,0x0, 0x1F]
    [0xC,0x0, 0x11]

    [0x4,0x4, 0x1F]
    [0x8,0x4, 0x1F]
    [0x4,0x7, 0x1F] # TODO: y should be 8 once we can morph ball
    [0x8,0x7, 0x1F] # TODO: y should be 8 once we can morph ball

    [0x0,0xD, 0x1F]
    [0x4,0xD, 0x1F]
    [0x8,0xD, 0x10]
  ]
  items: [
  ]

module.exports = RoomDefs
