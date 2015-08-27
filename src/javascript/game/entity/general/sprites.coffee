
sprites =
  main_title:
    spriteSheet: "images/general.json"
    states:
      main:
        frame: "main_title"

  creature_explosion:
    spriteSheet: "images/general.json"
    states:
      "explode":
        frames: [
          "creature_explode_a1"
          "blank"
          "creature_explode_a2"
          "blank"
        ]
        fps: 20
    props:
      anchor:
        x: 0.5
        y: 0.5

module.exports = sprites
