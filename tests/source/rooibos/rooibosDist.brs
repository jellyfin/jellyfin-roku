'/**
' * rooibos - simple, flexible, fun brightscript test framework for roku scenegraph apps
' * @version v2.3.0
' * @link https://github.com/georgejecook/rooibos#readme
' * @license MIT
' */
function Rooibos__Init(preTestSetup = invalid,  testUtilsDecoratorMethodName = invalid, testSceneName = invalid, nodeContext = invalid) as void
  args = {}
  if createObject("roAPPInfo").IsDev() <> true then
    ? " not running in dev mode! - rooibos tests only support sideloaded builds - aborting"
    return
  end if
  args.testUtilsDecoratorMethodName = testUtilsDecoratorMethodName
  args.nodeContext = nodeContext
  screen = CreateObject("roSGScreen")
  m.port = CreateObject("roMessagePort")
  screen.setMessagePort(m.port)
  if testSceneName = invalid
    testSceneName = "TestsScene"
  end if
  ? "Starting test using test scene with name TestsScene" ; testSceneName
  scene = screen.CreateScene(testSceneName)
  scene.id = "ROOT"
  screen.show()
  m.global = screen.getGlobalNode()
  m.global.addFields({"testsScene": scene})
  if (preTestSetup <> invalid)
    preTestSetup(screen)
  end if
  testId = args.TestId
  if (testId = invalid)
    testId = "UNDEFINED_TEST_ID"
  end if
  ? "#########################################################################"
  ? "#TEST START : ###" ; testId ; "###"
  args.testScene = scene
  args.global = m.global
  runner = RBS_TR_TestRunner(args)
  runner.Run()
  while(true)
    msg = wait(0, m.port)
    msgType = type(msg)
    if msgType = "roSGScreenEvent"
      if msg.isScreenClosed()
        return
      end if
    end if
  end while
end function
function BaseTestSuite() as object
  this = {}
  this.Name               = "BaseTestSuite"
  this.invalidValue = "#ROIBOS#INVALID_VALUE" ' special value used in mock arguments
  this.ignoreValue = "#ROIBOS#IGNORE_VALUE" ' special value used in mock arguments
  this.allowNonExistingMethodsOnMocks = true
  this.isAutoAssertingMocks = true
  this.TestCases = []
  this.AddTest            = RBS_BTS_AddTest
  this.CreateTest           = RBS_BTS_CreateTest
  this.GetLegacyCompatibleReturnValue = RBS_BTS_GetLegacyCompatibleReturnValue
  this.Fail               = RBS_BTS_Fail
  this.AssertFalse          = RBS_BTS_AssertFalse
  this.AssertTrue           = RBS_BTS_AssertTrue
  this.AssertEqual          = RBS_BTS_AssertEqual
  this.AssertLike           = RBS_BTS_AssertLike
  this.AssertNotEqual         = RBS_BTS_AssertNotEqual
  this.AssertInvalid          = RBS_BTS_AssertInvalid
  this.AssertNotInvalid         = RBS_BTS_AssertNotInvalid
  this.AssertAAHasKey         = RBS_BTS_AssertAAHasKey
  this.AssertAANotHasKey        = RBS_BTS_AssertAANotHasKey
  this.AssertAAHasKeys        = RBS_BTS_AssertAAHasKeys
  this.AssertAANotHasKeys       = RBS_BTS_AssertAANotHasKeys
  this.AssertArrayContains      = RBS_BTS_AssertArrayContains
  this.AssertArrayNotContains     = RBS_BTS_AssertArrayNotContains
  this.AssertArrayContainsSubset    = RBS_BTS_AssertArrayContainsSubset
  this.AssertArrayContainsAAs     = RBS_BTS_AssertArrayContainsAAs
  this.AssertArrayNotContainsSubset   = RBS_BTS_AssertArrayNotContainsSubset
  this.AssertArrayCount         = RBS_BTS_AssertArrayCount
  this.AssertArrayNotCount      = RBS_BTS_AssertArrayNotCount
  this.AssertEmpty          = RBS_BTS_AssertEmpty
  this.AssertNotEmpty         = RBS_BTS_AssertNotEmpty
  this.AssertArrayContainsOnlyValuesOfType    = RBS_BTS_AssertArrayContainsOnlyValuesOfType
  this.AssertType           = RBS_BTS_AssertType
  this.AssertSubType        = RBS_BTS_AssertSubType
  this.AssertNodeCount         = RBS_BTS_AssertNodeCount
  this.AssertNodeNotCount      = RBS_BTS_AssertNodeNotCount
  this.AssertNodeEmpty        = RBS_BTS_AssertNodeEmpty
  this.AssertNodeNotEmpty      = RBS_BTS_AssertNodenotEmpty
  this.AssertNodeContains      = RBS_BTS_AssertNodeContains
  this.AssertNodeNotContains     = RBS_BTS_AssertNodeNotContains
  this.AssertNodeContainsFields    = RBS_BTS_AssertNodeContainsFields
  this.AssertNodeNotContainsFields   = RBS_BTS_AssertNodeNotContainsFields
  this.AssertAAContainsSubset   = RBS_BTS_AssertAAContainsSubset
  this.EqValues             = RBS_BTS_EqValues
  this.EqAssocArrays          = RBS_BTS_EqAssocArray
  this.EqArray             = RBS_BTS_EqArray
  this.Stub       = RBS_BTS_Stub
  this.Mock       = RBS_BTS_Mock
  this.AssertMocks    = RBS_BTS_AssertMocks
  this.CreateFake     = RBS_BTS_CreateFake
  this.CombineFakes     = RBS_BTS_CombineFakes
  this.MockFail     = RBS_BTS_MockFail
  this.CleanMocks     = RBS_BTS_CleanMocks
  this.CleanStubs     = RBS_BTS_CleanStubs
  this.ExpectOnce         = RBS_BTS_ExpectOnce
  this.ExpectNone         = RBS_BTS_ExpectNone
  this.Expect             = RBS_BTS_Expect
  this.ExpectOnceOrNone   = RBS_BTS_ExpectOnceOrNone
  this.MockCallback0     = RBS_BTS_MockCallback0
  this.MockCallback1     = RBS_BTS_MockCallback1
  this.MockCallback2     = RBS_BTS_MockCallback2
  this.MockCallback3     = RBS_BTS_MockCallback3
  this.MockCallback4     = RBS_BTS_MockCallback4
  this.MockCallback5     = RBS_BTS_MockCallback5
  this.StubCallback0     = RBS_BTS_StubCallback0
  this.StubCallback1     = RBS_BTS_StubCallback1
  this.StubCallback2     = RBS_BTS_StubCallback2
  this.StubCallback3     = RBS_BTS_StubCallback3
  this.StubCallback4     = RBS_BTS_StubCallback4
  this.StubCallback5     = RBS_BTS_StubCallback5
  this.pathAsArray_ = RBS_BTS_rodash_pathsAsArray_
  this.g = RBS_BTS_rodash_get_
  return this
end function
sub RBS_BTS_AddTest(name, func,funcName, setup = invalid, teardown = invalid)
  m.testCases.Push(m.createTest(name, func, setup, teardown))
end sub
function RBS_BTS_CreateTest(name, func, funcName, setup = invalid, teardown = invalid ) as object
  if (func = invalid)
    ? " ASKED TO CREATE TEST WITH INVALID FUNCITON POINTER FOR FUNCTION " ; funcName
  end if
  return {
    Name: name
    Func: func
    FuncName: funcName
    SetUp: setup
    TearDown: teardown
  }
end function
function RBS_BTS_Fail(msg = "Error" ) as dynamic
  if (m.currentResult.isFail) then return m.GetLegacyCompatibleReturnValue(false) ' skip test we already failed
  m.currentResult.AddResult(msg)
  return m.GetLegacyCompatibleReturnValue(false)
end function
function RBS_BTS_GetLegacyCompatibleReturnValue(value) as object
  if (value = true)
    if (m.isLegacy = true)
      return ""
    else
      return true
    end if
  else
    if (m.isLegacy = true)
      return "ERROR"
    else
      return false
    end if
  end if
end function
function RBS_BTS_AssertFalse(expr , msg = "Expression evaluates to true" ) as dynamic
  if (m.currentResult.isFail) then return m.GetLegacyCompatibleReturnValue(false) ' skip test we already failed
  if not RBS_CMN_IsBoolean(expr) or expr
    m.currentResult.AddResult(msg)
    return m.fail(msg)
  end if
  m.currentResult.AddResult("")
  return m.GetLegacyCompatibleReturnValue(true)
end function
function RBS_BTS_AssertTrue(expr , msg = "Expression evaluates to false" ) as dynamic
  if (m.currentResult.isFail) then return m.GetLegacyCompatibleReturnValue(false) ' skip test we already failed
  if not RBS_CMN_IsBoolean(expr) or not expr then
    m.currentResult.AddResult(msg)
    return m.GetLegacyCompatibleReturnValue(false)
  end if
  m.currentResult.AddResult("")
  return m.GetLegacyCompatibleReturnValue(true)
end function
function RBS_BTS_AssertEqual(first , second , msg = "" ) as dynamic
  if (m.currentResult.isFail) then return m.GetLegacyCompatibleReturnValue(false) ' skip test we already failed
  if not m.eqValues(first, second)
    if msg = ""
      first_as_string = RBS_CMN_AsString(first)
      second_as_string = RBS_CMN_AsString(second)
      msg = first_as_string + " != " + second_as_string
    end if
    m.currentResult.AddResult(msg)
    return m.GetLegacyCompatibleReturnValue(false)
  end if
  m.currentResult.AddResult("")
  return m.GetLegacyCompatibleReturnValue(true)
end function
function RBS_BTS_AssertLike(first , second , msg = "" ) as dynamic
  if (m.currentResult.isFail) then return m.GetLegacyCompatibleReturnValue(false) ' skip test we already failed
  if first <> second
    if msg = ""
      first_as_string = RBS_CMN_AsString(first)
      second_as_string = RBS_CMN_AsString(second)
      msg = first_as_string + " != " + second_as_string
    end if
    m.currentResult.AddResult(msg)
    return m.GetLegacyCompatibleReturnValue(false)
  end if
  m.currentResult.AddResult("")
  return m.GetLegacyCompatibleReturnValue(true)
end function
function RBS_BTS_AssertNotEqual(first , second , msg = "" ) as dynamic
  if (m.currentResult.isFail) then return m.GetLegacyCompatibleReturnValue(false) ' skip test we already failed
  if m.eqValues(first, second)
    if msg = ""
      first_as_string = RBS_CMN_AsString(first)
      second_as_string = RBS_CMN_AsString(second)
      msg = first_as_string + " == " + second_as_string
    end if
    m.currentResult.AddResult(msg)
    return m.GetLegacyCompatibleReturnValue(false)
  end if
  m.currentResult.AddResult("")
  return m.GetLegacyCompatibleReturnValue(true)
end function
function RBS_BTS_AssertInvalid(value , msg = "" ) as dynamic
  if (m.currentResult.isFail) then return m.GetLegacyCompatibleReturnValue(false) ' skip test we already failed
  if value <> invalid
    if msg = ""
      expr_as_string = RBS_CMN_AsString(value)
      msg = expr_as_string + " <> Invalid"
    end if
    m.currentResult.AddResult(msg)
    return m.GetLegacyCompatibleReturnValue(false)
  end if
  m.currentResult.AddResult("")
  return m.GetLegacyCompatibleReturnValue(true)
end function
function RBS_BTS_AssertNotInvalid(value , msg = "" ) as dynamic
  if (m.currentResult.isFail) then return m.GetLegacyCompatibleReturnValue(false) ' skip test we already failed
  if value = invalid
    if msg = ""
      expr_as_string = RBS_CMN_AsString(value)
      msg = expr_as_string + " = Invalid"
    end if
    m.currentResult.AddResult(msg)
    return m.GetLegacyCompatibleReturnValue(false)
  end if
  m.currentResult.AddResult("")
  return m.GetLegacyCompatibleReturnValue(true)
