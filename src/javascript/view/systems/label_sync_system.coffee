PIXI = require 'pixi.js'
ViewObjectSyncSystem = require "../view_object_sync_system"

StyleDefaults =
  font: "normal 10pt Arial"
  fill: "white"

class LabelSyncSystem extends ViewObjectSyncSystem
  @Subscribe: ['label', 'position']
  @SyncComponent: 'label'
  # @CacheName: 'label'
  # @Ident: ['label', 'cid']

  newObject: (comps) ->
    labelComp = comps.get('label')
    textContent = labelComp.get('content')
    style =
      font: labelComp.get('font', StyleDefaults.font)
      fill: labelComp.get('fill_color', StyleDefaults.fill)

    label = new PIXI.Text(textContent, style)
    @ui.addObjectToLayer(label, labelComp.get('layer'))
    label

  updateObject: (comps, label) ->
    labelComp = comps.get('label')
    position = comps.get('position')
    content = labelComp.get('content')
    visible = labelComp.get('visible')
    x = position.get('x')
    y = position.get('y')

    if x != label.position.x or y != label.position.y
      label.position.set x,y

    if content != label.text
      label.setText(content)

    if visible != label.visible
      label.visible = visible


module.exports = LabelSyncSystem

