'@TestSuite [GLT] Globals Tests

'@Setup
function GLT_setup() as void
    
end function

'+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
'@It tests the ability to use the globals getter/setter
'+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++


'@Test Global Getter and Setter
'@Params["this", "that"]
'@Params["somenumber", 2342342]
function GLT__SetGetGlobals(key, value) as void
    setGlobal(key, value)
    m.assertEqual(getGlobal(key), value)
end function