end function
function RBS_BTS_AssertAAHasKey(array , key , msg = "" ) as dynamic
  if (m.currentResult.isFail) then return m.GetLegacyCompatibleReturnValue(false) ' skip test we already failed
  if RBS_CMN_IsAssociativeArray(array)
    if not array.DoesExist(key)
      if msg = ""
        msg = "Array doesn't have the '" + key + "' key."
      end if
      m.currentResult.AddResult(msg)
      return m.GetLegacyCompatibleReturnValue(false)
    end if
  else
    msg = "Input value is not an Associative Array."
    m.currentResult.AddResult(msg)
    return m.GetLegacyCompatibleReturnValue(false)
  end if
  m.currentResult.AddResult("")
  return m.GetLegacyCompatibleReturnValue(true)
end function
function RBS_BTS_AssertAANotHasKey(array , key , msg = "" ) as dynamic
  if (m.currentResult.isFail) then return m.GetLegacyCompatibleReturnValue(false) ' skip test we already failed
  if RBS_CMN_IsAssociativeArray(array)
    if array.DoesExist(key)
      if msg = ""
        msg = "Array has the '" + key + "' key."
      end if
      m.currentResult.AddResult(msg)
      return m.GetLegacyCompatibleReturnValue(false)
    end if
  else
    msg = "Input value is not an Associative Array."
    m.currentResult.AddResult(msg)
    return m.GetLegacyCompatibleReturnValue(false)
  end if
  m.currentResult.AddResult("")
  return m.GetLegacyCompatibleReturnValue(true)
end function
function RBS_BTS_AssertAAHasKeys(array , keys , msg = "" ) as dynamic
  if (m.currentResult.isFail) then return m.GetLegacyCompatibleReturnValue(false) ' skip test we already failed
  if RBS_CMN_IsAssociativeArray(array) and RBS_CMN_IsArray(keys)
    for each key in keys
      if not array.DoesExist(key)
        if msg = ""
          msg = "Array doesn't have the '" + key + "' key."
        end if
        m.currentResult.AddResult(msg)
        return m.GetLegacyCompatibleReturnValue(false)
      end if
    end for
  else
    msg = "Input value is not an Associative Array."
    m.currentResult.AddResult(msg)
    return m.GetLegacyCompatibleReturnValue(false)
  end if
  m.currentResult.AddResult("")
  return m.GetLegacyCompatibleReturnValue(true)
end function
function RBS_BTS_AssertAANotHasKeys(array , keys , msg = "" ) as dynamic
  if (m.currentResult.isFail) then return m.GetLegacyCompatibleReturnValue(false) ' skip test we already failed
  if RBS_CMN_IsAssociativeArray(array) and RBS_CMN_IsArray(keys)
    for each key in keys
      if array.DoesExist(key)
        if msg = ""
          msg = "Array has the '" + key + "' key."
        end if
        m.currentResult.AddResult(msg)
        return m.GetLegacyCompatibleReturnValue(false)
      end if
    end for
  else
    msg = "Input value is not an Associative Array."
    m.currentResult.AddResult(msg)
    return m.GetLegacyCompatibleReturnValue(false)
  end if
  m.currentResult.AddResult("")
  return m.GetLegacyCompatibleReturnValue(true)
end function
function RBS_BTS_AssertArrayContains(array , value , key = invalid , msg = "" ) as dynamic
  if (m.currentResult.isFail) then return m.GetLegacyCompatibleReturnValue(false) ' skip test we already failed
  if RBS_CMN_IsAssociativeArray(array) or RBS_CMN_IsArray(array)
    if not RBS_CMN_ArrayContains(array, value, key)
      msg = "Array doesn't have the '" + RBS_CMN_AsString(value) + "' value."
      m.currentResult.AddResult(msg)
      return m.GetLegacyCompatibleReturnValue(false)
    end if
  else
    msg = "Input value is not an Array."
    m.currentResult.AddResult(msg)
    return m.GetLegacyCompatibleReturnValue(false)
  end if
  m.currentResult.AddResult("")
  return m.GetLegacyCompatibleReturnValue(true)
end function
function RBS_BTS_AssertArrayContainsAAs(array , values , msg = "" ) as dynamic
  if (m.currentResult.isFail) then return m.GetLegacyCompatibleReturnValue(false) ' skip test we already failed
  if not RBS_CMN_IsArray(values)
    msg = "values to search for are not an Array."
    m.currentResult.AddResult(msg)
    return m.GetLegacyCompatibleReturnValue(false)
  end if
  if RBS_CMN_IsArray(array)
    for each value in values
      isMatched = false
      if not RBS_CMN_IsAssociativeArray(value)
        msg = "Value to search for was not associativeArray "+  RBS_CMN_AsString(value)
        m.currentResult.AddResult(msg)
        return m.GetLegacyCompatibleReturnValue(false)
      end if
      for each item in array
        if (RBS_CMN_IsAssociativeArray(item))
          isValueMatched = true
          for each key in value
            fieldValue = value[key]
            itemValue = item[key]
            if (not m.EqValues(fieldValue, itemValue))
              isValueMatched = false
              exit for
            end if
          end for
          if (isValueMatched)
            isMatched = true
            exit for
          end if
        end if
      end for ' items in array
      if not isMatched
        msg = "array missing value: "+  RBS_CMN_AsString(value)
        m.currentResult.AddResult(msg)
        return m.GetLegacyCompatibleReturnValue(false)
      end if
    end for 'values to match
  else
    msg = "Input value is not an Array."
    m.currentResult.AddResult(msg)
    return m.GetLegacyCompatibleReturnValue(false)
  end if
  m.currentResult.AddResult("")
  return m.GetLegacyCompatibleReturnValue(true)
end function
function RBS_BTS_AssertArrayNotContains(array , value , key = invalid , msg = "" ) as dynamic
  if (m.currentResult.isFail) then return m.GetLegacyCompatibleReturnValue(false) ' skip test we already failed
  if RBS_CMN_IsAssociativeArray(array) or RBS_CMN_IsArray(array)
    if RBS_CMN_ArrayContains(array, value, key)
      msg = "Array has the '" + RBS_CMN_AsString(value) + "' value."
      m.currentResult.AddResult(msg)
      return m.GetLegacyCompatibleReturnValue(false)
    end if
  else
    msg = "Input value is not an Array."
    m.currentResult.AddResult(msg)
    return m.GetLegacyCompatibleReturnValue(false)
  end if
  m.currentResult.AddResult("")
  return m.GetLegacyCompatibleReturnValue(true)
end function
function RBS_BTS_AssertArrayContainsSubset(array , subset , msg = "" ) as dynamic
  if (m.currentResult.isFail) then return m.GetLegacyCompatibleReturnValue(false) ' skip test we already failed
  if (RBS_CMN_IsAssociativeArray(array) and RBS_CMN_IsAssociativeArray(subset)) or (RBS_CMN_IsArray(array) and RBS_CMN_IsArray(subset))
    isAA = RBS_CMN_IsAssociativeArray(subset)
    for each item in subset
      key = invalid
      value = item
      if isAA
        key = item
        value = subset[key]
      end if
      if not RBS_CMN_ArrayContains(array, value, key)
        msg = "Array doesn't have the '" + RBS_CMN_AsString(value) + "' value."
        m.currentResult.AddResult(msg)
        return m.GetLegacyCompatibleReturnValue(false)
      end if
    end for
  else
    msg = "Input value is not an Array."
    m.currentResult.AddResult(msg)
    return m.GetLegacyCompatibleReturnValue(false)
  end if
  m.currentResult.AddResult("")
  return m.GetLegacyCompatibleReturnValue(true)
end function
function RBS_BTS_AssertArrayNotContainsSubset(array , subset , msg = "" ) as dynamic
  if (m.currentResult.isFail) then return m.GetLegacyCompatibleReturnValue(false) ' skip test we already failed
  if (RBS_CMN_IsAssociativeArray(array) and RBS_CMN_IsAssociativeArray(subset)) or (RBS_CMN_IsArray(array) and RBS_CMN_IsArray(subset))
    isAA = RBS_CMN_IsAssociativeArray(subset)
    for each item in subset
      key = invalid
      value = item
      if isAA
        key = item
        value = item[key]
      end if
      if RBS_CMN_ArrayContains(array, value, key)
        msg = "Array has the '" + RBS_CMN_AsString(value) + "' value."
        m.currentResult.AddResult(msg)
        return m.GetLegacyCompatibleReturnValue(false)
      end if
    end for
  else
    msg = "Input value is not an Array."
    m.currentResult.AddResult(msg)
    return m.GetLegacyCompatibleReturnValue(false)
  end if
  m.currentResult.AddResult("")
  return m.GetLegacyCompatibleReturnValue(true)
end function
function RBS_BTS_AssertArrayCount(array , count , msg = "" ) as dynamic
  if (m.currentResult.isFail) then return m.GetLegacyCompatibleReturnValue(false) ' skip test we already failed
  if RBS_CMN_IsAssociativeArray(array) or RBS_CMN_IsArray(array)
    if array.Count() <> count
      msg = "Array items count " + RBS_CMN_AsString(array.Count()) + " <> " + RBS_CMN_AsString(count) + "."
      m.currentResult.AddResult(msg)
      return m.GetLegacyCompatibleReturnValue(false)
    end if
  else
    msg = "Input value is not an Array."
    m.currentResult.AddResult(msg)
    return m.GetLegacyCompatibleReturnValue(false)
  end if
  m.currentResult.AddResult("")
  return m.GetLegacyCompatibleReturnValue(true)
end function
function RBS_BTS_AssertArrayNotCount(array , count , msg = "" ) as dynamic
  if (m.currentResult.isFail) then return m.GetLegacyCompatibleReturnValue(false) ' skip test we already failed
  if RBS_CMN_IsAssociativeArray(array) or RBS_CMN_IsArray(array)
    if array.Count() = count
      msg = "Array items count = " + RBS_CMN_AsString(count) + "."
      m.currentResult.AddResult(msg)
      return m.GetLegacyCompatibleReturnValue(false)
    end if
  else
    msg = "Input value is not an Array."
    m.currentResult.AddResult(msg)
    return m.GetLegacyCompatibleReturnValue(false)
  end if
  m.currentResult.AddResult("")
  return m.GetLegacyCompatibleReturnValue(true)
end function
function RBS_BTS_AssertEmpty(item , msg = "" ) as dynamic
  if (m.currentResult.isFail) then return m.GetLegacyCompatibleReturnValue(false) ' skip test we already failed
  if RBS_CMN_IsAssociativeArray(item) or RBS_CMN_IsArray(item)
    if item.Count() > 0
      msg = "Array is not empty."
      m.currentResult.AddResult(msg)
      return m.GetLegacyCompatibleReturnValue(false)
    end if
  else if (RBS_CMN_IsString(item))
    if (RBS_CMN_AsString(item) <> "")
      msg = "Input value is not empty."
      m.currentResult.AddResult(msg)
      return m.GetLegacyCompatibleReturnValue(false)
    end if
  else
    msg = "AssertEmpty: Input value was not an array or a string"
    m.currentResult.AddResult(msg)
    return m.GetLegacyCompatibleReturnValue(false)
  end if
  m.currentResult.AddResult("")
  return m.GetLegacyCompatibleReturnValue(true)
end function
function RBS_BTS_AssertNotEmpty(item , msg = "" ) as dynamic
  if (m.currentResult.isFail) then return m.GetLegacyCompatibleReturnValue(false) ' skip test we already failed
  if RBS_CMN_IsAssociativeArray(item) or RBS_CMN_IsArray(item)
    if item.Count() = 0
      msg = "Array is empty."
      m.currentResult.AddResult(msg)
      return m.GetLegacyCompatibleReturnValue(false)
    end if
  else if RBS_CMN_IsString(item)
    if (item = "")
      msg = "Input value is empty."
      m.currentResult.AddResult(msg)
      return m.GetLegacyCompatibleReturnValue(false)
    end if
  else
    msg = "Input value is not a string or array."
    m.currentResult.AddResult(msg)
    return m.GetLegacyCompatibleReturnValue(false)
  end if
  m.currentResult.AddResult("")
  return m.GetLegacyCompatibleReturnValue(true)
