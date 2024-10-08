components {
  id: "slime"
  component: "/game/slime.script"
}
embedded_components {
  id: "sprite"
  type: "sprite"
  data: "default_animation: \"walk\"\n"
  "material: \"/builtins/materials/sprite.material\"\n"
  "textures {\n"
  "  sampler: \"texture_sampler\"\n"
  "  texture: \"/assets/images/enemies/baseballer.tilesource\"\n"
  "}\n"
  ""
  position {
    x: 10.0
    y: 14.0
  }
}
embedded_components {
  id: "collisionobject"
  type: "collisionobject"
  data: "type: COLLISION_OBJECT_TYPE_KINEMATIC\n"
  "mass: 0.0\n"
  "friction: 0.1\n"
  "restitution: 0.5\n"
  "group: \"enemy\"\n"
  "mask: \"player\"\n"
  "mask: \"bullet\"\n"
  "embedded_collision_shape {\n"
  "  shapes {\n"
  "    shape_type: TYPE_BOX\n"
  "    position {\n"
  "    }\n"
  "    rotation {\n"
  "    }\n"
  "    index: 0\n"
  "    count: 3\n"
  "  }\n"
  "  data: 10.0\n"
  "  data: 10.0\n"
  "  data: 10.0\n"
  "}\n"
  ""
}
