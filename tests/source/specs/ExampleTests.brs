'@TestSuite [EXT] Example Tests

'@Setup
function EXT_setup() as void
    m.setupThing = "something created during setup"
end function

'+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
'@It tests methods present on the node
'+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++


'@Test onKeyEvent
function EXT__AssertFalse() as void
    m.AssertFalse(False)
end function

