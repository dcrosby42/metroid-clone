PIXI = require 'pixi.js'
ViewObjectSyncSystem = require "../view_object_sync_system"
C = require '../../components'
T = C.Types

StyleDefaults =
  font: "normal 10pt Arial"
  fill: "white"

class LabelSyncSystem extends ViewObjectSyncSystem
  @Subscribe: [ T.Label, T.Position ]
  @SyncComponentInSlot: 0
  @CacheName: 'label'

  newObject: (r) ->
    [labelComp] = r.comps
    textContent = labelComp.content
    style = {
      font: labelComp.font
      fill: labelComp.fill_color
    }
    style.font ?= StyleDefaults.font
    style.fill ?= StyleDefaults.fill

    label = new PIXI.Text(textContent, style)
    label._name = "Label '#{textContent}'"
    @uiState.addObjectToLayer(label, labelComp.layer)
    label

  updateObject: (r, label) ->
    [labelComp,position] = r.comps
    content = labelComp.content
    visible = labelComp.visible
    x = position.x
    y = position.y

    if x != label.position.x or y != label.position.y
      label.position.set x,y

    if content != label.text
      label.setText(content)

    if visible != label.visible
      label.visible = visible


module.exports = -> new LabelSyncSystem()