end function
function RBS_BTS_AssertArrayContainsOnlyValuesOfType(array , typeStr , msg = "" ) as dynamic
  if (m.currentResult.isFail) then return m.GetLegacyCompatibleReturnValue(false) ' skip test we already failed
  if typeStr <> "String" and typeStr <> "Integer" and typeStr <> "Boolean" and typeStr <> "Array" and typeStr <> "AssociativeArray"
    msg = "Type must be Boolean, String, Array, Integer, or AssociativeArray"
    m.currentResult.AddResult(msg)
    return m.GetLegacyCompatibleReturnValue(false)
  end if
  if RBS_CMN_IsAssociativeArray(array) or RBS_CMN_IsArray(array)
    methodName = "RBS_CMN_Is" + typeStr
    typeCheckFunction = RBS_CMN_GetIsTypeFunction(methodName)
    if (typeCheckFunction <> invalid)
      for each item in array
        if not typeCheckFunction(item)
          msg = RBS_CMN_AsString(item) + "is not a '" + typeStr + "' type."
          m.currentResult.AddResult(msg)
          return m.GetLegacyCompatibleReturnValue(false)
        end if
      end for
    else
      msg = "could not find comparator for type '" + typeStr + "' type."
      m.currentResult.AddResult(msg)
      return m.GetLegacyCompatibleReturnValue(false)
    end if
  else
    msg = "Input value is not an Array."
    m.currentResult.AddResult(msg)
    return m.GetLegacyCompatibleReturnValue(false)
  end if
  m.currentResult.AddResult("")
  return m.GetLegacyCompatibleReturnValue(true)
end function
function RBS_CMN_GetIsTypeFunction(name)
  if name = "RBS_CMN_IsFunction"
    return RBS_CMN_IsFunction
  else if name = "RBS_CMN_IsXmlElement"
    return RBS_CMN_IsXmlElement
  else if name = "RBS_CMN_IsInteger"
    return RBS_CMN_IsInteger
  else if name = "RBS_CMN_IsBoolean"
    return RBS_CMN_IsBoolean
  else if name = "RBS_CMN_IsFloat"
    return RBS_CMN_IsFloat
  else if name = "RBS_CMN_IsDouble"
    return RBS_CMN_IsDouble
  else if name = "RBS_CMN_IsLongInteger"
    return RBS_CMN_IsLongInteger
  else if name = "RBS_CMN_IsNumber"
    return RBS_CMN_IsNumber
  else if name = "RBS_CMN_IsList"
    return RBS_CMN_IsList
  else if name = "RBS_CMN_IsArray"
    return RBS_CMN_IsArray
  else if name = "RBS_CMN_IsAssociativeArray"
    return RBS_CMN_IsAssociativeArray
  else if name = "RBS_CMN_IsSGNode"
    return RBS_CMN_IsSGNode
  else if name = "RBS_CMN_IsString"
    return RBS_CMN_IsString
  else if name = "RBS_CMN_IsDateTime"
    return RBS_CMN_IsDateTime
  else if name = "RBS_CMN_IsUndefined"
    return RBS_CMN_IsUndefined
  else
    return invalid
  end if
end function
function RBS_BTS_AssertType(value , typeStr , msg ="" ) as dynamic
  if (m.currentResult.isFail) then return m.GetLegacyCompatibleReturnValue(false) ' skip test we already failed
  if type(value) <> typeStr
    if msg = ""
      expr_as_string = RBS_CMN_AsString(value)
      msg = expr_as_string + " was not expected type " + typeStr
    end if
    m.currentResult.AddResult(msg)
    return m.GetLegacyCompatibleReturnValue(false)
  end if
  m.currentResult.AddResult("")
  return m.GetLegacyCompatibleReturnValue(true)
end function
function RBS_BTS_AssertSubType(value , typeStr , msg ="" ) as dynamic
  if (m.currentResult.isFail) then return m.GetLegacyCompatibleReturnValue(false) ' skip test we already failed
  if type(value) <> "roSGNode"
    if msg = ""
      expr_as_string = RBS_CMN_AsString(value)
      msg = expr_as_string + " was not a node, so could not match subtype " + typeStr
    end if
    m.currentResult.AddResult(msg)
    return m.GetLegacyCompatibleReturnValue(false)
  else if (value.subType() <> typeStr)
    if msg = ""
      expr_as_string = RBS_CMN_AsString(value)
      msg = expr_as_string + "( type : " + value.subType() +") was not of subType " + typeStr
    end if
    m.currentResult.AddResult(msg)
    return m.GetLegacyCompatibleReturnValue(false)
  end if
  m.currentResult.AddResult("")
  return m.GetLegacyCompatibleReturnValue(true)
end function
function RBS_BTS_EqValues(Value1 , Value2 ) as dynamic
  val1Type = type(Value1)
  val2Type = type(Value2)
  if val1Type = "<uninitialized>" or val2Type = "<uninitialized>" or val1Type = "" or val2Type = ""
    ? "ERROR!!!! - undefined value passed"
    return false
  end if
  if val1Type = "roString" or val1Type = "String"
    Value1 = RBS_CMN_AsString(Value1)
  else
    Value1 = box(Value1)
  end if
  if val2Type = "roString" or val2Type = "String"
    Value2 = RBS_CMN_AsString(Value2)
  else
    Value2 = box(Value2)
  end if
  val1Type = type(Value1)
  val2Type = type(Value2)
  if val1Type = "roFloat" and val2Type = "roInt"
    Value2 = box(Cdbl(Value2))
  else if val2Type = "roFloat" and val1Type = "roInt"
    Value1 = box(Cdbl(Value1))
  end if
  if val1Type <> val2Type
    return false
  else
    valtype = val1Type
    if valtype = "roList"
      return RBS_BTS_EqArray(Value1, Value2)
    else if valtype = "roAssociativeArray"
      return RBS_BTS_EqAssocArray(Value1, Value2)
    else if valtype = "roArray"
      return RBS_BTS_EqArray(Value1, Value2)
    else if (valtype = "roSGNode")
      if (val2Type <> "roSGNode")
        return false
      else
        return Value1.isSameNode(Value2)
      end if
    else
      return Value1 = Value2
    end if
  end if
end function
function RBS_BTS_EqAssocArray(Value1 , Value2 ) as dynamic
  l1 = Value1.Count()
  l2 = Value2.Count()
  if not l1 = l2
    return false
  else
    for each k in Value1
      if not Value2.DoesExist(k)
        return false
      else
        v1 = Value1[k]
        v2 = Value2[k]
        if not RBS_BTS_EqValues(v1, v2)
          return false
        end if
      end if
    end for
    return true
  end if
end function
function RBS_BTS_EqArray(Value1 , Value2 ) as dynamic
  if not (RBS_CMN_IsArray(Value1)) or not RBS_CMN_IsArray(Value2) then return false
  l1 = Value1.Count()
  l2 = Value2.Count()
  if not l1 = l2
    return false
  else
    for i = 0 to l1 - 1
      v1 = Value1[i]
      v2 = Value2[i]
      if not RBS_BTS_EqValues(v1, v2) then
        return false
      end if
    end for
    return true
  end if
end function
function RBS_BTS_AssertNodeCount(node , count , msg = "" ) as dynamic
  if (m.currentResult.isFail) then return m.GetLegacyCompatibleReturnValue(false) ' skip test we already failed
  if type(node) = "roSGNode"
    if node.getChildCount() <> count
      msg = "node items count <> " + RBS_CMN_AsString(count) + ". Received " + RBS_CMN_AsString(node.getChildCount())
      m.currentResult.AddResult(msg)
      return m.GetLegacyCompatibleReturnValue(false)
    end if
  else
    msg = "Input value is not an node."
    m.currentResult.AddResult(msg)
    return m.GetLegacyCompatibleReturnValue(false)
  end if
  m.currentResult.AddResult("")
  return m.GetLegacyCompatibleReturnValue(true)
end function
function RBS_BTS_AssertNodeNotCount(node , count , msg = "" ) as dynamic
  if (m.currentResult.isFail) then return m.GetLegacyCompatibleReturnValue(false) ' skip test we already failed
  if type(node) = "roSGNode"
    if node.getChildCount() = count
      msg = "node items count = " + RBS_CMN_AsString(count) + "."
      m.currentResult.AddResult(msg)
      return m.GetLegacyCompatibleReturnValue(false)
    end if
  else
    msg = "Input value is not an node."
    m.currentResult.AddResult(msg)
    return m.GetLegacyCompatibleReturnValue(false)
  end if
  m.currentResult.AddResult("")
  return m.GetLegacyCompatibleReturnValue(true)
end function
function RBS_BTS_AssertNodeEmpty(node , msg = "" ) as dynamic
  if (m.currentResult.isFail) then return m.GetLegacyCompatibleReturnValue(false) ' skip test we already failed
  if type(node) = "roSGNode"
    if node.getChildCount() > 0
      msg = "node is not empty."
      m.currentResult.AddResult(msg)
      return m.GetLegacyCompatibleReturnValue(false)
    end if
  end if
  m.currentResult.AddResult("")
  return m.GetLegacyCompatibleReturnValue(true)
end function
function RBS_BTS_AssertNodeNotEmpty(node , msg = "" ) as dynamic
  if (m.currentResult.isFail) then return m.GetLegacyCompatibleReturnValue(false) ' skip test we already failed
  if type(node) = "roSGNode"
    if node.Count() = 0
      msg = "Array is empty."
      m.currentResult.AddResult(msg)
      return m.GetLegacyCompatibleReturnValue(false)
    end if
  end if
  m.currentResult.AddResult("")
  return m.GetLegacyCompatibleReturnValue(true)
end function
function RBS_BTS_AssertNodeContains(node , value , msg = "" ) as dynamic
  if (m.currentResult.isFail) then return m.GetLegacyCompatibleReturnValue(false) ' skip test we already failed
  if  type(node) = "roSGNode"
    if not RBS_CMN_NodeContains(node, value)
      msg = "Node doesn't have the '" + RBS_CMN_AsString(value) + "' value."
      m.currentResult.AddResult(msg)
      return m.GetLegacyCompatibleReturnValue(false)
    end if
  else
    msg = "Input value is not an Node."
    m.currentResult.AddResult(msg)
    return m.GetLegacyCompatibleReturnValue(false)
  end if
  m.currentResult.AddResult("")
  return m.GetLegacyCompatibleReturnValue(true)
end function
function RBS_BTS_AssertNodeContainsOnly(node , msg = "" ) as dynamic
  if (m.currentResult.isFail) then return m.GetLegacyCompatibleReturnValue(false) ' skip test we already failed
  if  type(node) = "roSGNode"
    if not RBS_CMN_NodeContains(node, value)
      msg = "Node doesn't have the '" + RBS_CMN_AsString(value) + "' value."
      m.currentResult.AddResult(msg)
      return m.GetLegacyCompatibleReturnValue(false)
    else if node.getChildCount() <> 1
      msg = "Node Contains speicified value; but other values as well"
      m.currentResult.AddResult(msg)
      return m.GetLegacyCompatibleReturnValue(false)
    end if
  else
    msg = "Input value is not an Node."
    m.currentResult.AddResult(msg)
    return m.GetLegacyCompatibleReturnValue(false)
  end if
  m.currentResult.AddResult("")
  return m.GetLegacyCompatibleReturnValue(true)
end function
function RBS_BTS_AssertNodeNotContains(node , value , msg = "" ) as dynamic
  if (m.currentResult.isFail) then return m.GetLegacyCompatibleReturnValue(false) ' skip test we already failed
  if  type(node) = "roSGNode"
    if RBS_CMN_NodeContains(node, value)
      msg = "Node has the '" + RBS_CMN_AsString(value) + "' value."
      m.currentResult.AddResult(msg)
      return m.GetLegacyCompatibleReturnValue(false)
    end if
  else
    msg = "Input value is not an Node."
    m.currentResult.AddResult(msg)
    return m.GetLegacyCompatibleReturnValue(false)
  end if
  m.currentResult.AddResult("")
  return m.GetLegacyCompatibleReturnValue(true)
