vein = Vein.create()
vein.on 'ready', (services) ->
  console.log "Connected - Available services: #{services}"
  vein.add 1, 2, 3, 4, (res) ->
    console.log res