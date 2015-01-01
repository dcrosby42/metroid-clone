SystemRegistry = require '../../ecs/system_registry'

Systems = new SystemRegistry()

Systems.register 'sprite_sync',     require('./sprite_sync_system')
Systems.register 'controller',      require('./controller_system')
#XXX Systems.register 'movement',        require('./movement_system')

Systems.register 'samus_motion',    require('../entity/samus/systems/samus_motion')
Systems.register 'samus_animation', require('../entity/samus/systems/samus_animation')
Systems.register 'samus_controller_action', require('../entity/samus/systems/samus_controller_action')

module.exports = Systems