end function
function RBS_BTS_AssertNodeContainsFields(node , subset , ignoredFields=invalid, msg = "" ) as dynamic
  if (m.currentResult.isFail) then return m.GetLegacyCompatibleReturnValue(false) ' skip test we already failed
  if ( type(node) = "roSGNode" and RBS_CMN_IsAssociativeArray(subset)) or ( type(node) = "roSGNode"  and RBS_CMN_IsArray(subset))
    isAA = RBS_CMN_IsAssociativeArray(subset)
    isIgnoredFields = RBS_CMN_IsArray(ignoredFields)
    for each key in subset
      if (key <> "")
        if (not isIgnoredFields or not RBS_CMN_ArrayContains(ignoredFields, key))
          subsetValue = subset[key]
          nodeValue = node[key]
          if not m.eqValues(nodeValue, subsetValue)
            msg = key + ": Expected '" + RBS_CMN_AsString(subsetValue) + "', got '" + RBS_CMN_AsString(nodeValue) + "'"
            m.currentResult.AddResult(msg)
            return m.GetLegacyCompatibleReturnValue(false)
          end if
        end if
      else
        ? "Found empty key!"
      end if
    end for
  else
    msg = "Input value is not an Node."
    m.currentResult.AddResult(msg)
    return m.GetLegacyCompatibleReturnValue(false)
  end if
  m.currentResult.AddResult("")
  return m.GetLegacyCompatibleReturnValue(true)
end function
function RBS_BTS_AssertNodeNotContainsFields(node , subset , msg = "" ) as dynamic
  if (m.currentResult.isFail) then return m.GetLegacyCompatibleReturnValue(false) ' skip test we already failed
  if ( type(node) = "roSGNode"  and RBS_CMN_IsAssociativeArray(subset)) or ( type(node) = "roSGNode" and RBS_CMN_IsArray(subset))
    isAA = RBS_CMN_IsAssociativeArray(subset)
    for each item in subset
      key = invalid
      value = item
      if isAA
        key = item
        value = item[key]
      end if
      if RBS_CMN_NodeContains(node, value, key)
        msg = "Node has the '" + RBS_CMN_AsString(value) + "' value."
        m.currentResult.AddResult(msg)
        return m.GetLegacyCompatibleReturnValue(false)
      end if
    end for
  else
    msg = "Input value is not an Node."
    m.currentResult.AddResult(msg)
    return m.GetLegacyCompatibleReturnValue(false)
  end if
  m.currentResult.AddResult("")
  return m.GetLegacyCompatibleReturnValue(true)
end function
function RBS_BTS_AssertAAContainsSubset(array , subset , ignoredFields = invalid, msg = "" ) as dynamic
  if (m.currentResult.isFail) then return m.GetLegacyCompatibleReturnValue(false) ' skip test we already failed
  if (RBS_CMN_IsAssociativeArray(array) and RBS_CMN_IsAssociativeArray(subset))
    isAA = RBS_CMN_IsAssociativeArray(subset)
    isIgnoredFields = RBS_CMN_IsArray(ignoredFields)
    for each key in subset
      if (key <> "")
        if (not isIgnoredFields or not RBS_CMN_ArrayContains(ignoredFields, key))
          subsetValue = subset[key]
          arrayValue = array[key]
          if not m.eqValues(arrayValue, subsetValue)
            msg = key + ": Expected '" + RBS_CMN_AsString(subsetValue) + "', got '" + RBS_CMN_AsString(arrayValue) + "'"
            m.currentResult.AddResult(msg)
            return m.GetLegacyCompatibleReturnValue(false)
          end if
        end if
      else
        ? "Found empty key!"
      end if
    end for
  else
    msg = "Input values are not an Associative Array."
    return m.GetLegacyCompatibleReturnValue(false)
  end if
  m.currentResult.AddResult("")
  return m.GetLegacyCompatibleReturnValue(true)
end function
function RBS_BTS_Stub(target, methodName, returnValue = invalid, allowNonExistingMethods = false) as object
  if (type(target) <> "roAssociativeArray")
    m.Fail("could not create Stub provided target was null")
    return {}
  end if
  if (m.stubs =invalid)
    m.__stubId = -1
    m.stubs = {}
  end if
  m.__stubId++
  if (m.__stubId > 5)
    ? "ERROR ONLY 6 STUBS PER TEST ARE SUPPORTED!!"
    return invalid
  end if
  id = stri(m.__stubId).trim()
  fake = m.CreateFake(id, target, methodName, 1, invalid, returnValue)
  m.stubs[id] = fake
  allowNonExisting = m.allowNonExistingMethodsOnMocks = true or allowNonExistingMethods
  isMethodPresent = type(target[methodName]) = "Function" or type(target[methodName]) = "roFunction"
  if (isMethodPresent or allowNonExisting)
    target[methodName] = m["StubCallback" + id]
    target.__stubs = m.stubs
    if (not isMethodPresent)
      ? "WARNING - stubbing call " ; methodName; " which did not exist on target object"
    end if
  else
    ? "ERROR - could not create Stub : method not found  "; target ; "." ; methodName
  end if
  return fake
end function
function RBS_BTS_ExpectOnce(target, methodName, expectedArgs = invalid, returnValue = invalid, allowNonExistingMethods = false) as object
  return m.Mock(target, methodName, 1, expectedArgs, returnValue, allowNonExistingMethods)
end function
function RBS_BTS_ExpectOnceOrNone(target, methodName, isExpected, expectedArgs = invalid, returnValue = invalid, allowNonExistingMethods = false) as object
  if isExpected
    return m.ExpectOnce(target, methodName, expectedArgs, returnValue, allowNonExistingMethods)
  else
    return m.ExpectNone(target, methodName, allowNonExistingMethods)
  end if
end function
function RBS_BTS_ExpectNone(target, methodName, allowNonExistingMethods = false) as object
  return m.Mock(target, methodName, 0, invalid, invalid, allowNonExistingMethods)
end function
function RBS_BTS_Expect(target, methodName, expectedInvocations = 1, expectedArgs = invalid, returnValue = invalid, allowNonExistingMethods = false) as object
  return m.Mock(target, methodName, expectedInvocations, expectedArgs, returnValue, allowNonExistingMethods)
end function
function RBS_BTS_Mock(target, methodName, expectedInvocations = 1, expectedArgs = invalid, returnValue = invalid, allowNonExistingMethods = false) as object
  if not RBS_CMN_IsAssociativeArray(target)
    m.Fail("mock args: target was not an AA")
  else if not RBS_CMN_IsString(methodName)
    m.Fail("mock args: methodName was not a string")
  else if not RBS_CMN_IsNumber(expectedInvocations)
    m.Fail("mock args: expectedInvocations was not an int")
  else if not RBS_CMN_IsArray(expectedArgs) and RBS_CMN_IsValid(expectedArgs)
    m.Fail("mock args: expectedArgs was not invalid or an array of args")
  else if RBS_CMN_IsUndefined(expectedArgs)
    m.Fail("mock args: expectedArgs undefined")
  end if
  if m.currentResult.isFail
    ? "ERROR: "; m.currentResult.messages[m.currentResult.currentAssertIndex - 1]
    return {}
  end if
  if (m.mocks = invalid)
    m.__mockId = -1
    m.__mockTargetId = -1
    m.mocks = {}
  end if
  fake = invalid
  if not target.doesExist("__rooibosTargetId")
    m.__mockTargetId++
    target["__rooibosTargetId"] = m.__mockTargetId
  end if
  for i = 0 to m.__mockId
    id = stri(i).trim()
    mock =  m.mocks[id]
    if mock <> invalid and mock.methodName = methodName and mock.target.__rooibosTargetId = target.__rooibosTargetId
      fake = mock
      exit for
    end if
  end for
  if fake = invalid
    m.__mockId++
    id = stri(m.__mockId).trim()
    if (m.__mockId > 6)
      ? "ERROR ONLY 6 MOCKS PER TEST ARE SUPPORTED!! you're on # " ; m.__mockId
      ? " Method was " ; methodName
      return invalid
    end if
    fake = m.CreateFake(id, target, methodName, expectedInvocations, expectedArgs, returnValue)
    m.mocks[id] = fake 'this will bind it to m
    allowNonExisting = m.allowNonExistingMethodsOnMocks = true or allowNonExistingMethods
    isMethodPresent = type(target[methodName]) = "Function" or type(target[methodName]) = "roFunction"
    if (isMethodPresent or allowNonExisting)
      target[methodName] =  m["MockCallback" + id]
      target.__mocks = m.mocks
      if (not isMethodPresent)
        ? "WARNING - mocking call " ; methodName; " which did not exist on target object"
      end if
    else
      ? "ERROR - could not create Mock : method not found  "; target ; "." ; methodName
    end if
  else
    m.CombineFakes(fake, m.CreateFake(id, target, methodName, expectedInvocations, expectedArgs, returnValue))
  end if
  return fake
end function
function RBS_BTS_CreateFake(id, target, methodName, expectedInvocations = 1, expectedArgs =invalid, returnValue=invalid ) as object
  expectedArgsValues = []
  hasArgs = RBS_CMN_IsArray(expectedArgs)
  if (hasArgs)
    defaultValue = m.invalidValue
  else
    defaultValue = m.ignoreValue
    expectedArgs = []
  end if
  for i = 0 to 9
    if (hasArgs and expectedArgs.count() > i)
      value = expectedArgs[i]
      if not RBS_CMN_IsUndefined(value)
        expectedArgsValues.push(expectedArgs[i])
      else
        expectedArgsValues.push("#ERR-UNDEFINED!")
      end if
    else
      expectedArgsValues.push(defaultValue)
    end if
  end for
  fake = {
    id : id,
    target: target,
    methodName: methodName,
    returnValue: returnValue,
    isCalled: false,
    invocations: 0,
    invokedArgs: [invalid, invalid, invalid, invalid, invalid, invalid, invalid, invalid, invalid],
    expectedArgs: expectedArgsValues,
    expectedInvocations: expectedInvocations,
    callback: function (arg1=invalid,  arg2=invalid,  arg3=invalid,  arg4=invalid,  arg5=invalid,  arg6=invalid,  arg7=invalid,  arg8=invalid,  arg9 =invalid)as dynamic
      if (m.allInvokedArgs = invalid)
        m.allInvokedArgs = []
      end if
      m.invokedArgs = [arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9 ]
      m.allInvokedArgs.push ([arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9 ])
      m.isCalled = true
      m.invocations++
      if (type(m.returnValue) = "roAssociativeArray" and m.returnValue.doesExist("multiResult"))
        returnValues = m.returnValue["multiResult"]
        returnIndex = m.invocations -1
        if (type(returnValues) = "roArray" and returnValues.count() > 0)
          if returnValues.count() <= m.invocations
            returnIndex = returnValues.count() -1
            print "Multi return values all used up - repeating last value"
          end if
          return returnValues[returnIndex]
        else
          ? "Multi return value was specified; but no array of results were found"
          return invalid
        end if
      else
        return m.returnValue
      end if
    end function
  }
  return fake
end function
function RBS_BTS_CombineFakes(fake, otherFake)
  if type(fake.expectedArgs) <> "roAssociativeArray" or not fake.expectedArgs.doesExist("multiInvoke")
    currentExpectedArgsArgs = fake.expectedArgs
    fake.expectedArgs = {
      "multiInvoke": [currentExpectedArgsArgs]
    }
  end if
  fake.expectedArgs.multiInvoke.push(otherFake.expectedArgs)
  if type(fake.returnValue) <> "roAssociativeArray" or not fake.returnValue.doesExist("multiResult")
    currentReturnValue = fake.returnValue
    fake.returnValue = {
      "multiResult": [currentReturnValue]
    }
  end if
  fake.returnValue.multiResult.push(otherFake.returnValue)
  fake.expectedInvocations++
