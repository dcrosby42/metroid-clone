
sprites = {}
sprites =
  maru_mari:
    spriteSheet: "images/items.json"
    states:
      default:
        frame: "maru_mari"
    props:
      anchor:
        x: 0.5
        y: 0.5

  missile_container:
    spriteSheet: "images/items.json"
    states:
      default:
        frame: "missile_container"
    props:
      anchor:
        x: 0.5
        y: 0.5
#
#   health_drop:
#     spriteSheet: "images/general.json"
#     states:
#       default:
#         frames: [
#           "health_drop_01"
#           "health_drop_02"
#         ]
#         fps: 50
#         anchor:
#           x: 0.5
#           y: 0.5
#
#   creature_explosion:
#     spriteSheet: "images/general.json"
#     states:
#       "explode":
#         frames: [
#           "creature_explode_a1"
#           "blank"
#           "creature_explode_a2"
#           "blank"
#         ]
#         fps: 20
#     props:
#       anchor:
#         x: 0.5
#         y: 0.5

module.exports = sprites
