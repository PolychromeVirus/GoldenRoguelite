/// @func TickMonsterStatuses()
/// @desc Tick status resist timers for all living monsters. Called at end of each boss phase.
function TickMonsterStatuses() {
    with (objMonster) {
        if monsterHealth <= 0 { continue }
        if !boss { continue }  // only bosses tick here — regular enemies tick when they act
        if status_timer <= 0 { continue }
        status_timer--
        if status_timer == 0 {
            poison    = false
            venom     = false
            stun      = 0
            sleep     = false
            delude    = false
            psyseal   = false
            haunt     = 0
            lose_turn = false
            locked    = false
            mark      = false
            InjectLog(name + " shook off all status conditions!")
        }
    }
}