end function
function RBS_BTS_AssertMocks() as void
  if (m.__mockId = invalid or not RBS_CMN_IsAssociativeArray(m.mocks))
    return
  end if
  lastId = int(m.__mockId)
  for each id in m.mocks
    mock = m.mocks[id]
    methodName = mock.methodName
    if (mock.expectedInvocations <> mock.invocations)
      m.MockFail(methodName, "Wrong number of calls. (" + stri(mock.invocations).trim() + " / " + stri(mock.expectedInvocations).trim() + ")")
      m.CleanMocks()
      return
    else if mock.expectedInvocations > 0 and (RBS_CMN_IsArray(mock.expectedArgs) or (type(mock.expectedArgs) = "roAssociativeArray" and RBS_CMN_IsArray(mock.expectedArgs.multiInvoke)))
      isMultiArgsSupported = type(mock.expectedArgs) = "roAssociativeArray" and RBS_CMN_IsArray(mock.expectedArgs.multiInvoke)
      for invocationIndex = 0 to mock.invocations - 1
        invokedArgs = mock.allInvokedArgs[invocationIndex]
        if isMultiArgsSupported
          expectedArgs = mock.expectedArgs.multiInvoke[invocationIndex]
        else
          expectedArgs = mock.expectedArgs
        end if
        for i = 0 to expectedArgs.count() -1
          value = invokedArgs[i]
          expected = expectedArgs[i]
          didNotExpectArg = RBS_CMN_IsString(expected) and expected = m.invalidValue
          if (didNotExpectArg)
            expected = invalid
          end if
          if (not (RBS_CMN_IsString(expected) and expected = m.ignoreValue) and not m.eqValues(value, expected))
            if (expected = invalid)
              expected = "[INVALID]"
            end if
            m.MockFail(methodName, "on Invocation #" + stri(invocationIndex).trim() + ", expected arg #" + stri(i).trim() + "  to be '" + RBS_CMN_AsString(expected) + "' got '" + RBS_CMN_AsString(value) + "')")
            m.CleanMocks()
            return
          end if
        end for
      end for
    end if
  end for
  m.CleanMocks()
end function
function RBS_BTS_CleanMocks() as void
  if m.mocks = invalid return
    for each id in m.mocks
      mock = m.mocks[id]
      mock.target.__mocks = invalid
    end for
    m.mocks = invalid
  end function
  function RBS_BTS_CleanStubs() as void
    if m.stubs = invalid return
      for each id in m.stubs
        stub = m.stubs[id]
        stub.target.__stubs = invalid
      end for
      m.stubs = invalid
    end function
    function RBS_BTS_MockFail(methodName, message) as dynamic
      if (m.currentResult.isFail) then return m.GetLegacyCompatibleReturnValue(false) ' skip test we already failed
      m.currentResult.AddResult("mock failure on '" + methodName + "' : "  + message)
      return m.GetLegacyCompatibleReturnValue(false)
    end function
    function RBS_BTS_StubCallback0(arg1=invalid,  arg2=invalid,  arg3=invalid,  arg4=invalid,  arg5=invalid,  arg6=invalid,  arg7=invalid,  arg8=invalid,  arg9 =invalid)as dynamic
      fake = m.__Stubs["0"]
      return fake.callback(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9)
    end function
    function RBS_BTS_StubCallback1(arg1=invalid,  arg2=invalid,  arg3=invalid,  arg4=invalid,  arg5=invalid,  arg6=invalid,  arg7=invalid,  arg8=invalid,  arg9 =invalid)as dynamic
      fake = m.__Stubs["1"]
      return fake.callback(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9)
    end function
    function RBS_BTS_StubCallback2(arg1=invalid,  arg2=invalid,  arg3=invalid,  arg4=invalid,  arg5=invalid,  arg6=invalid,  arg7=invalid,  arg8=invalid,  arg9 =invalid)as dynamic
      fake = m.__Stubs["2"]
      return fake.callback(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9)
    end function
    function RBS_BTS_StubCallback3(arg1=invalid,  arg2=invalid,  arg3=invalid,  arg4=invalid,  arg5=invalid,  arg6=invalid,  arg7=invalid,  arg8=invalid,  arg9 =invalid)as dynamic
      fake = m.__Stubs["3"]
      return fake.callback(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9)
    end function
    function RBS_BTS_StubCallback4(arg1=invalid,  arg2=invalid,  arg3=invalid,  arg4=invalid,  arg5=invalid,  arg6=invalid,  arg7=invalid,  arg8=invalid,  arg9 =invalid)as dynamic
      fake = m.__Stubs["4"]
      return fake.callback(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9)
    end function
    function RBS_BTS_StubCallback5(arg1=invalid,  arg2=invalid,  arg3=invalid,  arg4=invalid,  arg5=invalid,  arg6=invalid,  arg7=invalid,  arg8=invalid,  arg9 =invalid)as dynamic
      fake = m.__Stubs["5"]
      return fake.callback(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9)
    end function
    function RBS_BTS_MockCallback0(arg1=invalid,  arg2=invalid,  arg3=invalid,  arg4=invalid,  arg5=invalid,  arg6=invalid,  arg7=invalid,  arg8=invalid,  arg9 =invalid)as dynamic
      fake = m.__mocks["0"]
      return fake.callback(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9)
    end function
    function RBS_BTS_MockCallback1(arg1=invalid,  arg2=invalid,  arg3=invalid,  arg4=invalid,  arg5=invalid,  arg6=invalid,  arg7=invalid,  arg8=invalid,  arg9 =invalid)as dynamic
      fake = m.__mocks["1"]
      return fake.callback(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9)
    end function
    function RBS_BTS_MockCallback2(arg1=invalid,  arg2=invalid,  arg3=invalid,  arg4=invalid,  arg5=invalid,  arg6=invalid,  arg7=invalid,  arg8=invalid,  arg9 =invalid)as dynamic
      fake = m.__mocks["2"]
      return fake.callback(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9)
    end function
    function RBS_BTS_MockCallback3(arg1=invalid,  arg2=invalid,  arg3=invalid,  arg4=invalid,  arg5=invalid,  arg6=invalid,  arg7=invalid,  arg8=invalid,  arg9 =invalid)as dynamic
      fake = m.__mocks["3"]
      return fake.callback(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9)
    end function
    function RBS_BTS_MockCallback4(arg1=invalid,  arg2=invalid,  arg3=invalid,  arg4=invalid,  arg5=invalid,  arg6=invalid,  arg7=invalid,  arg8=invalid,  arg9 =invalid)as dynamic
      fake = m.__mocks["4"]
      return fake.callback(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9)
    end function
    function RBS_BTS_MockCallback5(arg1=invalid,  arg2=invalid,  arg3=invalid,  arg4=invalid,  arg5=invalid,  arg6=invalid,  arg7=invalid,  arg8=invalid,  arg9 =invalid)as dynamic
      fake = m.__mocks["5"]
      return fake.callback(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9)
    end function
    function RBS_BTS_rodash_pathsAsArray_(path)
      pathRE = CreateObject("roRegex", "\[([0-9]+)\]", "i")
      segments = []
      if type(path) = "String" or type(path) = "roString"
        dottedPath = pathRE.replaceAll(path, ".\1")
        stringSegments = dottedPath.tokenize(".")
        for each s in stringSegments
          if (Asc(s) >= 48) and (Asc(s) <= 57)
            segments.push(s.toInt())
          else
            segments.push(s)
          end if
        end for
      else if type(path) = "roList" or type(path) = "roArray"
        stringPath = ""
        for each s in path
          stringPath = stringPath + "." + Box(s).toStr()
        end for
        segments = m.pathAsArray_(stringPath)
      else
        segments = invalid
      end if
      return segments
    end function
    function RBS_BTS_rodash_get_(aa, path, default=invalid)
      if type(aa) <> "roAssociativeArray" and type(aa) <> "roArray" and type(aa) <> "roSGNode" then return default
      segments = m.pathAsArray_(path)
      if (Type(path) = "roInt" or Type(path) = "roInteger" or Type(path) = "Integer")
        path = stri(path).trim()
      end if
      if segments = invalid then return default
      result = invalid
      while segments.count() > 0
        key = segments.shift()
        if (type(key) = "roInteger") 'it's a valid index
          if (aa <> invalid and GetInterface(aa, "ifArray") <> invalid)
            value = aa[key]
          else if (aa <> invalid and GetInterface(aa, "ifSGNodeChildren") <> invalid)
            value = aa.getChild(key)
          else if (aa <> invalid and GetInterface(aa, "ifAssociativeArray") <> invalid)
            key = tostr(key)
            if not aa.doesExist(key)
              exit while
            end if
            value = aa.lookup(key)
          else
            value = invalid
          end if
        else
          if not aa.doesExist(key)
            exit while
          end if
          value = aa.lookup(key)
        end if
        if segments.count() = 0
          result = value
          exit while
        end if
        if type(value) <> "roAssociativeArray" and type(value) <> "roArray" and type(value) <> "roSGNode"
          exit while
        end if
        aa = value
      end while
      if result = invalid then return default
      return result
    end function
function RBS_CMN_IsXmlElement(value ) as boolean
  return RBS_CMN_IsValid(value) and GetInterface(value, "ifXMLElement") <> invalid
end function
function RBS_CMN_IsFunction(value ) as boolean
  return RBS_CMN_IsValid(value) and GetInterface(value, "ifFunction") <> invalid
end function
function RBS_CMN_GetFunction(filename, functionName) as object
  if (not RBS_CMN_IsNotEmptyString(functionName)) then return invalid
  if (not RBS_CMN_IsNotEmptyString(filename)) then return invalid
  mapFunction = RBSFM_getFunctionsForFile(filename)
  if mapFunction <> invalid
    map = mapFunction()
    if (type(map) ="roAssociativeArray")
      functionPointer = map[functionName]
      return functionPointer
    else
      return invalid
    end if
  end if
  return invalid
end function
function RBS_CMN_GetFunctionBruteForce(functionName) as object
  if (not RBS_CMN_IsNotEmptyString(functionName)) then return invalid
  filenames = RBSFM_getFilenames()
  for i = 0 to filenames.count() - 1
    filename = filenames[i]
    mapFunction = RBSFM_getFunctionsForFile(filename)
    if mapFunction <> invalid
      map = mapFunction()
      if (type(map) ="roAssociativeArray")
        functionPointer = map[functionName]
        if functionPointer <> invalid
          return functionPointer
        end if
      end if
    end if
  end for
  return invalid
end function
function RBS_CMN_IsBoolean(value ) as boolean
  return RBS_CMN_IsValid(value) and GetInterface(value, "ifBoolean") <> invalid
end function
function RBS_CMN_IsInteger(value ) as boolean
  return RBS_CMN_IsValid(value) and GetInterface(value, "ifInt") <> invalid and (Type(value) = "roInt" or Type(value) = "roInteger" or Type(value) = "Integer")
end function
function RBS_CMN_IsFloat(value ) as boolean
  return RBS_CMN_IsValid(value) and GetInterface(value, "ifFloat") <> invalid
end function
function RBS_CMN_IsDouble(value ) as boolean
  return RBS_CMN_IsValid(value) and GetInterface(value, "ifDouble") <> invalid
end function
function RBS_CMN_IsLongInteger(value ) as boolean
  return RBS_CMN_IsValid(value) and GetInterface(value, "ifLongInt") <> invalid
end function
function RBS_CMN_IsNumber(value ) as boolean
  return RBS_CMN_IsLongInteger(value) or RBS_CMN_IsDouble(value) or RBS_CMN_IsInteger(value) or RBS_CMN_IsFloat(value)
end function
function RBS_CMN_IsList(value ) as boolean
  return RBS_CMN_IsValid(value) and GetInterface(value, "ifList") <> invalid
