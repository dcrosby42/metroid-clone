SystemRegistry = require '../../ecs/system_registry'

Systems = new SystemRegistry()

Systems.register 'sprite_sync',     require('./sprite_sync_system')
Systems.register 'controller',      require('./controller_system')
Systems.register 'map_physics',     require('./map_physics')
Systems.register 'sound',           require('./sound_system')
Systems.register 'sound_sync',      require('./sound_sync_system')
Systems.register 'death_timer',     require('./death_timer_system')
Systems.register 'visual_timer',    require('./visual_timer_system')
Systems.register 'gravity',         require('./gravity_system')

Systems.register 'samus_motion',            require('../entity/samus/systems/samus_motion')
Systems.register 'samus_animation',         require('../entity/samus/systems/samus_animation')
Systems.register 'samus_controller_action', require('../entity/samus/systems/samus_controller_action')
Systems.register 'samus_action_sounds',     require('../entity/samus/systems/samus_action_sounds')
Systems.register 'samus_action_velocity',   require('../entity/samus/systems/samus_action_velocity')
Systems.register 'samus_viewport_tracker',  require('../entity/samus/systems/samus_viewport_tracker')
Systems.register 'samus_weapon',  require('../entity/samus/systems/samus_weapon')

Systems.register 'skree_action',  require('../entity/enemies/systems/skree_action')
Systems.register 'skree_velocity',  require('../entity/enemies/systems/skree_velocity')
Systems.register 'skree_animation',  require('../entity/enemies/systems/skree_animation')


module.exports = Systems

