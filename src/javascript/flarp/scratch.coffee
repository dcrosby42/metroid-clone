PostOffice = require './post_office'
po = new PostOffice()

pem=po.newMailbox()
aem=po.newMailbox()
dtm=po.newMailbox()

player = pem.signal
admin = aem.signal
dt = dtm.signal

b = player
  .merge(admin)
  .merge(dt)
  .bundleOn(dt)

b.subscribe (v) -> console.log("Bundle:",v)

# ef = es.bundleOn(dts.signal)
#
# ef.subscribe (v) -> console.log("fold:",v)

dtm.address.send "t1"
pem.address.send "p1"
aem.address.send "a1"
pem.address.send "p2"

po.sync()


pem.address.send "p3"
dtm.address.send "t2"
po.sync()