end function
function RBS_CMN_IsArray(value ) as boolean
  return RBS_CMN_IsValid(value) and GetInterface(value, "ifArray") <> invalid
end function
function RBS_CMN_IsAssociativeArray(value ) as boolean
  return RBS_CMN_IsValid(value) and GetInterface(value, "ifAssociativeArray") <> invalid
end function
function RBS_CMN_IsSGNode(value ) as boolean
  return RBS_CMN_IsValid(value) and GetInterface(value, "ifSGNodeChildren") <> invalid
end function
function RBS_CMN_IsString(value ) as boolean
  return RBS_CMN_IsValid(value) and GetInterface(value, "ifString") <> invalid
end function
function RBS_CMN_IsNotEmptyString(value ) as boolean
  return RBS_CMN_IsString(value) and len(value) > 0
end function
function RBS_CMN_IsDateTime(value ) as boolean
  return RBS_CMN_IsValid(value) and (GetInterface(value, "ifDateTime") <> invalid or Type(value) = "roDateTime")
end function
function RBS_CMN_IsValid(value ) as boolean
  return not RBS_CMN_IsUndefined(value) and value <> invalid
end function
function RBS_CMN_IsUndefined(value ) as boolean
  return type(value) = "" or Type(value) = "<uninitialized>"
end function
function RBS_CMN_ValidStr(obj ) as string
  if obj <> invalid and GetInterface(obj, "ifString") <> invalid
    return obj
  else
    return ""
  end if
end function
function RBS_CMN_AsString(input ) as string
  if RBS_CMN_IsValid(input) = false
    return ""
  else if RBS_CMN_IsString(input)
    return input
  else if RBS_CMN_IsInteger(input) or RBS_CMN_IsLongInteger(input) or RBS_CMN_IsBoolean(input)
    return input.ToStr()
  else if RBS_CMN_IsFloat(input) or RBS_CMN_IsDouble(input)
    return Str(input).Trim()
  else if type(input) = "roSGNode"
    return "Node(" + input.subType() +")"
  else if type(input) = "roAssociativeArray"
    isFirst = true
    text = "{"
    if (not isFirst)
      text += ","
      isFirst = false
    end if
    for each key in input
      text += key + ":" + RBS_CMN_AsString(input[key])
    end for
    text += "}"
    return text
  else
    return ""
  end if
end function
function RBS_CMN_AsInteger(input ) as integer
  if RBS_CMN_IsValid(input) = false
    return 0
  else if RBS_CMN_IsString(input)
    return input.ToInt()
  else if RBS_CMN_IsInteger(input)
    return input
  else if RBS_CMN_IsFloat(input) or RBS_CMN_IsDouble(input) or RBS_CMN_IsLongInteger(input)
    return Int(input)
  else
    return 0
  end if
end function
function RBS_CMN_AsLongInteger(input ) as longinteger
  if RBS_CMN_IsValid(input) = false
    return 0
  else if RBS_CMN_IsString(input)
    return RBS_CMN_AsInteger(input)
  else if RBS_CMN_IsLongInteger(input) or RBS_CMN_IsFloat(input) or RBS_CMN_IsDouble(input) or RBS_CMN_IsInteger(input)
    return input
  else
    return 0
  end if
end function
function RBS_CMN_AsFloat(input ) as float
  if RBS_CMN_IsValid(input) = false
    return 0.0
  else if RBS_CMN_IsString(input)
    return input.ToFloat()
  else if RBS_CMN_IsInteger(input)
    return (input / 1)
  else if RBS_CMN_IsFloat(input) or RBS_CMN_IsDouble(input) or RBS_CMN_IsLongInteger(input)
    return input
  else
    return 0.0
  end if
end function
function RBS_CMN_AsDouble(input ) as double
  if RBS_CMN_IsValid(input) = false
    return 0.0
  else if RBS_CMN_IsString(input)
    return RBS_CMN_AsFloat(input)
  else if RBS_CMN_IsInteger(input) or RBS_CMN_IsLongInteger(input) or RBS_CMN_IsFloat(input) or RBS_CMN_IsDouble(input)
    return input
  else
    return 0.0
  end if
end function
function RBS_CMN_AsBoolean(input ) as boolean
  if RBS_CMN_IsValid(input) = false
    return false
  else if RBS_CMN_IsString(input)
    return LCase(input) = "true"
  else if RBS_CMN_IsInteger(input) or RBS_CMN_IsFloat(input)
    return input <> 0
  else if RBS_CMN_IsBoolean(input)
    return input
  else
    return false
  end if
end function
function RBS_CMN_AsArray(value ) as object
  if RBS_CMN_IsValid(value)
    if not RBS_CMN_IsArray(value)
      return [value]
    else
      return value
    end if
  end if
  return []
end function
function RBS_CMN_IsNullOrEmpty(value ) as boolean
  if RBS_CMN_IsString(value)
    return Len(value) = 0
  else
    return not RBS_CMN_IsValid(value)
  end if
end function
function RBS_CMN_FindElementIndexInArray(array , value , compareAttribute = invalid , caseSensitive = false ) as integer
  if RBS_CMN_IsArray(array)
    for i = 0 to RBS_CMN_AsArray(array).Count() - 1
      compareValue = array[i]
      if compareAttribute <> invalid and RBS_CMN_IsAssociativeArray(compareValue)
        compareValue = compareValue.LookupCI(compareAttribute)
      end if
      if RBS_BTS_EqValues(compareValue, value)
        return i
      end if
      item = array[i]
    next
  end if
  return -1
end function
function RBS_CMN_ArrayContains(array , value , compareAttribute = invalid ) as boolean
  return (RBS_CMN_FindElementIndexInArray(array, value, compareAttribute) > -1)
end function
function RBS_CMN_FindElementIndexInNode(node , value ) as integer
  if type(node) = "roSGNode"
    for i = 0 to node.getChildCount() - 1
      compareValue = node.getChild(i)
      if type(compareValue) = "roSGNode" and compareValue.isSameNode(value)
        return i
      end if
    next
  end if
  return -1
end function
function RBS_CMN_NodeContains(node , value ) as boolean
  return (RBS_CMN_FindElementIndexInNode(node, value) > -1)
end function
function RBS_ItG_GetTestCases(group) as object
  if (group.hasSoloTests = true)
    return group.soloTestCases
  else
    return group.testCases
  end if
end function
function RBS_ItG_GetRunnableTestSuite(group) as object
  testCases = RBS_ItG_GetTestCases(group)
  runnableSuite = BaseTestSuite()
  runnableSuite.name = group.name
  runnableSuite.isLegacy = group.isLegacy = true
  if group.testCaseLookup = invalid
    group.testCaseLookup = {}
  end if
  for each testCase in testCases
    name = testCase.name
    if (testCase.isSolo = true)
      name += " [SOLO] "
    end if
    testFunction = RBS_CMN_GetFunction(group.filename, testCase.funcName)
    runnableSuite.addTest(name, testFunction, testCase.funcName)
    group.testCaseLookup[name] = testCase
  end for
  runnableSuite.SetUp = RBS_CMN_GetFunction(group.filename, group.setupFunctionName)
  runnableSuite.TearDown =  RBS_CMN_GetFunction(group.filename, group.teardownFunctionName)
  runnableSuite.BeforeEach =  RBS_CMN_GetFunction(group.filename, group.beforeEachFunctionName)
  runnableSuite.AfterEach =  RBS_CMN_GetFunction(group.filename, group.afterEachFunctionName)
  return runnableSuite
end function
function ItemGenerator(scheme as object) as object
  this = {}
  this.getItem    = RBS_IG_GetItem
  this.getAssocArray  = RBS_IG_GetAssocArray
  this.getArray     = RBS_IG_GetArray
  this.getSimpleType  = RBS_IG_GetSimpleType
  this.getInteger   = RBS_IG_GetInteger
  this.getFloat     = RBS_IG_GetFloat
  this.getString    = RBS_IG_GetString
  this.getBoolean   = RBS_IG_GetBoolean
  if not RBS_CMN_IsValid(scheme)
    return invalid
  end if
  return this.getItem(scheme)
end function
function RBS_IG_GetItem(scheme as object) as object
  item = invalid
  if RBS_CMN_IsAssociativeArray(scheme)
    item = m.getAssocArray(scheme)
  else if RBS_CMN_IsArray(scheme)
    item = m.getArray(scheme)
  else if RBS_CMN_IsString(scheme)
    item = m.getSimpleType(lCase(scheme))
  end if
  return item
end function
function RBS_IG_GetAssocArray(scheme as object) as object
  item = {}
  for each key in scheme
    if not item.DoesExist(key)
      item[key] = m.getItem(scheme[key])
    end if
  end for
  return item
end function
function RBS_IG_GetArray(scheme as object) as object
  item = []
  for each key in scheme
    item.Push(m.getItem(key))
  end for
  return item
end function
function RBS_IG_GetSimpleType(typeStr as string) as object
  item = invalid
  if typeStr = "integer" or typeStr = "int" or typeStr = "roint"
    item = m.getInteger()
  else if typeStr = "float" or typeStr = "rofloat"
    item = m.getFloat()
  else if typeStr = "string" or typeStr = "rostring"
    item = m.getString(10)
  else if typeStr = "boolean" or typeStr = "roboolean"
    item = m.getBoolean()
  end if
  return item
end function
function RBS_IG_GetBoolean() as boolean
  return RBS_CMN_AsBoolean(Rnd(2) \ Rnd(2))
end function
function RBS_IG_GetInteger(seed = 100 as integer) as integer
  return Rnd(seed)
end function
function RBS_IG_GetFloat() as float
  return Rnd(0)
end function
function RBS_IG_GetString(seed as integer) as string
  item = ""
  if seed > 0
    stringLength = Rnd(seed)
    for i = 0 to stringLength
      chType = Rnd(3)
      if chType = 1     'Chr(48-57) - numbers
        chNumber = 47 + Rnd(10)
      else if chType = 2  'Chr(65-90) - Uppercase Letters
        chNumber = 64 + Rnd(26)
      else        'Chr(97-122) - Lowercase Letters
        chNumber = 96 + Rnd(26)
      end if
      item = item + Chr(chNumber)
    end for
  end if
  return item
end function
function UnitTestRuntimeConfig()
  this = {}
  this.CreateSuites = RBS_CreateSuites
  this.hasSoloSuites = false
  this.hasSoloGroups = false
  this.hasSoloTests = false
  this.suites = this.CreateSuites()
  return this
end function
function RBS_CreateSuites()
  suites = RBSFM_getTestSuitesForProject()
  includedSuites = []
  for i = 0 to suites.count() -1
    suite = suites[i]
    if (suite.valid)
      if (suite.isSolo)
        m.hasSoloSuites = true
      end if
      if (suite.hasSoloTests = true)
        m.hasSoloTests = true
      end if
      if (suite.hasSoloGroups = true)
        m.hasSoloGroups = true
      end if
      includedSuites.Push(suite)
    else
      ? "ERROR! suite was not valid - ignoring"
    end if
  end for
  return includedSuites
end function
function RBS_STATS_CreateTotalStatistic() as object
  statTotalItem = {
    Suites    : []
    Time    : 0
    Total     : 0
    Correct   : 0
    Fail    : 0
    Ignored   : 0
    Crash     : 0
    IgnoredTestNames: []
  }
  return statTotalItem
end function
function RBS_STATS_MergeTotalStatistic(stat1, stat2) as void
  for each suite in stat2.Suites
    stat1.Suites.push(suite)
  end for
  stat1.Time += stat2.Time
  stat1.Total += stat2.Total
  stat1.Correct += stat2.Correct
  stat1.Fail += stat2.Fail
  stat1.Crash += stat2.Crash
  stat1.Ignored += stat2.Ignored
  stat1.IgnoredTestNames.append(stat2.IgnoredTestNames)
end function
function RBS_STATS_CreateSuiteStatistic(name as string) as object
  statSuiteItem = {
    Name  : name
    Tests   : []
    Time  : 0
    Total   : 0
    Correct : 0
    Fail  : 0
    Crash   : 0
    Ignored   : 0
    IgnoredTestNames:[]
  }
  return statSuiteItem
