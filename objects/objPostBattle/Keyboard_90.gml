// Clean up leftover monster instances before drafts/options
with (objMonster) { instance_destroy() }
ProcessPostBattleQueue()
instance_destroy()
