SystemRegistry = require '../../ecs/system_registry'

Systems = new SystemRegistry()

Systems.register 'sprite_sync',     require('./sprite_sync_system')
Systems.register 'controller',      require('./controller_system')
Systems.register 'samus_motion',    require('./samus_motion_system')
Systems.register 'samus_animation', require('./samus_animation_system')
Systems.register 'movement',        require('./movement_system')

module.exports = Systems