end function
function RBS_STATS_CreateTestStatistic(name as string, result = "Success" as string, time = 0 as integer, errorCode = 0 as integer, errorMessage = "" as string) as object
  statTestItem = {
    Name  : name
    Result  : result
    Time  : time
    Error   : {
      Code  : errorCode
      Message : errorMessage
    }
  }
  return statTestItem
end function
sub RBS_STATS_AppendTestStatistic(statSuiteObj as object, statTestObj as object)
  if RBS_CMN_IsAssociativeArray(statSuiteObj) and RBS_CMN_IsAssociativeArray(statTestObj)
    statSuiteObj.Tests.Push(statTestObj)
    if RBS_CMN_IsInteger(statTestObj.time)
      statSuiteObj.Time = statSuiteObj.Time + statTestObj.Time
    end if
    statSuiteObj.Total = statSuiteObj.Total + 1
    if lCase(statTestObj.Result) = "success"
      statSuiteObj.Correct = statSuiteObj.Correct + 1
    else if lCase(statTestObj.result) = "fail"
      statSuiteObj.Fail = statSuiteObj.Fail + 1
    else
      statSuiteObj.crash = statSuiteObj.crash + 1
    end if
  end if
end sub
sub RBS_STATS_AppendSuiteStatistic(statTotalObj as object, statSuiteObj as object)
  if RBS_CMN_IsAssociativeArray(statTotalObj) and RBS_CMN_IsAssociativeArray(statSuiteObj)
    statTotalObj.Suites.Push(statSuiteObj)
    statTotalObj.Time = statTotalObj.Time + statSuiteObj.Time
    if RBS_CMN_IsInteger(statSuiteObj.Total)
      statTotalObj.Total = statTotalObj.Total + statSuiteObj.Total
    end if
    if RBS_CMN_IsInteger(statSuiteObj.Correct)
      statTotalObj.Correct = statTotalObj.Correct + statSuiteObj.Correct
    end if
    if RBS_CMN_IsInteger(statSuiteObj.Fail)
      statTotalObj.Fail = statTotalObj.Fail + statSuiteObj.Fail
    end if
    if RBS_CMN_IsInteger(statSuiteObj.Crash)
      statTotalObj.Crash = statTotalObj.Crash + statSuiteObj.Crash
    end if
  end if
end sub
function UnitTestCase(name as string, func as dynamic, funcName as string, isSolo as boolean, isIgnored as boolean, lineNumber as integer, params = invalid, paramTestIndex =0, paramLineNumber = 0)
  this = {}
  this.isSolo = isSolo
  this.func = func
  this.funcName = funcName
  this.isIgnored = isIgnored
  this.name = name
  this.lineNumber = lineNumber
  this.paramLineNumber = paramLineNumber
  this.assertIndex = 0
  this.assertLineNumberMap = {}
  this.AddAssertLine = RBS_TC_AddAssertLine
  this.getTestLineIndex = 0
  this.rawParams = params
  this.paramTestIndex = paramTestIndex
  this.isParamTest = false
  this.time = 0
  if (params <> invalid)
    this.name += stri(this.paramTestIndex)
  end if
  return this
end function
function RBS_TC_AddAssertLine(lineNumber as integer)
  m.assertLineNumberMap[stri(m.assertIndex).trim()] = lineNumber
  m.assertIndex++
end function
function RBS_TC_GetAssertLine(testCase, index)
  if (testCase.assertLineNumberMap.doesExist(stri(index).trim()))
    return testCase.assertLineNumberMap[stri(index).trim()]
  else
    return testCase.lineNumber
  end if
end function
function Logger(config) as object
  this = {}
  this.config = config
  this.verbosityLevel = {
    basic   : 0
    normal  : 1
    verbose : 2
  }
  this.verbosity        = this.config.logLevel
  this.PrintStatistic     = RBS_LOGGER_PrintStatistic
  this.PrintMetaSuiteStart  = RBS_LOGGER_PrintMetaSuiteStart
  this.PrintSuiteStatistic  = RBS_LOGGER_PrintSuiteStatistic
  this.PrintTestStatistic   = RBS_LOGGER_PrintTestStatistic
  this.PrintStart       = RBS_LOGGER_PrintStart
  this.PrintEnd         = RBS_LOGGER_PrintEnd
  this.PrintSuiteStart    = RBS_LOGGER_PrintSuiteStart
  return this
end function
sub RBS_LOGGER_PrintStatistic(statObj as object)
  m.PrintStart()
  previousfile = invalid
  for each testSuite in statObj.Suites
    if (not statObj.testRunHasFailures or ((not m.config.showOnlyFailures) or testSuite.fail > 0 or testSuite.crash > 0))
      if (testSuite.metaTestSuite.filePath <> previousfile)
        m.PrintMetaSuiteStart(testSuite.metaTestSuite)
        previousfile = testSuite.metaTestSuite.filePath
      end if
      m.PrintSuiteStatistic(testSuite, statObj.testRunHasFailures)
    end if
  end for
  ? ""
  m.PrintEnd()
  ? "Total  = "; RBS_CMN_AsString(statObj.Total); " ; Passed  = "; statObj.Correct; " ; Failed   = "; statObj.Fail; " ; Ignored   = "; statObj.Ignored
  ? " Time spent: "; statObj.Time; "ms"
  ? ""
  ? ""
  if (statObj.ignored > 0)
    ? "IGNORED TESTS:"
    for each ignoredItemName in statObj.IgnoredTestNames
      print ignoredItemName
    end for
  end if
  if (statObj.Total = statObj.Correct)
    overrallResult = "Success"
  else
    overrallResult = "Fail"
  end if
  ? "RESULT: "; overrallResult
end sub
sub RBS_LOGGER_PrintSuiteStatistic(statSuiteObj as object, hasFailures)
  m.PrintSuiteStart(statSuiteObj.Name)
  for each testCase in statSuiteObj.Tests
    if (not hasFailures or ((not m.config.showOnlyFailures) or testCase.Result <> "Success"))
      m.PrintTestStatistic(testCase)
    end if
  end for
  ? " |"
end sub
sub RBS_LOGGER_PrintTestStatistic(testCase as object)
  metaTestCase = testCase.metaTestCase
  if (LCase(testCase.Result) <> "success")
    testChar = "-"
    assertIndex = metaTestCase.testResult.failedAssertIndex
    locationLine = StrI(RBS_TC_GetAssertLine(metaTestCase,assertIndex)).trim()
  else
    testChar = "|"
    locationLine = StrI(metaTestCase.lineNumber).trim()
  end if
  locationText = testCase.filePath.trim() + "(" + locationLine + ")"
  insetText = ""
  if (metaTestcase.isParamTest <> true)
    messageLine = RBS_LOGGER_FillText(" " + testChar + " |--" + metaTestCase.Name + " : ", ".", 80)
    ? messageLine ; testCase.Result ; " (" + stri(metaTestCase.time).trim() +"ms)"
  else if ( metaTestcase.paramTestIndex = 0)
    name = metaTestCase.Name
    if (len(name) > 1 and right(name, 1) = "0")
      name = left(name, len(name) - 1)
    end if
    ? " " + testChar + " |--" + name+ " : "
  end if
  if (metaTestcase.isParamTest = true)
    insetText = "  "
    messageLine = RBS_LOGGER_FillText(" " + testChar + insetText + " |--" + formatJson(metaTestCase.rawParams) + " : ", ".", 80)
    ? messageLine ; testCase.Result ; " (" + stri(metaTestCase.time).trim() +"ms)"
  end if
  if LCase(testCase.Result) <> "success"
    ? " | "; insettext ;"  |--Location: "; locationText
    if (metaTestcase.isParamTest = true)
      ? " | "; insettext ;"  |--Param Line: "; StrI(metaTestCase.paramlineNumber).trim()
    end if
    ? " | "; insettext ;"  |--Error Message: "; testCase.Error.Message
  end if
end sub
function RBS_LOGGER_FillText(text as string, fillChar = " ", numChars = 40) as string
  if (len(text) >= numChars)
    text = left(text, numChars - 5) + "..." + fillChar + fillChar
  else
    numToFill= numChars - len(text) -1
    for i = 0 to numToFill
      text += fillChar
    end for
  end if
  return text
end function
sub RBS_LOGGER_PrintStart()
  ? ""
  ? "[START TEST REPORT]"
  ? ""
end sub
sub RBS_LOGGER_PrintEnd()
  ? ""
  ? "[END TEST REPORT]"
  ? ""
end sub
sub RBS_LOGGER_PrintSuiteSetUp(sName as string)
  if m.verbosity = m.verbosityLevel.verbose
    ? "================================================================="
    ? "===   SetUp "; sName; " suite."
    ? "================================================================="
  end if
end sub
sub RBS_LOGGER_PrintMetaSuiteStart(metaTestSuite)
  ? metaTestSuite.name; " (" ; metaTestSuite.filePath + "(1))"
end sub
sub RBS_LOGGER_PrintSuiteStart(sName as string)
  ? " |-" ; sName
end sub
sub RBS_LOGGER_PrintSuiteTearDown(sName as string)
  if m.verbosity = m.verbosityLevel.verbose
    ? "================================================================="
    ? "===   TearDown "; sName; " suite."
    ? "================================================================="
  end if
end sub
sub RBS_LOGGER_PrintTestSetUp(tName as string)
  if m.verbosity = m.verbosityLevel.verbose
    ? "----------------------------------------------------------------"
    ? "---   SetUp "; tName; " test."
    ? "----------------------------------------------------------------"
  end if
end sub
sub RBS_LOGGER_PrintTestTearDown(tName as string)
  if m.verbosity = m.verbosityLevel.verbose
    ? "----------------------------------------------------------------"
    ? "---   TearDown "; tName; " test."
    ? "----------------------------------------------------------------"
  end if
end sub
function UnitTestResult() as object
  this = {}
  this.messages = CreateObject("roArray", 0, true)
  this.isFail = false
  this.currentAssertIndex = 0
  this.failedAssertIndex = 0
  this.Reset = RBS_TRes_Reset
  this.AddResult = RBS_TRes_AddResult
  this.GetResult = RBS_TRes_GetResult
  return this
end function
function RBS_TRes_Reset() as void
  m.isFail = false
  m.messages = CreateObject("roArray", 0, true)
end function
function RBS_TRes_AddResult(message as string) as string
  if (message <> "")
    m.messages.push(message)
    if (not m.isFail)
      m.failedAssertIndex = m.currentAssertIndex
    end if
    m.isFail = true
  end if
  m.currentAssertIndex++
  return message
end function
function RBS_TRes_GetResult() as string
  if (m.isFail)
    msg = m.messages.peek()
    if (msg <> invalid)
      return msg
    else
      return "unknown test failure"
    end if
  else
    return ""
  end if
end function
function RBS_TR_TestRunner(args = {}) as object
  this = {}
  this.testScene = args.testScene
  this.nodeContext = args.nodeContext
  fs = CreateObject("roFileSystem")
  defaultConfig = {
    logLevel : 1,
    testsDirectory: "pkg:/source/Tests",
    testFilePrefix: "Test__",
    failFast: false,
    showOnlyFailures: false,
    maxLinesWithoutSuiteDirective: 100
  }
  rawConfig = invalid
  config = invalid
  if (args.testConfigPath <> invalid and fs.Exists(args.testConfigPath))
    ? "Loading test config from " ; args.testConfigPath
    rawConfig = ReadAsciiFile(args.testConfigPath)
  else if (fs.Exists("pkg:/source/tests/testconfig.json"))
    ? "Loading test config from default location : pkg:/source/tests/testconfig.json"
    rawConfig = ReadAsciiFile("pkg:/source/tests/testconfig.json")
  else
    ? "None of the testConfig.json locations existed"
  end if
  if (rawConfig <> invalid)
    config = ParseJson(rawConfig)
  end if
  if (config = invalid or not RBS_CMN_IsAssociativeArray(config) or RBS_CMN_IsNotEmptyString(config.rawtestsDirectory))
    ? "WARNING : specified config is invalid - using default"
    config = defaultConfig
  end if
  if (args.showOnlyFailures <> invalid)
    config.showOnlyFailures = args.showOnlyFailures = "true"
  end if
  if (args.failFast <> invalid)
    config.failFast = args.failFast = "true"
  end if
  this.testUtilsDecoratorMethodName = args.testUtilsDecoratorMethodName
  this.config = config
  this.config.testsDirectory = config.testsDirectory
  this.logger = Logger(this.config)
  this.global = args.global
  this.Run          = RBS_TR_Run
  return this
end function
sub RBS_TR_Run()
  if type(RBSFM_getTestSuitesForProject) <> "Function"
    ? " ERROR! RBSFM_getTestSuitesForProject is not found! That looks like you didn't run the preprocessor as part of your test process. Please refer to the docs."
    return
  end if
  totalStatObj = RBS_STATS_CreateTotalStatistic()
  m.runtimeConfig = UnitTestRuntimeConfig()
  m.runtimeConfig.global = m.global
  totalStatObj.testRunHasFailures = false
  for each metaTestSuite in m.runtimeConfig.suites
    if (m.runtimeConfig.hasSoloTests = true)
      if (metaTestSuite.hasSoloTests <> true)
        if (m.config.logLevel = 2)
          ? "TestSuite " ; metaTestSuite.name ; " Is filtered because it has no solo tests"
        end if
        goto skipSuite
      end if
    else if (m.runtimeConfig.hasSoloSuites)
      if (metaTestSuite.isSolo <> true)
        if (m.config.logLevel = 2)
          ? "TestSuite " ; metaTestSuite.name ; " Is filtered due to solo flag"
        end if
        goto skipSuite
      end if
    end if
    if (metaTestSuite.isIgnored = true)
      if (m.config.logLevel = 2)
        ? "Ignoring TestSuite " ; metaTestSuite.name ; " Due to Ignore flag"
      end if
      totalstatobj.ignored ++
      totalStatObj.IgnoredTestNames.push("|-" + metaTestSuite.name + " [WHOLE SUITE]")
      goto skipSuite
    end if
    if (metaTestSuite.isNodeTest = true and metaTestSuite.nodeTestFileName <> "")
      ? " +++++RUNNING NODE TEST"
      nodeType = metaTestSuite.nodeTestFileName
      ? " node type is " ; nodeType
      node = m.testScene.CallFunc("Rooibos_CreateTestNode", nodeType)
      if (type(node) = "roSGNode" and node.subType() = nodeType)
        args = {
          "metaTestSuite": metaTestSuite
          "testUtilsDecoratorMethodName": m.testUtilsDecoratorMethodName
          "config": m.config
          "runtimeConfig": m.runtimeConfig
        }
        nodeStatResults = node.callFunc("Rooibos_RunNodeTests", args)
        RBS_STATS_MergeTotalStatistic(totalStatObj, nodeStatResults)
        m.testScene.RemoveChild(node)
      else
        ? " ERROR!! - could not create node required to execute tests for " ; metaTestSuite.name
        ? " Node of type " ; nodeType ; " was not found/could not be instantiated"
      end if
    else
      if (metaTestSuite.hasIgnoredTests)
        totalStatObj.IgnoredTestNames.push("|-" + metaTestSuite.name)
      end if
      RBS_RT_RunItGroups(metaTestSuite, totalStatObj, m.testUtilsDecoratorMethodName, m.config, m.runtimeConfig, m.nodeContext)
    end if
    skipSuite:
  end for
  m.logger.PrintStatistic(totalStatObj)
  RBS_TR_SendHomeKeypress()
end sub
sub RBS_RT_RunItGroups(metaTestSuite, totalStatObj, testUtilsDecoratorMethodName, config, runtimeConfig, nodeContext = invalid)
  if (testUtilsDecoratorMethodName <> invalid)
    testUtilsDecorator = RBS_CMN_GetFunctionBruteForce(testUtilsDecoratorMethodName)
    if (not RBS_CMN_IsFunction(testUtilsDecorator))
      ? "[ERROR] Test utils decorator method `" ; testUtilsDecoratorMethodName ;"` was not in scope! for testSuite: " + metaTestSuite.name
    end if
  end if
  for each itGroup in metaTestSuite.itGroups
    testSuite = RBS_ItG_GetRunnableTestSuite(itGroup)
    if (nodeContext <> invalid)
      testSuite.node = nodeContext
      testSuite.global = nodeContext.global
      testSuite.top = nodeContext.top
    end if
    if (RBS_CMN_IsFunction(testUtilsDecorator))
      testUtilsDecorator(testSuite)
    end if
    totalStatObj.Ignored += itGroup.ignoredTestCases.count()
    if (itGroup.isIgnored = true)
      if (config.logLevel = 2)
        ? "Ignoring itGroup " ; itGroup.name ; " Due to Ignore flag"
      end if
      totalStatObj.ignored += itGroup.testCases.count()
      totalStatObj.IgnoredTestNames.push("  |-" + itGroup.name + " [WHOLE GROUP]")
      goto skipItGroup
    else
      if (itGroup.ignoredTestCases.count() > 0)
        totalStatObj.IgnoredTestNames.push("  |-" + itGroup.name)
        totalStatObj.ignored += itGroup.ignoredTestCases.count()
        for each testCase in itGroup.ignoredTestCases
          if (testcase.isParamTest <> true)
            totalStatObj.IgnoredTestNames.push("  | |--" + testCase.name)
          else if (testcase.paramTestIndex = 0)
            testCaseName = testCase.Name
            if (len(testCaseName) > 1 and right(testCaseName, 1) = "0")
              testCaseName = left(testCaseName, len(testCaseName) - 1)
            end if
            totalStatObj.IgnoredTestNames.push("  | |--" + testCaseName)
          end if
        end for
      end if
    end if
    if (runtimeConfig.hasSoloTests)
      if (itGroup.hasSoloTests <> true)
        if (config.logLevel = 2)
          ? "Ignoring itGroup " ; itGroup.name ; " Because it has no solo tests"
        end if
        goto skipItGroup
      end if
    else if (runtimeConfig.hasSoloGroups)
      if (itGroup.isSolo <> true)
        goto skipItGroup
      end if
    end if
    if (testSuite.testCases.Count() = 0)
      if (config.logLevel = 2)
        ? "Ignoring TestSuite " ; itGroup.name ; " - NO TEST CASES"
      end if
      goto skipItGroup
    end if
    if RBS_CMN_IsFunction(testSuite.SetUp)
      testSuite.SetUp()
    end if
    RBS_RT_RunTestCases(metaTestSuite, itGroup, testSuite, totalStatObj, config, runtimeConfig)
    if RBS_CMN_IsFunction(testSuite.TearDown)
      testSuite.TearDown()
    end if
    if (totalStatObj.testRunHasFailures = true and config.failFast = true)
      exit for
    end if
    skipItGroup:
  end for
end sub
sub RBS_RT_RunTestCases(metaTestSuite, itGroup, testSuite, totalStatObj, config, runtimeConfig)
  suiteStatObj = RBS_STATS_CreateSuiteStatistic(itGroup.Name)
  testSuite.global = runtimeConfig.global
  for each testCase in testSuite.testCases
    metaTestCase = itGroup.testCaseLookup[testCase.Name]
    if (runtimeConfig.hasSoloTests and not metaTestCase.isSolo)
      goto skipTestCase
    end if
    if RBS_CMN_IsFunction(testSuite.beforeEach)
      testSuite.beforeEach()
    end if
    testTimer = CreateObject("roTimespan")
    testCaseTimer = CreateObject("roTimespan")
    testStatObj = RBS_STATS_CreateTestStatistic(testCase.Name)
    testSuite.testCase = testCase.Func
    testStatObj.filePath = metaTestSuite.filePath
    testStatObj.metaTestCase = metaTestCase
    testSuite.currentResult = UnitTestResult()
    testStatObj.metaTestCase.testResult = testSuite.currentResult
    if (metaTestCase.isParamsValid)
      if (metaTestCase.isParamTest)
        testCaseParams = []
        for paramIndex = 0 to metaTestCase.rawParams.count()
          paramValue = metaTestCase.rawParams[paramIndex]
          if type(paramValue) = "roString" and len(paramValue) >= 8 and left(paramValue, 8) = "#RBSNode"
            nodeType = "ContentNode"
            paramDirectiveArgs = paramValue.split("|")
            if paramDirectiveArgs.count() > 1
              nodeType = paramDirectiveArgs[1]
            end if
            paramValue = createObject("roSGNode", nodeType)
          end if
          testCaseParams.push(paramValue)
        end for
        testCaseTimer.mark()
        if (metaTestCase.expectedNumberOfParams = 1)
          testSuite.testCase(testCaseParams[0])
        else if (metaTestCase.expectedNumberOfParams = 2)
          testSuite.testCase(testCaseParams[0], testCaseParams[1])
        else if (metaTestCase.expectedNumberOfParams = 3)
          testSuite.testCase(testCaseParams[0], testCaseParams[1], testCaseParams[2])
        else if (metaTestCase.expectedNumberOfParams = 4)
          testSuite.testCase(testCaseParams[0], testCaseParams[1], testCaseParams[2], testCaseParams[3])
        else if (metaTestCase.expectedNumberOfParams = 5)
          testSuite.testCase(testCaseParams[0], testCaseParams[1], testCaseParams[2], testCaseParams[3], testCaseParams[4])
        else if (metaTestCase.expectedNumberOfParams = 6)
          testSuite.testCase(testCaseParams[0], testCaseParams[1], testCaseParams[2], testCaseParams[3], testCaseParams[4], testCaseParams[5])
        end if
        metaTestCase.time = testCaseTimer.totalMilliseconds()
      else
        testCaseTimer.mark()
        testSuite.testCase()
        metaTestCase.time = testCaseTimer.totalMilliseconds()
      end if
    else
      testSuite.Fail("Could not parse args for test ")
    end if
    if testSuite.isAutoAssertingMocks = true
      testSuite.AssertMocks()
      testSuite.CleanMocks()
      testSuite.CleanStubs()
    end if
    runResult = testSuite.currentResult.GetResult()
    if runResult <> ""
      testStatObj.Result      = "Fail"
      testStatObj.Error.Code    = 1
      testStatObj.Error.Message   = runResult
    else
      testStatObj.Result      = "Success"
    end if
    testStatObj.Time = testTimer.TotalMilliseconds()
    RBS_STATS_AppendTestStatistic(suiteStatObj, testStatObj)
    if RBS_CMN_IsFunction(testSuite.afterEach)
      testSuite.afterEach()
    end if
    if testStatObj.Result <> "Success"
      totalStatObj.testRunHasFailures = true
    end if
    if testStatObj.Result = "Fail" and config.failFast = true
      exit for
    end if
    skipTestCase:
  end for
  suiteStatObj.metaTestSuite = metaTestSuite
  RBS_STATS_AppendSuiteStatistic(totalStatObj, suiteStatObj)
end sub
sub RBS_TR_SendHomeKeypress()
  ut = CreateObject("roUrlTransfer")
  ut.SetUrl("http://localhost:8060/keypress/Home")
  ut.PostFromString("")
end sub
function Rooibos_RunNodeTests(args) as object
  ? " RUNNING NODE TESTS"
  totalStatObj = RBS_STATS_CreateTotalStatistic()
  RBS_RT_RunItGroups(args.metaTestSuite, totalStatObj, args.testUtilsDecoratorMethodName, args.config, args.runtimeConfig, m)
  return totalStatObj
end function
function Rooibos_CreateTestNode(nodeType) as object
  node = createObject("roSGNode", nodeType)
  if (type(node) = "roSGNode" and node.subType() = nodeType)
    m.top.AppendChild(node)
    return node
  else
    ? " Error creating test node of type " ; nodeType
    return invalid
  end if
end function